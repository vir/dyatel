package Dyatel::View::HTML;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
# Set to 1 for detailed timer stats in your HTML as comments
    TIMER              => 1,
# This is your wrapper template located in the 'root/src'
    WRAPPER => 'wrapper.tt',
);

=head1 NAME

Dyatel::View::HTML - TT View for Dyatel

=head1 DESCRIPTION

TT View for Dyatel.

=head1 SEE ALSO

L<Dyatel>

=head1 AUTHOR

Vasily i. Redkin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
