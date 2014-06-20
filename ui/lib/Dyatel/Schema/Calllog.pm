use utf8;
package Dyatel::Schema::Calllog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Calllog

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

=head1 TABLE: C<calllog>

=cut

__PACKAGE__->table("calllog");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'calllog_id_seq'

=head2 ts

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

=head2 billid

  data_type: 'text'
  is_nullable: 0

=head2 tag

  data_type: 'text'
  is_nullable: 1

=head2 uid

  data_type: 'integer'
  is_nullable: 1

=head2 value

  data_type: 'text'
  is_nullable: 1

=head2 params

  data_type: 'hstore'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "calllog_id_seq",
  },
  "ts",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 1,
    original      => { default_value => \"now()" },
  },
  "billid",
  { data_type => "text", is_nullable => 0 },
  "tag",
  { data_type => "text", is_nullable => 1 },
  "uid",
  { data_type => "integer", is_nullable => 1 },
  "value",
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


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 13:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YNtcwxaWWjA8T0tGbPCN9w

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
