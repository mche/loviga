return
  unless $c->stash('топ-категории');

my $rows = @{$c->stash('топ-категории')}/3 + (@{$c->stash('топ-категории')}%3 ? 1 : 0);

table({-class=>"clearfix", -style=>"padding:1rem;"},
tbody({},
  map {
    Tr({-class=>"", -style000=>"padding: 0rem 0.5rem;",},
      map {
        td(
          a({-href=>$c->url_for('поиск транспорта')->query(c=>$_->{id}), -class=>"hover",}, "$_->{title} ($_->{count})"),
        );
      } @{$c->stash('топ-категории')}[($_*3)..($_*3+2)],
    );
    
  } (0..($rows-1)),

),),