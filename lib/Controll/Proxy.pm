package Controll::Proxy;
use Mojo::Base 'Mojolicious::Controller';
use Proxy;

has dbh => sub { shift->app->dbh->{'main'} };

has proxy_handler => sub {  Proxy->new(dbh=>shift->dbh); };

sub index {
  my $c = shift;
  #~ $c->render(title => 'Прокси');
  $c->render(format=>'txt', text=>$c->dumper($c->proxy_handler->proxy_list));
}


sub proxy_load {
  my $c = shift;
  $c->render(format=>'txt', text=>$c->dumper([$c->proxy_handler->proxy_load]));
}


sub use_proxy {
  my $c = shift;
  my $r = $c->proxy_handler->use_proxy
    || ($c->proxy_handler->proxy_load && $c->proxy_handler->use_proxy);
  #~ $c->render(json=>$r);
  $c->render(format=>'txt', text=>"$r->{type}://$r->{proxy} === ". $c->dumper($c->proxy_handler->check_proxy($r)));
}


1;