#!/bin/sh
#
# (c) vir
#
# Last modified: 2013-07-24 15:22:28 +0400
#

DIR=`dirname $0`
#$DIR/dyatel_create.pl model DB DBIC::Schema Dyatel::Schema create=static components=TimeStamp,InflateColumn::Serializer dbi:Pg:dbname=yate yate
$DIR/dyatel_create.pl model DB DBIC::Schema Dyatel::Schema create=static components=InflateColumn::Serializer dbi:Pg:dbname=yate yate

