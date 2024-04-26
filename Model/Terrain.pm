package Terrain;

use strict;
use warnings;
use lib "./Model";
use Point;

sub new {
    my ( $class, $helicoptere, $dimension ,@batiments) = @_;
    my $self = {
        helicoptere => $helicoptere,
        dimension   => $dimension,
        batiments   => @batiments,
    };
    bless $self, $class;
    return $self;
}

sub get_helicoptere {
    my ($self) = @_;
    return $self->{helicoptere};
}

sub set_helicoptere {
    my ( $self, $helicoptere ) = @_;
    $self->{helicoptere} = $helicoptere;
}

sub get_batiments {
    my ($self) = @_;
    return $self->{batiments};
}

sub set_batiments {
    my ( $self, @batiment ) = @_;
    $self->{batiments} = @batiment;
}

sub get_dimension {
    my ($self) = @_;
    return $self->{dimension};
}

sub set_dimension {
    my ( $self, $dimension ) = @_;
    $self->{dimension} = $dimension;
}

#type piste piste_arrive piste_depart
sub get_heliport {
    my ( $self, $type_piste ) = @_;
    my $piste_arrive;
    foreach my $batiment ( @{$self->get_batiments} ) {
        if ( $batiment->get_typeBatiment() eq "$type_piste" ) {
            $piste_arrive = $batiment;
            last;
        }
    }
    return $piste_arrive;
}

sub status_jeu {
    my ($self) = @_;
    my $stat   = 0;
    my $arrive = $self->get_heliport('H-arriver'),$self->get_heliport('H-arriver'),$self->get_heliport('H-arriver');
    if (
        Batiment::point_inside_batiment(
            $self->get_helicoptere()->get_position(),@{$arrive->get_liste_point()}
        )
      )
    {
        $stat = 1;
        print "c est gagne ";
    }
    return $stat;
}

sub offside_terrain {
    my ($self,$position) = @_;
    my $statut           = 0;
    my @terrainDimension = (Point->new(0,0),Point->new(0,$self->get_dimension()->[1]),Point->new($self->get_dimension()->[0],$self->get_dimension()->[1]),Point->new($self->get_dimension()->[0],0));

    #a l interieur du terrain
    if ( Batiment::is_inside($position,-10,@terrainDimension) ) {
        $statut = 1;
    }
    return $statut;
}

sub get_obstacle{
    my ( $self, $type_piste ) = @_;
    my @piste_arrive;
    foreach my $batiment ( @{$self->get_batiments} ) {
        if ( $batiment->get_typeBatiment() eq "obstacle" ) {
            push @piste_arrive , $batiment;
        }
    }
    return @piste_arrive;
}
sub view_obstacle{
    my ($self,$point) = @_;
    my @obstacle = $self->get_obstacle();
    my $statut = 1;

    foreach my $obstacle (@obstacle) {
        if ( Batiment::is_inside($point,10,@{$obstacle->get_liste_point()}) ) {
            $statut = 0;
        }
    }
    return $statut;
}
sub inside_heliport{
    my ($self,$point) = @_;
    my $statut = 0;
    my @heliport = ($self->get_heliport('H-depart'),$self->get_heliport('H-arriver'));
    foreach my $heliport (@heliport) {
        if ( Batiment::point_inside_batiment($point,@{$heliport->get_liste_point()}) ) {
            $statut = 1;
        }
    }
    return $statut;
}

sub get_point{
    my ($self) = @_;
    my $point = $self->get_helicoptere()->get_position();
    my $score = 0;

    foreach my $obstacle ($self->get_obstacle) {
        $score += Batiment::point_obtenue($point,25,@{$obstacle->get_liste_point()});
        
    }
    return $score;
}


1;
