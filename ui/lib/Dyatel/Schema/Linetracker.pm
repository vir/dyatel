use utf8;
package Dyatel::Schema::Linetracker;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Linetracker

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

=head1 TABLE: C<linetracker>

=cut

__PACKAGE__->table("linetracker");

=head1 ACCESSORS

=head2 uid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 direction

  data_type: 'text'
  is_nullable: 1

=head2 status

  data_type: 'text'
  is_nullable: 1

=head2 chan

  data_type: 'text'
  is_nullable: 1

=head2 caller

  data_type: 'text'
  is_nullable: 1

=head2 called

  data_type: 'text'
  is_nullable: 1

=head2 billid

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "uid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "direction",
  { data_type => "text", is_nullable => 1 },
  "status",
  { data_type => "text", is_nullable => 1 },
  "chan",
  { data_type => "text", is_nullable => 1 },
  "caller",
  { data_type => "text", is_nullable => 1 },
  "called",
  { data_type => "text", is_nullable => 1 },
  "billid",
  { data_type => "text", is_nullable => 1 },
);

=head1 RELATIONS

=head2 uid

Type: belongs_to

Related object: L<Dyatel::Schema::Users>

=cut

__PACKAGE__->belongs_to("uid", "Dyatel::Schema::Users", { id => "uid" });


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ffFPkMW9ArhynfH65yjEng


# You can replace this text with custom content, and it will be preserved on regeneration
1;
