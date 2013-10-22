package Dyatel::Schema::Ipnetworks;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("ipnetworks");
__PACKAGE__->add_columns(
  "net",
  {
    data_type => "cidr",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->add_unique_constraint("ipnetworks_net_key", ["net"]);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-10-23 21:35:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3ZKswys7JQZo/zGxZF3ubA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
