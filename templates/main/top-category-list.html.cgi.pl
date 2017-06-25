

($c->stash('топ-категории') || '') && ul({-class=>"clearfix center", -style=>"padding:1rem;"},
  map {
    li({-class=>"inline", -style=>"padding: 0rem 0.5rem;",}, a({-href=>$c->url_for('поиск транспорта')->query(c=>$_->{id}), -class=>"hover",}, "$_->{title} ($_->{count})"),);
    
  } @{$c->stash('топ-категории')},

),