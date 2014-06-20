use utf8;
package Dyatel::Schema::Subscriptions;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Subscriptions

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

=head1 TABLE: C<subscriptions>

=cut

__PACKAGE__->table("subscriptions");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'subscriptions_id_seq'

=head2 ts

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

=head2 notifier

  data_type: 'text'
  is_nullable: 0

=head2 subscriber

  data_type: 'text'
  is_nullable: 0

=head2 operation

  data_type: 'text'
  is_nullable: 0

=head2 data

  data_type: 'text'
  is_nullable: 1

=head2 notifyto

  data_type: 'text'
  is_nullable: 1

=head2 expires

  data_type: 'interval'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "subscriptions_id_seq",
  },
  "ts",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 1,
    original      => { default_value => \"now()" },
  },
  "notifier",
  { data_type => "text", is_nullable => 0 },
  "subscriber",
  { data_type => "text", is_nullable => 0 },
  "operation",
  { data_type => "text", is_nullable => 0 },
  "data",
  { data_type => "text", is_nullable => 1 },
  "notifyto",
  { data_type => "text", is_nullable => 1 },
  "expires",
  { data_type => "interval", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EEMtmfdZMytYXlYrjd7LUA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
