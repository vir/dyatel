package Dyatel::Schema::Vcards;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->table("vcards");
__PACKAGE__->add_columns(
  "uid",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "vcard",
  { data_type => "xml", default_value => undef, is_nullable => 1, size => undef },
);
__PACKAGE__->belongs_to("uid", "Dyatel::Schema::Users", { id => "uid" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-10-23 21:35:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xpqOMqb25gMyUdGG+5qPmw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
