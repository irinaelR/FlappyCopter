package Connection;

use DBI;
use strict;
use warnings;

sub new {
    my ($class) = @_;
    my $self = {
        host     => "localhost", 
        database => "HelicoptereGame",
        username => "root",     
        password => "",       
    };
    bless $self, $class;
    return $self;
}

sub get_connection {
    my ($self) = @_;

    # Error handling and connection pooling (optional)
    my $dbh;
    eval {
        $dbh = DBI->connect(
            "DBI:mysql:$self->{database}:$self->{host}",
            $self->{username},
            $self->{password}
        );
    };

    if (!$dbh) {
        die "Connection failed: " . DBI->errstr;
    }

    return $dbh;
}

1;
