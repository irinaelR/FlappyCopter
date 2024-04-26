package Tank;

use lib "Model";
use Point;


sub new {
    my ($class, $score, $position) = @_;
    my $self = {
        # direction => "Right",
        score     => $score,
        position  => $position
    };
    bless $self, $class;
    return $self;
}

sub get_position {
    my $self = shift;
    return $self->{position};
}

sub set_position {
    my ($self, $position) = @_;
    $self->{position} = $position;
}

sub get_direction {
    my $self = shift;
    return $self->{direction};
}

sub set_direction {
    my ($self, $dir) = @_;
    $self->{direction} = $dir;
}

sub get_score {
    my $self = shift;
    return $self->{score};
}

sub set_score {
    my ($self, $p) = @_;
    $self->{score} = $p;
}

sub set_position {
    my ($self, $score) = @_;
    $self->{score} = $score;
}

sub read_tanks {
    use Connection;

    my @liste_tanks     = ();
    my $connection      = Connection->new()->get_connection();
    my $sth             = $connection->prepare("SELECT * FROM TANKS");
    $sth->execute();

    while ( my $row = $sth->fetchrow_hashref ) {
        my $x = $row->{x_pos};
        my $y = $row->{y_pos};
        my $position = Point->new($x, $y);

        my $points = $row->{points};
        # print $points."\n";

        my $new_Tank = Tank->new(0, $position);
        $new_Tank->set_position($position);
        $new_Tank->set_score(int($points));

        push @liste_tanks, $new_Tank;
        # print $new_Tank->get_score()."heh \n";
    }

    $sth->finish;
    return @liste_tanks;
}

sub hit_tank {
    my ($point, @liste_tanks) = @_;
    my $hit_tank = undef;

    foreach my $tank (@liste_tanks) {
        if($point->get_x() >= $tank->get_position()->get_x() && $point->get_x() <= $tank->get_position()->get_x()+48 && $point->get_y() >= $tank->get_position()->get_y()) {
            $hit_tank = $tank;
            last;
        }
    }

    return $hit_tank;
}

sub moov {
    my ($self, $vitesse) = @_;
    my $position = $self->get_position();
    if($self->get_direction() eq "Right") {
        $position->set_x($position->get_x() + $vitesse);
    } else {
        $position->set_x($position->get_x() - $vitesse);
    }
}

sub move_tank {
    my ($self, $terrain) = @_;
    my @dirArr = ("Right", "Left");
    @dirArr = grep {$_ ne $self->get_direction()} @dirArr;
    my $oppositeDir = $dirArr[0];

    if(!$terrain->view_obstacle($self->get_position()) || !$terrain->offside_terrain($self->get_position)) {
        $self->set_direction($oppositeDir);
    }

    $self->moov(2.5);

    # $self->set_position(Point::moov($self->get_direction(), $self->get_position(), 2.5));
}

1;