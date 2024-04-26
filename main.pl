use strict;
use warnings;
use Tk;
use Data::Dumper;
use lib "./Model";
use Terrain;
use Drawer;
use Helicoptere;
use Batiment;
use Point;
use Win32;
use Tank;

# Création de la fenêtre principale Tk
my $mw = MainWindow->new;
$mw->title("Helicoptere");

# Lecture de l'hélicoptère et des bâtiments à partir des fichiers
my $helicoptere = Helicoptere::read_helicoptere(1);
my @batiments   = Batiment::read_batiments();
my @tanks       = Tank::read_tanks();
# print $tanks[0]->get_score();
my $dimension   = [ 1000, 800 ];

# Création du terrain de jeu
my $terrain = Terrain->new( $helicoptere, $dimension, \@batiments );

# Création du canvas
my $canvas = $mw->Canvas( -width => $dimension->[0], -height => $dimension->[1] )->pack;

my %keys_pressed;
my %points_score;
my @obstacles = $terrain->get_obstacle();

my @bombs;

$points_score{"point"} = 0;

sub eventDirection {
    my ( $direction, $action, $terrain ) = @_;

    # Enregistrez si une touche est pressée ou relâchée
    if ( $action eq 'press' ) {
        $keys_pressed{$direction} = 1;
        #print "Pressed $direction\n";
    }
    elsif ( $action eq 'release' ) {
        delete $keys_pressed{$direction};
        #print "Released $direction\n";
    }

}

our $helico_pic = $canvas->Photo(-file => "inc/hAlea.png");
our $bomb_pic = $canvas->Photo(-file => "inc/bomb.png"); 
our $tank_pic = $canvas->Photo(-file => "inc/icons8-tank-48.png");
sub draw_terrain {
    my ( $canvas, $terrain ) = @_;
    $canvas->delete('all');    # Supprime tout ce qui est dessiné sur le canvas

    my @terrainDimension = (
        Point->new( 0, 0 ),
        Point->new( 0, $terrain->get_dimension()->[1] ),
        Point->new(
            $terrain->get_dimension()->[0],
            $terrain->get_dimension()->[1]
        ),
        Point->new( $terrain->get_dimension()->[0], 0 )
    );
    Drawer::draw_polygon( $canvas, "#f2f2f2", "", @terrainDimension );

    # Dessiner les obstacles
    Drawer::draw_tab_polygon( $canvas, @{ $terrain->get_batiments } );

    # Dessiner l'hélicoptère
    my $helico = $terrain->get_helicoptere();
    my $x      = $helico->get_position()->get_x();
    my $y      = $helico->get_position()->get_y();

   
    # Drawer::draw_gif( $canvas,$x,$y,"");
    $canvas->createImage($x, $y, -image => $helico_pic);

    # dessiner les bombes
    foreach my $bomb (@bombs) {
        # Drawer::draw_gif( $canvas,$bomb->get_x(),$bomb->get_y(),"inc/bomb.png");
        $canvas->createImage($bomb->get_x(),$bomb->get_y(), -image => $bomb_pic);
    }

    # dessiner les tanks
    foreach my $tank (@tanks) {
        # Drawer::draw_gif( $canvas,$tank->get_position()->get_x(),$tank->get_position()->get_y(),"inc/icons8-tank-48.png");
        $canvas->createImage($tank->get_position()->get_x(),$tank->get_position()->get_y(), -image => $tank_pic);
        $canvas->createText(
            $tank->get_position()->get_x(), $tank->get_position()->get_y()-35,
            -text => $tank->get_score(),
            -fill => 'black'
        );
    }

    $canvas->createText(
        20, 20,
        -text => $points_score{"point"},
        -fill => 'black'
    );
}


sub update_map_and_events {
    my ( $canvas, $terrain,@obstacles) = @_;
    if ($terrain->status_jeu()) {
        #$points_score{"point"} = $terrain->get_point();
        print "Vous avez gagné! avec le score de ".$points_score{"point"};
        Win32::MsgBox("Vous avez gagné! avec le score de ".$points_score{"point"},0);
    }
    else {
        # Déplacer vers le bas l'hélicoptère si la touche "haut" n'est pas pressée
        unless ( exists $keys_pressed{'Up'} )
        {    
            if(!Point::detect_collision($terrain, "Down", 0)) {
                Helicoptere::moov("Down", $terrain->get_helicoptere(), 5);
            }
        }
        foreach my $key ( keys %keys_pressed ) {
            if(!Point::detect_collision($terrain, $key, 1)) {
                Helicoptere::moov($key, $terrain->get_helicoptere(), 5);
                my @newTB;
                foreach my $obs ( @obstacles){
                    my $pt = Batiment::point_obtenue($terrain->get_helicoptere()->get_position(), $terrain->get_helicoptere()->get_taille,@{$obs->get_liste_point});
                    if($pt == 0){
                        push @newTB , $obs;
                    }
                    else{
                        $points_score{"point"} += $pt;
                    }
                }
                @obstacles = @newTB;
            }
        }
        
        foreach my $bomb(@bombs) {
            # print $bomb->get_x();
            my $tank_to_rem = Tank::hit_tank($bomb, @tanks);
            if($terrain->offside_terrain($bomb) && !defined $tank_to_rem) {
                Point::moov("Down", $bomb, 5);
            } else {
                @bombs = grep { $_ != $bomb } @bombs;
                if(defined $tank_to_rem) {
                    $points_score{"point"} += $tank_to_rem->get_score();
                    @tanks = grep { $_ != $tank_to_rem } @tanks;
                }
            }
        }

        foreach my $tank (@tanks) {
            # print $tank->get_score();
            $tank->move_tank($terrain);
        }

        # Redessiner le terrain
        draw_terrain( $canvas, $terrain);

        # Planifier la prochaine mise à jour
        $mw->after( 10, sub { update_map_and_events( $canvas, $terrain, @obstacles) } );
    }
}

# Capturer des touches de direction
$mw->bind( '<KeyPress-Up>', 
    sub { eventDirection( 'Up', 'press', $terrain ) } );

$mw->bind( '<KeyRelease-Up>',
    sub { eventDirection( 'Up', 'release', $terrain ) } );

$mw->bind( '<KeyPress-Down>',
    sub { eventDirection( 'Down', 'press', $terrain ) } );

$mw->bind( '<KeyRelease-Down>',
    sub { eventDirection( 'Down', 'release', $terrain ) } );

$mw->bind( '<KeyPress-Left>',
    sub { eventDirection( 'Left', 'press', $terrain ) } );

$mw->bind( '<KeyRelease-Left>',
    sub { eventDirection( 'Left', 'release', $terrain ) } );

$mw->bind( '<KeyPress-Right>',
    sub { eventDirection( 'Right', 'press', $terrain ) } );

$mw->bind( '<KeyRelease-Right>',
    sub { eventDirection( 'Right', 'release', $terrain ) } );

$mw->bind('<KeyPress-x>', 
    sub { 
        my $b = $terrain->get_helicoptere()->get_center_pos();
        push @bombs, $b;
        # print "Bomb count: ".($#bombs+1)."\n";
    });

# Lancer la première mise à jour
update_map_and_events( $canvas, $terrain,@obstacles);

MainLoop;

1;
