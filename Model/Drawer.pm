package Drawer;

use strict;
use warnings;
use Data::Dumper;
use Tk::Photo;
use Tk::PNG;

sub draw_polygon {
    my ( $canvas, $color, $text, @points ) = @_;

    my @coords;
    foreach my $point (@points) {
        push @coords, $point->get_x()
        , $point->get_y();
    }

    # Dessiner le polygone avec l'étiquette 'terrain'
    my $polygon_id =
      $canvas->createPolygon( @coords, -fill => $color, -outline => 'black', -tags => ['terrain']);

    # Calculer le centre du polygone
    my $center_x = ( $coords[0] + $coords[2] + $coords[4] ) / 3;
    my $center_y = ( $coords[1] + $coords[3] + $coords[5] ) / 3;

    # Ecrire le texte au-dessus du polygone
    $canvas->createText(
        $center_x, $center_y,
        -text => $text,
        -fill => 'black'
    );
    return $polygon_id;
}


sub draw_tab_polygon {
    my ( $canvas, @batiments ) = @_;
    foreach my $batiment (@batiments) {
        if ( $batiment->get_typeBatiment() eq "obstacle" ) {
            draw_polygon( $canvas, "#302B2A", "",
                @{ $batiment->get_liste_point() } );
        }
        elsif ( $batiment->get_typeBatiment() eq "H-depart" ) {
            draw_polygon( $canvas, "#93B7C9", "",
                @{ $batiment->get_liste_point() } );
        }
        else {
            draw_polygon( $canvas, "#93B7C9", "",
                @{ $batiment->get_liste_point() } );
        }
    }

}

sub draw_gif {
    my ( $canvas, $x, $y, $image_path ) = @_;

    # Load the GIF image
    my $image = $canvas->Photo( -format => 'png', -file => $image_path );

    # Get image dimensions
    my $image_width  = $image->width;
    my $image_height = $image->height;

    # Calculate new coordinates for centering
    my $new_x = $x - $image_width / 2;
    my $new_y = $y - $image_height / 2;

    # Draw the image centered at the new coordinates with the tag 'helicopter'
    my $image_item = $canvas->createImage(
        $new_x, $new_y,
        -image  => $image,
        -anchor => 'nw',
        -tags   => ['terrain']
    );

    return $image_item;    # Return the created image item
}


sub draw_point {
    my ( $canvas, $x, $y, $thickness, $color ) = @_;

# Calcule les coordonnées du rectangle définissant le point en fonction de l'épaisseur
    my $x1 = $x - $thickness;
    my $y1 = $y - $thickness;
    my $x2 = $x + $thickness;
    my $y2 = $y + $thickness;

    # Dessine le point en tant qu'oval avec les coordonnées calculées
    $canvas->createOval(
        $x1, $y1, $x2, $y2,
        -fill    => $color,
        -outline => $color
    );
}

1;
