package Dyatel::Schema::Morenums;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("morenums");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('morenums_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "uid",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "sortkey",
  { data_type => "integer", default_value => 100, is_nullable => 0, size => 4 },
  "numkind",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "val",
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
  "timeout",
  { data_type => "integer", default_value => 10, is_nullable => 0, size => 4 },
  "div_noans",
  {
    data_type => "boolean",
    default_value => "false",
    is_nullable => 0,
    size => 1,
  },
  "div_offline",
  {
    data_type => "boolean",
    default_value => "false",
    is_nullable => 0,
    size => 1,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("morenums_pkey", ["id"]);
__PACKAGE__->belongs_to("uid", "Dyatel::Schema::Users", { id => "uid" });
__PACKAGE__->belongs_to("numkind", "Dyatel::Schema::Numkinds", { id => "numkind" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-10-23 21:35:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oZlJr0iopHopLFWrvNSPVA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
