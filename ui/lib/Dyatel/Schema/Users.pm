package Dyatel::Schema::Users;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("users");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('users_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "num",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "alias",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "password",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "descr",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "lastreg",
  {
    data_type => "timestamp with time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "lastip",
  {
    data_type => "inet",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "nat_support",
  { data_type => "boolean", default_value => undef, is_nullable => 1, size => 1 },
  "nat_port_support",
  { data_type => "boolean", default_value => undef, is_nullable => 1, size => 1 },
  "domain",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("users_pkey", ["id"]);
__PACKAGE__->has_many(
  "offlinemsgs",
  "Dyatel::Schema::Offlinemsgs",
  { "foreign.uid" => "self.id" },
);
__PACKAGE__->has_many(
  "privdatas",
  "Dyatel::Schema::Privdata",
  { "foreign.uid" => "self.id" },
);
__PACKAGE__->has_many(
  "provisions",
  "Dyatel::Schema::Provision",
  { "foreign.uid" => "self.id" },
);
__PACKAGE__->has_many(
  "regs",
  "Dyatel::Schema::Regs",
  { "foreign.userid" => "self.id" },
);
__PACKAGE__->has_many(
  "rosters",
  "Dyatel::Schema::Roster",
  { "foreign.uid" => "self.id" },
);
__PACKAGE__->has_many(
  "vcards",
  "Dyatel::Schema::Vcards",
  { "foreign.uid" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-07-24 15:44:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GXCprMteQ/bYKERV7PVbEg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
