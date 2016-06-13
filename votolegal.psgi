use strict;
use warnings;

use VotoLegal;

my $app = VotoLegal->apply_default_middlewares(VotoLegal->psgi_app);
$app;

