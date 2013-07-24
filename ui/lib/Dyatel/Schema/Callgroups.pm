package Dyatel::Schema::Callgroups;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("callgroups");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('callgroups_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "num",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "descr",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "distr",
  {
    data_type => "calldistribution",
    default_value => "'parallel'::calldistribution",
    is_nullable => 0,
    size => 4,
  },
  "rotary_last",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("callgroups_pkey", ["id"]);
__PACKAGE__->has_many(
  "callgrpmembers",
  "Dyatel::Schema::Callgrpmembers",
  { "foreign.grp" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-07-24 15:44:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0etNze7cnYcgqA2TxpHvzA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
