BEGIN { $| = 1; print "1..11\n"; }
END {print "not ok 1\n" unless $loaded;}

use Sig::PackageScoped::Paranoid;

$loaded = 1;

use strict;

result(1);

{
    package Foo;

    # dying in package Foo now prepends 'Foo: ' to message
    Sig::PackageScoped::set_sig( __DIE__ => sub { die "Foo: $_[0]" } );

    eval { die "bar\n" };

    chomp $@;
    main::result( $@ eq 'Foo: bar',
		  "\$\@ should be 'Foo: bar' but it is '$@'\n" );

    {
	# dying in package Foo now prepends 'Foo2: ' to message.  This
	# should reset to just 'Foo: ' when the local var goes out of
	# scope
	local $SIG{__DIE__} = sub { die "Foo2: $_[0]" };

	eval { die "bar\n" };

	chomp $@;
	main::result( $@ eq 'Foo2: bar',
		      "\$\@ should be 'Foo: bar' but it is '$@'\n" );

	package Bar;

	# now that we're in Bar it should be a regular die
	eval { die "bar\n"; };

	chomp $@;
	main::result( $@ eq 'bar',
		      "\$\@ should be 'bar' but it is '$@'\n" );
    }

    # back in package Foo with previous handler restored
    eval { die "bar\n" };

    chomp $@;
    main::result( $@ eq 'Foo: bar',
		  "\$\@ should be 'Foo: bar' but it is '$@'\n" );

    package Bar;

    # in bar, no handler should be set
    eval { die "bar\n"; };

    chomp $@;
    main::result( $@ eq 'bar',
		  "\$\@ should be 'bar' but it is '$@'\n" );

    package Foo;

    eval { die "bar\n" };

    # return to Foo just to check
    chomp $@;
    main::result( $@ eq 'Foo: bar',
		  "\$\@ should be 'Foo: bar' but it is '$@'\n" );

    {
	# resets package Foo entirely
	$SIG{__DIE__} = sub { die "Foo2: $_[0]" };

	eval { die "bar\n" };

	chomp $@;
	main::result( $@ eq 'Foo2: bar',
		      "\$\@ should be 'Foo: bar' but it is '$@'\n" );
    }

    eval { die "bar\n"; };

    # We reset foo entirely
    chomp $@;
    main::result( $@ eq 'Foo2: bar',
		  "\$\@ should be 'Foo2: bar' but it is '$@'\n" );

    package Bar;

    # in bar, _still_ no handler should be set
    eval { die "bar\n"; };

    chomp $@;
    main::result( $@ eq 'bar',
		  "\$\@ should be 'bar' but it is '$@'\n" );

    package Foo;

    # remove our handler(s)
    Sig::PackageScoped::unset_sig( __DIE__ => 1, __WARN__ => 1 );

    eval { die "bar\n"; };

    chomp $@;
    main::result( $@ eq 'bar',
		  "\$\@ should be 'bar' but it is '$@'\n" );

}


sub result
{
    my $ok = !!shift;
    use vars qw($TESTNUM);
    $TESTNUM++;
    print "not "x!$ok, "ok $TESTNUM\n";
    print @_ if !$ok;
}
