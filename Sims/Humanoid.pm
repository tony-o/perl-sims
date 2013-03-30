package Sims::Humanoid;

use strict;
use warnings;

use base 'Sims::Player';
use Data::Dump qw(dump);

sub new{
  my ($class, $id) = @_;
  my $self = $class->SUPER::new($id);
  $self->{SESSION} = {STATS=>{
    DAYS_ALIVE => 0
    ,TIME_AWAKE => 0
    ,FLAGS => {}
  }};
  $self->{SESSION}->{WAKEUP} = {START=>6.00,END=>8.00};
  $self->{SESSION}->{SLEEP} = {START=>19.50,END=>22.00};
  $self->{SESSION}->{AWAKE} = 0;
  push(@{$self->{QUEUE}}, sub{
    my $env = shift;
    my $hum = $self->{SESSION};

#RULES
    my $tod = $env->{HOUR_OF_DAY} + ($env->{MINUTE_OF_DAY} / 60);
    if($tod >= $hum->{WAKEUP}->{START} && $tod <= $hum->{WAKEUP}->{END} && !$hum->{AWAKE}){
      my $distribution = abs(((($hum->{WAKEUP}->{END} - $hum->{WAKEUP}->{START})*.5) + $hum->{WAKEUP}->{START} - $tod)*.75) + .25;
      if(rand() > $distribution){
        $hum->{AWAKE} = 1;
        print "humanoid #$self->{_ID} has woken up $tod\n";
        $hum->{STATS}->{FLAGS}->{AWAKE} = $tod;
      }
    }
    if($tod >= $hum->{SLEEP}->{START} && $tod <= $hum->{SLEEP}->{END} && $hum->{AWAKE}){
      my $distribution = abs(((($hum->{SLEEP}->{END} - $hum->{SLEEP}->{START})*.5) + $hum->{SLEEP}->{START} - $tod)*.75) + .25;
      if(rand() > $distribution){
        $hum->{AWAKE} = 0;
        print "humanoid #$self->{_ID} has went to bed $tod\n";
        $hum->{STATS}->{TIME_AWAKE_YESTERDAY} = $tod - $hum->{STATS}->{FLAGS}->{AWAKE};
        $hum->{STATS}->{TIME_AWAKE} += $tod - $hum->{STATS}->{FLAGS}->{AWAKE};
        $hum->{STATS}->{DAYS_ALIVE}++;
        dump $hum->{STATS};
      }
    }

    return !0;
  });

  bless $self, $class;
  return $self;
}

1;
