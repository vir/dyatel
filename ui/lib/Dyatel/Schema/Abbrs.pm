package Dyatel::Schema::Abbrs;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("abbrs");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('abbrs_id_seq'::regclass)",
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
  "owner",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "target",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
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
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("abbrs_pkey", ["id"]);
__PACKAGE__->belongs_to("owner", "Dyatel::Schema::Users", { id => "owner" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-11-05 11:30:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AuqL4ngbf8LYARpcrz8dlw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
