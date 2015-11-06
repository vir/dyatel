use utf8;
package Dyatel::Schema::Queues;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Queues

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

=head1 TABLE: C<queues>

=cut

__PACKAGE__->table("queues");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'queues_id_seq'

=head2 mintime

  data_type: 'integer'
  default_value: 500
  is_nullable: 1

=head2 length

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 maxout

  data_type: 'integer'
  default_value: -1
  is_nullable: 1

=head2 greeting

  data_type: 'text'
  is_nullable: 1

=head2 onhold

  data_type: 'text'
  is_nullable: 1

=head2 maxcall

  data_type: 'integer'
  is_nullable: 1

=head2 prompt

  data_type: 'text'
  is_nullable: 1

=head2 notify

  data_type: 'text'
  is_nullable: 1

=head2 detail

  data_type: 'boolean'
  default_value: true
  is_nullable: 1

=head2 single

  data_type: 'boolean'
  default_value: false
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "queues_id_seq",
  },
  "mintime",
  { data_type => "integer", default_value => 500, is_nullable => 1 },
  "length",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "maxout",
  { data_type => "integer", default_value => -1, is_nullable => 1 },
  "greeting",
  { data_type => "text", is_nullable => 1 },
  "onhold",
  { data_type => "text", is_nullable => 1 },
  "maxcall",
  { data_type => "integer", is_nullable => 1 },
  "prompt",
  { data_type => "text", is_nullable => 1 },
  "notify",
  { data_type => "text", is_nullable => 1 },
  "detail",
  { data_type => "boolean", default_value => \"true", is_nullable => 1 },
  "single",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 callgroups

Type: has_many

Related object: L<Dyatel::Schema::Callgroups>

=cut

__PACKAGE__->has_many(
  "callgroups",
  "Dyatel::Schema::Callgroups",
  { "foreign.queue" => "self.id" },
  undef,
);

=head2 queuestats

Type: has_many

Related object: L<Dyatel::Schema::Queuestats>

=cut

__PACKAGE__->has_many(
  "queuestats",
  "Dyatel::Schema::Queuestats",
  { "foreign.q" => "self.id" },
  undef,
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-11-06 11:51:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CfaeyDbIF+zM4adQyu42Ig


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
