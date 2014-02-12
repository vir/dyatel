package Dyatel::Schema::Blfs;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("blfs");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('blfs_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "uid",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "key",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "num",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "label",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("blfs_pkey", ["id"]);
__PACKAGE__->add_unique_constraint("blfs_uniqe_index", ["uid", "key"]);
__PACKAGE__->belongs_to("uid", "Dyatel::Schema::Users", { id => "uid" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2014-02-12 15:11:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:skY5uaUO8S14MpQUG+2Mnw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
