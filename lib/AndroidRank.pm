package AndroidRank;

use Mojo::Base -base;

use Mojo::UserAgent;
use Mojo::Util qw/url_escape trim/;
use Mojo::JSON qw/decode_json/;

sub suggest {
  my ($self, %args) = @_;
  my $q = url_escape($args{q});
  my $url = $self->_url("searchjson?name_startsWith=$q");
  my $res = Mojo::UserAgent->new->get($url)->res->body;
  $res = substr $res, 1, -2;
  $res = decode_json($res);
  return [ map {
    { title => $_->{name}, ext_id => $_->{appid} };
  } @{$res->{geonames}} ];
}

sub get_app_details {
  my ($self, %args) = @_;
  my $url = $self->_url("details?id=$args{ext_id}");
  my $dom = Mojo::UserAgent->new->max_redirects(5)->get($url)->res->dom;
  my $details = {};
  $details->{title} = $dom->at('[itemprop="name"]')->text;
  ($details->{artist_id}) = $dom->at('h1')->next->at('a')->attr('href') =~ /id=([^&]+)/;
  $details->{artist_name} = $dom->at('h1')->next->at('a')->text;
  $details->{short_text} = trim $dom->at('#content')->children->[0]->children->[1]->all_text;
  $details->{icon} = eval { $dom->at('[itemprop="image"]')->attr('src') };
  $details->{app_info} = {
    @{$dom->find('table.appstat')->[0]->find('tbody tr')->map(sub {
      $_->at('th')->all_text => $_->at('td')->all_text;
    })->to_array}
  };
  $details->{app_installs} = {
    @{$dom->find('table.appstat')->[2]->find('tbody tr')->map(sub {
      $_->at('th')->all_text => $_->at('td')->all_text;
    })->to_array},
    # + бага в вёрстке
    $dom->find('table.appstat')->[2]->find('tbody > th')->first->all_text,
    $dom->find('table.appstat')->[2]->find('tbody > td')->first->all_text,
  };
  $details->{rating_values} = {
    @{$dom->find('table.appstat')->[3]->find('tbody tr')->map(sub {
      $_->at('th')->all_text => $_->at('td')->all_text;
    })->to_array},
  };
  $details->{rating_scores} = {
    @{$dom->find('table[itemprop="aggregateRating"] tbody tr')->map(sub {
      $_->at('th')->all_text => $_->at('td')->all_text;
    })->to_array},
  };
  $details->{country_ratings} = {
    # не понятно откуда брать, на странице нет такой инфы.
  };
  return $details;
}

sub _url {
  my ($self, $path) = @_;
  return "http://www.androidrank.org/$path";
}

1;
