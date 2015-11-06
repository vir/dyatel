use utf8;
package Dyatel::Schema::Queuestats;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Queuestats

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

=head1 TABLE: C<queuestats>

=cut

__PACKAGE__->table("queuestats");

=head1 ACCESSORS

=head2 q

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 ts

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 required

  data_type: 'integer'
  is_nullable: 1

=head2 cur

  data_type: 'integer'
  is_nullable: 1

=head2 waiting

  data_type: 'integer'
  is_nullable: 1

=head2 found

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "q",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "ts",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "required",
  { data_type => "integer", is_nullable => 1 },
  "cur",
  { data_type => "integer", is_nullable => 1 },
  "waiting",
  { data_type => "integer", is_nullable => 1 },
  "found",
  { data_type => "integer", is_nullable => 1 },
);

=head1 RELATIONS

=head2 q

Type: belongs_to

Related object: L<Dyatel::Schema::Queues>

=cut

__PACKAGE__->belongs_to("q", "Dyatel::Schema::Queues", { id => "q" });


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-11-06 11:51:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:U1gv0hbIH/ssTA1TDAB+AA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
