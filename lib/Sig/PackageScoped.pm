package Sig::PackageScoped;

use strict;
use vars qw($VERSION @ISA @EXPORT_OK %HANDLERS);

require Exporter;

@ISA = qw(Exporter);

@EXPORT_OK = qw(set_sig unset_sig);

$VERSION = '0.01';

1;

sub import
{
    $SIG{__DIE__} = sub { my $package = caller(0);
			  exists $HANDLERS{$package}{__DIE__} ?
			  $HANDLERS{$package}{__DIE__}->(@_) :
			  die @_;
		        };
    $SIG{__WARN__} = sub { my $package = caller(0);
			   exists $HANDLERS{$package}{__WARN__} ?
			   $HANDLERS{$package}{__WARN__}->(@_) :
			   warn @_;
		         };
}

sub set_sig
{
    my %p = @_;

    my $package = $p{package} || caller(0);

    $HANDLERS{$package}{__DIE__} = $p{__DIE__} if exists $p{__DIE__};
    $HANDLERS{$package}{__WARN__} = $p{__WARN__} if exists $p{__WARN__};
}

sub unset_sig
{
    my %p = @_;

    my $package = delete $p{package} || caller(0);

    delete @{ $HANDLERS{$package} }{ keys %p };
}

__END__

=head1 NAME

Sig::PackageScoped - Make $SIG{__DIE__} and $SIG{__WARN__} package scoped

=head1 SYNOPSIS

  use Sig::PackageScoped qw(set_sig unset_sig);

  set_sig( __DIE__ => sub { die "Really dead: @_" } );

  unset_sig( __DIE__ => 1 );

=head1 DESCRIPTION

If all your modules use this module's functions to declare this signal
handlers, then they won't overwrite each other.  If you're working
with modules that don't play nice, see Sig::PackageScoped::Paranoid.

=head1 EXPORTS

This module will optionally export the C<set_sig> and <unset_sig>
subroutines.  By default, nothing is exported.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=cut
