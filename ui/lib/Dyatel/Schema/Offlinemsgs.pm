package Dyatel::Schema::Offlinemsgs;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("offlinemsgs");
__PACKAGE__->add_columns(
  "uid",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "ts",
  { data_type => "bigint", default_value => undef, is_nullable => 0, size => 8 },
  "msg",
  { data_type => "xml", default_value => undef, is_nullable => 0, size => undef },
);
__PACKAGE__->belongs_to("uid", "Dyatel::Schema::Users", { id => "uid" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-07-24 15:44:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:M2Fp+5gq9x/WpXAgtQUinA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
