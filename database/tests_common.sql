CREATE SCHEMA test;

SET search_path TO test, public;

CREATE TABLE results(ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP, name TEXT, err TEXT);

CREATE OR REPLACE FUNCTION run_all_tests() RETURNS BOOLEAN AS $$
DECLARE
	func TEXT;
	ok BOOLEAN;
BEGIN
	ok := TRUE;
	FOR func IN SELECT p.proname FROM pg_catalog.pg_namespace n JOIN pg_catalog.pg_proc p ON p.pronamespace = n.oid WHERE n.nspname = 'test' AND p.proname LIKE 'test_%' LOOP
		BEGIN
			EXECUTE 'SELECT ' || func || '()';
		EXCEPTION WHEN OTHERS THEN
			INSERT INTO results(name, err) VALUES (func, SQLERRM);
			ok := FALSE;
		END;
	END LOOP;
	RETURN ok;
END;
$$ LANGUAGE PlPgSQL VOLATILE;

CREATE AGGREGATE hstore_agg (hstore) (
    SFUNC = hs_concat(hstore, hstore),
    STYPE = hstore
);

