CREATE DOMAIN phone AS TEXT CHECK( VALUE ~ E'^\+?[0-9\8\#]+$' );


CREATE TABLE numtypes (
	numtype VARCHAR PRIMARY KEY,
	descr TEXT
);

CREATE TABLE directory (
	num PHONE PRIMARY KEY,
	numtype VARCHAR NOT NULL REFERENCES numtypes(numtype),
	descr TEXT
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
        IF NEW.num <> OLD.num THEN
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



CREATE TABLE fingroups (
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL,
	sortkey INTEGER NOT NULL DEFAULT 100
);

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
	fingrp INTEGER REFERENCES fingroups(id) ON DELETE SET NULL
);
ALTER TABLE users ADD CONSTRAINT num_fk FOREIGN KEY (num) REFERENCES directory(num) ON UPDATE CASCADE ON DELETE CASCADE;
CREATE UNIQUE INDEX users_num_index ON users(num);
CREATE INDEX users_login_index ON users(login);

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
	route_params HSTORE;
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
CREATE OR REPLACE FUNCTION regs_route_part(caller_arg TEXT, called_arg TEXT, ip_host_arg INET, formats_arg TEXT, rtp_forward_arg TEXT, res HSTORE, cntr INTEGER)
	RETURNS TABLE (vals HSTORE, newcntr INTEGER) AS $$
DECLARE
	clr RECORD;
	cld RECORD;
	t RECORD;
	kvp RECORD;
	rtpfw BOOLEAN;
BEGIN
	cld := userrec(called_arg);
	IF cld.id IS NOT NULL THEN
		clr := userrec(caller_arg);
		rtpfw := COALESCE(clr.media_bypass, FALSE) AND cld.media_bypass AND rtp_forward_arg = 'possible';

		FOR t IN SELECT * FROM regs WHERE userid = cld.id AND expires > 'now' AND audio LOOP
			cntr := cntr + 1;
			res := res || hstore('callto.' || cntr, t.location);
			res := res || hstore('callto.' || cntr || '.rtp_forward', CASE WHEN rtpfw AND ipnetwork(ip_host_arg) = ipnetwork(t.ip_host) THEN 'yes' ELSE 'no' END);
			FOR kvp IN SELECT * FROM EACH(t.route_params) LOOP
				res := res || hstore('callto.' || cntr || '.' || kvp.key, kvp.value);
			END LOOP;
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
	ins_prefix TEXT NOT NULL DEFAULT ''
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

CREATE OR REPLACE FUNCTION regs_route(caller_arg TEXT, called_arg TEXT, ip_host_arg INET, formats_arg TEXT, rtp_forward_arg TEXT)
	RETURNS TABLE(key TEXT, value TEXT) AS $$
DECLARE
	res HSTORE;
	cntr INTEGER;
	t RECORD;
	uoffline BOOLEAN;
BEGIN
	res := '';
	SELECT * INTO res, cntr FROM regs_route_part(caller_arg, called_arg, ip_host_arg, formats_arg, rtp_forward_arg, res, 0);

	uoffline := res::TEXT = '';

	-- Add 'offline' and 'No answer' divertions
	FOR t IN SELECT regexp_replace(n.val, '[^0-9\*\#\+]', '', 'g') AS val, n.timeout, k.*
			FROM morenums n INNER JOIN numkinds k ON k.id = n.numkind
			WHERE uid = userid(called_arg) AND CASE WHEN uoffline THEN div_offline ELSE div_noans END ORDER BY n.sortkey, n.id LOOP
		IF res::TEXT <> '' THEN
			res := res || hstore('callto.' || cntr || '.maxcall', (t.timeout * 1000)::TEXT); -- appand to previous group
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
		RETURN QUERY SELECT * FROM each(res);
	END IF;
END;
$$ LANGUAGE PlPgSQL;




CREATE TYPE CALLDISTRIBUTION AS ENUM ('parallel', 'linear', 'rotary');

CREATE TABLE callgroups(
	id SERIAL PRIMARY KEY,
	num PHONE NOT NULL,
	distr CALLDISTRIBUTION NOT NULL DEFAULT 'parallel',
	rotary_last INTEGER NOT NULL DEFAULT 0,
	ringback TEXT NULL,
	maxcall INTEGER NOT NULL DEFAULT 0,
	exitpos PHONE NULL
);
ALTER TABLE callgroups ADD CONSTRAINT num_fk FOREIGN KEY (num) REFERENCES directory(num) ON UPDATE CASCADE ON DELETE CASCADE;
CREATE UNIQUE INDEX callgroups_num_index ON callgroups(num);
CREATE TABLE callgrpmembers(
	grp INTEGER NOT NULL REFERENCES callgroups(id) ON DELETE CASCADE,
	ord INTEGER,
	num PHONE NOT NULL
);
CREATE UNIQUE INDEX callgrpmembers_uniq_index ON callgrpmembers(grp, ord);
ALTER TABLE callgrpmembers ADD CONSTRAINT callgrpmembers_check_pkey PRIMARY KEY USING INDEX callgrpmembers_uniq_index;


CREATE OR REPLACE FUNCTION callgroups_route(caller_arg TEXT, called_arg TEXT, ip_host_arg INET, formats_arg TEXT, rtp_forward_arg TEXT)
	RETURNS TABLE(key TEXT, value TEXT) AS $$
DECLARE
	g RECORD;
	t RECORD;
	res HSTORE;
	cntr INTEGER;
	cntr2 INTEGER;
BEGIN
	SELECT * INTO g FROM callgroups WHERE num = called_arg;
	IF NOT FOUND THEN
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
	FOR t IN SELECT num FROM callgrpmembers WHERE grp = g.id ORDER BY ord LOOP
		SELECT * INTO res, cntr2 FROM regs_route_part(caller_arg, t.num, ip_host_arg, formats_arg, rtp_forward_arg, res, cntr2);
	END LOOP;

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

CREATE OR REPLACE FUNCTION any_change_trigger_uid() RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'DELETE' THEN
		PERFORM pg_notify(TG_TABLE_NAME::TEXT, OLD.uid::TEXT);
	ELSE
		PERFORM pg_notify(TG_TABLE_NAME::TEXT, NEW.uid::TEXT);
	END IF;
	RETURN NEW;
END $$ LANGUAGE PlPgSQL;

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
	DELETE FROM linetracker WHERE chan = msg->'chan';
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

CREATE OR REPLACE FUNCTION callpickup_route(clrnum TEXT, cldnum TEXT)
	RETURNS TABLE(key TEXT, value TEXT) AS $$
BEGIN
	IF cldnum <> service_code('pickupgroup') THEN
		RETURN;
	END IF;

	RETURN QUERY SELECT 'location'::TEXT, ('pickup/' || chan)::TEXT
		FROM linetracker l INNER JOIN pickupgrpmembers m1 ON m1.uid = l.uid
		INNER JOIN pickupgrpmembers m2 ON m2.grp = m1.grp
		WHERE direction = 'outgoing' AND status = 'ringing'
			AND m2.uid = userid(clrnum) ORDER BY m2.id LIMIT 1;
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

CREATE OR REPLACE FUNCTION abbrs_route(clrnum TEXT, cldnum TEXT)
	RETURNS TABLE(key TEXT, value TEXT) AS $$
DECLARE
	u INTEGER;
BEGIN
	u := userid(clrnum);
	RETURN QUERY SELECT 'location'::TEXT, 'lateroute/' || target::TEXT FROM abbrs WHERE num = cldnum AND owner = u
		UNION SELECT 'location'::TEXT, 'lateroute/' || target FROM abbrs WHERE num = cldnum AND owner IS NULL;
END;
$$ LANGUAGE PlPgSql;


-- Scheduled route changes
CREATE TABLE schedule (
	id SERIAL PRIMARY KEY,
	prio INTEGER NOT NULL DEFAULT 100,
	mday DATE,
	days INTEGER NOT NULL DEFAULT 1,
	dow SMALLINT[] NOT NULL DEFAULT '{0,1,2,3,4,5,6}',
	tstart TIME WITHOUT TIME ZONE NOT NULL,
	tend TIME WITHOUT TIME ZONE NOT NULL,
	mode TEXT NOT NULL
);

INSERT INTO schedule (prio,      tstart, tend, mode) VALUES ( 0,                '00:00', '24:00', 'holiday');
INSERT INTO schedule (prio, dow, tstart, tend, mode) VALUES (10, '{1,2,3,4,5}', '09:00', '18:00', 'work');
-- INSERT INTO schedule (prio, dow, tstart, tend, mode) VALUES (20, '{1,2,3,4,5}', '18:00', '21:00', 'evening');
-- INSERT INTO schedule (prio, dow, tstart, tend, mode) VALUES (30, '{1,2,3,4,5}', '21:00', '24:00', 'night');
-- INSERT INTO schedule (prio, dow, tstart, tend, mode) VALUES (30, '{1,2,3,4,5}', '00:00', '09:00', 'night');
-- INSERT INTO schedule (mday, days, tstart, tend, mode) VALUES ('2013-12-31', 9, '0:00', '24:00', 'holiday');

CREATE OR REPLACE FUNCTION scheduled_mode(ts TIMESTAMP WITH TIME ZONE DEFAULT 'now', tz TEXT DEFAULT current_setting('TIMEZONE')) RETURNS TEXT AS $$
DECLARE
	wts TIMESTAMP WITH TIME ZONE;
	d DATE;
	t TIME WITHOUT TIME ZONE;
	wd SMALLINT;
	r TEXT;
BEGIN
	wts := ts AT TIME ZONE tz;
	d := wts;
	t := wts;
	wd := EXTRACT(dow FROM d)::SMALLINT;
	-- RAISE NOTICE 'wts: %, d: %, t: %, wd: %', wts, d, t, wd;
	SELECT mode INTO r FROM schedule s WHERE wd = ANY (s.dow)
		AND t >= s.tstart AND t < s.tend
		AND (mday IS NULL OR
			(d >= mday AND d < mday + days)) 
		ORDER BY prio DESC, mday DESC, tstart DESC LIMIT 1;
	RETURN r;
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
BEGIN
	m := scheduled_mode();
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
BEGIN
	cf := config('route');
	IF (msg->'billid') IS NOT NULL AND toBoolean(cf->'debug', FALSE) THEN
		INSERT INTO calllog(billid, tag, value, params) VALUES (msg->'billid', 'DEBUG', 'call.route', msg);
	END IF;

	RETURN QUERY
		SELECT * FROM regs_route(msg->'caller', msg->'called', (msg->'ip_host')::INET, msg->'formats', msg->'rtp_forward')
	UNION
		SELECT * FROM callgroups_route(msg->'caller', msg->'called', (msg->'ip_host')::INET, msg->'formats', msg->'rtp_forward')
	UNION
		SELECT * FROM callpickup_route(msg->'caller', msg->'called')
	UNION
		SELECT * FROM abbrs_route(msg->'caller', msg->'called')
	UNION
		SELECT * FROM incoming_route(msg);
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

-- http events receivers' sessions
CREATE TABLE sessions (
	token VARCHAR PRIMARY KEY DEFAULT random_string(16),
	uid INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	ts TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	events TEXT[]
);

CREATE TRIGGER sessions_change_trigger AFTER INSERT OR UPDATE OR DELETE
	ON sessions FOR EACH ROW EXECUTE PROCEDURE any_change_trigger_uid();

-- vim: ft=sql

