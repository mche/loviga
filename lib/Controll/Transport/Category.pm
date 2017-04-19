package Controll::Transport::Category;
use Mojo::Base 'Mojolicious::Controller';
use Model::Transport::Category;
#~ use Mojo::Home;
use Mojo::Util qw(steady_time);
use Mojo::Asset::File; # удалять файлы
use Mojo::JSON qw(encode_json);

=pod

=cut

my $model = Model::Transport::Category->new; # синглтон самого базового DBIx::Mojo::Model уже инициализирован! в плугине RoutesAuthDBI
my $home = Mojo::Home->new;
my $img_path;
my $asset_img = Mojo::Asset::File->new;

has static_dir => sub { shift->config('mojo_static_paths')->[0]; };
has category_count => sub {$model->category_count};# hashref

sub new {
  my $c = shift->SUPER::new(@_);
  $img_path = $c->config('Категории транспорта')->{img_path};
  $asset_img->path(sprintf("%s/%s%s/", $c->config('mojo_home'), $c->static_dir, $img_path, ));#$remove
  return $c;
}

sub tree {
  my $c = shift;
  $c->render(
    handler=>'ep',
    title=>'Категории транспортных средств',
    img_path=>$img_path,
    data_save_url=>$c->url_for('сохранение дерева категорий и пиктограмм'),
    data_url=>"/controllers/transport/category/tree.json",
    template_url => "/controllers/transport/category/tree.html",
    #~ stylesheets=>["/lib/angular-ui-tree/angular-ui-tree.min.css", "/controllers/transport/category/tree.css",],
    stylesheets=>["lib/angular-ui-tree/dist/angular-ui-tree.min.css", "/controllers/transport/category/tree.css",],
    javascripts => [qw(/lib/ng-file-upload/ng-file-upload-all.min.js /lib/angular-ui-tree/dist/angular-ui-tree.min.js /controllers/transport/category/tree.js)],
    
    #~ stylesheets=>["/lib/angular-ui-tree/angular-ui-tree.min.css", "/controllers/transport/category/style.css"], в шаблоне перенес
  
  );#javascripts=>["/lib/ng-file-upload/ng-file-upload-all.min.js", ""],)
}

sub data {
  my $c = shift;
  
  $c->render(json => $c->_unpack_tree(22, 1));
}

sub save {
  my $c = shift;
  if (my $tree = $c->req->json) {
    #~ $c->app->log->debug($c->dumper());
    
    my $pack = $c->_pack_tree({id=>0, childs=>[{id=>22, childs=>$tree}],});
    
    # <!-- файловая версия дерева категорий обновляется при изменениях -->
    my $file = Mojo::Asset::File->new;# Temporary file
    #~ $file->add_chunk($c->req->body)
    #~ $file->add_chunk(encode_json($pack->[0]))
    $file->add_chunk(encode_json $c->_unpack_tree(22) )
      ->move_to(sprintf("%s/%s/%s", $c->config('mojo_home'), $c->static_dir, "controllers/transport/category/tree.json"));
    
    $file = Mojo::Asset::File->new;
    $file->add_chunk( encode_json $model->категории_для_поиска() )
      ->move_to(sprintf("%s/%s/%s", $c->config('mojo_home'), $c->static_dir, "controllers/transport/category/search.json"));
    
    return $c->render(json=>$pack);
  }
  # картинка одной позиции
  elsif (my $img = $c->req->upload('img') ) {
    my $name = steady_time().".".$img->filename;
    if (my $remove = $c->req->param('remove_img')) {
      my $path = $asset_img->path;
      $asset_img->path($path."/".$remove)->move_to('/dev/null');
      $asset_img->path($path);
      #~ Mojo::Asset::File->new(path => sprintf("%s/%s%s/%s", $c->config('mojo_home'), $c->static_dir, $img_path, $remove));
    }
    $img->move_to(sprintf("%s/%s%s/%s", $c->config('mojo_home'), $c->static_dir, $img_path, $name));
    #~ my $dir = sprintf("/%s%s/%s", $c->static_dir, $img_path);
    $c->render(json=>{name=>$name,});#dir=>$img_path, 
  }
  
}


sub _unpack_tree {# рекурсивно распаковать список таблицы дерева в иерархию дерева
  my ($c, $node_id, $count) = @_;# count флажок количеств единиц в категориях
  my $childs = $model->expand_node($node_id);
  for my $child (@$childs) {
    $child->{_count} = $c->category_count->{$child->{id}}{count} // 0
      if $count;
    delete $child->{ts};
    $child->{_childs_ids} = delete $child->{childs}; # просто массив индексов потомков
    $child->{_img_url} = $child->{img} #$img_path . '/' . 
      if $child->{img};
    $child->{childs} = $c->_unpack_tree($child->{id}, $count);
  }
  return $childs;
}

sub _pack_tree {# рекурсивно упаковать структуру дерева в список таблицы
  my $c = shift;
  my ($parent, $childs) = @_; #@childs
  $childs ||= $parent->{childs};
  #~ $parent = $model->категория($parent)
    #~ unless ref $parent;
  #~ $parent->{childs} = \@childs;
  my $ret = [];# возвратить список сохраненых узлов
  while ( my $child = shift @$childs ) {
    my $childs = delete $child->{childs};
    $child->{childs} = [];# теперь тут иды
    for (@$childs) {
      $_->{id} ||= $model->sequence_next_val($model->{template_vars}{sequence});
      push @{$child->{childs}}, $_->{id};
    }
    $child->{parent} = $parent->{id};
    if ($child->{img} && !$child->{_img_url}) {# покинуть картинку
      my $path = $asset_img->path;
      $asset_img->path($path."/".$child->{img})->move_to('/dev/null');
      $asset_img->path($path);
      $child->{img} = undef;
    }
    my $skip_data = {};
    $skip_data->{$_} = delete $child->{$_} for grep /^_/, keys %$child;
    #~ $c->app->log->debug($c->dumper($child));
    my $node =  $model->сохранить_категорию($child);# 
    #~ $child->{_childs} = delete $child->{childs};
    #~ $child->{childs} = $childs;
    push @$ret, $node, @{$c->_pack_tree($node, $childs)};
  }
  return $ret;
}

#~ sub _nodes_id {# рекурсивно всем узлам назначить id, структура дерева полностью сохраняется
  #~ for my $node (@_) {
    #~ my $skiped_data = {};
    #~ $skiped_data->{$_} = delete $node->{$_} for grep /^_/ || !defined($node->{$_}), keys %$node;
    #~ my $childs = delete $node->{childs};
    #~ $node->{id} ||= $model->sequence_next_val($model->{template_vars}{schema}, $model->{template_vars}{sequence});# узла еще может не быть в базе
      #~ unless $node->{id};
    #~ $node->{childs} = $childs || [];
    #~ &_nodes_id(@{$node->{childs} || []});
  #~ }
  
#~ }





1;