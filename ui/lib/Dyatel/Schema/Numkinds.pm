package Dyatel::Schema::Numkinds;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("numkinds");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('numkinds_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "descr",
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
  "set_local_caller",
  {
    data_type => "boolean",
    default_value => "false",
    is_nullable => 0,
    size => 1,
  },
  "set_context",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "ins_prefix",
  {
    data_type => "text",
    default_value => "''::text",
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("numkinds_pkey", ["id"]);
__PACKAGE__->has_many(
  "morenums",
  "Dyatel::Schema::Morenums",
  { "foreign.numkind" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-10-23 21:35:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0rjHvi1z85fAVVhmqe/Dqw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
