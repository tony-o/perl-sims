use strict;
use warnings;

use Data::Dump qw(dump);
use Sims::Controller;
use Sims::Humanoid;

my $controller = Sims::Controller->new();
my @sims;

push(@sims, Sims::Humanoid->new(0));
push(@sims, Sims::Humanoid->new(1));
$controller->add_sim($sims[0]);
$controller->add_sim($sims[1]);


$controller->add_process(sub{
  my $session = shift;
  $session->{HOUR_OF_DAY} = 0 unless defined $session->{HOUR_OF_DAY};
  $session->{MINUTE_OF_DAY} = 0 unless defined $session->{MINUTE_OF_DAY};
  $session->{MINUTE_OF_DAY} += 3;
  if($session->{MINUTE_OF_DAY} >= 60){
    $session->{HOUR_OF_DAY} += ($session->{HOUR_OF_DAY} == 23 ? -23 : 1);
    $session->{MINUTE_OF_DAY} = 0;
  }
  $session->{TIME_OF_DAY} = sprintf "%02d:%02d", $session->{HOUR_OF_DAY}, $session->{MINUTE_OF_DAY};
  return !0;
});


$controller->go({
  INTERVAL => .005 
});

