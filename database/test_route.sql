
SET search_path TO test, public;

CREATE OR REPLACE FUNCTION test_route_user_1() RETURNS VOID AS $$
DECLARE
	got HSTORE;
	exp HSTORE;
BEGIN
	exp := '"callto.1"=>"223@voip.ctm.ru/a13131a6316fc01cae1f8e79936c31b2", "callto.2"=>"223@voip.ctm.ru/bc4244be85e614bceffb92119042837e", "callto.3"=>"223@voip.ctm.ru/3291b21f0567ec3dde269efd001ef178", "dtmfpass"=>"false", "location"=>"fork", "pbxassist"=>"true", "copyparams"=>"pbxassist,dtmfpass", "tonedetect_out"=>"true", "callto.1.secure"=>"yes", "callto.2.secure"=>"yes", "callto.3.secure"=>"yes"';
	SELECT hstore_agg(HSTORE(field, value)) INTO got FROM route_master('caller => 222, called => 223'::HSTORE);
	if got IS NULL OR got <> exp THEN
		RAISE EXCEPTION 'Got: %, Expected: %', (got - exp)::TEXT, (exp - got)::TEXT;
	END IF;
END
$$ LANGUAGE PlPgSql VOLATILE;


CREATE OR REPLACE FUNCTION test_route_callgrp_parallel() RETURNS VOID AS $$
DECLARE
	got HSTORE;
	exp HSTORE;
BEGIN
	exp := '"location"=>"fork"'
		|| ', "callto.1"=>"tone/ring", "callto.1.fork.autoring"=>"true", "callto.1.fork.calltype"=>"persistent", "callto.1.fork.automessage"=>"call.progress"'
		|| ', "callto.2"=>"sip/sip:226@192.168.50.26:5060", "callto.2.secure"=>"no", "callto.2.oconnection_id"=>"general"'
		|| ', "callto.3"=>"sip/sip:227@192.168.60.152:48422;transport=TLS;ob", "callto.3.secure"=>"yes", "callto.3.oconnection_id"=>"tls:192.168.8.53:5061-192.168.60.152:48422"'
		|| ', "callto.4"=>"sip/sip:228@118.190.212.112:5060;transport=TCP", "callto.4.secure"=>"no", "callto.4.oconnection_id"=>"tcp:99.229.59.30:5060-188.130.242.162:56502"'
		|| ', "callto.5"=>"sip/sip:229@1.2.3.4:5060", "callto.5.secure"=>"no"';
	SELECT hstore_agg(HSTORE(field, value)) INTO got FROM route_master('caller=>+76543210000, called=>5000');
	if got IS NULL OR got <> exp THEN
		RAISE EXCEPTION 'Got: %, Expected: %', (got - exp)::TEXT, (exp - got)::TEXT;
	END IF;
END
$$ LANGUAGE PlPgSql VOLATILE;


CREATE OR REPLACE FUNCTION test_route_callgrp_recurs() RETURNS VOID AS $$
DECLARE
	got HSTORE;
	exp HSTORE;
BEGIN
	exp := '"location"=>"fork"'
		|| ', "callto.1"=>"sip/sip:226@192.168.50.26:5060", "callto.1.secure"=>"no", "callto.1.oconnection_id"=>"general"'
		|| ', "callto.2"=>"sip/sip:227@192.168.60.152:48422;transport=TLS;ob", "callto.2.secure"=>"yes", "callto.2.oconnection_id"=>"tls:192.168.8.53:5061-192.168.60.152:48422"'
		|| ', "callto.3"=>"|next=5000"'
		|| ', "callto.4"=>"sip/sip:229@1.2.3.4:5060", "callto.4.secure"=>"no"'
		|| ', "callto.5"=>"sip/sip:230@1.2.3.4:5060", "callto.5.secure"=>"no"'
		|| ', "callto.6"=>"|next=5000"'
		|| ', "callto.7"=>"sip/sip:231@1.2.3.4:5060", "callto.7.secure"=>"no"'
		|| ', "callto.8"=>"|drop=8000"'
		|| ', "callto.9"=>"sip/sip:232@1.2.3.4:5060", "callto.9.secure"=>"no"'
		|| ', "callto.10"=>"|drop=8000"'
		|| ', "callto.11"=>"sip/sip:226@192.168.50.26:5060", "callto.11.secure"=>"no", "callto.11.oconnection_id"=>"general"'
		|| ', "callto.12"=>"sip/sip:227@192.168.60.152:48422;transport=TLS;ob", "callto.12.secure"=>"yes", "callto.12.oconnection_id"=>"tls:192.168.8.53:5061-192.168.60.152:48422"'
		|| ', "callto.13"=>"|next=5000"'
		|| ', "callto.14"=>"sip/sip:229@1.2.3.4:5060", "callto.14.secure"=>"no"'
		|| ', "callto.15"=>"sip/sip:230@1.2.3.4:5060", "callto.15.secure"=>"no"';
	SELECT hstore_agg(HSTORE(field, value)) INTO got FROM route_master('caller=>123, called=>5004');
	if got IS NULL OR got <> exp THEN
		RAISE EXCEPTION 'Got: %, Expected: %', (got - exp)::TEXT, (exp - got)::TEXT;
	END IF;
END
$$ LANGUAGE PlPgSql VOLATILE;


CREATE OR REPLACE FUNCTION test_route_callgrp_linear() RETURNS VOID AS $$
DECLARE
	got HSTORE;
	exp HSTORE;
BEGIN
	exp := '"location"=>"fork"'
		|| ', "callto.1"=>"tone/ring"'
		|| ', "callto.1.fork.autoring"=>"true"'
		|| ', "callto.1.fork.calltype"=>"persistent"'
		|| ', "callto.1.fork.automessage"=>"call.progress"'
		|| ', "callto.2"=>"sip/sip:226@192.168.50.26:5060"'
		|| ', "callto.2.secure"=>"no"'
		|| ', "callto.2.oconnection_id"=>"general"'
		|| ', "callto.3"=>"|next=5000"'
		|| ', "callto.4"=>"sip/sip:227@192.168.60.152:48422;transport=TLS;ob"'
		|| ', "callto.4.secure"=>"yes"'
		|| ', "callto.4.oconnection_id"=>"tls:192.168.8.53:5061-192.168.60.152:48422"'
		|| ', "callto.5"=>"|drop=5000"'
		|| ', "callto.6"=>"sip/sip:228@118.190.212.112:5060;transport=TCP"'
		|| ', "callto.6.secure"=>"no"'
		|| ', "callto.6.oconnection_id"=>"tcp:99.229.59.30:5060-188.130.242.162:56502"'
		|| ', "callto.7"=>"|drop=5000"'
		|| ', "callto.8"=>"sip/sip:229@1.2.3.4:5060"'
		|| ', "callto.8.secure"=>"no"'
		|| ', "callto.9"=>"|exec=60000"'
		|| ', "callto.10"=>"lateroute/266"';
	SELECT hstore_agg(HSTORE(field, value)) INTO got FROM route_master('caller=>+76543210000, called=>5001');
	if got IS NULL OR got <> exp THEN
		RAISE EXCEPTION 'Got: %, Expected: %', (got - exp)::TEXT, (exp - got)::TEXT;
	END IF;
END
$$ LANGUAGE PlPgSql VOLATILE;

CREATE OR REPLACE FUNCTION test_route_pickup() RETURNS VOID AS $$
DECLARE
	got HSTORE;
	exp HSTORE;
BEGIN
	exp := '"location"=>"pickup/sip/666"';
	SELECT hstore_agg(HSTORE(field, value)) INTO got FROM route_master('caller => 222, called => *1'::HSTORE);
	if got IS NULL OR got <> exp THEN
		RAISE EXCEPTION 'Got: %, Expected: %', (got - exp)::TEXT, (exp - got)::TEXT;
	END IF;
END
$$ LANGUAGE PlPgSql VOLATILE;

CREATE OR REPLACE FUNCTION test_route_abbr1() RETURNS VOID AS $$
DECLARE
	got HSTORE;
	exp HSTORE;
BEGIN
	exp := '"location"=>"lateroute/+79210000002"';
	SELECT hstore_agg(HSTORE(field, value)) INTO got FROM route_master('caller => 222, called => #1'::HSTORE);
	if got IS NULL OR got <> exp THEN
		RAISE EXCEPTION 'Got: %, Expected: %', (got - exp)::TEXT, (exp - got)::TEXT;
	END IF;
END
$$ LANGUAGE PlPgSql VOLATILE;

CREATE OR REPLACE FUNCTION test_route_abbr2() RETURNS VOID AS $$
DECLARE
	got HSTORE;
	exp HSTORE;
BEGIN
	SELECT hstore_agg(HSTORE(field, value)) INTO got FROM route_master('caller => 223, called => #1'::HSTORE);
	if got IS NOT NULL THEN
		RAISE EXCEPTION 'Got: %, Expected: %', got::TEXT, NULL;
	END IF;
END
$$ LANGUAGE PlPgSql VOLATILE;

CREATE OR REPLACE FUNCTION test_route_abbr3() RETURNS VOID AS $$
DECLARE
	got HSTORE;
	exp HSTORE;
BEGIN
	exp := '"location"=>"lateroute/+79210000001"';
	SELECT hstore_agg(HSTORE(field, value)) INTO got FROM route_master('caller => 223, called => 666'::HSTORE);
	if got IS NULL OR got <> exp THEN
		RAISE EXCEPTION 'Got: %, Expected: %', (got - exp)::TEXT, (exp - got)::TEXT;
	END IF;
END
$$ LANGUAGE PlPgSql VOLATILE;

CREATE OR REPLACE FUNCTION test_route_fictive() RETURNS VOID AS $$
DECLARE
	got HSTORE;
	exp HSTORE;
BEGIN
	exp := '"location"=>"lateroute/6411"';
	SELECT hstore_agg(HSTORE(field, value)) INTO got FROM route_master('caller => 223, called => 6411'::HSTORE);
	if got IS NULL OR got <> exp THEN
		RAISE EXCEPTION 'Got: %, Expected: %', (got - exp)::TEXT, (exp - got)::TEXT;
	END IF;
END
$$ LANGUAGE PlPgSql VOLATILE;

CREATE OR REPLACE FUNCTION test_route_fictive_grp() RETURNS VOID AS $$
DECLARE
	got HSTORE;
	exp HSTORE;
BEGIN
	exp := '"location"=>"fork"'
		||', "callto.1"=>"sip/sip:231@1.2.3.4:5060"'
		||', "callto.2"=>"sip/sip:232@1.2.3.4:5060"'
		||', "callto.3"=>"lateroute/6415"'
		||', "callto.1.secure"=>"no", "callto.2.secure"=>"no"';
	SELECT hstore_agg(HSTORE(field, value)) INTO got FROM route_master('caller => 223, called => 5007'::HSTORE);
	if got IS NULL OR got <> exp THEN
		RAISE EXCEPTION 'Got: %, Expected: %', (got - exp)::TEXT, (exp - got)::TEXT;
	END IF;
END
$$ LANGUAGE PlPgSql VOLATILE;

