use utf8;
package Dyatel::Schema::Cdr;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Cdr

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

=head1 TABLE: C<cdr>

=cut

__PACKAGE__->table("cdr");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'cdr_id_seq'

=head2 ts

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 chan

  data_type: 'text'
  is_nullable: 1

=head2 address

  data_type: 'text'
  is_nullable: 1

=head2 direction

  data_type: 'text'
  is_nullable: 1

=head2 billid

  data_type: 'text'
  is_nullable: 1

=head2 caller

  data_type: 'text'
  is_nullable: 1

=head2 called

  data_type: 'text'
  is_nullable: 1

=head2 duration

  data_type: 'interval'
  is_nullable: 1

=head2 billtime

  data_type: 'interval'
  is_nullable: 1

=head2 ringtime

  data_type: 'interval'
  is_nullable: 1

=head2 status

  data_type: 'text'
  is_nullable: 1

=head2 reason

  data_type: 'text'
  is_nullable: 1

=head2 ended

  data_type: 'boolean'
  is_nullable: 1

=head2 callid

  data_type: 'text'
  is_nullable: 1

=head2 calledfull

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "cdr_id_seq",
  },
  "ts",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "chan",
  { data_type => "text", is_nullable => 1 },
  "address",
  { data_type => "text", is_nullable => 1 },
  "direction",
  { data_type => "text", is_nullable => 1 },
  "billid",
  { data_type => "text", is_nullable => 1 },
  "caller",
  { data_type => "text", is_nullable => 1 },
  "called",
  { data_type => "text", is_nullable => 1 },
  "duration",
  { data_type => "interval", is_nullable => 1 },
  "billtime",
  { data_type => "interval", is_nullable => 1 },
  "ringtime",
  { data_type => "interval", is_nullable => 1 },
  "status",
  { data_type => "text", is_nullable => 1 },
  "reason",
  { data_type => "text", is_nullable => 1 },
  "ended",
  { data_type => "boolean", is_nullable => 1 },
  "callid",
  { data_type => "text", is_nullable => 1 },
  "calledfull",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GvRf6KeUmn4Zu+gn7U7VgA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
