package Dyatel::Schema::Prices;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("prices");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('prices_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "pref",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "price",
  { data_type => "real", default_value => undef, is_nullable => 0, size => 4 },
  "descr",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("prices_pkey", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2014-01-10 17:41:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xBB92U2ZQF9I2oK4/OSVyg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
