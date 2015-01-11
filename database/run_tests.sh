#!/bin/sh -ex
#
# (c) vir
#
# Last modified: 2015-01-10 20:01:58 +0300
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


