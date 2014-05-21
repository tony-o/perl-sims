#!/usr/bin/env perl

use strict;
use warnings;

use Modern::Perl;
use Data::Dump qw(dump);
use Sims::Controller;
use Sims::Humanoid;

my $controller = Sims::Controller->new();
my @sims;
my $simcount = 90;

foreach (1 .. $simcount) {
  push(@sims, Sims::Player->new($_));
}


sub winner {
  my ($sim1,$sim2) = @_;

  return 1 if $sim1->{STR} >= $sim2->{STR};
  return 0;
}

my @grid;
my $gridsize = 10;
foreach (0 .. $gridsize-1){ push @grid, [((0) x $gridsize)];};
my $simrules = sub{
  my ($self, @env) = @_;
  if (!defined $self->{X}) {
    my ($x,$y) = (int(rand($gridsize)),int(rand($gridsize)));
    while ($grid[$x][$y] != 0) {
      ($x,$y) = (int(rand($gridsize)),int(rand($gridsize)));
    }
    $self->{X} = $x;
    $self->{Y} = $y;
    $self->{STR} = int(rand(100));
  }
  my $nextdir = int(rand(5));
  #say "ID: " . $self->{_ID} . "\t" . $self->{STR};
  # 0 = left, 1 = up, 2 = right, 3 = down, 4 = nothing
  $grid[$self->{X}][$self->{Y}] = 0;
  $self->{X}-- if ($nextdir == 0 && $self->{X} - 1 >= 0);
  $self->{X}++ if ($nextdir == 2 && $self->{X} + 1 < $gridsize);
  $self->{Y}-- if ($nextdir == 1 && $self->{Y} - 1 >= 0);
  $self->{Y}++ if ($nextdir == 3 && $self->{Y} + 1 < $gridsize);
  if ($grid[$self->{X}][$self->{Y}] != 0) {
    my $battleid = $controller->sim_bus($grid[$self->{X}][$self->{Y}]);
    my $result   = winner($self, $battleid);
    $controller->kill_sim($battleid->{_ID}) if $result == 1;
    $controller->kill_sim($self->{_ID}) if $result == 0;
    #my $newsim = Sims::Player->new(scalar(@sims) + 1);
    #say "add:" . $newsim->{_ID};
    #push @sims, $newsim;
    #$controller->add_sim($newsim);
    #setupsim($newsim);
    return if $result == 0;
  }
  $grid[$self->{X}][$self->{Y}] = $self->{_ID};

};
sub setupsim {
  my ($sim) = @_;
  $sim->add_queue($simrules);
}

foreach (@sims) { 
  setupsim($_);
  $controller->add_sim($_);
}

$controller->add_process(sub{
  my ($self,$session) = @_;
  #global rules
  say '-';
  foreach (@grid) {
    foreach (@{$_}) {
      printf "%03d ", $_;
    }
    print "\n";
  }
  $self->{POPULATION} = 1 if !defined $self->{POPULATION};
  say '- ' . sprintf("%02d", scalar(keys %{$self->{SIMS}}) * 100 / $self->{POPULATION}) . ', ' . scalar(keys %{$self->{SIMS}});
  $self->{POPULATION} = scalar(keys %{$self->{SIMS}});
  $self->{READY}->send if $self->{POPULATION} == 1;
  return !0;
});


$controller->go({
  INTERVAL => 1, 
});

