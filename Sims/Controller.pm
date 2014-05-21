package Sims::Controller;

use strict;
use warnings;
use AnyEvent;
use Data::Dump qw(dump);
my @sims;

sub new{
  my ($class) = @_;
  my $self = {
    INTERVAL => 5    
    ,QUEUE => []
    ,SIMULATION_VARIABLES => {}
    ,SIMS => {}
  };
  bless $self, $class;
  return $self;
}

sub looper {
  my ($self) = @_;
  foreach (@{$self->{QUEUE}}){
    $_->($self, $self->{SIMULATION_VARIABLES});
  }
  my ($k,$v);
  foreach (keys %{$self->{SIMS}}) {
    $k = $_;
    $v = $self->{SIMS}->{$k};
    next if !defined $self->{SIMS}->{$k};
    $v->{RUN}($self->{SIMULATION_VARIABLES}, 5);
  }
}

sub go{
  my ($self,$params) = @_;
  $self->{INTERVAL} = $params->{INTERVAL} || $self->{INTERVAL};
  $self->{TIMER} = AE::timer 0, $self->{INTERVAL}, sub { $self->looper };
  $self->{READY} = AE::cv;
  $self->{READY}->recv;
  return !0;
}


sub add_sim{
  my ($self,$sim) = @_;
  die 'ID ALREADY USED' if defined $self->{SIMS}->{$sim->{_ID}};
  $self->{SIMS}->{$sim->{_ID}} = $sim;
  return !0;
}

sub kill_sim{
  my ($self,$id) = @_;
  delete $self->{SIMS}->{$id};
}

sub sim_bus{
  my ($self, $id) = @_;
  return $self->{SIMS}->{$id};
  return !0;
}

sub add_process{
  my ($self,$process) = @_;
  push(@{$self->{QUEUE}}, $process);
  return !0;
}

1;
