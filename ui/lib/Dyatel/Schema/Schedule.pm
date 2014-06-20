use utf8;
package Dyatel::Schema::Schedule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Schedule

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

=head1 TABLE: C<schedule>

=cut

__PACKAGE__->table("schedule");

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
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QxpaZGQZD6b1EE3NUjnHRA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
