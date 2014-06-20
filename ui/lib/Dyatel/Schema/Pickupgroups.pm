use utf8;
package Dyatel::Schema::Pickupgroups;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Pickupgroups

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

=head1 TABLE: C<pickupgroups>

=cut

__PACKAGE__->table("pickupgroups");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'pickupgroups_id_seq'

=head2 callgrepcopy

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 descr

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "pickupgroups_id_seq",
  },
  "callgrepcopy",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "descr",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 callgrepcopy

Type: belongs_to

Related object: L<Dyatel::Schema::Callgroups>

=cut

__PACKAGE__->belongs_to(
  "callgrepcopy",
  "Dyatel::Schema::Callgroups",
  { id => "callgrepcopy" },
);

=head2 pickupgrpmembers

Type: has_many

Related object: L<Dyatel::Schema::Pickupgrpmembers>

=cut

__PACKAGE__->has_many(
  "pickupgrpmembers",
  "Dyatel::Schema::Pickupgrpmembers",
  { "foreign.grp" => "self.id" },
  undef,
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0bzACQAQKZLRAMWYv7YgEw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
