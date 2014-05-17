package Sims::Player;

use strict;
use warnings;

sub new{
  my $class = shift;
  my $self = {
    _ID => shift
    ,QUEUE => []
  };
  my $runner = sub{
    my ($env) = @_;
    foreach (@{$self->{QUEUE}}){
      $_->($self, $env);
    }
    return !0;
  };
  $self->{RUN} = $runner;
  bless $self, $class;
  return $self;
};

sub add_queue{
  my ($self, $sub) = @_;
  push(@{$self->{QUEUE}}, $sub);
  return !0;
}

1;
