package Dyatel::Schema::Incoming;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("incoming");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('incoming_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "ctx",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "called",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "mode",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "route",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("incoming_pkey", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-10-23 21:35:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OC9p542JcZA9pKHbdozQMA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
