package Dyatel::Controller::U::CDR;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dyatel::Controller::U::CDR - Catalyst Controller

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

sub list :Local Args(1)
{
	my($self, $c, $filter) = @_;
	my $opts = {
		columns => [qw/ id ts direction billid caller called duration billtime ringtime status reason ended calledfull /],
#		columns => [qw/ id ts chan address direction billid caller called duration billtime ringtime status reason ended callid calledfull /],
		order_by => 'ts DESC'
	};
	my $num = $c->{stash}->{unum};
	my %filters = (
		all => {
			-or => [
				-and => [
					caller => $num,
					direction => 'incoming',
				],
				-and => [
					-or => [
						called => $num,
						calledfull => $num,
					],
					direction => 'outgoing',
				],
			],
		},
		missed => {
			-or => [
				called => $num,
				calledfull => $num,
			],
			direction => 'outgoing',
			status => 'ringing',
			reason => 'hangup',
		},
		answered => {
			-or => [
				called => $num,
				calledfull => $num,
			],
			direction => 'outgoing',
			status => 'answered',
		},
		outgoing => {
			caller => $num,
			direction => 'incoming',
			-not => {
				billtime => '0s',
				status => 'rejected',
			},
		},
	);
	my $where = $filters{$filter} || $filters{all};

	warn "whene now: ".Dumper($where);
# apply more filters
#	unless(($c->request->params->{empty}||'') ne 'false') {
#		$where->{billtime} = { '>', '1 s' };
#	}
#	if(($c->request->params->{phone}||'') =~ /^\s*(\S.*?)\s*$/) {
#		my @p;
#		foreach my $k(qw(caller called calledfull)) {
#			push @p, { $k => { 'like', "%$1%" } };
#		}
#		$where->{'-or'} = \@p;
#	}
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

	warn "whene final: ".Dumper($where);

	if($c->request->params->{page}) {
		$opts->{page} = $c->request->params->{page};
		$opts->{rows} = $c->request->params->{perpage} || 50;

		my $row = $c->model('DB::Cdr')->search($where, {
			columns => [qw/ /],
			'+select' => [{ MIN => 'id', -as => 'min' }, { MAX => 'id', -as => 'max' }],
			'+as' =>   [qw/ min max /],
		})->first();
		my $total = ($row->get_column('max')||0) - ($row->get_column('min')||0);
		$c->stash(totalrows => $total);
	} else {
		$opts->{rows} = $c->request->params->{limit} || 50;
	}

	$c->stash(rows => [$c->model('DB::Cdr')->search($where, $opts)]);
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






