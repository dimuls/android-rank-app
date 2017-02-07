#!/usr/bin/env perl

use lib 'lib';

use Mojolicious::Lite;
use AndroidRank;

get '/' => sub {
  my $c = shift;
  $c->render('index');
};

get '/details.json' => sub {
  my $c = shift;
  my $ext_id = $c->param('ext_id');
  my $details = AndroidRank->new->get_app_details(ext_id => $ext_id);
  $c->render(json => $details);
};

get '/suggest.json' => sub {
  my $c = shift;
  my $q = $c->param('q');
  my $suggest = AndroidRank->new->suggest(q => $q);
  $c->render(json => $suggest);
};

app->start;
