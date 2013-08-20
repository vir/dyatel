CREATE DOMAIN phone AS TEXT CHECK( VALUE ~ E'^\\d+$' );

CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	num PHONE NOT NULL,
	alias TEXT NULL CHECK(alias ~ E'^\\w+$'),
	domain TEXT NOT NULL,
	password TEXT NOT NULL,
	descr TEXT NULL,
	lastreg TIMESTAMP WITH TIME ZONE,
	lastip INET,
	nat_support BOOLEAN,
	nat_port_support BOOLEAN,
	media_bypass BOOLEAN DEFAULT FALSE
);

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
	audio BOOLEAN DEFAULT TRUE
);

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
                r := ROW( NULL::INTEGER, NULL::PHONE, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TIMESTAMP WITH TIME ZONE, NULL::INET, NULL::BOOLEAN, NULL::BOOLEAN, NULL::BOOLEAN);
        END IF;
        RETURN NEXT r;
END;
$$ LANGUAGE PlPgSQL STRICT STABLE;


CREATE OR REPLACE FUNCTION userid(username TEXT) RETURNS INTEGER AS $$
	SELECT id FROM userrec($1);
$$ LANGUAGE SQL STRICT STABLE;

CREATE OR REPLACE FUNCTION user_register(regnum TEXT, loc TEXT, exp TEXT, dev TEXT, drv TEXT, ipt TEXT, iph INET, ipp INTEGER) RETURNS VOID AS $$
DECLARE
	uid INTEGER;
	expint TIMESTAMP WITH TIME ZONE;
BEGIN
	uid := userid(regnum);
	IF uid IS NULL THEN
		RAISE EXCEPTION 'User % not found', regnum;
	END IF;
	IF exp IS NOT NULL AND exp <> '' THEN
		expint := CURRENT_TIMESTAMP + (exp::TEXT || ' s')::INTERVAL;
	END IF;
	DELETE FROM regs WHERE userid = uid AND location = loc;
	INSERT INTO regs(userid, ts, location, expires, device, driver, ip_transport, ip_host, ip_port, audio)
		VALUES (uid, CURRENT_TIMESTAMP, loc, expint, dev, drv, ipt, iph, ipp, drv <> 'jabber');
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

CREATE OR REPLACE FUNCTION roster_set_name(username TEXT, ctct TEXT, name TEXT, grps TEXT) RETURNS VOID AS $$
DECLARE
	id INTEGER;
BEGIN
	id := userid($1);
	UPDATE roster SET label = $3, groups = $4 WHERE uid = id AND contact = ctct;
	IF NOT FOUND THEN
		INSERT INTO roster(uid, contact, label, groups) VALUES (id, ctct, $3, $4);
	END IF;
END;
$$ LANGUAGE PlPgSQL;

CREATE OR REPLACE FUNCTION roster_set_full(username TEXT, ctct TEXT, subs TEXT, name TEXT, grps TEXT) RETURNS VOID AS $$
DECLARE
	id INTEGER;
BEGIN
	id := userid($1);
	UPDATE roster SET subscription = subs, label = name, groups = grps WHERE uid = id AND contact = ctct;
	IF NOT FOUND THEN
		INSERT INTO roster(uid, contact, subscription, label, groups) VALUES (id, ctct, subs, name, grps);
	END IF;
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
			RAISE NOTICE 'User % already has % moffline messages while % is allowed', username, n, maxcount;
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

-- requires yate modification a769565
--  51cdc1ec7322aa09930c6a473e456adf95949daf
CREATE OR REPLACE FUNCTION caps_update(contct TEXT, has_audio BOOLEAN) RETURNS VOID AS $$
	UPDATE regs SET audio = $2 WHERE location = $1
$$ LANGUAGE SQL;


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
CREATE OR REPLACE FUNCTION regs_route(caller_arg TEXT, called_arg TEXT, ip_host_arg INET, formats_arg TEXT, rtp_forward_arg TEXT)
	RETURNS TABLE(key TEXT, value TEXT) AS $$
DECLARE
	res HSTORE;
	cntr INTEGER;
BEGIN
	res := '';
	SELECT * INTO res, cntr FROM regs_route_part(caller_arg, called_arg, ip_host_arg, formats_arg, rtp_forward_arg, res, 0);

	IF res::TEXT = '' THEN
		RETURN;
	ELSE
		res := res || 'location => fork';
		RETURN QUERY SELECT * FROM each(res);
	END IF;
END;
$$ LANGUAGE PlPgSQL;

CREATE OR REPLACE FUNCTION regs_route_part(caller_arg TEXT, called_arg TEXT, ip_host_arg INET, formats_arg TEXT, rtp_forward_arg TEXT, res HSTORE, cntr INTEGER)
	RETURNS TABLE (vals HSTORE, newcntr INTEGER) AS $$
DECLARE
	clr RECORD;
	cld RECORD;
	t RECORD;
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
		END LOOP;
	END IF;

	RETURN QUERY SELECT res, cntr;
END;
$$ LANGUAGE PlPgSQL;






CREATE TYPE CALLDISTRIBUTION AS ENUM ('parallel', 'linear', 'rotary');

CREATE TABLE callgroups(
	id SERIAL PRIMARY KEY,
	num PHONE NOT NULL,
	descr TEXT,
	distr CALLDISTRIBUTION NOT NULL DEFAULT 'parallel',
	rotary_last INTEGER NOT NULL DEFAULT 0,
	ringback TEXT NULL,
	maxcall INTEGER NOT NULL DEFAULT 0,
	exitpos PHONE NULL
);
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


CREATE OR REPLACE FUNCTION route_master(msg HSTORE) RETURNS TABLE(field TEXT, value TEXT) AS $$
BEGIN
	RETURN QUERY
		SELECT * FROM regs_route(msg->'caller', msg->'called', (msg->'ip_host')::INET, msg->'formats', msg->'rtp_forward')
	UNION
		SELECT * FROM callgroups_route(msg->'caller', msg->'called', (msg->'ip_host')::INET, msg->'formats', msg->'rtp_forward');
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
	descr TEXT, prompt TEXT, timeout INTEGER,
	e0 PHONE, e1 PHONE, e2 PHONE, e3 PHONE,
	e4 PHONE, e5 PHONE, e6 PHONE, e7 PHONE,
	e8 PHONE, e9 PHONE, estar PHONE, ehash PHONE,
	etimeout PHONE
);

CREATE TABLE ivr_minidisa(
	id SERIAL PRIMARY KEY, num PHONE NOT NULL,
	descr TEXT, prompt TEXT, timeout INTEGER,
	numlen INTEGER NOT NULL DEFAULT 3,
	firstdigit VARCHAR(12),
	etimeout PHONE
);

-- vim: ft=sql
