package Dyatel::Schema::IvrAa;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("ivr_aa");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('ivr_aa_id_seq'::regclass)",
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
  "prompt",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "timeout",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "e0",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "e1",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "e2",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "e3",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "e4",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "e5",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "e6",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "e7",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "e8",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "e9",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "estar",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "ehash",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "etimeout",
  {
    data_type => "phone",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("ivr_aa_pkey", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-10-23 21:35:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Qgef+P9X7qPJ4RFsZ8I4aQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
