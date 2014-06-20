use utf8;
package Dyatel::Schema::Numtypes;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Numtypes

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

=head1 TABLE: C<numtypes>

=cut

__PACKAGE__->table("numtypes");

=head1 ACCESSORS

=head2 numtype

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 descr

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "numtype",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "descr",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</numtype>

=back

=cut

__PACKAGE__->set_primary_key("numtype");

=head1 RELATIONS

=head2 directories

Type: has_many

Related object: L<Dyatel::Schema::Directory>

=cut

__PACKAGE__->has_many(
  "directories",
  "Dyatel::Schema::Directory",
  { "foreign.numtype" => "self.numtype" },
  undef,
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FKmA5OdYoaFtxGjQlmS0Iw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
