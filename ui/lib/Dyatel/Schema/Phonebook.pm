package Dyatel::Schema::Phonebook;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("phonebook");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('phonebook_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "owner",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "num",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "descr",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "comments",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("phonebook_pkey", ["id"]);
__PACKAGE__->belongs_to("owner", "Dyatel::Schema::Users", { id => "owner" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-12-06 15:20:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kvnSt4hj7QsofqUupFaj2g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
