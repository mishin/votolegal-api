package VotoLegal::Logger;
use strict;
use DateTime;
use IO::Handle;
use Log::Log4perl qw(:easy);

if ( $ENV{VOTOLEGAL_API_LOG_DIR} ) {
    if ( -d $ENV{VOTOLEGAL_API_LOG_DIR} ) {

        my $date = DateTime->now->ymd('-');

        $ENV{VOTOLEGAL_API_LOG_FILE} = $ENV{VOTOLEGAL_API_LOG_DIR} . "/api.$date.$$.log";
        print STDERR "Redirecting STDERR/STDOUT to $ENV{VOTOLEGAL_API_LOG_FILE}\n";
        close(STDERR);
        close(STDOUT);
        autoflush STDERR 1;
        autoflush STDOUT 1;
        open( STDERR, '>>', $ENV{VOTOLEGAL_API_LOG_FILE} ) or die 'cannot redirect STDERR';
        open( STDOUT, '>>', $ENV{VOTOLEGAL_API_LOG_FILE} ) or die 'cannot redirect STDOUT';

    }
    else {
        print STDERR "VOTOLEGAL_API_LOG_DIR is not a dir";
    }
}

Log::Log4perl->easy_init(
    {
        level  => $DEBUG,
        layout => '%p{3} %d{yyyy-MM-dd HH:mm:ss.SSS}[%P] %x%m{indent=1}%n',
        ( $ENV{VOTOLEGAL_API_LOG_FILE} ? ( file => '>>' . $ENV{VOTOLEGAL_API_LOG_FILE} ) : () ),
        'utf8'    => 1,
        autoflush => 1,

    }
);

# importa as funcoes para o script.
no strict 'refs';
*{"main::$_"} = *$_ for grep { defined &{$_} } keys %VotoLegal::Logger::;
use strict 'refs';

our @ISA = qw(Exporter);

our @EXPORT = qw(log_info log_fatal log_error get_logger);

my $logger = get_logger;

# logs
sub log_info {
    my (@texts) = @_;
    $logger->info( join ' ', @texts );
}

sub log_error {
    my (@texts) = @_;
    $logger->error( join ' ', @texts );
}

sub log_fatal {
    my (@texts) = @_;
    $logger->fatal( join ' ', @texts );
}

1;
