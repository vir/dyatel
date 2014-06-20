use utf8;
package Dyatel::Schema::Ipnetworks;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Ipnetworks

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

=head1 TABLE: C<ipnetworks>

=cut

__PACKAGE__->table("ipnetworks");

=head1 ACCESSORS

=head2 net

  data_type: 'cidr'
  is_nullable: 0

=head2 id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "net",
  { data_type => "cidr", is_nullable => 0 },
  "id",
  { data_type => "integer", is_nullable => 0 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<ipnetworks_net_key>

=over 4

=item * L</net>

=back

=cut

__PACKAGE__->add_unique_constraint("ipnetworks_net_key", ["net"]);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BXAq/gDuNDfLYyzdzjWe1Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
