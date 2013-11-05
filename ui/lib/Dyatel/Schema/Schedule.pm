package Dyatel::Schema::Schedule;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("schedule");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('schedule_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "prio",
  { data_type => "integer", default_value => 100, is_nullable => 0, size => 4 },
  "mday",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
  "days",
  { data_type => "integer", default_value => 1, is_nullable => 0, size => 4 },
  "dow",
  {
    data_type => "smallint[]",
    default_value => "'{0,1,2,3,4,5,6}'::smallint[]",
    is_nullable => 0,
    size => undef,
  },
  "tstart",
  {
    data_type => "time without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "tend",
  {
    data_type => "time without time zone",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "mode",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("schedule_pkey", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-11-05 11:30:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:k/PcGW+CaVNzqrfJrvkzGA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
