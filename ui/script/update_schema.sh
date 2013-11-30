#!/bin/sh
#
# (c) vir
#
# Last modified: 2013-12-01 01:31:34 +0400
#

DIR=`dirname $0`
#$DIR/dyatel_create.pl model DB DBIC::Schema Dyatel::Schema create=static components=TimeStamp,InflateColumn::Serializer dbi:Pg:dbname=yate yate
$DIR/dyatel_create.pl model DB DBIC::Schema Dyatel::Schema create=static components=InflateColumn::Serializer dbi:Pg:dbname=yate yate

cd $DIR/..

SD=lib/Dyatel/Schema

test -d ${SD} || exit 1

FILES=`git status lib/Dyatel/Schema | awk '($2 == "modified:") { print $3 }'`

for F in ${FILES}
do
	echo ${F}
	if ! git --no-pager diff --no-color lib/Dyatel/Schema/Vcards.pm | grep '^[+-]' | grep -v '^[+-]\(#\|--\|++\)'
	then
		echo ' - no changes'
		git checkout ${F}
	fi
done

git status ${SD}

