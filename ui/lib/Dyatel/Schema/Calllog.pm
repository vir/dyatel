package Dyatel::Schema::Calllog;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("calllog");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "bigint",
    default_value => "nextval('calllog_id_seq'::regclass)",
    is_nullable => 0,
    size => 8,
  },
  "ts",
  {
    data_type => "timestamp with time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
  "billid",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "tag",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "uid",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "value",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "params",
  {
    data_type => "hstore",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("calllog_pkey", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2014-02-26 00:20:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Sx8w7RYBo1XRlfgSCmK9QA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
