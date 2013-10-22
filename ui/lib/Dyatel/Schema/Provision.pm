package Dyatel::Schema::Provision;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("provision");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('provision_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "uid",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "hw",
  { data_type => "macaddr", default_value => undef, is_nullable => 1, size => 6 },
  "devtype",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "params",
  {
    data_type => "hstore",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("provision_pkey", ["id"]);
__PACKAGE__->belongs_to("uid", "Dyatel::Schema::Users", { id => "uid" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-10-23 21:35:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ds2R29Wnx2na97BBJc/n1Q

# Fix hstore column. This requires InflateColumn::Serializer component
__PACKAGE__->add_columns(
  "params",
  {
#    data_type => "hstore",
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
    serializer_class => 'Hstore',
    recursive_encode => 1, # (optional) 
  },
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
