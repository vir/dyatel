use utf8;
package Dyatel::Schema::Regs;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Regs

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::Serializer>

=back

=cut

__PACKAGE__->load_components("InflateColumn::Serializer");

=head1 TABLE: C<regs>

=cut

__PACKAGE__->table("regs");

=head1 ACCESSORS

=head2 userid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 ts

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

=head2 location

  data_type: 'text'
  is_nullable: 0

=head2 expires

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 device

  data_type: 'text'
  is_nullable: 1

=head2 driver

  data_type: 'text'
  is_nullable: 1

=head2 ip_transport

  data_type: 'text'
  is_nullable: 1

=head2 ip_host

  data_type: 'inet'
  is_nullable: 1

=head2 ip_port

  data_type: 'integer'
  is_nullable: 1

=head2 audio

  data_type: 'boolean'
  default_value: true
  is_nullable: 1

=head2 route_params

  data_type: 'hstore'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "userid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "ts",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 1,
    original      => { default_value => \"now()" },
  },
  "location",
  { data_type => "text", is_nullable => 0 },
  "expires",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "device",
  { data_type => "text", is_nullable => 1 },
  "driver",
  { data_type => "text", is_nullable => 1 },
  "ip_transport",
  { data_type => "text", is_nullable => 1 },
  "ip_host",
  { data_type => "inet", is_nullable => 1 },
  "ip_port",
  { data_type => "integer", is_nullable => 1 },
  "audio",
  { data_type => "boolean", default_value => \"true", is_nullable => 1 },
  "route_params",
  { data_type => "hstore", is_nullable => 1 },
);

=head1 RELATIONS

=head2 userid

Type: belongs_to

Related object: L<Dyatel::Schema::Users>

=cut

__PACKAGE__->belongs_to("userid", "Dyatel::Schema::Users", { id => "userid" });


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WftNTLMO3L9hkkYxHMOaow

# add primary key to make DBIx::* happy
__PACKAGE__->set_primary_key(qw/userid location/);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
