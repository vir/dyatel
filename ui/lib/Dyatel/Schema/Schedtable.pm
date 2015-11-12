use utf8;
package Dyatel::Schema::Schedtable;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Schedtable

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

=head1 TABLE: C<schedtable>

=cut

__PACKAGE__->table("schedtable");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'schedule_id_seq'

=head2 prio

  data_type: 'integer'
  default_value: 100
  is_nullable: 0

=head2 mday

  data_type: 'date'
  is_nullable: 1

=head2 days

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 dow

  data_type: 'smallint[]'
  default_value: '{0,1,2,3,4,5,6}'::smallint[]
  is_nullable: 0

=head2 tstart

  data_type: 'time'
  is_nullable: 0

=head2 tend

  data_type: 'time'
  is_nullable: 0

=head2 mode

  data_type: 'text'
  is_nullable: 0

=head2 schedule

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "schedule_id_seq",
  },
  "prio",
  { data_type => "integer", default_value => 100, is_nullable => 0 },
  "mday",
  { data_type => "date", is_nullable => 1 },
  "days",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "dow",
  {
    data_type     => "smallint[]",
    default_value => \"'{0,1,2,3,4,5,6}'::smallint[]",
    is_nullable   => 0,
  },
  "tstart",
  { data_type => "time", is_nullable => 0 },
  "tend",
  { data_type => "time", is_nullable => 0 },
  "mode",
  { data_type => "text", is_nullable => 0 },
  "schedule",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 schedule

Type: belongs_to

Related object: L<Dyatel::Schema::Schedules>

=cut

__PACKAGE__->belongs_to("schedule", "Dyatel::Schema::Schedules", { id => "schedule" });


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-11-10 16:14:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AHSgEDvyu7QklI6JSF+e9g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
