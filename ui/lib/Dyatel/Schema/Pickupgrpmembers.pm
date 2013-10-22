package Dyatel::Schema::Pickupgrpmembers;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("pickupgrpmembers");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('pickupgrpmembers_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "grp",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "uid",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("pickupgrpmembers_pkey", ["id"]);
__PACKAGE__->belongs_to("uid", "Dyatel::Schema::Users", { id => "uid" });
__PACKAGE__->belongs_to("grp", "Dyatel::Schema::Pickupgroups", { id => "grp" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-10-23 21:35:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uqtzbqhy8Qc4m0cI2YHaWQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
