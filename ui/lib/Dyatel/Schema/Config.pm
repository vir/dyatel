use utf8;
package Dyatel::Schema::Config;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Config

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

=head1 TABLE: C<config>

=cut

__PACKAGE__->table("config");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'config_id_seq'

=head2 section

  data_type: 'text'
  is_nullable: 0

=head2 params

  data_type: 'hstore'
  is_nullable: 0

=head2 ts

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 uid

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "config_id_seq",
  },
  "section",
  { data_type => "text", is_nullable => 0 },
  "params",
  { data_type => "hstore", is_nullable => 0 },
  "ts",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "uid",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<config_section_index>

=over 4

=item * L</section>

=back

=cut

__PACKAGE__->add_unique_constraint("config_section_index", ["section"]);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nYEthebFqAwzhNXiSdbtKw

__PACKAGE__->add_columns(
  "params",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
    serializer_class => 'Hstore',
    recursive_encode => 1, # (optional) 
  },
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
