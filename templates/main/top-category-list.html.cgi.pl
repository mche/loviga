return
  unless $c->stash('топ-категории');

my $rows = @{$c->stash('топ-категории')}/3 + (@{$c->stash('топ-категории')}%3 ? 1 : 0);

table({-class=>"clearfix", -style=>""},
tbody({},
  map {
    Tr({-class=>"", },
      map {
        td({-style=>"padding: 0rem 1rem; width:33.3%",},
          a({-href=>$c->url_for('поиск транспорта')->query(c=>$_->{id}), -class=>"hover",}, "$_->{title} ($_->{count})"),
        );
      } @{$c->stash('топ-категории')}[($_*3)..($_*3+2)],
    );
    
  } (0..($rows-1)),

),),