#!/usr/bin/env perl

use strict;
use warnings;

use Modern::Perl;
use Data::Dump qw(dump);
use Sims::Controller;
use Sims::Humanoid;

my $controller = Sims::Controller->new();
my @sims;

foreach (1..2) {
  push(@sims, Sims::Player->new($_));
}


my @grid;
foreach (0..2){ push @grid, [0,0,0];};# [0,0,0, 0,0,0, 0,0,0, 0]; }
my $simrules = sub{
  my ($self, @env) = @_;
  if (!defined $self->{X}) {
    $self->{X} = int(rand(3));
    $self->{Y} = int(rand(3));
  }
  my $nextdir = int(rand(4));
  say "ID: " . $self->{_ID};
  # 0 = left, 1 = up, 2 = right, 3 = down
  $grid[$self->{X}][$self->{Y}] = 0;
  $self->{X}-- if ($nextdir == 0 && $self->{X} - 1 >= 0);
  $self->{X}++ if ($nextdir == 2 && $self->{X} + 1 < 3);
  $self->{Y}-- if ($nextdir == 1 && $self->{Y} - 1 >= 0);
  $self->{Y}++ if ($nextdir == 3 && $self->{Y} + 1 < 3);
  if ($grid[$self->{X}][$self->{Y}] != 0) {
    my $killid = $controller->sim_bus($grid[$self->{X}][$self->{Y}]);
    say "kill:" . $killid->{_ID};
    $controller->kill_sim($killid->{_ID});
    my $newsim = Sims::Player->new(scalar(@sims) + 1);
    say "add:" . $newsim->{_ID};
    push @sims, $newsim;
    $controller->add_sim($newsim);
    setupsim($newsim);
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
  say '-';
  return !0;
});


$controller->go({
  INTERVAL => 1, 
});

