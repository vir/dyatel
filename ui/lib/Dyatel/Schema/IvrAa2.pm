use utf8;
package Dyatel::Schema::IvrAa2;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::IvrAa2

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

=head1 TABLE: C<ivr_aa2>

=cut

__PACKAGE__->table("ivr_aa2");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'ivr_aa2_id_seq'

=head2 num

  data_type: 'phone'
  is_foreign_key: 1
  is_nullable: 0

=head2 prompt

  data_type: 'text'
  is_nullable: 1

=head2 timeout

  data_type: 'integer[]'
  is_nullable: 1

=head2 shortnum

  data_type: 'hstore'
  is_nullable: 1

=head2 numlen

  data_type: 'integer'
  default_value: 3
  is_nullable: 0

=head2 numtypes

  data_type: 'character varying[]'
  default_value: '{}'::character varying[]
  is_nullable: 1

=head2 assist

  data_type: 'boolean'
  default_value: true
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
    sequence          => "ivr_aa2_id_seq",
  },
  "num",
  { data_type => "phone", is_foreign_key => 1, is_nullable => 0 },
  "prompt",
  { data_type => "text", is_nullable => 1 },
  "timeout",
  { data_type => "integer[]", is_nullable => 1 },
  "shortnum",
  { data_type => "hstore", is_nullable => 1 },
  "numlen",
  { data_type => "integer", default_value => 3, is_nullable => 0 },
  "numtypes",
  {
    data_type     => "character varying[]",
    default_value => \"'{}'::character varying[]",
    is_nullable   => 1,
  },
  "assist",
  { data_type => "boolean", default_value => \"true", is_nullable => 1 },
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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-05-19 15:19:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FIhKCP3hYxhBPF/6ixHd+A

__PACKAGE__->add_columns(
	'shortnum' => {
		'data_type' => 'hstore',
		'size'      => 255,
		'serializer_class' => 'Hstore',
		'recursive_encode' => 1, # (optional) 
	}
);


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
