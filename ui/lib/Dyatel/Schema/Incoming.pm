use utf8;
package Dyatel::Schema::Incoming;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Incoming

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

=head1 TABLE: C<incoming>

=cut

__PACKAGE__->table("incoming");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'incoming_id_seq'

=head2 ctx

  data_type: 'text'
  is_nullable: 1

=head2 called

  data_type: 'phone'
  is_nullable: 1

=head2 mode

  data_type: 'text'
  is_nullable: 1

=head2 route

  data_type: 'phone'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "incoming_id_seq",
  },
  "ctx",
  { data_type => "text", is_nullable => 1 },
  "called",
  { data_type => "phone", is_nullable => 1 },
  "mode",
  { data_type => "text", is_nullable => 1 },
  "route",
  { data_type => "phone", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kB8bMqwkupP8diGLcXxDXQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
