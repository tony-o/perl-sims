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
    ,IDCACHE => {}
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
  foreach (keys %{$self->{IDCACHE}}) {
    $k = $_;
    $v = $self->{IDCACHE}->{$k};
    next if !defined $self->{IDCACHE}->{$k};
    print "run: " . $v->{_ID}, "\n";
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
  die 'ID ALREADY USED' if defined $self->{IDCACHE}->{$sim->{_ID}};
  $self->{IDCACHE}->{$sim->{_ID}} = $sim;
  print "IDCACHE: " . $sim->{_ID} . "\n";
  return !0;
}

sub kill_sim{
  my ($self,$id) = @_;
  print "del: $id\n";
  delete $self->{IDCACHE}->{$id};
}

sub sim_bus{
  my ($self, $id) = @_;
  return $self->{IDCACHE}->{$id};
  return !0;
}

sub add_process{
  my ($self,$process) = @_;
  push(@{$self->{QUEUE}}, $process);
  return !0;
}

1;
