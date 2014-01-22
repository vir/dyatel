package Dyatel::Schema::IvrMinidisa;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("ivr_minidisa");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('ivr_minidisa_id_seq'::regclass)",
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
  "prompt",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "timeout",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "numlen",
  { data_type => "integer", default_value => 3, is_nullable => 0, size => 4 },
  "firstdigit",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 12,
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
__PACKAGE__->add_unique_constraint("ivr_minidisa_pkey", ["id"]);
__PACKAGE__->belongs_to("num", "Dyatel::Schema::Directory", { num => "num" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2014-01-19 02:26:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/bRPLXEHX2T5mWwqU+RjQA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
