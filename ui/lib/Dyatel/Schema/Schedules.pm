use utf8;
package Dyatel::Schema::Schedules;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Schedules

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

=head1 TABLE: C<schedules>

=cut

__PACKAGE__->table("schedules");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'schedules_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 comments

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "schedules_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "comments",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<schedules_name_index>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("schedules_name_index", ["name"]);

=head1 RELATIONS

=head2 schedtables

Type: has_many

Related object: L<Dyatel::Schema::Schedtable>

=cut

__PACKAGE__->has_many(
  "schedtables",
  "Dyatel::Schema::Schedtable",
  { "foreign.schedule" => "self.id" },
  undef,
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-11-10 16:14:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:iutK957TyO9wDNtZTA4abQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
