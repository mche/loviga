package Controll::Address;
use Mojo::Base 'Mojolicious::Controller';
#~ use Model::Address;

#~ my $model = Model::Address->new; #
has model => sub {shift->app->models->{'Address'}};

sub search {
  my $c=shift;
  
  my @q = grep /[\dа-я-]/, map s/[^\s\dа-я-"]+//gr, map s/\s+/ /gr,$c->vars('q');
  
  $c->render(json=>[])
    unless @q && length $q[0] > 2;
  #~ sleep 3;
  
  my @data = map {
    $c->model->полный_адрес_формат($_);
  } @{ $c->model->поиск([map("\\m".lc, @q)], 20) };# лимит 10
  
  
  $c->render(json=>\@data);
  
  #~ $c->render(json=>[({full=>"ok, @q"}) x 10]);
  
  
}

sub поиск_город {
  my $c=shift;
  
  my @q = grep /[\dа-я-]/, map s/[^\s\dа-я-"]+//gr, map s/\s+/ /gr,$c->vars('q');
  
  $c->render(json=>[])
    unless @q && length $q[0] > 2;
  #~ sleep 3;
  
  my @data = map {
    $c->model->полный_адрес_формат($_);
  } @{ $c->model->поиск_город(join('', map("\\m".lc.".*", @q)), 20) };# лимит 10
  
  
  $c->render(json=>\@data);
  
}

sub addr_type {
  my $c=shift;
  $c->render(json=>$c->model->addr_type);
}

1;