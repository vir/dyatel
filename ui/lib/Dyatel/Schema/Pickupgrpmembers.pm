use utf8;
package Dyatel::Schema::Pickupgrpmembers;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Pickupgrpmembers

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

=head1 TABLE: C<pickupgrpmembers>

=cut

__PACKAGE__->table("pickupgrpmembers");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'pickupgrpmembers_id_seq'

=head2 grp

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 uid

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
    sequence          => "pickupgrpmembers_id_seq",
  },
  "grp",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "uid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 grp

Type: belongs_to

Related object: L<Dyatel::Schema::Pickupgroups>

=cut

__PACKAGE__->belongs_to("grp", "Dyatel::Schema::Pickupgroups", { id => "grp" });

=head2 uid

Type: belongs_to

Related object: L<Dyatel::Schema::Users>

=cut

__PACKAGE__->belongs_to("uid", "Dyatel::Schema::Users", { id => "uid" });


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/4qu9TxJrMK85kSMEhCspg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
