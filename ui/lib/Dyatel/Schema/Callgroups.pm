use utf8;
package Dyatel::Schema::Callgroups;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Callgroups

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

=head1 TABLE: C<callgroups>

=cut

__PACKAGE__->table("callgroups");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'callgroups_id_seq'

=head2 num

  data_type: 'phone'
  is_foreign_key: 1
  is_nullable: 0

=head2 distr

  data_type: 'enum'
  default_value: 'parallel'
  extra: {custom_type_name => "calldistribution",list => ["parallel","linear","rotary"]}
  is_nullable: 0

=head2 rotary_last

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 ringback

  data_type: 'text'
  is_nullable: 1

=head2 maxcall

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 exitpos

  data_type: 'phone'
  is_nullable: 1

=head2 queue

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "callgroups_id_seq",
  },
  "num",
  { data_type => "phone", is_foreign_key => 1, is_nullable => 0 },
  "distr",
  {
    data_type => "enum",
    default_value => "parallel",
    extra => {
      custom_type_name => "calldistribution",
      list => ["parallel", "linear", "rotary"],
    },
    is_nullable => 0,
  },
  "rotary_last",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "ringback",
  { data_type => "text", is_nullable => 1 },
  "maxcall",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "exitpos",
  { data_type => "phone", is_nullable => 1 },
  "queue",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<callgroups_num_index>

=over 4

=item * L</num>

=back

=cut

__PACKAGE__->add_unique_constraint("callgroups_num_index", ["num"]);

=head1 RELATIONS

=head2 callgrpmembers

Type: has_many

Related object: L<Dyatel::Schema::Callgrpmembers>

=cut

__PACKAGE__->has_many(
  "callgrpmembers",
  "Dyatel::Schema::Callgrpmembers",
  { "foreign.grp" => "self.id" },
  undef,
);

=head2 num

Type: belongs_to

Related object: L<Dyatel::Schema::Directory>

=cut

__PACKAGE__->belongs_to("num", "Dyatel::Schema::Directory", { num => "num" });

=head2 pickupgroups

Type: has_many

Related object: L<Dyatel::Schema::Pickupgroups>

=cut

__PACKAGE__->has_many(
  "pickupgroups",
  "Dyatel::Schema::Pickupgroups",
  { "foreign.callgrepcopy" => "self.id" },
  undef,
);

=head2 queue

Type: belongs_to

Related object: L<Dyatel::Schema::Queues>

=cut

__PACKAGE__->belongs_to("queue", "Dyatel::Schema::Queues", { id => "queue" });


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-11-06 11:44:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rzBxPJVfswCeTkM+HoqzPw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
