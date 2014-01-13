package Dyatel;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple
		StackTrace
		Unicode
		Authentication
/;

extends 'Catalyst';

our $VERSION = '0.01';

use Log::Any::Adapter;

# Configure the application.
#
# Note that settings in dyatel.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'Dyatel',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
);

# Enable UTF-8 in config file
__PACKAGE__->config( 'Plugin::ConfigLoader' => {
	driver => {
		'General' => { -UTF8 => 1 },
	}
} );

# Set unicode HTML output
__PACKAGE__->config( 'View::HTML' => {
	ENCODING => 'UTF-8',
} );

# Limit JSON output
#__PACKAGE__->config( 'View::JSON' => {
#		expose_stash => 'json' 
#} );

__PACKAGE__->config(
	'Plugin::Authentication' => {
		default_realm => 'remoterealm',
		realms => {
			remoterealm => {
				credential => { class => 'Remote' },
				store => { class => 'Null' }
			},
		},
	},
);

# Start the application
__PACKAGE__->setup();

# Prepare logger to be used in models
Log::Any::Adapter->set('Catalyst', logger => __PACKAGE__->log);

if($ENV{TEST_AUTH_USER}) {
	require Dyatel::TestAuth;
	Dyatel::TestAuth->meta->apply(__PACKAGE__->engine);
}

=head1 NAME

Dyatel - Catalyst based application

=head1 SYNOPSIS

    script/dyatel_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Dyatel::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Vasily i. Redkin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# Dirty hack to fix JSON serialization
package DBIx::Class;

use Data::Dumper;
sub TO_JSON {
	my $self = shift;
	unless($self->can('get_inflated_columns') && $self->can('columns')) {
		my $copy;
		$copy = sub {
			my($x) = @_;
			if(! ref($x)) {
				return $x;
			} elsif(ref($x) eq 'ARRAY') {
				my $r;
				foreach my $e(@$x) {
					push @$r, $copy->($e);
				}
				return $r;
			} elsif(ref($x) eq 'HASH') {
				my $r;
				foreach my $k(keys %$x) {
					$r->{$k} = $copy->($x->{$k});
				}
				return $r;
			}
		};
		my $r = $copy->($self);
#		print "TO_JSON: ".Dumper($r);
		return $r;
	}
	my $r = { $self->get_inflated_columns };
	foreach my $k($self->columns()) {
		next unless defined $r->{$k};
		my $inf = $self->column_info($k);
		if($inf->{data_type} eq "boolean") {
			$r->{$k} = \( $r->{$k} ? 1 : 0 );
		}
	}
	return $r;
}

1;


