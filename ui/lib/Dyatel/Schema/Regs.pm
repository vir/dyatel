package Dyatel::Schema::Regs;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("regs");
__PACKAGE__->add_columns(
  "userid",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "ts",
  {
    data_type => "timestamp with time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
  "location",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "expires",
  {
    data_type => "timestamp with time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "device",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "driver",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "ip_transport",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "ip_host",
  {
    data_type => "inet",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "ip_port",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "audio",
  {
    data_type => "boolean",
    default_value => "true",
    is_nullable => 1,
    size => 1,
  },
  "route_params",
  {
    data_type => "hstore",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->belongs_to("userid", "Dyatel::Schema::Users", { id => "userid" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-11-05 11:30:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Y52Vf/Z6jfYRrppmHjavsw

# add primary key to make DBIx::* happy
__PACKAGE__->set_primary_key(qw/userid location/);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
