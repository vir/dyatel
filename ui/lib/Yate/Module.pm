package Yate::Module;
use utf8;
use strict;
use warnings;
use Carp;
use Yate;
use constant HANDLER_KEY => ' ';
use constant DEBUG => $ENV{YATE_MODULE_DEBUG};

sub new
{
	my $class = shift;
	my($yate, $name) = @_;
	($name = $0) =~ s/^.*[\/\\](.*?)(?:\.pl)?$/$1/is unless $name;
	$yate = Yate->new() unless $yate;
	$yate->setlocal('scriptname', $name);
	$yate->setlocal('trackparam', $name);
	my $self = bless { YATE => $yate, NAME => $name, PRIO => { } }, $class;
	$self->{handlers} = {
		command => sub { $self->_on_engine_command(@_) },
	};
	$self->{commands} = { };
	return $self;
}

sub yate { return shift->{YATE} }
sub name { return shift->{NAME} }
sub priority { my $self = shift; my($which) = @_; return $self->{PRIO}{$which} || 200; }
sub _to_boolean
{
	my($string, $default) = @_;
	if(defined $string) {
		my @str_false = ( "false", "no",  "off", "disable", "f" );
		my @str_true  = ( "true",  "yes", "on",  "enable",  "t" );
		return 0 if grep({ $string eq $_ } @str_false);
		return 1 if grep { $string eq $_ } @str_true;
	}
	return $default->($string) if 'CODE' eq ref $default;
	return $default;
}

sub _install_handler
{
	my $self = shift;
	my($which) = @_;
warn "_install_handler($which)" if DEBUG;
	die unless $self->{handlers}{$which};
	$self->yate->install("engine.$which", $self->{handlers}{$which}, $self->priority($which));
}

sub _uninstall_handler
{
	my $self = shift;
	my($which) = @_;
warn "_uninstall_handler($which)" if DEBUG;
	die unless $self->{handlers}{$which};
	$self->yate->uninstall("engine.$which", $self->{handlers}{$which});
}

#===== engine.command =====

sub _on_engine_command
{
	my $self = shift;
	my $msg = shift;
#$msg->dump('_on_engine_command');
	my $commands = $self->{commands};
	if($msg->param('partial')) {
		my @partline = split(/\s+/, $msg->param('partline')||'');
		while((my $c = shift @partline) && ref($commands) eq 'HASH') {
			$commands = $commands->{$c};
		}
		return undef unless 'HASH' eq ref $commands;
		return undef if 1 == keys(%$commands) && $commands->{(HANDLER_KEY)};

		my $partword = $msg->param('partword')||'';
		my $rx = qr/^\Q$partword\E/i;
		my @retvalue = split(/\t/, $msg->header('retvalue')||'');
		foreach my $k(sort grep { /$rx/ } keys %$commands) {
			if($k eq HANDLER_KEY) {
				push @retvalue, '<CR>' unless 1 == keys %$commands;
			} else {
				push @retvalue, $k unless grep { $_ eq $k } @retvalue;
			}
		}
		return ['false', join("\t", @retvalue)];
	} elsif(my $line = $msg->param('line')) {
		my @line = split(/\s+/, $line);
		while(@line && ref($commands) eq 'HASH') {
			my $c = shift @line;
			$commands = $commands->{$c};
		}
		if($commands->{(HANDLER_KEY)} && ('CODE' eq ref($commands->{(HANDLER_KEY)}))) {
			my $r = $commands->{(HANDLER_KEY)}->(join(' ', @line));
			$r =~ s#\s*$#\r\n#s;
			return $r;
		}
#		warn "Can not execute command '$line': ".(defined($commands) ? $commands : '(undef)')." is not a CODE reference";
		return undef;
	}
}

sub handle_command
{
	my $self = shift;
	my($cmd, $handler) = @_;
	my @cmd = split(/\s+/, $cmd);
	my $lastone = pop @cmd;
	my $commands = $self->{commands};
	$self->_install_handler('command') unless $self->{commands} && keys(%$commands);
	while(my $c = shift @cmd) {
		$commands->{$c} = { } unless $commands->{$c};
		if('HASH' eq ref $commands->{$c}) {
			$commands = $commands->{$c};
		}
	}
	$commands->{$lastone}{(HANDLER_KEY)} = $handler;
}

sub unhandle_command
{
	my $self = shift;
	my($cmd) = @_;
	my @cmd = split(/\s+/, $cmd);
	my @stack;
	my $commands = $self->{commands};
	foreach my $c(@cmd) {
		push @stack, $commands;
		last unless 'HASH' eq ref $commands->{$c};
		$commands = $commands->{$c};
	}
	delete $commands->{(HANDLER_KEY)};
	for(my $i = $#stack; $i >= 0; --$i) {
		delete $stack[$i]->{$cmd[$i]} unless keys %{$stack[$i]->{$cmd[$i]}};
	}
	$self->_uninstall_handler('command') unless $self->{commands} && keys %{ $self->{commands} };
}

#===== engine.debug =====

sub handle_debug
{
	my $self = shift;
	my($handler) = @_;
	$self->{handlers}{debug} = sub {
		my $msg = shift;
		return undef unless $msg->param('module')//'' eq $self->name;
		return $handler->($msg->param('line')//())."\r\n";
	};
	$self->_install_handler('debug');
	$self->handle_command('debug '.$self->name);
}

sub unhandle_debug
{
	my $self = shift;
	$self->unhandle_command('debug '.$self->name);
	$self->_uninstall_handler('debug');
	delete $self->{handlers}{debug};
}

#===== engine.status =====

sub handle_status
{
	my $self = shift;
	my($handler) = @_;
	$self->{handlers}{status} = sub {
		my $msg = shift;
		return undef if $msg->param('module') && $msg->param('module') ne $self->name;
		my $st = $handler->(_to_boolean($msg->param('details')), 0);
		$st = "type=ext," . $st unless $st =~ /\btype=/s;
		$st = "name=" . $self->name . ',' . $st unless $st =~ /\bname=/s;
		$st .= "\r\n" unless $st =~ /\r\n$/s;
		return $st if $msg->param('module') && $msg->param('module') eq $self->name;
		return ['false', $msg->header('retvalue').$st];
	};
	$self->_install_handler('status');
	$self->handle_command('status '.$self->name);
}

sub unhandle_status
{
	my $self = shift;
	$self->unhandle_command('status '.$self->name);
	$self->_uninstall_handler('status');
	delete $self->{handlers}{status};
}

1;



