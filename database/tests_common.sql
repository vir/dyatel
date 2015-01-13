CREATE SCHEMA test;

SET search_path TO test, public;

CREATE TABLE results(
	ts TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	name TEXT,
	success BOOLEAN,
	delay INTERVAL,
	err TEXT
);

CREATE OR REPLACE FUNCTION run_all_tests() RETURNS BOOLEAN AS $$
DECLARE
	func TEXT;
	ok BOOLEAN;
	t TIMESTAMP WITH TIME ZONE;
BEGIN
	ok := TRUE;
	FOR func IN SELECT p.proname FROM pg_catalog.pg_namespace n JOIN pg_catalog.pg_proc p ON p.pronamespace = n.oid WHERE n.nspname = 'test' AND p.proname LIKE 'test_%' LOOP
		BEGIN
			t := clock_timestamp();
			EXECUTE 'SELECT ' || func || '()';
			INSERT INTO results(ts, name, success, delay) VALUES (t, func, TRUE, clock_timestamp() - t);
		EXCEPTION WHEN OTHERS THEN
			INSERT INTO results(ts, name, success, delay, err) VALUES (t, func, FALSE, clock_timestamp() - t, SQLERRM);
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

