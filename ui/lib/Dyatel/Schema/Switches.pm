use utf8;
package Dyatel::Schema::Switches;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Switches

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

=head1 TABLE: C<switches>

=cut

__PACKAGE__->table("switches");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'switches_id_seq'

=head2 num

  data_type: 'phone'
  is_foreign_key: 1
  is_nullable: 0

=head2 param

  data_type: 'text'
  is_nullable: 0

=head2 arg

  data_type: 'text'
  is_nullable: 1

=head2 defroute

  data_type: 'phone'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "switches_id_seq",
  },
  "num",
  { data_type => "phone", is_foreign_key => 1, is_nullable => 0 },
  "param",
  { data_type => "text", is_nullable => 0 },
  "arg",
  { data_type => "text", is_nullable => 1 },
  "defroute",
  { data_type => "phone", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 num

Type: belongs_to

Related object: L<Dyatel::Schema::Directory>

=cut

__PACKAGE__->belongs_to("num", "Dyatel::Schema::Directory", { num => "num" });

=head2 switch_cases

Type: has_many

Related object: L<Dyatel::Schema::SwitchCases>

=cut

__PACKAGE__->has_many(
  "switch_cases",
  "Dyatel::Schema::SwitchCases",
  { "foreign.switch" => "self.id" },
  undef,
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-11-06 11:51:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pZO2X1+WYmHa2JYE9bKZXA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
