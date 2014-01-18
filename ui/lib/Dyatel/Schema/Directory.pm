package Dyatel::Schema::Directory;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("directory");
__PACKAGE__->add_columns(
  "num",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
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
__PACKAGE__->set_primary_key("num");
__PACKAGE__->add_unique_constraint("directory_pkey", ["num"]);
__PACKAGE__->has_many(
  "abbrs",
  "Dyatel::Schema::Abbrs",
  { "foreign.num" => "self.num" },
);
__PACKAGE__->has_many(
  "callgroups",
  "Dyatel::Schema::Callgroups",
  { "foreign.num" => "self.num" },
);
__PACKAGE__->belongs_to(
  "numtype",
  "Dyatel::Schema::Numtypes",
  { numtype => "numtype" },
);
__PACKAGE__->has_many(
  "ivr_aas",
  "Dyatel::Schema::IvrAa",
  { "foreign.num" => "self.num" },
);
__PACKAGE__->has_many(
  "ivr_minidisas",
  "Dyatel::Schema::IvrMinidisa",
  { "foreign.num" => "self.num" },
);
__PACKAGE__->has_many(
  "users",
  "Dyatel::Schema::Users",
  { "foreign.num" => "self.num" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2014-01-17 06:22:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dC2rODvaQyAo3fM4YLf1kg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
