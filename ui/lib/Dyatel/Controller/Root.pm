package Dyatel::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Dyatel::Controller::Root - Root Controller for Dyatel

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path Args(0)
{
	my( $self, $c ) = @_;
	$c->stash(template => 'root.tt', no_wrapper => 1);
}

sub auto : Private {
	my ( $self, $c ) = @_;
	unless ($c->user_exists) {
		unless ($c->authenticate( {} )) {
			$c->response->status(403);
			$c->response->body('Unauthorized');
			return 0;
		}
	}
	return 1;
}

#use Data::Dumper;
#sub env :Local
#{
#	my ( $self, $c ) = @_;
#	$c->res->headers->header("Content-type"=> 'text/plain');
#	my $req = $c->req;
#	$c->response->body(
#		'$c->engine->env is : '.Dumper($c->engine->env)
#		."c->req is $req\n"
#		.'c->config is ' .Dumper($c->config)
#		."\nENV is : ".Dumper(\%ENV)
#	);
#}


=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
	my($self, $c) = @_;
# Accept: application/json
	if(($c->request->header('Accept')||'') =~ /\bapplication\/json\b/
			or ($c->req->param('o')||'') eq 'json') {
		$c->stash(current_view => 'JSON');
	}
}

=head1 AUTHOR

Vasily i. Redkin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
