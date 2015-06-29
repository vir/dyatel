package Dyatel::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';
use Log::Any qw($log);

# Support configuration loading even when used from external script
my $cfg;
eval { $cfg = Dyatel->config->{'Model::DB'}; }; # this succeeds if running inside Catalyst
if ($@) # otherwise if called from outside Catalyst try manual load of model configuration
{
	if(eval "require Dyatel::ExtConfig") {
		$cfg = Dyatel::ExtConfig::load()->{Model}{DB};
	} else { # fallback
		$cfg = {
			schema_class => 'Dyatel::Schema',
			connect_info => {
				dsn => 'dbi:Pg:dbname=dyatel',
				user => 'dyatel',
				password => '',
			},
		};
	}
}
$cfg->{schema_class} ||= 'Dyatel::Schema';
__PACKAGE__->config( $cfg ); # put model parameters into main configuration


sub xsearch
{
	my $self = shift;
	my($q, $opts) = @_;
	my $storage = $self->storage;
	return $storage->dbh_do(sub {
		my $self = shift;
		my $dbh = shift;
		my @selects;
		push @selects, q"SELECT 'directory' AS src, num, descr, numtype AS numkind FROM directory WHERE descr ILIKE $1 OR num ILIKE $1" if $opts->{loc};
		push @selects, q"SELECT 'users' AS src, d.num, d.descr, 'local' AS numkind FROM users u INNER JOIN directory d ON d.num = u.num WHERE alias ILIKE $1 OR login ILIKE $1 OR dispname ILIKE $1" if $opts->{loc};
		push @selects, q"SELECT 'users' AS src, m.val AS num, d.descr, LOWER(COALESCE(k.tag, k.descr)) AS numkind FROM users u INNER JOIN morenums m ON m.uid = u.id INNER JOIN numkinds k ON k.id = m.numkind INNER JOIN directory d ON d.num = u.num WHERE d.descr ILIKE $1 OR d.num ILIKE $1 OR alias ILIKE $1 OR login ILIKE $1 OR dispname ILIKE $1 OR m.val ILIKE $1 OR m.descr ILIKE $1" if $opts->{more};
		push @selects, q"SELECT 'cpb' AS src, p.num, p.descr, LOWER(COALESCE(k.tag, k.descr)) AS numkind FROM phonebook p INNER JOIN numkinds k ON k.id = p.numkind WHERE owner IS NULL AND (p.descr ILIKE $1 OR p.num ILIKE $1)" if $opts->{com};
		push @selects, q"SELECT 'ppb' AS src, p.num, p.descr, LOWER(COALESCE(k.tag, k.descr)) AS numkind FROM phonebook p INNER JOIN numkinds k ON k.id = p.numkind WHERE owner = ".$opts->{uid}.q" AND (p.descr ILIKE $1 OR p.num ILIKE $1)" if $opts->{pvt};
		return [ ] unless @selects;
		my $sql = join(' UNION ', @selects)." ORDER BY num;";
    $log->debug("Search SQL: $sql, arg: <<$q>>");
		my $sth = $dbh->prepare($sql);
		$sth->execute("%$q%");
		my $r = $sth->fetchall_arrayref( { } ); # note empty hash ref - makes array of hashes
		return $r;
	});
}

sub xinfo
{
	my $self = shift;
	my($q, $opts) = @_;
	my $storage = $self->storage;
	return $storage->dbh_do(sub {
		my $self = shift;
		my $dbh = shift;
		my @selects;
		push @selects, q"SELECT 'directory' AS src, d.num, d.descr, d.numtype AS numkind, u.id AS uid FROM directory d LEFT JOIN users u ON u.num = d.num WHERE d.num = $1";
		push @selects, q"SELECT 'morenums' AS src, m.val AS num, d.descr, LOWER(COALESCE(k.tag, k.descr)) AS numkind, u.id AS uid FROM users u INNER JOIN morenums m ON m.uid = u.id INNER JOIN numkinds k ON k.id = m.numkind INNER JOIN directory d ON d.num = u.num WHERE normalize_num(m.val) = normalize_num($1)";
		push @selects, q"SELECT 'cpb' AS src, p.num, p.descr, LOWER(COALESCE(k.tag, k.descr)) AS numkind, NULL AS uid FROM phonebook p INNER JOIN numkinds k ON k.id = p.numkind WHERE owner IS NULL AND p.num = $1";
		push @selects, q"SELECT 'ppb' AS src, p.num, p.descr, LOWER(COALESCE(k.tag, k.descr)) AS numkind, NULL AS uid FROM phonebook p INNER JOIN numkinds k ON k.id = p.numkind WHERE owner = ".$opts->{uid}.' AND p.num = $1';
		my $sql = join(' UNION ', @selects)." ORDER BY num;";
    $log->debug("Search SQL: $sql, arg: <<$q>>");
		my $sth = $dbh->prepare($sql);
		$sth->execute($q);
		my $r = $sth->fetchall_arrayref( { } ); # note empty hash ref - makes array of hashes
		return $r;
	});
}

sub dir_conflict
{
	my $self = shift;
	my($num) = @_;
	return $self->storage->dbh_do(sub {
		my $self = shift;
		my $dbh = shift;
		my $r = $dbh->selectrow_array('SELECT directory_check_num(?);', undef, $num);
		return $r;
	});
}

sub user_blfs
{
	my $self = shift;
	my($uid) = @_;
	my $sql = << '***';
SELECT b.key, b.num, b.label, u.id AS uid, d.numtype AS dirtype, d.descr AS dirdescr, COALESCE(status_num(b.num), 'unknown') AS status
	FROM blfs b
		LEFT JOIN users u ON u.num = b.num
		LEFT JOIN directory d ON d.num = b.num
	WHERE b.uid = ? ORDER BY CASE WHEN b.key ~ '^[0-9]+$' THEN to_char(b.key::INTEGER, '099') ELSE b.key END;
***
	return $self->storage->dbh_do(sub {
		my $self = shift;
		my $dbh = shift;
		my $r = $dbh->selectall_arrayref($sql, { Slice => {} }, $uid);
		return $r;
	});
}

sub num_status
{
	my $self = shift;
	my($num) = @_;
	return $self->storage->dbh_do(sub {
		my $self = shift;
		my $dbh = shift;
		return $dbh->selectrow_hashref("SELECT * FROM status_num2(?);", undef, $num);
	});
}

sub notify
{
	my $self = shift;
	my($name, $payload) = @_;
	return $self->storage->dbh_do(sub { shift; return shift->do("NOTIFY $name, ?", undef, $payload); });
}

=head1 NAME

Dyatel::Model::DB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<Dyatel>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<Dyatel::Schema>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.61

=head1 AUTHOR

Vasily i. Redkin

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
