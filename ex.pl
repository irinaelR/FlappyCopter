
use warnings;
use strict;
use Tk;

my $mw = MainWindow->new( -bg => 'black' );
$mw->geometry('+100+100');

my $height = 400;
my $width  = 600;

# first create a canvas widget
my $canvas = $mw->Canvas(
    -height => $height,
    -width  => $width,
    -bg     => 'black',
)->pack();

my $turret = $canvas->createOval(
    $width / 2 - 50, $height - 50, $width / 2 + 50, $height + 50,
    -fill => 'steelblue',
    -tags => ['turret']
);

my $px0    = $width / 2;
my $py0    = $height;
my $px     = $width / 2;
my $py     = $height - 65;
my $px_new = $px;
my $py_new = $py;

my $angle  = 1.57;          # pi divided by 2, 90 degrees in radians
my $power  = 50;
my $status = '  Ready  ';

my %projectile;
my %missle;
my $launcher;
my @ammo        = ( 1 .. 15 );   #reusable object array for projectiles
my $bat_level   = 100;
my $ammo_tot    = 500;
my $missles_max = 100;
my @missles     = ( 1 .. 20 );   #reusable object array for missles, max in play
+my $hits = 0;

my $cannon = $canvas->createLine(
    $px0, $py0, $px, $py,
    -width => 10,
    -fill  => 'lightblue',
    -tags  => ['cannon'],
);

$canvas->lower( 'cannon', 'turret' );

#1 degree in rads is pi divided by 180 = .01745
$mw->bind( '<Left>',  sub { &rotate(.01745) } );
$mw->bind( '<Right>', sub { &rotate(-.01745) } );
$mw->bind( '<Up>',    sub { &power(10) } );
$mw->bind( '<Down>',  sub { &power(-10) } );
$mw->bind( '<space>', sub { &fire } );

my $frame = $mw->Frame( -background => 'grey45' )->pack( -fill => 'x' );

$frame->Label(
    -text        => 'Power ',
    -bg          => 'grey45',
    -fg          => 'green',
    -borderwidth => 0
)->pack( -side => 'left' );

$frame->Label(
    -textvariable => \$power,
    -bg           => 'grey45',
    -fg           => 'green',
    -width        => 3,
    -borderwidth  => 0
)->pack( -side => 'left' );

$frame->Label(
    -text        => '   ',
    -bg          => 'grey45',
    -borderwidth => 0
)->pack( -side => 'left' );

$frame->Label(
    -textvariable => \$status,
    -bg           => 'grey45',
    -fg           => 'yellow',
    -width        => 15,
    -borderwidth  => 0
)->pack( -side => 'left' );

$frame->Label(
    -text        => '   ',
    -bg          => 'grey45',
    -borderwidth => 0
)->pack( -side => 'left' );

$frame->Label(
    -text        => 'Battery Level ',
    -bg          => 'grey45',
    -fg          => 'lightblue',
    -borderwidth => 0
)->pack( -side => 'left' );

$frame->Label(
    -textvariable => \$bat_level,
    -bg           => 'grey45',
    -fg           => 'lightblue',
    -width        => 4,
    -borderwidth  => 0
)->pack( -side => 'left' );

$frame->Label(
    -text        => '   ',
    -bg          => 'grey45',
    -borderwidth => 0
)->pack( -side => 'left' );

$frame->Label(
    -text        => 'Ammo Supply ',
    -bg          => 'grey45',
    -fg          => 'red',
    -borderwidth => 0
)->pack( -side => 'left' );

$frame->Label(
    -textvariable => \$ammo_tot,
    -bg           => 'grey45',
    -fg           => 'red',
    -width        => 3,
    -borderwidth  => 0
)->pack( -side => 'left' );

$frame->Label(
    -text        => '   ',
    -bg          => 'grey45',
    -borderwidth => 0
)->pack( -side => 'left' );

$frame->Label(
    -text        => 'Hits ',
    -bg          => 'grey45',
    -fg          => 'orange',
    -borderwidth => 0
)->pack( -side => 'left' );

$frame->Label(
    -textvariable => \$hits,
    -bg           => 'grey45',
    -fg           => 'orange',
    -width        => 3,
    -borderwidth  => 0
)->pack( -side => 'left' );

$frame->Button(
    -text    => 'Exit',
    -command => sub { exit }
)->pack( -side => 'right', -padx => 3 );

my $startbut;
$startbut = $frame->Button(
    -text    => 'New Game',
    -command => sub {
        $startbut->configure( -state => 'disabled' );
        &launch;
    },
)->pack( -side => 'right', -padx => 3 );

my $solar_panel = Tk::After->new(
    $canvas, 1000, 'repeat',
    sub {
        $bat_level++;
        $bat_level = sprintf "%.1f", $bat_level;

        if ( $bat_level > 100 ) { $bat_level = 100 }
    }
);

MainLoop();
#####################################################################
sub launch {

    $mw->bind( '<space>', sub { &fire } );
    $status = 'Ready';

    $launcher = Tk::After->new(
        $canvas, 1000, 'repeat',
        sub {
            my $rand = int( rand(100) );
            if ( $rand > 70 ) {    #launch

                $missles_max--;

                if ( $missles_max == 0 ) {
                    print chr(07);
                    $status = 'You Win';
                    &restart;
                }

                my $misl = shift @missles;
                my $mx   = int( rand $width );
                my $my   = -20;

                $missle{$misl}{'warhead'} =
                  $canvas->createOval( $mx - 8, $my - 8, $mx + 8, $my + 8,
                    -fill => 'yellow' );

                my ( $dx, $dy );
                $dx = 0;
                $dy = .8;

                $missle{$misl}{'repeater'} = Tk::After->new(
                    $canvas, 10, 'repeat',
                    sub {
                        $canvas->move( $missle{$misl}{'warhead'}, $dx, $dy );
                        my ( $x, $y, $x1, $y1 ) =
                          $canvas->bbox( $missle{$misl}{'warhead'} );
                        my @overlap =
                          $canvas->find( 'overlapping', $x, $y, $x1, $y1 );

                        if ( scalar @overlap > 1 ) {
                            $missle{$misl}{'repeater'}->cancel;
                            $canvas->delete( $missle{$misl}{'warhead'} );
                            $missle{$misl} = ();
                            push @missles, $misl;
                            $hits++;
                        }

                        if ( $y > $height + 10 ) {
                            $missle{$misl}{'repeater'}->cancel;
                            $canvas->delete( $missle{$misl}{'warhead'} );
                            $missle{$misl} = ();
                            push @missles, $misl;
                            print chr(07);
                            $status = 'Uh Oh Boom';
                            &restart;
                        }
                    }
                );

            }

        }
    );

}
####################################################################
####################################################################
sub fire {

    if (   ( scalar @ammo == 0 )
        || ( $ammo_tot < 0 )
        || ( $bat_level < 0 ) )
    {
        print chr(07);
        $status = 'Gun Jambed';
        return;
    }

    my $num = shift @ammo;

    $projectile{$num}{'shell'} = $canvas->createOval(
        $px_new - 4,
        $py_new - 4,
        $px_new + 4,
        $py_new + 4,
        -fill => 'pink'
    );

    $bat_level -= 1.5;
    $bat_level = sprintf "%.1f", $bat_level;
    $ammo_tot--;

    my ( $dx, $dy );
    if ( $px_new == $px0 ) { $dy = -$power / 10; $dx = 0 }
    else {
        $dx = cos($angle) * $power / 10;
        $dy = -sin($angle) * $power / 10;
    }

    $projectile{$num}{'repeater'} = Tk::After->new(
        $canvas, 10, 'repeat',
        sub {
            $canvas->move( $projectile{$num}{'shell'}, $dx, $dy );
            my ( $x, $y ) = $canvas->bbox( $projectile{$num}{'shell'} );

            if (   $y > $height + 10
                || $y < -10
                || $x < -10
                || $x > $width + +10 )
            {
                $projectile{$num}{'repeater'}->cancel;
                $canvas->delete( $projectile{$num}{'shell'} );
                $projectile{$num} = ();
                push @ammo, $num;
                $status = 'Ready';
            }
        }
    );
}

######################################################################
  ###

  sub power {
    my $pow = shift;
    $power += $pow;
    if ( $power < 10 )  { $power = 10 }
    if ( $power > 100 ) { $power = 100 }
}
######################################################################
  ####

  sub rotate {
    my $change = shift;

    $angle += 5 * $change;

    if ( $angle > 3.1 ) { $angle = 3.1; return }
    if ( $angle < .1 )  { $angle = .1;  return }
    $angle = sprintf "%.4f", $angle;

    #  print "$angle\t";

    $py_new = $height - sin($angle) * 65;
    $px_new = ( $width / 2 ) + ( cos($angle) * 65 );

    $canvas->delete($cannon);
    $cannon = ();
    $cannon = $canvas->createLine(
        $px0, $py0, $px_new, $py_new,
        -width => 10,
        -fill  => 'lightblue',
        -tags  => ['cannon'],
    );

    $canvas->lower( 'cannon', 'turret' );
}
######################################################################  #####

  sub restart {

    $launcher->cancel;
    $mw->bind( '<space>', sub { } );

    my $wait;
    $wait = Tk::After->new(
        $canvas, 10, 'repeat',
        sub {
            if ( scalar @missles == 20 ) {
                $wait->cancel;
                $bat_level   = 100;
                $ammo_tot    = 500;
                $missles_max = 100;
                $hits        = 0;
                $startbut->configure( -state => 'normal' );
            }
            else { return }
        }
    );

}
