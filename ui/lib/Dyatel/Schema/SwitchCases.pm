use utf8;
package Dyatel::Schema::SwitchCases;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::SwitchCases

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

=head1 TABLE: C<switch_cases>

=cut

__PACKAGE__->table("switch_cases");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'switch_cases_id_seq'

=head2 switch

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 value

  data_type: 'text'
  is_nullable: 1

=head2 route

  data_type: 'phone'
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
    sequence          => "switch_cases_id_seq",
  },
  "switch",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "value",
  { data_type => "text", is_nullable => 1 },
  "route",
  { data_type => "phone", is_nullable => 0 },
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

=head2 C<switch_cases_uniq_index>

=over 4

=item * L</switch>

=item * L</value>

=back

=cut

__PACKAGE__->add_unique_constraint("switch_cases_uniq_index", ["switch", "value"]);

=head1 RELATIONS

=head2 switch

Type: belongs_to

Related object: L<Dyatel::Schema::Switches>

=cut

__PACKAGE__->belongs_to("switch", "Dyatel::Schema::Switches", { id => "switch" });


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-11-06 11:51:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UYAspivXLFyOmG65qnnfkg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
