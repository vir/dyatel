package Dyatel::Schema::Config;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("config");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('config_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "section",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "params",
  {
    data_type => "hstore",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "ts",
  {
    data_type => "timestamp with time zone",
    default_value => "now()",
    is_nullable => 0,
    size => 8,
  },
  "uid",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("config_pkey", ["id"]);
__PACKAGE__->add_unique_constraint("config_section_index", ["section"]);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2014-02-26 00:20:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vA3v8EWi+0I+fHuEPwhDag


# You can replace this text with custom content, and it will be preserved on regeneration
1;
