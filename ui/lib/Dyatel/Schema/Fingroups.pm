package Dyatel::Schema::Fingroups;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("fingroups");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('fingroups_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "name",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "sortkey",
  { data_type => "integer", default_value => 100, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("fingroups_pkey", ["id"]);
__PACKAGE__->has_many(
  "users",
  "Dyatel::Schema::Users",
  { "foreign.fingrp" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2014-01-10 17:41:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:isLYHvGIIzjDk/0XFGp17g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
