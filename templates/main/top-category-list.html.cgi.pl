

ul({},
  map {
    li({-class=>"inline",}, a({-href=>$c->url_for('поиск транспорта')->query(c=>$_->{id}),}, "$_->{title} ($_->{count})"),);
    
  } @{$c->stash('топ-категории')},

),