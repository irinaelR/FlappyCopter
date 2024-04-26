package Helicoptere;

use strict;
use warnings;

use lib "Model";
use Connection;
use Point;

# Constructeur
sub new {
    my ( $class, $id_helicoptere, $nom, $position ) = @_;
    my $self = {
        id_helicoptere => $id_helicoptere,
        nom            => $nom,
        position       => $position,
        taille         =>25,
    };
    bless $self, $class;
    return $self;
}


sub get_taille {
    my $self = shift;
    return $self->{taille};
}
# Getter pour id_helicoptere
sub get_id_helicoptere {
    my $self = shift;
    return $self->{id_helicoptere};
}

# Setter pour id_helicoptere
sub set_id_helicoptere {
    my ( $self, $id_helicoptere ) = @_;
    $self->{id_helicoptere} = $id_helicoptere;
}

# Getter pour nom
sub get_nom {
    my $self = shift;
    return $self->{nom};
}

# Setter pour nom
sub set_nom {
    my ( $self, $nom ) = @_;
    $self->{nom} = $nom;
}

# Getter pour position
sub get_position {
    my $self = shift;
    return $self->{position};
}

# Setter pour position
sub set_position {
    my ( $self, $position ) = @_;
    $self->{position} = $position;
}

# CRUD Operations

# Create
sub create_helicoptere {
    my ( $class, $nom, $point ) = @_;

    # Création d'une nouvelle instance de la classe Helicoptere
    my $helicoptere = Helicoptere->new( undef, $nom, $point );

    # Insertion de l'hélicoptère dans la base de données
    my $connection = Connection->new()->get_connection();
    my $sth        = $connection->prepare(
        "INSERT INTO helicoptere (nom, posiX, posiY) VALUES (?, ?, ?)");
    $sth->execute(
        $helicoptere->get_nom,
        $helicoptere->get_point->get_x,
        $helicoptere->get_point->get_y
    );

    # Récupération de l'ID généré pour l'hélicoptère nouvellement créé
    my $id_helicoptere =
      $connection->last_insert_id( undef, undef, 'helicoptere',
        'id_helicoptere' );

    # Mise à jour de l'ID de l'hélicoptère avec l'ID généré
    $helicoptere->set_id_helicoptere($id_helicoptere);

    return $helicoptere;
}

# Read
sub read_helicoptere {
    my ($id_helicoptere) = @_;

    # Récupération des informations sur l'hélicoptère à partir de la base de données
    my $connection = Connection->new()->get_connection();
    my $sth = $connection->prepare("SELECT * FROM helicoptere WHERE id_helicoptere = ?");
    $sth->execute($id_helicoptere);

    # Récupération de la ligne de la base de données
    my $row = $sth->fetchrow_hashref;

    # Création d'une instance de la classe Helicoptere à partir des données récupérées
    my $helicoptere = Helicoptere->new($row->{id_helicoptere}, $row->{nom}, Point->new($row->{posiX}, $row->{posiY}));
    return $helicoptere;
}


# Update
sub update_helicoptere {
    my ( $self, $nom, $point ) = @_;

    # Mise à jour des informations de l'hélicoptère dans la base de données
    my $connection = Connection->new()->get_connection();
    my $sth        = $connection->prepare(
"UPDATE helicoptere SET nom = ?, posiX = ?, posiY = ? WHERE id_helicoptere = ?"
    );
    $sth->execute( $nom, $point->get_x, $point->get_y,
        $self->get_id_helicoptere );

    # Mise à jour des informations de l'objet Helicoptere
    $self->set_nom($nom);
    $self->set_point($point);
}

# Delete
sub delete_helicoptere {
    my ($self) = @_;

    my $connection = Connection->new()->get_connection();
    my $sth =
      $connection->prepare("DELETE FROM helicoptere WHERE id_helicoptere = ?");
    $sth->execute( $self->get_id_helicoptere );
}

# fonction de deplacement de l helicoptere

sub moov {
    my ($direction, $helicoptere, $vitesse) = @_;
    my $position = $helicoptere->get_position();
    if ($direction eq "Down") {
        $position->set_y($position->get_y() + $vitesse);
    }
    elsif ($direction eq "Up") {
        $position->set_y($position->get_y() - $vitesse);
    }
    elsif ($direction eq "Left") {
        $position->set_x($position->get_x() - $vitesse);
    }
    elsif ($direction eq "Right") {
        $position->set_x($position->get_x() + $vitesse);
    }
    else {
        die "Direction invalide : $direction";
    }
    $helicoptere->set_position($position);
    return $helicoptere;
}

sub get_center_pos {
    my ($self) = @_;
    my $centerX = ($self->get_position()->get_x() + $self->get_taille()/2);
    my $centerY = ($self->get_position()->get_y() + $self->get_taille()/2);
    return Point->new($centerX, $centerY);
}


1;
