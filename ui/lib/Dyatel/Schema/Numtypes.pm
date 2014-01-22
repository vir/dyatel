package Dyatel::Schema::Numtypes;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("numtypes");
__PACKAGE__->add_columns(
  "numtype",
  {
    data_type => "character varying",
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
);
__PACKAGE__->set_primary_key("numtype");
__PACKAGE__->add_unique_constraint("numtypes_pkey", ["numtype"]);
__PACKAGE__->has_many(
  "directories",
  "Dyatel::Schema::Directory",
  { "foreign.numtype" => "self.numtype" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2014-01-17 06:22:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gJIvBKWaRMX7Tj1r7aUQ6g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
