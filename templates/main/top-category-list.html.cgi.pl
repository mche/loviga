

ul({},
  map {
    li({-class=>"inline chip", -style="margin: 0.3rem 0rem;",}, a({-href=>$c->url_for('поиск транспорта')->query(c=>$_->{id}),}, "$_->{title} ($_->{count})"),);
    
  } @{$c->stash('топ-категории')},

),