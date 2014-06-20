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

=cut

__PACKAGE__->add_columns(
  "grp",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "ord",
  { data_type => "integer", is_nullable => 0 },
  "num",
  { data_type => "phone", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</grp>

=item * L</ord>

=back

=cut

__PACKAGE__->set_primary_key("grp", "ord");

=head1 RELATIONS

=head2 grp

Type: belongs_to

Related object: L<Dyatel::Schema::Callgroups>

=cut

__PACKAGE__->belongs_to("grp", "Dyatel::Schema::Callgroups", { id => "grp" });


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PGJ5poNeTfGzb70drZFzGA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
