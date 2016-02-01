use utf8;
package Dyatel::Schema::Callgrpmembers;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Callgrpmembers

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

=head1 TABLE: C<callgrpmembers>

=cut

__PACKAGE__->table("callgrpmembers");

=head1 ACCESSORS

=head2 grp

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 ord

  data_type: 'integer'
  is_nullable: 0

=head2 num

  data_type: 'phone'
  is_nullable: 0

=head2 enabled

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'callgrpmembers_id_seq'

=head2 maxcall

  data_type: 'integer'
  default_value: 8
  is_nullable: 0

=head2 keepring

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "grp",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "ord",
  { data_type => "integer", is_nullable => 0 },
  "num",
  { data_type => "phone", is_nullable => 0 },
  "enabled",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "callgrpmembers_id_seq",
  },
  "maxcall",
  { data_type => "integer", default_value => 8, is_nullable => 0 },
  "keepring",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<callgrpmembers_uniq_index>

=over 4

=item * L</grp>

=item * L</ord>

=back

=cut

__PACKAGE__->add_unique_constraint("callgrpmembers_uniq_index", ["grp", "ord"]);

=head1 RELATIONS

=head2 grp

Type: belongs_to

Related object: L<Dyatel::Schema::Callgroups>

=cut

__PACKAGE__->belongs_to("grp", "Dyatel::Schema::Callgroups", { id => "grp" });


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-12-04 09:54:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ooiY2DaBYAA1qpu505XmQg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
