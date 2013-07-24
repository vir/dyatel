package Dyatel::Schema::Subscriptions;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("subscriptions");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "bigint",
    default_value => "nextval('subscriptions_id_seq'::regclass)",
    is_nullable => 0,
    size => 8,
  },
  "ts",
  {
    data_type => "timestamp with time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
  "notifier",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "subscriber",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "operation",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "data",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "notifyto",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "expires",
  {
    data_type => "interval",
    default_value => undef,
    is_nullable => 1,
    size => 16,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("subscriptions_pkey", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-07-24 15:44:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xD0TONAtj2p9jyNdOuAEqQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
