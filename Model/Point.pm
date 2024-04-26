package Point;

use strict;
use warnings;

sub new {
    my ($class, $x, $y) = @_;
    my $self = {
        x => $x,
        y => $y,
    };
    bless $self, $class;
    return $self;
}

sub get_x {
  my $self = shift;
  return $self->{x};
}
sub set_x {
  my ($self, $x) = @_;
  $self->{x} = $x;
}
sub get_y {
  my $self = shift;
  return $self->{y};
}
sub set_y {
  my ($self, $y) = @_;
  $self->{y} = $y;
}

sub moov {
    my ($direction, $point, $vitesse) = @_;
    if ($direction eq "Down") {
        $point->set_y($point->get_y() + $vitesse);
    }
    elsif ($direction eq "Up") {
        $point->set_y($point->get_y() - $vitesse);
    }
    elsif ($direction eq "Left") {
        $point->set_x($point->get_x() - $vitesse);
    }
    elsif ($direction eq "Right") {
        $point->set_x($point->get_x() + $vitesse);
    }
    else {
        die "Direction invalide : $direction";
    }
    return $point;
}

sub detect_collision {
	my ($terrain, $key, $heliportOk) = @_;
	my $current_position = $terrain->get_helicoptere()->get_position();
	my $temp_position    = Point->new( $current_position->get_x(),
		$current_position->get_y() );

	Point::moov($key, $temp_position,5);
	if ( $terrain->offside_terrain($temp_position) && $terrain->view_obstacle($temp_position) && ((!$terrain->inside_heliport($current_position) && !$heliportOk) || ($heliportOk))) {
		return 0; # no collision
	}
	else {
		return 1; # collision
	}
}


1;