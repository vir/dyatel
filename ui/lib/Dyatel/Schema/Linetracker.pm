package Dyatel::Schema::Linetracker;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("linetracker");
__PACKAGE__->add_columns(
  "uid",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "usecount",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "direction",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "status",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "chan",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "caller",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "called",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "billid",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->belongs_to("uid", "Dyatel::Schema::Users", { id => "uid" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-11-05 11:30:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7ftuksRVsuKPi4SUsDOJvg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
