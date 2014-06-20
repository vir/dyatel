package Dyatel::Controller::A::Cdrs;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::A::Cdrs - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
		$c->response->redirect($c->uri_for($self->action_for('list')));
}

use Data::Dumper;

sub list :Local
{
	my($self, $c) = @_;
	my $opts = {
		page => $c->request->params->{page},
		rows => $c->request->params->{perpage} || 50,
		order_by => 'ts DESC'
	};
	my $where = {
		ts => { '>', '2013-11-18' },
	};
	unless(($c->request->params->{empty}||'') ne 'false') {
		$where->{billtime} = { '>', '1 s' };
	}
	if(($c->request->params->{phone}||'') =~ /^\s*(\S.*?)\s*$/) {
		my @p;
		foreach my $k(qw(caller called calledfull)) {
			push @p, { $k => { 'like', "%$1%" } };
		}
		$where->{'-or'} = \@p;
	}
	my($df, $dt) = ($c->request->params->{datefrom}, $c->request->params->{dateto});
	if($df || $dt) {
		my %p;
		$p{'>='} = $df if $df;
		$p{'<'} = $dt if $dt;
		$where->{ts} = \%p;
	}
	if($c->request->params->{billid}) {
		$where->{billid} = $c->request->params->{billid};
	}

	my $row = $c->model('DB::Cdr')->search($where, {
		columns => [qw/ /],
		'+select' => [{ MIN => 'id', -as => 'min' }, { MAX => 'id', -as => 'max' }],
		'+as' =>   [qw/ min max /],
	})->first();
#	$r->result_class('DBIx::Class::ResultClass::HashRefInflator');
	my $total = $row->get_column('max') - $row->get_column('min');

	$c->stash(rows => [$c->model('DB::Cdr')->search($where, $opts)], totalrows => $total, template => 'cdrs/list.tt');
}

sub calllog :Local :Args(1)
{
	my($self, $c, $billid) = @_;
	my $s = $c->model('DB::CallLog')->search({billid => $billid}, {columns => [qw/ id ts uid tag value /], order_by => [qw/ts/]});
	$c->stash(rows => [$s->all]);
}

=encoding utf8

=head1 AUTHOR

Vasily i. Redkin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
