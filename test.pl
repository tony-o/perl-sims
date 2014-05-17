#!/usr/bin/env perl

use strict;
use warnings;

use Modern::Perl;
use Data::Dump qw(dump);
use Sims::Controller;
use Sims::Humanoid;

my $controller = Sims::Controller->new();
my @sims;

foreach (1..20) {
  push(@sims, Sims::Player->new($_));
}

my $simrules = sub{
  my ($self, @env) = @_;
  say 'sim #' . $self->{_ID} . ' checking in';
};

foreach (@sims) { 
  $_->add_queue($simrules); 
  $controller->add_sim($_);
}

$controller->add_process(sub{
  my $session = shift;
#global rules
  return !0;
});


$controller->go({
  INTERVAL => 1 
});

