use utf8;
package Dyatel::Schema::IvrAa;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::IvrAa

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

=head1 TABLE: C<ivr_aa>

=cut

__PACKAGE__->table("ivr_aa");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'ivr_aa_id_seq'

=head2 num

  data_type: 'phone'
  is_foreign_key: 1
  is_nullable: 0

=head2 prompt

  data_type: 'text'
  is_nullable: 1

=head2 timeout

  data_type: 'integer'
  is_nullable: 1

=head2 e0

  data_type: 'phone'
  is_nullable: 1

=head2 e1

  data_type: 'phone'
  is_nullable: 1

=head2 e2

  data_type: 'phone'
  is_nullable: 1

=head2 e3

  data_type: 'phone'
  is_nullable: 1

=head2 e4

  data_type: 'phone'
  is_nullable: 1

=head2 e5

  data_type: 'phone'
  is_nullable: 1

=head2 e6

  data_type: 'phone'
  is_nullable: 1

=head2 e7

  data_type: 'phone'
  is_nullable: 1

=head2 e8

  data_type: 'phone'
  is_nullable: 1

=head2 e9

  data_type: 'phone'
  is_nullable: 1

=head2 estar

  data_type: 'phone'
  is_nullable: 1

=head2 ehash

  data_type: 'phone'
  is_nullable: 1

=head2 etimeout

  data_type: 'phone'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "ivr_aa_id_seq",
  },
  "num",
  { data_type => "phone", is_foreign_key => 1, is_nullable => 0 },
  "prompt",
  { data_type => "text", is_nullable => 1 },
  "timeout",
  { data_type => "integer", is_nullable => 1 },
  "e0",
  { data_type => "phone", is_nullable => 1 },
  "e1",
  { data_type => "phone", is_nullable => 1 },
  "e2",
  { data_type => "phone", is_nullable => 1 },
  "e3",
  { data_type => "phone", is_nullable => 1 },
  "e4",
  { data_type => "phone", is_nullable => 1 },
  "e5",
  { data_type => "phone", is_nullable => 1 },
  "e6",
  { data_type => "phone", is_nullable => 1 },
  "e7",
  { data_type => "phone", is_nullable => 1 },
  "e8",
  { data_type => "phone", is_nullable => 1 },
  "e9",
  { data_type => "phone", is_nullable => 1 },
  "estar",
  { data_type => "phone", is_nullable => 1 },
  "ehash",
  { data_type => "phone", is_nullable => 1 },
  "etimeout",
  { data_type => "phone", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 num

Type: belongs_to

Related object: L<Dyatel::Schema::Directory>

=cut

__PACKAGE__->belongs_to("num", "Dyatel::Schema::Directory", { num => "num" });


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0GX/X2mZiRnnGCwLRBC6SA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
