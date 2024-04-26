package Batiment;

use strict;
use warnings;
use Data::Dumper;
use lib 'Model';
use Connection;
use Point;

sub new {
    my ( $class, $id_batiment, $typeBatiment, @liste_point ) = @_;
    my $self = {
        id_batiment  => $id_batiment,
        liste_point  => \@liste_point,
        typeBatiment => $typeBatiment,
    };
    bless $self, $class;
    return $self;
}

sub get_id_batiment {
    my $self = shift;
    return $self->{id_batiment};
}

sub set_id_batiment {
    my ( $self, $id_batiment ) = @_;
    $self->{id_batiment} = $id_batiment;
}

sub get_liste_point {
    my $self = shift;
    return $self->{liste_point};
}

sub set_liste_point {
    my ( $self, $liste_point ) = @_;
    $self->{liste_point} = $liste_point;
}

sub get_typeBatiment {
    my $self = shift;
    return $self->{typeBatiment};
}

sub set_typeBatiment {
    my ( $self, $typeBatiment ) = @_;
    $self->{typeBatiment} = $typeBatiment;
}

sub read_batiments {
    use Connection;

    my $connection      = Connection->new()->get_connection();
    my @liste_batiments = ();
    my $sth             = $connection->prepare("SELECT * FROM batiment");
    $sth->execute();

    while ( my $row = $sth->fetchrow_hashref ) {
        my @liste_point = ();
        my $les_points  = $row->{liste_point};
        my @points      = split( ",", $les_points );
        foreach my $point (@points) {
            my ( $x, $y ) = split( "-", $point );

            push @liste_point, Point->new( $x, $y );
        }
        my $type = $row->{typeBatiment};

        #print $type;
        push @liste_batiments,
          Batiment->new( $row->{id_batiment}, $type, @liste_point );
    }

    $sth->finish;
    return @liste_batiments;
}

sub create_batiment {
    my ( $id_batiment, @liste_point ) = @_;

    my $connection = Connection->new()->get_connection();
    my $sth =
      $connection->prepare("INSERT INTO batiment (liste_point) VALUES (?)");
    my $liste_point_string =
      join( "-", map { join( ",", $_->get_y() ) } @liste_point );
    $sth->execute( $id_batiment, $liste_point_string );

    $sth->finish;
}

sub update_batiment {
    my ( $id_batiment, @liste_point, $typeBatiment ) = @_;

    my $connection = Connection->new()->get_connection();
    my $sth        = $connection->prepare(
"UPDATE batiment SET liste_point = ?,SET typeBatiment = ? WHERE id_batiment = ?"
    );
    my $liste_point_string = join( "-",
        map { join( ",", $_->get_x(), $_->get_y() ) } @liste_point,
        $typeBatiment );
    $sth->execute( $liste_point_string, $id_batiment );

    $sth->finish;
}

sub delete_batiment {
    my $id_batiment = shift;

    my $connection = Connection->new()->get_connection();
    my $sth =
      $connection->prepare("DELETE FROM batiment WHERE id_batiment = ?");
    $sth->execute($id_batiment);

    $sth->finish;
}

# fonction pour le reperage des objet qui est dans le batiment
sub point_inside_batiment {
  my ($point, @liste_point) = @_;
  my $marge = 0;
  my $x = $point->get_x();
  my $y = $point->get_y();

  # Ajuster les coordonnées des points pour inclure la marge
  my @adjusted_points;
  foreach my $p (@liste_point) {
    push @adjusted_points, Point->new($p->get_x() + $marge, $p->get_y() + $marge);
  }

  my @points = @adjusted_points;
  my $num_points = scalar @points;
  my $i;
  my $j = $num_points - 1;
  my $inside = 0;

  for ($i = 0; $i < $num_points; $i++) {
    my $adjusted_y_i = $points[$i]->get_y();
    my $adjusted_y_j = $points[$j]->get_y();

    # Considérer la marge lors de la vérification de l'intersection des coordonnées y
    if ((($adjusted_y_i > $y) != ($adjusted_y_j > $y))
        && ($x < ($points[$j]->get_x() - $points[$i]->get_x()) * ($y - $adjusted_y_i) / ($adjusted_y_j - $adjusted_y_i) + $points[$i]->get_x())) {
      $inside = !$inside;
    }
    $j = $i;
  }
  return $inside;
}

sub is_inside {
    my ($point , $marge ,@listePoint) = @_ ;
    my $minx = $listePoint[0]->get_x() - $marge;
    my $miny = $listePoint[0]->get_y() - $marge;
    my $maxx = $listePoint[2]->get_x() + $marge;
    my $maxy = $listePoint[2]->get_y() + $marge;


    if ( ($point->get_x() >= $minx && $point->get_x() <= $maxx) &&
         ($point->get_y() >= $miny && $point->get_y() <= $maxy) ) {
        return 1;
    }
    return 0;
}

sub centre_polygone

{
    my ($self) = @_;

    my @points = @{ $self->{liste_point} };

    my $sum_x = 0;
    my $sum_y = 0;

    foreach my $point (@points) {
        $sum_x += $point->get_x();
        $sum_y += $point->get_y();
    }

    my $nombre_points = scalar @points;
    my $centre_x      = $sum_x / $nombre_points;
    my $centre_y      = $sum_y / $nombre_points;

    return ( $centre_x, $centre_y );
}


sub point_obtenue{
    my ($point,$taille,@liste) = @_;
    my $x = $point->get_x();
    my $y = $point->get_y();
    if ($x > $liste[3]->get_x){
        my $espace = $liste[0]->get_y;
        if($espace <= $taille * 3 ){
            print "obtenu 4 \n";
            return 4;
        }elsif($espace > $taille * 3 ){
            print "obtenu 2 \n";
            return 2;
        }
    }else{
        return 0;
    }
}
1;
