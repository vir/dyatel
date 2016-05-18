package Dyatel::Model::FS::Avatars;
use Moose;
use namespace::autoclean;
use MooseX::Types::Moose qw/ArrayRef HashRef CodeRef Str ClassName/;
extends 'Catalyst::Model';
use Data::Dumper;

# Support configuration loading even when used from external script
my $cfg;
eval { $cfg = Dyatel->config->{'Model::FS::Avatars'}; }; # this succeeds if running inside Catalyst
if ($@) # otherwise if called from outside Catalyst try manual load of model configuration
{
	if(eval "require Dyatel::ExtConfig") {
		$cfg = Dyatel::ExtConfig::load()->{Model}{'FS::Avatars'};
	} else { # fallback
		die;
	}
}
__PACKAGE__->config( $cfg ); # put model parameters into main configuration

has fsdir => (is => 'rw', isa => Str, default => sub { my $r = ''; $r = Dyatel->config->{root} if Dyatel->can('config') && Dyatel->config && Dyatel->config->{root}; return $r.'/avatars' });
has webdir => (is => 'rw', isa => Str, default => '/avatars');

=head1 NAME

Dyatel::Model::FS::Avatars - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Vasily i. Redkin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub get
{
	my $self = shift;
	my($uid, $extended) = @_;
	my $fn = "/user_$uid.png";
	my $path = $self->fsdir.$fn;
	if($extended) {
		my $fn2 = "/user_$uid-new.png";
		my $path2 = $self->fsdir.$fn2;
		my $tail = '?'.time;
		my $r = { };
		if(-f $path) {
			$r->{old} = $self->webdir.$fn.$tail;
			$r->{oldts} = (stat(_))[9];
		} else {
			$r->{old} = undef;
		}
		if(-f $path2) {
			$r->{new} = $self->webdir.$fn2.$tail;
			$r->{newts} = (stat(_))[9];
		} else {
			$r->{new} = undef;
		}
		return $r;
	}
	return undef unless -f $path;
	return $self->webdir.$fn.'?'.(stat(_))[9];
}

sub savepath
{
	my $self = shift;
	my($uid) = @_;
	my $fn = "/user_$uid-new.png";
	return $self->fsdir.$fn;
}

# http://stackoverflow.com/questions/890925/how-can-i-resize-an-image-to-fit-area-with-imagemagick
sub set
{
	my $self = shift;
	my($uid, $path) = @_;
	if(eval "require Image::Magick") {
		my $image = Image::Magick->new;
		$image->read($path);

		$image->Set( Gravity => 'Center' );
		$image->Resize( geometry => '200x200^' );
		$image->Extent( geometry => '200x200' );
#		$image->Crop( geometry => '200x200+0+0' );
#		$image->Set( page=>'0x0+0+0' ); # equivalent to the +repage command-line option
		$image->Write( $self->savepath($uid) );
	} else {
		warn "No Image::Magick module - can not resize avatar!\n";
		eval "require File::Copy" or die;
		File::Copy::copy($path, $self->savepath($uid));
	}
	return 1;
}

sub replace
{
	my $self = shift;
	my($uid) = @_;
	my $path1 = $self->savepath($uid);
	my $path2 = $path1;
	$path2 =~ s/-new\././s;
	return rename $path1, $path2;
}

sub delete
{
	my $self = shift;
	my($uid) = @_;
	my $path = $self->savepath($uid);
	$path =~ s/-new\././s;
	warn "UNLINKING $path";
	return unlink $path;
}

__PACKAGE__->meta->make_immutable;

1;
