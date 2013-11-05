package Dyatel::Schema::Cdr;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("cdr");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "bigint",
    default_value => "nextval('cdr_id_seq'::regclass)",
    is_nullable => 0,
    size => 8,
  },
  "ts",
  {
    data_type => "timestamp with time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "chan",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "address",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "direction",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "billid",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "caller",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "called",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "duration",
  {
    data_type => "interval",
    default_value => undef,
    is_nullable => 1,
    size => 16,
  },
  "billtime",
  {
    data_type => "interval",
    default_value => undef,
    is_nullable => 1,
    size => 16,
  },
  "ringtime",
  {
    data_type => "interval",
    default_value => undef,
    is_nullable => 1,
    size => 16,
  },
  "status",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "reason",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "ended",
  { data_type => "boolean", default_value => undef, is_nullable => 1, size => 1 },
  "callid",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("cdr_pkey", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-11-05 11:30:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FYnkZkZVYj/GXuweUqP4lw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
