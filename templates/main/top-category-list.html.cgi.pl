

($c->stash('топ-категории') || '') && ul({-class=>"clearfix",},
  map {
    li({-class=>"inline chip", -style=>"margin: 0.1rem 0rem;",}, a({-href=>$c->url_for('поиск транспорта')->query(c=>$_->{id}),}, "$_->{title} ($_->{count})"),);
    
  } @{$c->stash('топ-категории')},

),