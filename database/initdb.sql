CREATE DOMAIN phone AS TEXT CHECK( VALUE ~ E'^\\+?[0-9\\*\\#]+$' );


CREATE TABLE numtypes (
	numtype VARCHAR PRIMARY KEY,
	descr TEXT
);

CREATE TABLE directory (
	num PHONE PRIMARY KEY,
	numtype VARCHAR NOT NULL REFERENCES numtypes(numtype),
	descr TEXT,
	is_prefix BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX directory_prefix_smart_index ON directory USING btree (num text_pattern_ops);

CREATE OR REPLACE FUNCTION directory_check_num(newnum PHONE) RETURNS TEXT[] AS $$
	SELECT array_agg(num::TEXT) FROM (
		SELECT num FROM directory WHERE num LIKE $1 || '%' UNION
		SELECT num FROM directory WHERE $1 LIKE num || '%') ss;
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION directory_uniq_prefix_trigger() RETURNS TRIGGER AS $$
DECLARE
        cflct TEXT;
BEGIN
	IF TG_OP = 'UPDATE' THEN
		IF NEW.num <> OLD.num THEN
			cflct := array_to_string(directory_check_num(NEW.num), ', ');
		END IF;
	ELSE
		cflct := array_to_string(directory_check_num(NEW.num), ', ');
	END IF;
        IF LENGTH(cflct) <> 0 THEN
                RAISE EXCEPTION 'Conflict: %', cflct;
        END IF;
        RETURN NEW;
END;
$$ LANGUAGE PlPgSQL;

CREATE TRIGGER directory_uniq_prefix_trigger BEFORE INSERT OR UPDATE ON directory
	FOR EACH ROW EXECUTE PROCEDURE directory_uniq_prefix_trigger();

INSERT INTO numtypes (numtype, descr) VALUES ('user', 'User extension number');
INSERT INTO numtypes (numtype, descr) VALUES ('callgrp', 'PBX call group');
INSERT INTO numtypes (numtype, descr) VALUES ('abbr', 'Abbreveated number');
INSERT INTO numtypes (numtype, descr) VALUES ('ivr', 'Interactive voice response');
INSERT INTO numtypes (numtype, descr) VALUES ('switch', 'Several choices based on some condition');
INSERT INTO numtypes (numtype, descr) VALUES ('fictive', 'Fictive number (routed elsewhere)');



CREATE TABLE fingroups (
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL,
	sortkey INTEGER NOT NULL DEFAULT 100
);

CREATE TYPE encription_mode AS ENUM('off', 'on', 'ssl');

CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	num PHONE NOT NULL,
	alias TEXT NULL CHECK(alias ~ E'^\\w+$'),
	domain TEXT NOT NULL,
	password TEXT NOT NULL,
	lastreg TIMESTAMP WITH TIME ZONE,
	lastip INET,
	nat_support BOOLEAN,
	nat_port_support BOOLEAN,
	media_bypass BOOLEAN DEFAULT FALSE,
	dispname TEXT NULL,
	login TEXT NULL,
	badges TEXT[] NOT NULL DEFAULT '{}',
	fingrp INTEGER REFERENCES fingroups(id) ON DELETE SET NULL,
	secure encription_mode NOT NULL DEFAULT 'ssl',
	cti BOOLEAN DEFAULT FALSE,
	linesnum INTEGER NOT NULL DEFAULT 1
);
ALTER TABLE users ADD CONSTRAINT num_fk FOREIGN KEY (num) REFERENCES directory(num) ON UPDATE CASCADE ON DELETE CASCADE;
CREATE UNIQUE INDEX users_num_index ON users(num);
CREATE INDEX users_login_index ON users(login);

CREATE OR REPLACE VIEW nextprevusers AS
	SELECT id, num, LEAD(id) OVER (ORDER BY num) AS next, LAG(id) OVER (ORDER BY num) AS prev FROM users;

CREATE TABLE regs (
	userid INTEGER NOT NULL REFERENCES users(id),
	ts TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	location TEXT NOT NULL,
	expires TIMESTAMP WITH TIME ZONE,
	device TEXT,
	driver TEXT,
	ip_transport TEXT,
	ip_host INET,
	ip_port INTEGER,
	audio BOOLEAN DEFAULT TRUE,
	route_params HSTORE
);

CREATE OR REPLACE FUNCTION regs_change_trigger() RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'DELETE' THEN
		PERFORM pg_notify(TG_TABLE_NAME::TEXT, OLD.userid::TEXT);
	ELSE
		PERFORM pg_notify(TG_TABLE_NAME::TEXT, NEW.userid::TEXT);
	END IF;
	RETURN NEW;
END $$ LANGUAGE PlPgSQL;

CREATE TRIGGER regs_change_trigger AFTER INSERT OR UPDATE OR DELETE
	ON regs FOR EACH ROW EXECUTE PROCEDURE regs_change_trigger();

CREATE TABLE subscriptions (
	id BIGSERIAL PRIMARY KEY,
	ts TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	notifier TEXT NOT NULL,
	subscriber TEXT NOT NULL,
	operation TEXT NOT NULL,
	data TEXT,
	notifyto TEXT,
	expires INTERVAL
);

CREATE OR REPLACE FUNCTION userrec(username TEXT) RETURNS SETOF users AS $$
DECLARE
        n TEXT;
        d TEXT;
        pos INTEGER;
        r RECORD;
BEGIN
        pos := position('@' in username);
        IF pos > 0 THEN
                n := substring(username for pos - 1);
                d := substring(username from pos + 1);
                SELECT * INTO r FROM users WHERE num = n AND domain = d;
        ELSE
                SELECT * INTO r FROM users WHERE num = username LIMIT 1;
        END IF;
        IF NOT FOUND THEN
		SELECT * INTO r FROM populate_record(NULL::users, '');
        END IF;
        RETURN NEXT r;
END;
$$ LANGUAGE PlPgSQL STRICT STABLE;


CREATE OR REPLACE FUNCTION userid(username TEXT) RETURNS INTEGER AS $$
	SELECT id FROM userrec($1);
$$ LANGUAGE SQL STRICT STABLE;

CREATE OR REPLACE FUNCTION user_register(msg HSTORE) RETURNS VOID AS $$
DECLARE
	uid INTEGER;
	expint TIMESTAMP WITH TIME ZONE;
	regnum TEXT;
	loc TEXT;
	exp TEXT;
	drv TEXT;
	a TEXT[];
	rp HSTORE;
BEGIN
	regnum := msg->'username';
	loc := msg->'data';
	exp := msg->'expires';
	drv := COALESCE(msg->'driver', msg->'module');
	uid := userid(regnum);
	IF uid IS NULL THEN
		RAISE EXCEPTION 'User % not found', regnum;
	END IF;
	IF exp IS NOT NULL AND exp <> '' THEN
		expint := CURRENT_TIMESTAMP + (exp::TEXT || ' s')::INTERVAL;
	END IF;
	IF COALESCE(msg->'route_params', '') <> '' THEN
		a := ('{' || (msg->'route_params') || '}')::TEXT[];
		rp = slice(msg, a);
	END IF;

	DELETE FROM regs WHERE userid = uid AND location = loc;
	INSERT INTO regs(userid, ts, location, expires, device, driver, ip_transport, ip_host, ip_port, audio, route_params)
		VALUES (uid, CURRENT_TIMESTAMP, loc, expint, msg->'device', drv, msg->'ip_transport', (msg->'ip_host')::INET, (msg->'ip_port')::INTEGER, drv <> 'jabber', rp);
END;
$$ LANGUAGE PlPgSQL;

CREATE OR REPLACE FUNCTION user_unregister(regnum TEXT, loc TEXT) RETURNS VOID AS $$
BEGIN
	DELETE FROM regs WHERE userid = (SELECT id FROM users WHERE num = regnum) AND location = loc;
END;
$$ LANGUAGE PlPgSQL;

CREATE OR REPLACE FUNCTION regs_expired_list() RETURNS TABLE(username TEXT, data TEXT, device TEXT, driver TEXT, ip_transport TEXT, ip_host INET, ip_port INTEGER, reason TEXT) AS $$
	SELECT users.num AS username, location AS data, device, driver, ip_transport, ip_host, ip_port, 'expired'::TEXT AS reason
		FROM regs INNER JOIN users ON users.id = regs.userid
		WHERE expires < CURRENT_TIMESTAMP;
$$ LANGUAGE SQL;


-- Jabber roster
CREATE TABLE roster(
	uid INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	contact TEXT NOT NULL,
	subscription TEXT,
	label TEXT,
	groups TEXT
);

-- Jabber vCards
CREATE TABLE vcards(
	uid INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	vcard xml
);

CREATE OR REPLACE FUNCTION vcard_get(usename TEXT) RETURNS XML AS $$
	SELECT vcard FROM vcards WHERE uid = userid($1)
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION vcard_set(username TEXT, vc XML) RETURNS VOID AS $$
DECLARE
	id INTEGER;
BEGIN
	id := userid($1);
	UPDATE vcards SET vcard = $2 WHERE uid = id;
	IF NOT FOUND THEN
		INSERT INTO vcards(uid, vcard) VALUES (id, $2);
	END IF;
END;
$$ LANGUAGE PlPgSQL;

CREATE OR REPLACE FUNCTION vcard_del(username TEXT) RETURNS VOID AS $$
	DELETE FROM vcards WHERE uid = userid($1);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION roster_set_subs(username TEXT, ctct TEXT, subs TEXT) RETURNS VOID AS $$
DECLARE
	id INTEGER;
BEGIN
	id := userid($1);
	UPDATE roster SET subscription = $3 WHERE uid = id AND contact = ctct;
	IF NOT FOUND THEN
		INSERT INTO roster(uid, contact, subscription) VALUES (id, ctct, subs);
	END IF;
END;
$$ LANGUAGE PlPgSQL;

CREATE OR REPLACE FUNCTION roster_set_name(uname TEXT, ctct TEXT, alias TEXT, grps TEXT)
	RETURNS TABLE(username TEXT, contact TEXT, name TEXT, groups TEXT) AS $$
DECLARE
	userid INTEGER;
BEGIN
	userid := userid($1);
	UPDATE roster SET label = $3, groups = $4 WHERE roster.uid = userid AND roster.contact = $2;
	IF NOT FOUND THEN
		INSERT INTO roster(uid, contact, label, groups) VALUES (userid, $2, $3, $4);
	END IF;
	RETURN QUERY SELECT u.num || '@' || u.domain AS username, r.contact, r.label AS name, r.groups FROM users u LEFT JOIN roster r ON u.id = r.uid WHERE u.id = userid AND r.contact = $2;
END;
$$ LANGUAGE PlPgSQL;

CREATE OR REPLACE FUNCTION roster_set_full(uname TEXT, ctct TEXT, subs TEXT, alias TEXT, grps TEXT)
	RETURNS TABLE(username TEXT, contact TEXT, name TEXT, groups TEXT, subscription TEXT) AS $$
DECLARE
	userid INTEGER;
BEGIN
	userid := userid($1);
	UPDATE roster SET subscription = $3, label = $4, groups = $5 WHERE roster.uid = userid AND roster.contact = $2;
	IF NOT FOUND THEN
		INSERT INTO roster(uid, contact, subscription, label, groups) VALUES (userid, $2, $3, $4, $5);
	END IF;
	RETURN QUERY SELECT u.num || '@' || u.domain AS username, r.contact, r.label AS name, r.groups, r.subscription FROM users u LEFT JOIN roster r ON u.id = r.uid WHERE u.id = userid AND r.contact = $2;
END;
$$ LANGUAGE PlPgSQL;


CREATE TABLE offlinemsgs(
	uid INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	ts BIGINT NOT NULL,
	msg XML NOT NULL
);

CREATE OR REPLACE FUNCTION offlinechat_get(username TEXT) RETURNS TABLE(username TEXT, "time" TEXT, "xml" XML) AS $$
	SELECT num || '@' || domain, ts::TEXT, msg
		FROM offlinemsgs o INNER JOIN userrec($1) u ON u.id = o.uid
		ORDER BY ts;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION offlinechat_add(username TEXT, message XML, tstamp BIGINT, maxcount INTEGER) RETURNS INTEGER AS $$
DECLARE
	id INTEGER;
	n INTEGER;
BEGIN
	id := userid(username);
	IF maxcount <> 0 THEN
		SELECT INTO n COUNT(*) FROM offlinemsgs WHERE uid = id;
		IF n >= maxcount THEN
			RAISE NOTICE 'User % already has % offline messages while % is allowed', username, n, maxcount;
			RETURN 0;
		END IF;
	END IF;
	INSERT INTO offlinemsgs(uid, ts, msg) VALUES (id, tstamp, message);
	RETURN 1;
END;
$$ LANGUAGE PlPgSQL;

CREATE OR REPLACE FUNCTION offlinechat_del(username TEXT) RETURNS VOID AS $$
	DELETE FROM offlinemsgs WHERE uid = userid($1);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION offlinechat_expire(maxts BIGINT) RETURNS VOID AS $$
	DELETE FROM offlinemsgs WHERE ts < $1;
$$ LANGUAGE SQL;

-- private data support --
CREATE TABLE privdata(
	uid INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	tag TEXT NOT NULL,
	xmlns TEXT NOT NULL,
	data XML
);

CREATE OR REPLACE FUNCTION privdata_get(username TEXT, datatag TEXT, datans TEXT) RETURNS XML AS $$
	SELECT data FROM privdata WHERE uid = userid($1) AND tag = $2 AND xmlns = $3;
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION privdata_set(username TEXT, datatag TEXT, datans TEXT, dataxml XML) RETURNS VOID AS $$
DECLARE
	u INTEGER;
BEGIN
	u := userid(username);
	UPDATE privdata SET data = dataxml WHERE uid = u AND tag = datatag AND xmlns = datans;
	IF NOT FOUND THEN
		INSERT INTO privdata(uid, tag, xmlns, data) VALUES (u, datatag, datans, dataxml);
	END IF;
END;
$$ LANGUAGE PlPgSQL;

CREATE OR REPLACE FUNCTION privdata_clear(username TEXT) RETURNS VOID AS $$
	DELETE FROM privdata WHERE uid = userid($1);
$$ LANGUAGE SQL;

-- requires yate modifications:
--  a769565 - caps_update
--  51cdc1e - hstore
CREATE OR REPLACE FUNCTION caps_update(msg HSTORE) RETURNS VOID AS $$
DECLARE
	loc TEXT;
BEGIN
	loc = msg->'contact' || '/' || msg->'instance';
	UPDATE regs SET audio = msg->'caps.audio' WHERE location = loc;
END;
$$ LANGUAGE PlPgSQL;

-- config
CREATE TABLE config (
	id SERIAL PRIMARY KEY,
	section TEXT NOT NULL,
	params HSTORE NOT NULL,
	ts TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
	uid INTEGER NULL
);
CREATE UNIQUE INDEX config_section_index ON config(section);

CREATE OR REPLACE FUNCTION config(section_name TEXT) RETURNS HSTORE AS $$
	SELECT params FROM config WHERE section = $1;
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION config(section_name text, param_name TEXT) RETURNS TEXT AS $$
	SELECT params->$2 FROM config WHERE section = $1;
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION toBoolean(s TEXT, def BOOLEAN DEFAULT NULL) RETURNS BOOLEAN AS $$
BEGIN
	IF LOWER(s) IN('false', 'no', 'off', 'disable', 'f') THEN
		RETURN FALSE;
	END IF;
	IF LOWER(s) IN('true', 'yes', 'on', 'enable', 't') THEN
		RETURN TRUE;
	END IF;
	RETURN def;
END;
$$ LANGUAGE PlPgSQL IMMUTABLE;


-- calls log
CREATE TABLE calllog(
	id BIGSERIAL PRIMARY KEY,
	ts TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	billid TEXT NOT NULL,
	tag TEXT,
	uid INTEGER NULL,
	value TEXT NULL,
	params HSTORE NULL
);
CREATE INDEX calllog_ts_index     ON calllog(ts);
CREATE INDEX calllog_billid_index ON calllog(billid);
CREATE INDEX calllog_tag_index    ON calllog(tag);

CREATE OR REPLACE FUNCTION calllog_change_trigger() RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'DELETE' THEN
		PERFORM pg_notify(TG_TABLE_NAME::TEXT, OLD.billid::TEXT);
	ELSE
		PERFORM pg_notify(TG_TABLE_NAME::TEXT, NEW.billid::TEXT);
	END IF;
	RETURN NEW;
END $$ LANGUAGE PlPgSQL;

CREATE TRIGGER calllog_change_trigger AFTER INSERT OR UPDATE OR DELETE
	ON calllog FOR EACH ROW EXECUTE PROCEDURE calllog_change_trigger();



CREATE TABLE ipnetworks (
	net CIDR NOT NULL UNIQUE,
	id INTEGER NOT NULL
);

CREATE OR REPLACE FUNCTION ipnetwork(ip INET) RETURNS INTEGER AS $$
	SELECT COALESCE((SELECT id FROM ipnetworks WHERE net >> $1 ORDER BY masklen(net) DESC LIMIT 1), 0);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION rtp_forward_possible(a1 INET, a2 INET) RETURNS TEXT AS $$
	SELECT CASE WHEN ipnetwork($1) = ipnetwork($2) THEN 'yes' ELSE 'no' END;
$$ LANGUAGE SQL;

-- routing functions requires the following upstream yate modifications:
--  988c55b7c9e19815956f73a9ad3c641f7ae96879 - transposedb
--  51cdc1ec7322aa09930c6a473e456adf95949daf - hstore
CREATE OR REPLACE FUNCTION regs_route_part(called_arg TEXT, res HSTORE, cntr INTEGER)
	RETURNS TABLE (vals HSTORE, newcntr INTEGER) AS $$
DECLARE
	cld RECORD;
	t RECORD;
	kvp RECORD;
	rtpfw BOOLEAN;
BEGIN
	cld := userrec(called_arg);
	IF cld.id IS NOT NULL THEN
		FOR t IN SELECT * FROM regs WHERE userid = cld.id AND expires > 'now' AND audio LOOP
			cntr := cntr + 1;
			res := res || hstore('callto.' || cntr, t.location);
			FOR kvp IN SELECT * FROM EACH(t.route_params) LOOP
				res := res || hstore('callto.' || cntr || '.' || kvp.key, kvp.value);
			END LOOP;
			res := res || hstore('callto.' || cntr || '.secure', CASE WHEN (cld.secure = 'ssl' AND t.ip_transport = 'TLS') OR cld.secure = 'on' THEN 'yes' ELSE 'no' END);
		END LOOP;
	END IF;

	RETURN QUERY SELECT res, cntr;
END;
$$ LANGUAGE PlPgSQL;

CREATE TABLE numkinds(
	id SERIAL PRIMARY KEY,
	descr TEXT NOT NULL,
	tag TEXT,
	set_local_caller BOOLEAN NOT NULL DEFAULT FALSE,
	set_context TEXT NULL,
	ins_prefix TEXT NOT NULL DEFAULT '',
	callabale BOOLEAN NOT NULL DEFAULT TRUE,
	announce TEXT NULL
);


INSERT INTO numkinds (descr) VALUES ('Celluar'), ('Home');

CREATE TABLE morenums(
	id SERIAL PRIMARY KEY,
	uid INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	sortkey INTEGER NOT NULL DEFAULT 100,
	numkind INTEGER NOT NULL REFERENCES numkinds(id),
	val TEXT NOT NULL,
	descr TEXT,
	timeout INTEGER NOT NULL DEFAULT 10,
	div_noans BOOLEAN NOT NULL DEFAULT FALSE,
	div_offline BOOLEAN NOT NULL DEFAULT FALSE
--	div_direct BOOLEAN NOT NULL DEFAULT FALSE,
--	div_busy BOOLEAN NOT NULL DEFAULT FALSE,
);

CREATE OR REPLACE FUNCTION normalize_num(n TEXT) RETURNS PHONE AS $$
	-- allow '+' only in the beginning, remove all other non-"digits"
	SELECT NULLIF(regexp_replace($1, '^(\+)|[^0-9\*\#]', '\1', 'g'), '')::PHONE;
$$ LANGUAGE SQL IMMUTABLE;

CREATE INDEX morenums_val_index ON morenums(normalize_num(val));

CREATE OR REPLACE FUNCTION regs_route(msg HSTORE)
	RETURNS TABLE(key TEXT, value TEXT) AS $$
DECLARE
	res HSTORE;
	cntr INTEGER;
	t RECORD;
	uoffline BOOLEAN;
	called_arg TEXT;
BEGIN
	res := '';
	called_arg := msg->'called';
	SELECT * INTO res, cntr FROM regs_route_part(called_arg, res, 0);

	uoffline := res::TEXT = '';

	-- Add 'offline' and 'No answer' divertions
	FOR t IN SELECT normalize_num(n.val) AS val, n.timeout, k.*
			FROM morenums n INNER JOIN numkinds k ON k.id = n.numkind
			WHERE uid = userid(called_arg) AND k.callabale AND CASE WHEN uoffline THEN div_offline ELSE div_noans END ORDER BY n.sortkey, n.id LOOP
		IF res::TEXT <> '' THEN
			res := res || hstore('callto.' || cntr || '.maxcall', (t.timeout * 1000)::TEXT); -- append to previous group
			cntr := cntr + 1;
			res := res || hstore('callto.' || cntr, '|');
		END IF;
		IF t.announce IS NOT NULL THEN
			cntr := cntr + 1;
			res := res || hstore('callto.' || cntr, t.announce);
			res := res || hstore('callto.' || cntr || '.single', 'yes');
			res := res || hstore('callto.' || cntr || '.fork.ringer', 'yes');
			res := res || hstore('callto.' || cntr || '.fork.autoring', 'yes');
			res := res || hstore('callto.' || cntr || '.fork.automessage', 'call.progress');
			cntr := cntr + 1;
			res := res || hstore('callto.' || cntr, '|');
		END IF;
		cntr := cntr + 1;
		res := res || hstore('callto.' || cntr, 'lateroute/' || t.ins_prefix || t.val);
		IF t.set_local_caller THEN
			res := res || hstore('callto.' || cntr || '.caller', called_arg);
		END IF;
		IF t.set_context IS NOT NULL THEN
			res := res || hstore('callto.' || cntr || '.context', t.set_context);
		END IF;
	END LOOP;

	IF res::TEXT = '' THEN
		RETURN;
	ELSE
		res := res || 'location => fork';
		res := res || hstore(ARRAY['copyparams', 'pbxassist,dtmfpass', 'tonedetect_out', 'true', 'pbxassist', 'true', 'dtmfpass', 'false']);
		RETURN QUERY SELECT * FROM each(res);
	END IF;
END;
$$ LANGUAGE PlPgSQL;


-- Line tracker
CREATE TABLE linetracker(
	uid INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	direction TEXT,
	status TEXT,
	chan TEXT,
	caller TEXT,
	called TEXT,
	billid TEXT
);

CREATE OR REPLACE FUNCTION any_change_trigger_uid() RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'DELETE' THEN
		PERFORM pg_notify(TG_TABLE_NAME::TEXT, OLD.uid::TEXT);
	ELSE
		PERFORM pg_notify(TG_TABLE_NAME::TEXT, NEW.uid::TEXT);
	END IF;
	RETURN NEW;
END $$ LANGUAGE PlPgSQL;

CREATE TRIGGER linetracker_change_trigger AFTER INSERT OR UPDATE OR DELETE
	ON linetracker FOR EACH ROW EXECUTE PROCEDURE any_change_trigger_uid();

CREATE OR REPLACE FUNCTION linetracker_flush() RETURNS VOID AS $$
BEGIN
	DELETE FROM linetracker;
END;
$$ LANGUAGE PlPgSQL;

CREATE OR REPLACE FUNCTION linetracker_ini(msg HSTORE) RETURNS VOID AS $$
DECLARE
	u INTEGER;
BEGIN
	IF msg->'chan' LIKE 'fork/%' THEN
		RETURN;
	END IF;
	u := userid(msg->'external');
	IF u IS NULL AND msg->'direction' = 'outgoing' AND (msg->'calledfull') IS NOT NULL THEN
		u := userid(msg->'calledfull');
	END IF;
	IF u IS NOT NULL THEN
		INSERT INTO linetracker(uid, direction, status, chan, caller, called, billid) VALUES (u, msg->'direction', msg->'status', msg->'chan', msg->'caller', msg->'called', msg->'billid');
	END IF;
END;
$$ LANGUAGE PlPgSQL;

CREATE OR REPLACE FUNCTION linetracker_upd(msg HSTORE) RETURNS VOID AS $$
BEGIN
	UPDATE linetracker SET direction = msg->'direction', status = msg->'status', caller = msg->'caller', called = msg->'called', billid = msg->'billid' WHERE chan = msg->'chan';
END;
$$ LANGUAGE PlPgSQL;

CREATE OR REPLACE FUNCTION linetracker_fin(msg HSTORE) RETURNS VOID AS $$
BEGIN
	-- make hangup of channel fork/30 clean up entries for fork/30/...
        DELETE FROM linetracker WHERE chan = msg->'chan' OR chan LIKE msg->'chan' || '/%';
END;
$$ LANGUAGE PlPgSQL;



-- queues
CREATE TABLE queues(
	id SERIAL PRIMARY KEY,
	mintime INTEGER DEFAULT 500,
	length INTEGER DEFAULT 0,
	maxout INTEGER DEFAULT -1,
	greeting TEXT,
	onhold TEXT,
	maxcall INTEGER,
	prompt TEXT,
	notify TEXT,
	detail BOOLEAN DEFAULT TRUE,
	single BOOLEAN DEFAULT FALSE
);
CREATE TABLE queuestats(
	q INTEGER NOT NULL REFERENCES queues(id) ON DELETE CASCADE,
	ts TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
	required INTEGER,
	cur INTEGER,
	waiting INTEGER,
	found INTEGER
);
CREATE OR REPLACE FUNCTION queues_avail(q TEXT, required INTEGER, cur INTEGER, waiting INTEGER)
	RETURNS TABLE(location TEXT, username TEXT, maxcall INTEGER, prompt TEXT) AS $$
DECLARE
	g RECORD;
	t RECORD;
	res HSTORE;
	cntr INTEGER;
	rowcount INTEGER DEFAULT 0;
	k TEXT;
	v TEXT;
BEGIN
	SELECT * INTO g FROM callgroups WHERE queue = q::INTEGER;
	IF NOT FOUND THEN
		RETURN;
	END IF;
	FOR t IN SELECT m.num FROM callgrpmembers m LEFT JOIN users u ON u.num = m.num WHERE m.grp = g.id AND m.enabled
			AND 0 = (SELECT COUNT(*) FROM linetracker WHERE uid = u.id) ORDER BY random() LIMIT required LOOP
		cntr := 1;
		SELECT * INTO res, cntr FROM regs_route_part(t.num, res, cntr);
		-- convert hstore to json
		location := '{"location": "fork"';
		FOR k, v IN SELECT * FROM each(res) LOOP
			location := location || ', "' || k || '": "' || regexp_replace(v, E'([\\"])', E'\\\\\\1', 'g') || '"';
		END LOOP;
		location := location || '}';
		username := t.num;
		IF cntr > 1 THEN
			RETURN NEXT;
			rowcount := rowcount + 1;
		END IF;
	END LOOP;
	INSERT INTO queuestats(q, required, cur, waiting, found) VALUES (g.queue, required, cur, waiting, rowcount);
END;
$$ LANGUAGE PlPgSQL;



-- call groups
-- http://en.wikipedia.org/wiki/Automatic_call_distributor#Distribution_methods
CREATE TYPE CALLDISTRIBUTION AS ENUM ('parallel', 'linear', 'rotary', 'uniform', 'queue');

CREATE TABLE callgroups(
	id SERIAL PRIMARY KEY,
	num PHONE NOT NULL,
	distr CALLDISTRIBUTION NOT NULL DEFAULT 'parallel',
	rotary_last INTEGER NOT NULL DEFAULT 0,
	ringback TEXT NULL,
	maxcall INTEGER NOT NULL DEFAULT 0,
	exitpos PHONE NULL,
	queue INTEGER NULL REFERENCES queues(id) ON DELETE SET NULL
);
ALTER TABLE callgroups ADD CONSTRAINT num_fk FOREIGN KEY (num) REFERENCES directory(num) ON UPDATE CASCADE ON DELETE CASCADE;
CREATE UNIQUE INDEX callgroups_num_index ON callgroups(num);
CREATE TABLE callgrpmembers(
	grp INTEGER NOT NULL REFERENCES callgroups(id) ON DELETE CASCADE,
	ord INTEGER,
	num PHONE NOT NULL,
	enabled BOOLEAN NOT NULL DEFAULT TRUE,
	maxcall INTEGER NOT NULL DEFAULT 8,
	keepring BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE UNIQUE INDEX callgrpmembers_uniq_index ON callgrpmembers(grp, ord);
ALTER TABLE callgrpmembers ADD CONSTRAINT callgrpmembers_check_pkey PRIMARY KEY USING INDEX callgrpmembers_uniq_index;


CREATE OR REPLACE FUNCTION callgroups_route_part(grprec callgroups, res HSTORE, cntr INTEGER, stack TEXT[] DEFAULT '{}')
	RETURNS TABLE (vals HSTORE, newcntr INTEGER) AS $$
DECLARE
	t callgrpmembers;
	sg callgroups;
	cntr2 INTEGER;
	cntr3 INTEGER;
	nextcallto TEXT;
	x RECORD;
BEGIN
	cntr2 := cntr;
	FOR x IN SELECT m, d, cg2 AS sg FROM callgrpmembers m
			INNER JOIN directory d ON (m.num = d.num AND NOT d.is_prefix) OR (substr(m.num, 1, length(d.num)) = d.num AND d.is_prefix)
			LEFT JOIN users u ON u.num = m.num AND u.linesnum > (SELECT COUNT(*) FROM linetracker WHERE uid = u.id)
			LEFT JOIN callgroups cg2 ON cg2.num = m.num
			WHERE m.grp = grprec.id AND m.enabled AND (u.id IS NOT NULL OR cg2.id IS NOT NULL OR d.numtype = 'fictive') ORDER BY ord LOOP
		IF nextcallto IS NOT NULL AND cntr2 <> cntr THEN
			cntr2 := cntr2 + 1;
			res := res || hstore('callto.' || cntr2, nextcallto);
			nextcallto := NULL;
		END IF;
		cntr3 := cntr2;
		CASE (x.d).numtype
			WHEN 'fictive' THEN
				cntr2 := cntr2 + 1;
				res := res || hstore('callto.' || cntr2, 'lateroute/'||(x.m).num);
			WHEN 'user' THEN
				SELECT * INTO res, cntr2 FROM regs_route_part((x.m).num, res, cntr2);
			WHEN 'callgrp' THEN
				IF NOT (x.sg).num = ANY(stack) THEN
					SELECT * INTO res, cntr2 FROM callgroups_route_part(x.sg, res, cntr2, stack || (x.sg).num::TEXT);
				END IF;
--			WHEN 'abbr' THEN
--			ELSE
		END CASE;
		IF grprec.distr = 'linear' THEN
			IF cntr3 = cntr2 THEN
				res := delete(res, 'callto.' || cntr2);
				cntr2 := cntr2 - 1;
			ELSE
				nextcallto := CASE WHEN (x.m).keepring THEN '|next=' ELSE '|drop=' END || (1000 * (x.m).maxcall)::TEXT;
			END IF;
		END IF;
	END LOOP;
	RETURN QUERY SELECT res, cntr2;
END;
$$ LANGUAGE PlPgSQL;

CREATE OR REPLACE FUNCTION callgroups_route(msg HSTORE)
	RETURNS TABLE(key TEXT, value TEXT) AS $$
DECLARE
	g callgroups;
	res HSTORE;
	cntr INTEGER;
	cntr2 INTEGER;
BEGIN
	-- NOTE: Supported distribution schemes: parallel, linear, queue --
	SELECT * INTO g FROM callgroups WHERE num = msg->'called';
	IF NOT FOUND THEN
		RETURN;
	END IF;
	IF g.distr = 'queue' AND g.queue IS NOT NULL THEN
		key := 'location';
		value := 'queue/' || g.queue::TEXT;
		RETURN NEXT;
		RETURN;
	END IF;

	res := 'location => fork';
	cntr := 0;

	IF LENGTH(g.ringback) > 0 THEN -- Fake ringback
		cntr := cntr + 1;
		res := res || hstore('callto.' || cntr, g.ringback);
		res := res || hstore('callto.' || cntr || '.fork.calltype', 'persistent');
		res := res || hstore('callto.' || cntr || '.fork.autoring', 'true');
		res := res || hstore('callto.' || cntr || '.fork.automessage', 'call.progress');
	END IF;

	cntr2 := cntr;
	SELECT * INTO res, cntr2 FROM callgroups_route_part(g, res, cntr2);

	IF cntr2 <> cntr THEN -- Members found
		cntr := cntr2;
		IF LENGTH(g.exitpos) > 0 THEN -- Exit position
			cntr := cntr + 1;
			IF g.maxcall > 0 THEN
				res := res || hstore('callto.' || cntr, '|exec=' || g.maxcall);
			ELSE
				res := res || hstore('callto.' || cntr, '|exec');
			END IF;
			cntr := cntr + 1;
			res := res || hstore('callto.' || cntr, 'lateroute/' || g.exitpos);
		END IF;
	ELSE -- No members found
		IF LENGTH(g.exitpos) > 0 THEN
			res := 'location => lateroute/' || g.exitpos;
		ELSE
			res := 'location => "", error => "offline"';
		END IF;
	END IF;

	RETURN QUERY SELECT * FROM each(res);
END;
$$ LANGUAGE PlPgSQL;





CREATE TABLE provision (
	id SERIAL PRIMARY KEY,
	uid INTEGER REFERENCES users(id) ON DELETE CASCADE,
	hw MACADDR,
	devtype TEXT,
	params HSTORE
);

CREATE TABLE ivr_aa(
	id SERIAL PRIMARY KEY, num PHONE NOT NULL,
	prompt TEXT, timeout INTEGER,
	e0 PHONE, e1 PHONE, e2 PHONE, e3 PHONE,
	e4 PHONE, e5 PHONE, e6 PHONE, e7 PHONE,
	e8 PHONE, e9 PHONE, estar PHONE, ehash PHONE,
	etimeout PHONE
);
ALTER TABLE ivr_aa ADD CONSTRAINT num_fk FOREIGN KEY (num) REFERENCES directory(num) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE TABLE ivr_minidisa(
	id SERIAL PRIMARY KEY, num PHONE NOT NULL,
	prompt TEXT, timeout INTEGER,
	numlen INTEGER NOT NULL DEFAULT 3,
	firstdigit VARCHAR(12),
	etimeout PHONE
);
ALTER TABLE ivr_minidisa ADD CONSTRAINT num_fk FOREIGN KEY (num) REFERENCES directory(num) ON UPDATE CASCADE ON DELETE CASCADE;



CREATE TABLE cdr (
	id BIGSERIAL PRIMARY KEY,
	ts TIMESTAMP WITH TIME ZONE,
	chan TEXT,
	address TEXT,
	direction TEXT,
	billid TEXT,
	caller TEXT,
	called TEXT,
	duration INTERVAL,
	billtime INTERVAL,
	ringtime INTERVAL,
	status TEXT,
	reason TEXT,
	ended BOOLEAN,
	callid TEXT,
	calledfull TEXT
);
CREATE INDEX cdr_billid_index ON cdr(billid);
CREATE INDEX cdr_caller_index ON cdr(caller);
CREATE INDEX cdr_direction_index ON cdr(direction);
CREATE INDEX cdr_status_index ON cdr(status);
CREATE INDEX cdr_ts_index ON cdr(ts);
CREATE INDEX cdr_callid_index ON cdr(callid);
CREATE INDEX cdr_calledfull_index ON cdr(calledfull);
ALTER TABLE cdr CLUSTER ON cdr_ts_index;



-- Resource subscribtion
--CREATE TABLE funclog (ts TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP, src VARCHAR(255) NULL, msg TEXT NOT NULL);
CREATE OR REPLACE FUNCTION subscriptions_subscribe(notifier_arg TEXT, event_arg TEXT, subscriber_arg TEXT, data_arg TEXT, notifyto_arg TEXT, expires_arg TEXT)
	RETURNS TABLE (notifier TEXT, data TEXT, subscriber TEXT, event TEXT, notifyto TEXT, notifyseq INT8) AS $$
BEGIN
	-- INSERT INTO funclog(src, msg) VALUES ('subscriptions_subscribe', 'notifier=' || notifier || ', operation=' || event_arg || ', subscriber=' || subscriber || ', data=' || data || ', notifyto=' || notifyto || ', expires=' || expires);
	IF event_arg IS NULL OR event_arg = '' THEN
		RETURN;
	END IF;
	INSERT INTO subscriptions(notifier, operation, subscriber, data, notifyto, expires) VALUES ($1, $2, $3, $4, $5, ($6 || ' s')::INTERVAL);
	RETURN QUERY SELECT $1, $4, $3, $2, $5, currval('subscriptions_id_seq');
END;
$$ LANGUAGE PlPgSQL;
CREATE OR REPLACE FUNCTION subscriptions_unsubscribe(notifier_arg TEXT, event_arg TEXT, subscriber_arg TEXT) RETURNS VOID AS $$
BEGIN
	-- INSERT INTO funclog(src, msg) VALUES ('subscriptions_unsubscribe', 'notifier=' || notifier || ', operation=' || event_arg || ', subscriber=' || subscriber);
	DELETE FROM subscriptions WHERE notifier = notifier_arg AND operation = event_arg AND subscriber = subscriber_arg;
END;
$$ LANGUAGE PlPgSQL;
CREATE OR REPLACE FUNCTION subscriptions_notify(notifier_arg TEXT, event_arg TEXT)
	RETURNS TABLE(notifier TEXT, data TEXT, subscriber TEXT, event TEXT, notifyto TEXT, notifyseq INT8) AS $$
BEGIN
	-- INSERT INTO funclog(src, msg) VALUES ('subscriptions_notify', 'notifier=' || notifier_arg || ', operation=' || event_arg);
	RETURN QUERY SELECT s.notifier, s.data, s.subscriber, s.operation, s.notifyto, s.id AS notifyseq
		FROM subscriptions s WHERE s.operation = event_arg AND s.notifier = notifier_arg;
END;
$$ LANGUAGE PlPgSQL;
CREATE OR REPLACE FUNCTION subscriptions_expires()
	RETURNS TABLE(notifier TEXT, data TEXT, subscriber TEXT, event TEXT, notifyto TEXT, notifyseq INT8) AS $$
BEGIN
	RETURN QUERY DELETE FROM subscriptions s WHERE s.ts + s.expires < CURRENT_TIMESTAMP RETURNING s.notifier, s.data, s.subscriber, s.operation AS event, s.notifyto, s.id AS notifyseq;
END;
$$ LANGUAGE PlPgSQL;



-- Call pickup
CREATE TABLE pickupgroups(
	id SERIAL PRIMARY KEY,
	callgrepcopy INTEGER NULL REFERENCES callgroups ON DELETE SET NULL,
	descr TEXT
);

CREATE TABLE pickupgrpmembers(
	id SERIAL PRIMARY KEY,
	grp INTEGER NOT NULL REFERENCES pickupgroups ON DELETE CASCADE,
	uid INTEGER REFERENCES users ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION pickupgroup_copy_callgoup(pgrp INTEGER, cgrp INTEGER) RETURNS INTEGER AS $$
BEGIN
	IF pgrp IS NULL THEN
		INSERT INTO pickupgroups(descr) VALUES (NULL);
	END IF;
	pgrp := lastval();
	UPDATE pickupgroups SET descr = (SELECT descr FROM callgroups WHERE id = cgrp), callgrepcopy = NULL WHERE id = pgrp;
	DELETE FROM pickupgrpmembers WHERE grp = pgrp;
	INSERT INTO pickupgrpmembers(grp, uid) SELECT pgrp, u.id FROM callgrpmembers m INNER JOIN users u ON u.num = m.num WHERE grp = cgrp;
	RETURN pgrp;
END;
$$ LANGUAGE PlPgSQL;

CREATE OR REPLACE FUNCTION service_code(srvcname TEXT) RETURNS TEXT AS $$
BEGIN
	RETURN CASE
		WHEN srvcname = 'pickupgroup' THEN '*1'
		ELSE NULL
	END;
END;
$$ LANGUAGE PlPgSQL STABLE;

CREATE OR REPLACE FUNCTION callpickup_route(msg HSTORE)
	RETURNS TABLE(key TEXT, value TEXT) AS $$
BEGIN
	IF msg->'called' <> service_code('pickupgroup') THEN
		RETURN;
	END IF;

	RETURN QUERY SELECT 'location'::TEXT, ('pickup/' || chan)::TEXT
		FROM linetracker l INNER JOIN pickupgrpmembers m1 ON m1.uid = l.uid
		INNER JOIN pickupgrpmembers m2 ON m2.grp = m1.grp
		WHERE direction = 'outgoing' AND status = 'ringing'
			AND m2.uid = userid(msg->'caller') ORDER BY m2.id LIMIT 1;
--			AND m2.uid = 180 AND m1.uid = 179;
END;
$$ LANGUAGE PlPgSql;

-- abbreveated numbers
CREATE TABLE abbrs(
	id SERIAL PRIMARY KEY,
	num PHONE NOT NULL,
	owner INTEGER REFERENCES users(id) NULL,
	target TEXT
);
ALTER TABLE abbrs ADD CONSTRAINT num_fk FOREIGN KEY (num) REFERENCES directory(num) ON UPDATE CASCADE ON DELETE CASCADE;
CREATE INDEX abbrs_uniq_index ON abbrs(num, owner);
CREATE INDEX abbrs_num_index ON abbrs(num);

CREATE OR REPLACE FUNCTION abbrs_route(msg HSTORE)
	RETURNS TABLE(key TEXT, value TEXT) AS $$
DECLARE
	u INTEGER;
BEGIN
	u := userid(msg->'caller');
	RETURN QUERY SELECT 'location'::TEXT, 'lateroute/' || target::TEXT FROM abbrs WHERE num = msg->'called' AND owner = u
		UNION SELECT 'location'::TEXT, 'lateroute/' || target FROM abbrs WHERE num = msg->'called' AND owner IS NULL;
END;
$$ LANGUAGE PlPgSql;


-- Scheduled route changes
CREATE TABLE schedules (
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL,
	comments TEXT
);
CREATE UNIQUE INDEX schedules_name_index ON schedules(name);

CREATE TABLE schedtable (
	id SERIAL PRIMARY KEY,
	prio INTEGER NOT NULL DEFAULT 100,
	mday DATE,
	days INTEGER NOT NULL DEFAULT 1,
	dow SMALLINT[] NOT NULL DEFAULT '{0,1,2,3,4,5,6}',
	tstart TIME WITHOUT TIME ZONE NOT NULL,
	tend TIME WITHOUT TIME ZONE NOT NULL,
	mode TEXT NOT NULL,
	schedule INTEGER NOT NULL REFERENCES schedules(id) ON DELETE CASCADE
);

INSERT INTO schedules(name) VALUES ('mode');
INSERT INTO schedtable (prio,      tstart, tend, mode, schedule) VALUES ( 0,                '00:00', '24:00', 'holiday', currval('schedules_id_seq'));
INSERT INTO schedtable (prio, dow, tstart, tend, mode, schedule) VALUES (10, '{1,2,3,4,5}', '09:00', '18:00', 'work',    currval('schedules_id_seq'));
-- INSERT INTO schedtable (prio, dow, tstart, tend, mode, schedule) VALUES (20, '{1,2,3,4,5}', '18:00', '21:00', 'evening', currval('schedules_id_seq'));
-- INSERT INTO schedtable (prio, dow, tstart, tend, mode, schedule) VALUES (30, '{1,2,3,4,5}', '21:00', '24:00', 'night',   currval('schedules_id_seq'));
-- INSERT INTO schedtable (prio, dow, tstart, tend, mode, schedule) VALUES (30, '{1,2,3,4,5}', '00:00', '09:00', 'night',   currval('schedules_id_seq'));
-- INSERT INTO schedtable (mday, days, tstart, tend, mode, schedule) VALUES ('2013-12-31', 9, '0:00', '24:00', 'holiday',   currval('schedules_id_seq'));

CREATE OR REPLACE FUNCTION scheduled_mode(schedname TEXT, ts TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, tz TEXT DEFAULT current_setting('TIMEZONE')) RETURNS TEXT AS $$
DECLARE
	wts TIMESTAMP WITH TIME ZONE;
	d DATE;
	t TIME WITHOUT TIME ZONE;
	wd SMALLINT;
	r TEXT;
	sid INTEGER;
BEGIN
	SELECT id INTO sid FROM schedules WHERE name = schedname;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Schedule % not found', schedname;
	END IF;
	wts := ts AT TIME ZONE tz;
	d := wts;
	t := wts;
	wd := EXTRACT(dow FROM d)::SMALLINT;
	-- RAISE NOTICE 'wts: %, d: %, t: %, wd: %', wts, d, t, wd;
	SELECT mode INTO r FROM schedtable s WHERE schedule = sid
		AND wd = ANY (s.dow)
		AND t >= s.tstart AND t < s.tend
		AND (mday IS NULL OR
			(d >= mday AND d < mday + days))
		ORDER BY prio DESC, mday DESC, tstart DESC LIMIT 1;
	RETURN r;
END;
$$ LANGUAGE PlPgSQL;

-- backward compatibility
CREATE OR REPLACE FUNCTION scheduled_mode(ts TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, tz TEXT DEFAULT current_setting('TIMEZONE')) RETURNS TEXT AS $$
BEGIN
	RETURN scheduled_mode('mode'::TEXT, ts, tz);
END;
$$ LANGUAGE PlPgSQL;


-- switch route
CREATE TABLE switches(
	id SERIAL PRIMARY KEY,
	num PHONE NOT NULL,
	param TEXT NOT NULL,
	arg TEXT NULL,
	defroute PHONE NOT NULL
);
ALTER TABLE switches ADD CONSTRAINT num_fk FOREIGN KEY (num) REFERENCES directory(num) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE TABLE switch_cases(
	id SERIAL PRIMARY KEY,
	switch INTEGER REFERENCES switches(id) ON UPDATE CASCADE ON DELETE CASCADE,
	value TEXT NULL NULL,
	route PHONE NOT NULL,
	comments TEXT NULL
);
CREATE UNIQUE INDEX switch_cases_uniq_index ON switch_cases(switch, value);

CREATE OR REPLACE FUNCTION switch_route(msg HSTORE) RETURNS TABLE(field TEXT, value TEXT) AS $$
DECLARE
	sw RECORD;
	r RECORD;
	m TEXT;
BEGIN
	SELECT * INTO sw FROM switches WHERE num = msg->'called';
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Switch % not found', msg->'called';
	END IF;

	CASE sw.param
		WHEN 'schedule' THEN
			m := scheduled_mode();
		WHEN 'config' THEN
			m := config('route', sw.arg);
		WHEN 'random' THEN
			SELECT c.value INTO m FROM switch_cases c WHERE c.switch = sw.id ORDER BY random() LIMIT 1;
		WHEN 'custom' THEN
			EXECUTE 'SELECT ' || sw.arg || '($1)' INTO m USING msg;
		ELSE
			RAISE EXCEPTION 'Invalid parameter % in switch %', sw.param, sw.num;
	END CASE;

	SELECT * INTO r FROM switch_cases c WHERE c.value = m;
	IF NOT FOUND THEN
		RETURN QUERY SELECT 'location'::TEXT, 'lateroute/' || sw.defroute;
	ELSE
		RETURN QUERY SELECT 'location'::TEXT, 'lateroute/' || r.route;
	END IF;

END;
$$ LANGUAGE PlPgSQL;



-- route incoming calls
CREATE TABLE incoming(
	id SERIAL PRIMARY KEY,
	ctx TEXT NULL,
	called PHONE,
	mode TEXT,
	route PHONE NOT NULL
);

CREATE OR REPLACE FUNCTION incoming_route(msg HSTORE) RETURNS TABLE(field TEXT, value TEXT) AS $$
DECLARE
	m TEXT;
	cf HSTORE;
BEGIN
	cf := config('route');
	IF (cf->'schedule_override') IS NOT NULL AND LENGTH(cf->'schedule_override') > 0 THEN
		m := cf->'schedule_override';
	ELSE
		m := scheduled_mode();
	END IF;
	RETURN QUERY SELECT 'location'::TEXT, 'lateroute/' || route FROM incoming
		WHERE (ctx IS NULL OR ctx = msg->'context')
			AND (called IS NULL OR called = msg->'called')
			AND (mode IS NULL OR mode = m)
		ORDER BY ctx IS NULL, called IS NULL, mode IS NULL LIMIT 1;
END;
$$ LANGUAGE PlPgSQL;

CREATE OR REPLACE FUNCTION route_master(msg HSTORE) RETURNS TABLE(field TEXT, value TEXT) AS $$
DECLARE
	cf HSTORE;
	nt TEXT;
BEGIN
	cf := config('route');
	IF (msg->'billid') IS NOT NULL AND toBoolean(cf->'debug', FALSE) THEN
		INSERT INTO calllog(billid, tag, value, params) VALUES (msg->'billid', 'DEBUG', 'call.route', msg);
	END IF;

	SELECT numtype INTO nt FROM directory WHERE (msg->'called' = num AND NOT is_prefix)
			OR (substr(msg->'called', 1, length(num)) = num AND is_prefix);

-- RAISE NOTICE 'nt: %', nt;
	CASE nt
		WHEN 'fictive' THEN
			field := 'location';
			value := 'lateroute/'||(msg->'called');
			RETURN NEXT;
		WHEN 'user' THEN
			RETURN QUERY SELECT * FROM regs_route(msg);
		WHEN 'callgrp' THEN
			RETURN QUERY SELECT * FROM callgroups_route(msg);
		WHEN 'abbr' THEN
			RETURN QUERY SELECT * FROM abbrs_route(msg);
		WHEN 'switch' THEN
			RETURN QUERY SELECT * FROM switch_route(msg);
		ELSE
			RETURN QUERY
				SELECT * FROM callpickup_route(msg)
			UNION
				SELECT * FROM incoming_route(msg);
	END CASE;
END;
$$ LANGUAGE PlPgSQL;


CREATE TABLE blfs(
	id SERIAL PRIMARY KEY,
	uid INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	key TEXT NOT NULL,
	num PHONE NOT NULL,
	label TEXT
);
CREATE UNIQUE INDEX blfs_uniqe_index ON blfs(uid, key);

CREATE TRIGGER blfs_change_trigger AFTER INSERT OR UPDATE OR DELETE
	ON blfs FOR EACH ROW EXECUTE PROCEDURE any_change_trigger_uid();



CREATE TABLE phonebook (
	id SERIAL PRIMARY KEY,
	owner INTEGER NULL REFERENCES users(id) ON DELETE CASCADE,
	num PHONE NOT NULL,
	descr TEXT NOT NULL,
	comments TEXT NOT NULL,
	numkind INTEGER NULL REFERENCES numkinds(id) ON DELETE SET NULL

);
CREATE INDEX phonebook_owner_index ON phonebook(owner);
CREATE INDEX phonebook_num_index ON phonebook USING gin(num gin_trgm_ops);
CREATE INDEX phonebook_descr_index ON phonebook USING gin(descr gin_trgm_ops);



CREATE TABLE prices(
	id SERIAL PRIMARY KEY,
	pref TEXT NOT NULL,
	price REAL NOT NULL,
	descr TEXT
);



CREATE OR REPLACE FUNCTION random_string(INTEGER) RETURNS TEXT AS $$
	SELECT array_to_string(ARRAY(SELECT substr('aeioubcdfghjkmnpqrstvwxyz23456789AEIOUBCDFGHJKMNPQRSTVWXYZ'::TEXT, 1+FLOOR(random()*58)::INTEGER, 1) FROM generate_series(1, $1)), '');
$$ LANGUAGE SQL VOLATILE;


-- http events receivers' sessions
CREATE TABLE sessions (
	token VARCHAR PRIMARY KEY DEFAULT random_string(16),
	uid INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	ts TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	events TEXT[]
);

CREATE TRIGGER sessions_change_trigger AFTER INSERT OR UPDATE OR DELETE
	ON sessions FOR EACH ROW EXECUTE PROCEDURE any_change_trigger_uid();


-- user/group/... status
CREATE OR REPLACE FUNCTION status_user(num PHONE) RETURNS TEXT AS $$
	SELECT CASE
			WHEN EXISTS(SELECT * FROM linetracker l WHERE l.uid = u.id AND l.direction = 'outgoing' AND l.status = 'ringing')
			THEN 'ringing'
			WHEN EXISTS(SELECT * FROM linetracker l WHERE l.uid = u.id)
			THEN 'busy'
			WHEN EXISTS(SELECT * FROM regs WHERE userid = u.id AND expires > CURRENT_TIMESTAMP)
			THEN 'online'
			ELSE 'offline'
	END FROM users u WHERE u.num = $1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION status_grp(num PHONE) RETURNS TEXT AS $$
DECLARE
	cnt BIGINT;
	online BIGINT;
	avail BIGINT;
BEGIN
	SELECT COUNT(*), COUNT(NULLIF(reg, false)), COUNT(NULLIF(reg AND NOT busy, false))
			INTO cnt, online, avail
		FROM ( SELECT u.num, COUNT(r.location) > 0 AS reg, COUNT(l.chan) > 0 AS busy
			FROM callgroups g
			 INNER JOIN callgrpmembers m ON m.grp = g.id
			 INNER JOIN users u ON u.num = m.num
			 LEFT JOIN regs r ON r.userid = u.id
			 LEFT JOIN linetracker l on l.uid = u.id
			WHERE g.num = $1
			GROUP BY u.num
		) ss;
	RETURN CASE
		WHEN online = 0 THEN 'offline'
		WHEN avail = 0 THEN 'busy'
		ELSE 'online'
	END;
END;
$$ LANGUAGE PlPgSQL;

CREATE OR REPLACE FUNCTION status_num2(num PHONE)
	RETURNS TABLE(nt VARCHAR, status TEXT) AS $$
BEGIN
	SELECT d.numtype INTO nt FROM directory d WHERE d.num = $1;
	IF NOT FOUND THEN
		nt := 'invalid';
	ELSIF nt = 'user' THEN
		status := status_user($1);
	ELSIF nt = 'callgrp' THEN
		status := status_grp($1);
	ELSIF nt = 'abbr' THEN
		SELECT status_num(target) INTO status FROM abbrs a WHERE a.num = $1;
	ELSIF nt = 'ivr' THEN
		status := 'online';
	ELSE
		status := 'unknown';
	END IF;
	RETURN NEXT;
END;
$$ LANGUAGE PlPgSQL;

CREATE OR REPLACE FUNCTION status_num(num PHONE) RETURNS TEXT AS $$
	SELECT status FROM status_num2($1);
$$ LANGUAGE SQL;




-- FIRST and LAST aggregates
-- https://wiki.postgresql.org/wiki/First/last_%28aggregate%29
CREATE OR REPLACE FUNCTION public.first_agg ( anyelement, anyelement )
RETURNS anyelement LANGUAGE sql IMMUTABLE STRICT AS $$
        SELECT $1;
$$;
CREATE AGGREGATE public.first (
        sfunc    = public.first_agg,
        basetype = anyelement,
        stype    = anyelement
);
CREATE OR REPLACE FUNCTION public.last_agg ( anyelement, anyelement )
RETURNS anyelement LANGUAGE sql IMMUTABLE STRICT AS $$
        SELECT $2;
$$;
CREATE AGGREGATE public.last (
        sfunc    = public.last_agg,
        basetype = anyelement,
        stype    = anyelement
);




-- vim: ft=sql

