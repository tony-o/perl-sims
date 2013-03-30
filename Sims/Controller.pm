package Sims::Controller;

use strict;
use warnings;
use AnyEvent;
use Data::Dump qw(dump);
my @sims;

sub new{
  my $class = shift;
  my $self = {
    INTERVAL => 5    
    ,QUEUE => []
    ,SIMS => [] 
    ,SIMULATION_VARIABLES => {}
  };
  bless $self, $class;
  return $self;
}

sub go{
  my ($self,$params) = @_;
  $self->{INTERVAL} = $params->{INTERVAL} || $self->{INTERVAL};
  $self->{TIMER} = AE::timer 0, $self->{INTERVAL}, sub{
    foreach (@{$self->{QUEUE}}){
      $_->($self->{SIMULATION_VARIABLES});
    }
    foreach (@{$self->{SIMS}}){
      $_->{RUN}($self->{SIMULATION_VARIABLES}, 5);
    }
  };
  $self->{READY} = AE::cv;
  $self->{READY}->recv;
  return !0;
}


sub add_sim{
  my ($self,$sim) = @_;
  push(@{$self->{SIMS}}, $sim);
  return !0;
}

sub add_process{
  my ($self,$process) = @_;
  push(@{$self->{QUEUE}}, $process);
  return !0;
}

1;
