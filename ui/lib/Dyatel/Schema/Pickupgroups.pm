package Dyatel::Schema::Pickupgroups;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("pickupgroups");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('pickupgroups_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "callgrepcopy",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "descr",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("pickupgroups_pkey", ["id"]);
__PACKAGE__->belongs_to(
  "callgrepcopy",
  "Dyatel::Schema::Callgroups",
  { id => "callgrepcopy" },
);
__PACKAGE__->has_many(
  "pickupgrpmembers",
  "Dyatel::Schema::Pickupgrpmembers",
  { "foreign.grp" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-10-23 21:35:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Vfi4AZubdZQxis7z4ejNoA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
