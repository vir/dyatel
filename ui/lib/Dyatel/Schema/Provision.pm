use utf8;
package Dyatel::Schema::Provision;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Provision

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

=head1 TABLE: C<provision>

=cut

__PACKAGE__->table("provision");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'provision_id_seq'

=head2 uid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 hw

  data_type: 'macaddr'
  is_nullable: 1

=head2 devtype

  data_type: 'text'
  is_nullable: 1

=head2 params

  data_type: 'hstore'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "provision_id_seq",
  },
  "uid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "hw",
  { data_type => "macaddr", is_nullable => 1 },
  "devtype",
  { data_type => "text", is_nullable => 1 },
  "params",
  { data_type => "hstore", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 uid

Type: belongs_to

Related object: L<Dyatel::Schema::Users>

=cut

__PACKAGE__->belongs_to("uid", "Dyatel::Schema::Users", { id => "uid" });


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:C0DKdGs/gOoFcUr8bOjmIw

# Fix hstore column. This requires InflateColumn::Serializer component
__PACKAGE__->add_columns(
  "params",
  {
#    data_type => "hstore",
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
    serializer_class => 'Hstore',
    recursive_encode => 1, # (optional) 
  },
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
