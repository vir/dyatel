use utf8;
package Dyatel::Schema::Privdata;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Privdata

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

=head1 TABLE: C<privdata>

=cut

__PACKAGE__->table("privdata");

=head1 ACCESSORS

=head2 uid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 tag

  data_type: 'text'
  is_nullable: 0

=head2 xmlns

  data_type: 'text'
  is_nullable: 0

=head2 data

  data_type: 'xml'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "uid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "tag",
  { data_type => "text", is_nullable => 0 },
  "xmlns",
  { data_type => "text", is_nullable => 0 },
  "data",
  { data_type => "xml", is_nullable => 1 },
);

=head1 RELATIONS

=head2 uid

Type: belongs_to

Related object: L<Dyatel::Schema::Users>

=cut

__PACKAGE__->belongs_to("uid", "Dyatel::Schema::Users", { id => "uid" });


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:j8FnUOBFtiQTdYoaW2xS4A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
