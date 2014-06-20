use utf8;
package Dyatel::Schema::Phonebook;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Phonebook

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

=head1 TABLE: C<phonebook>

=cut

__PACKAGE__->table("phonebook");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'phonebook_id_seq'

=head2 owner

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 num

  data_type: 'phone'
  is_nullable: 0

=head2 descr

  data_type: 'text'
  is_nullable: 0

=head2 comments

  data_type: 'text'
  is_nullable: 0

=head2 numkind

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "phonebook_id_seq",
  },
  "owner",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "num",
  { data_type => "phone", is_nullable => 0 },
  "descr",
  { data_type => "text", is_nullable => 0 },
  "comments",
  { data_type => "text", is_nullable => 0 },
  "numkind",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 numkind

Type: belongs_to

Related object: L<Dyatel::Schema::Numkinds>

=cut

__PACKAGE__->belongs_to("numkind", "Dyatel::Schema::Numkinds", { id => "numkind" });

=head2 owner

Type: belongs_to

Related object: L<Dyatel::Schema::Users>

=cut

__PACKAGE__->belongs_to("owner", "Dyatel::Schema::Users", { id => "owner" });


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ec/chXi7SLWQQ8175IWeXQ

# You can replace this text with custom content, and it will be preserved on regeneration
1;
