
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

