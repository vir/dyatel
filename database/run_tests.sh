#!/bin/sh -ex
#
# (c) vir
#
# Last modified: 2015-06-28 11:14:46 +0300
#

U=dyatel_test
D=dyatel_test

cd `dirname $0`

psql template1 << ***
DROP DATABASE IF EXISTS $D;
DROP USER IF EXISTS $U;
CREATE USER $U WITH PASSWORD 'xxx';
CREATE DATABASE $D OWNER $U ENCODING 'UTF-8';
***
psql $D -f admin.sql
psql -U $U $D -f initdb.sql
psql -U $U $D -f sampledata.sql
psql -U $U $D -f tests_common.sql
for f in test_*.sql
do
	psql -U $U $D -f $f
done
psql -U $U $D << ***
SET search_path TO test, public;
SELECT run_all_tests();
SELECT * FROM results ORDER BY ts;
SELECT COUNT(NULLIF(success, false)) AS success, COUNT(NULLIF(success, true)) AS errors FROM results;
***


