package Dyatel::Schema::Sessions;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("sessions");
__PACKAGE__->add_columns(
  "token",
  {
    data_type => "character varying",
    default_value => "random_string(16)",
    is_nullable => 0,
    size => undef,
  },
  "uid",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "ts",
  {
    data_type => "timestamp with time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
  "events",
  {
    data_type => "text[]",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("token");
__PACKAGE__->add_unique_constraint("sessions_pkey", ["token"]);
__PACKAGE__->belongs_to("uid", "Dyatel::Schema::Users", { id => "uid" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2014-01-29 09:58:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tyCQPSA8RZOm021zG8w9SA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
