use utf8;
package Dyatel::Schema::Numkinds;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Numkinds

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

=head1 TABLE: C<numkinds>

=cut

__PACKAGE__->table("numkinds");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'numkinds_id_seq'

=head2 descr

  data_type: 'text'
  is_nullable: 0

=head2 tag

  data_type: 'text'
  is_nullable: 1

=head2 set_local_caller

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 set_context

  data_type: 'text'
  is_nullable: 1

=head2 ins_prefix

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=head2 callabale

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 announce

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "numkinds_id_seq",
  },
  "descr",
  { data_type => "text", is_nullable => 0 },
  "tag",
  { data_type => "text", is_nullable => 1 },
  "set_local_caller",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "set_context",
  { data_type => "text", is_nullable => 1 },
  "ins_prefix",
  { data_type => "text", default_value => "", is_nullable => 0 },
  "callabale",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "announce",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 morenums

Type: has_many

Related object: L<Dyatel::Schema::Morenums>

=cut

__PACKAGE__->has_many(
  "morenums",
  "Dyatel::Schema::Morenums",
  { "foreign.numkind" => "self.id" },
  undef,
);

=head2 phonebooks

Type: has_many

Related object: L<Dyatel::Schema::Phonebook>

=cut

__PACKAGE__->has_many(
  "phonebooks",
  "Dyatel::Schema::Phonebook",
  { "foreign.numkind" => "self.id" },
  undef,
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-11-06 11:51:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9KA8NL/AhVAISuNoizg+6g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
