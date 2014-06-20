use utf8;
package Dyatel::Schema::Fingroups;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Fingroups

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

=head1 TABLE: C<fingroups>

=cut

__PACKAGE__->table("fingroups");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'fingroups_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 sortkey

  data_type: 'integer'
  default_value: 100
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "fingroups_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "sortkey",
  { data_type => "integer", default_value => 100, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 users

Type: has_many

Related object: L<Dyatel::Schema::Users>

=cut

__PACKAGE__->has_many(
  "users",
  "Dyatel::Schema::Users",
  { "foreign.fingrp" => "self.id" },
  undef,
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Vp+uRwXqUQtS96829v4hvw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
