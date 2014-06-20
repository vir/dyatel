use utf8;
package Dyatel::Schema::Nextprevusers;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Nextprevusers

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
__PACKAGE__->table_class("DBIx::Class::ResultSource::View");

=head1 TABLE: C<nextprevusers>

=cut

__PACKAGE__->table("nextprevusers");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 1

=head2 num

  data_type: 'phone'
  is_nullable: 1

=head2 next

  data_type: 'integer'
  is_nullable: 1

=head2 prev

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 1 },
  "num",
  { data_type => "phone", is_nullable => 1 },
  "next",
  { data_type => "integer", is_nullable => 1 },
  "prev",
  { data_type => "integer", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 14:13:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:R1HIXpBpy0AMXoe4RiJCYA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
