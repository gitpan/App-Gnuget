package App::Gnuget;
use Net::FTP;

our $VERSION = 1.925;

sub new {
    my $class = shift;
    $class = ref($class) || $class;
    my $self = { ftp => Net::FTP->new("ftp.gnu.org") };
    return bless($self, $class);
}

sub log {
    my ($self, $msg) = @_;
    print("[$$] $msg\n");
}

sub buildFtpCnx {
    my $self = shift;
    $self->{ftp}->login("anonymous", '-anonymous@')
        or die $self->{ftp}->message;
    $self->log("connected to GNU ftp");
    $self->{ftp}->cwd('/gnu') and $self->log("cwd() in gnu/");
}

sub download {
    my $self = shift;
    $self->{ftp}->cwd($self->{software}) 
	and $self->log("cwd() in $self->{software}/");
    $self->{ftp}->get($self->{archive})
	or $self->log("cannot download $self->{archive}");
    exit(1) if (! -e $self->{archive});
    $self->log("$self->{archive}'s download successful");
}

sub populate {
    my ($self, $name, $version) = @_;
    $self->{software} = $name;
    $self->{version} = $version;
    $self->{archive} = $self->{software}."-".$self->{version}.".tar.gz";
}


sub clean {
    my $self = shift;
    unlink($self->{archive})
        or $self->log("Cannot erase $self->{archive}");
    $self->log("$self->{archive} cleaned");
    $self->{ftp}->quit();
    $self->log("disconnected from GNU ftp");
}

sub uncompress {
    my $self = shift;
    system("tar xf $self->{archive} 2>/dev/null")
        and $self->log("cannot unpack archive");
    $self->log("$self->{archive} unpacked");
}

1;
