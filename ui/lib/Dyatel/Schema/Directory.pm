use utf8;
package Dyatel::Schema::Directory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Directory

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

=head1 TABLE: C<directory>

=cut

__PACKAGE__->table("directory");

=head1 ACCESSORS

=head2 num

  data_type: 'phone'
  is_nullable: 0

=head2 numtype

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 descr

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "num",
  { data_type => "phone", is_nullable => 0 },
  "numtype",
  {
    data_type      => "text",
    is_foreign_key => 1,
    is_nullable    => 0,
    original       => { data_type => "varchar" },
  },
  "descr",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</num>

=back

=cut

__PACKAGE__->set_primary_key("num");

=head1 RELATIONS

=head2 abbrs

Type: has_many

Related object: L<Dyatel::Schema::Abbrs>

=cut

__PACKAGE__->has_many(
  "abbrs",
  "Dyatel::Schema::Abbrs",
  { "foreign.num" => "self.num" },
  undef,
);

=head2 callgroups

Type: has_many

Related object: L<Dyatel::Schema::Callgroups>

=cut

__PACKAGE__->has_many(
  "callgroups",
  "Dyatel::Schema::Callgroups",
  { "foreign.num" => "self.num" },
  undef,
);

=head2 ivr_aas

Type: has_many

Related object: L<Dyatel::Schema::IvrAa>

=cut

__PACKAGE__->has_many(
  "ivr_aas",
  "Dyatel::Schema::IvrAa",
  { "foreign.num" => "self.num" },
  undef,
);

=head2 ivr_minidisas

Type: has_many

Related object: L<Dyatel::Schema::IvrMinidisa>

=cut

__PACKAGE__->has_many(
  "ivr_minidisas",
  "Dyatel::Schema::IvrMinidisa",
  { "foreign.num" => "self.num" },
  undef,
);

=head2 numtype

Type: belongs_to

Related object: L<Dyatel::Schema::Numtypes>

=cut

__PACKAGE__->belongs_to(
  "numtype",
  "Dyatel::Schema::Numtypes",
  { numtype => "numtype" },
);

=head2 users

Type: has_many

Related object: L<Dyatel::Schema::Users>

=cut

__PACKAGE__->has_many(
  "users",
  "Dyatel::Schema::Users",
  { "foreign.num" => "self.num" },
  undef,
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mDdyMDXOVpyGQ6qEcCaKxg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
