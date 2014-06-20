use utf8;
package Dyatel::Schema::Users;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dyatel::Schema::Users

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

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'users_id_seq'

=head2 num

  data_type: 'phone'
  is_foreign_key: 1
  is_nullable: 0

=head2 alias

  data_type: 'text'
  is_nullable: 1

=head2 domain

  data_type: 'text'
  is_nullable: 0

=head2 password

  data_type: 'text'
  is_nullable: 0

=head2 lastreg

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 lastip

  data_type: 'inet'
  is_nullable: 1

=head2 nat_support

  data_type: 'boolean'
  is_nullable: 1

=head2 nat_port_support

  data_type: 'boolean'
  is_nullable: 1

=head2 media_bypass

  data_type: 'boolean'
  default_value: false
  is_nullable: 1

=head2 dispname

  data_type: 'text'
  is_nullable: 1

=head2 login

  data_type: 'text'
  is_nullable: 1

=head2 badges

  data_type: 'text[]'
  default_value: '{}'::text[]
  is_nullable: 0

=head2 fingrp

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 secure

  data_type: 'enum'
  default_value: 'ssl'
  extra: {custom_type_name => "encription_mode",list => ["off","on","ssl"]}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "users_id_seq",
  },
  "num",
  { data_type => "phone", is_foreign_key => 1, is_nullable => 0 },
  "alias",
  { data_type => "text", is_nullable => 1 },
  "domain",
  { data_type => "text", is_nullable => 0 },
  "password",
  { data_type => "text", is_nullable => 0 },
  "lastreg",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "lastip",
  { data_type => "inet", is_nullable => 1 },
  "nat_support",
  { data_type => "boolean", is_nullable => 1 },
  "nat_port_support",
  { data_type => "boolean", is_nullable => 1 },
  "media_bypass",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
  "dispname",
  { data_type => "text", is_nullable => 1 },
  "login",
  { data_type => "text", is_nullable => 1 },
  "badges",
  {
    data_type     => "text[]",
    default_value => \"'{}'::text[]",
    is_nullable   => 0,
  },
  "fingrp",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "secure",
  {
    data_type => "enum",
    default_value => "ssl",
    extra => { custom_type_name => "encription_mode", list => ["off", "on", "ssl"] },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<users_num_index>

=over 4

=item * L</num>

=back

=cut

__PACKAGE__->add_unique_constraint("users_num_index", ["num"]);

=head1 RELATIONS

=head2 abbrs

Type: has_many

Related object: L<Dyatel::Schema::Abbrs>

=cut

__PACKAGE__->has_many(
  "abbrs",
  "Dyatel::Schema::Abbrs",
  { "foreign.owner" => "self.id" },
  undef,
);

=head2 blfs

Type: has_many

Related object: L<Dyatel::Schema::Blfs>

=cut

__PACKAGE__->has_many(
  "blfs",
  "Dyatel::Schema::Blfs",
  { "foreign.uid" => "self.id" },
  undef,
);

=head2 fingrp

Type: belongs_to

Related object: L<Dyatel::Schema::Fingroups>

=cut

__PACKAGE__->belongs_to("fingrp", "Dyatel::Schema::Fingroups", { id => "fingrp" });

=head2 linetrackers

Type: has_many

Related object: L<Dyatel::Schema::Linetracker>

=cut

__PACKAGE__->has_many(
  "linetrackers",
  "Dyatel::Schema::Linetracker",
  { "foreign.uid" => "self.id" },
  undef,
);

=head2 morenums

Type: has_many

Related object: L<Dyatel::Schema::Morenums>

=cut

__PACKAGE__->has_many(
  "morenums",
  "Dyatel::Schema::Morenums",
  { "foreign.uid" => "self.id" },
  undef,
);

=head2 num

Type: belongs_to

Related object: L<Dyatel::Schema::Directory>

=cut

__PACKAGE__->belongs_to("num", "Dyatel::Schema::Directory", { num => "num" });

=head2 offlinemsgs

Type: has_many

Related object: L<Dyatel::Schema::Offlinemsgs>

=cut

__PACKAGE__->has_many(
  "offlinemsgs",
  "Dyatel::Schema::Offlinemsgs",
  { "foreign.uid" => "self.id" },
  undef,
);

=head2 phonebooks

Type: has_many

Related object: L<Dyatel::Schema::Phonebook>

=cut

__PACKAGE__->has_many(
  "phonebooks",
  "Dyatel::Schema::Phonebook",
  { "foreign.owner" => "self.id" },
  undef,
);

=head2 pickupgrpmembers

Type: has_many

Related object: L<Dyatel::Schema::Pickupgrpmembers>

=cut

__PACKAGE__->has_many(
  "pickupgrpmembers",
  "Dyatel::Schema::Pickupgrpmembers",
  { "foreign.uid" => "self.id" },
  undef,
);

=head2 privdatas

Type: has_many

Related object: L<Dyatel::Schema::Privdata>

=cut

__PACKAGE__->has_many(
  "privdatas",
  "Dyatel::Schema::Privdata",
  { "foreign.uid" => "self.id" },
  undef,
);

=head2 provisions

Type: has_many

Related object: L<Dyatel::Schema::Provision>

=cut

__PACKAGE__->has_many(
  "provisions",
  "Dyatel::Schema::Provision",
  { "foreign.uid" => "self.id" },
  undef,
);

=head2 regs

Type: has_many

Related object: L<Dyatel::Schema::Regs>

=cut

__PACKAGE__->has_many(
  "regs",
  "Dyatel::Schema::Regs",
  { "foreign.userid" => "self.id" },
  undef,
);

=head2 rosters

Type: has_many

Related object: L<Dyatel::Schema::Roster>

=cut

__PACKAGE__->has_many(
  "rosters",
  "Dyatel::Schema::Roster",
  { "foreign.uid" => "self.id" },
  undef,
);

=head2 sessions

Type: has_many

Related object: L<Dyatel::Schema::Sessions>

=cut

__PACKAGE__->has_many(
  "sessions",
  "Dyatel::Schema::Sessions",
  { "foreign.uid" => "self.id" },
  undef,
);

=head2 vcards

Type: has_many

Related object: L<Dyatel::Schema::Vcards>

=cut

__PACKAGE__->has_many(
  "vcards",
  "Dyatel::Schema::Vcards",
  { "foreign.uid" => "self.id" },
  undef,
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-20 14:13:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yRsGo4Jf02Z+Z4AKT+nA9A

__PACKAGE__->belongs_to("fingrp", "Dyatel::Schema::Fingroups", { id => "fingrp" }, { join_type => 'left' });

1;
