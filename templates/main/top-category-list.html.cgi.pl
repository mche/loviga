return
  unless $c->stash('топ-категории');

my $rows = @{$c->stash('топ-категории')}/3 + (@{$c->stash('топ-категории')}%3 ? 1 : 0);

div({-class=>"container clearfix"},
table({-class=>"card teal lighten-5", -style=>""},
tbody({},
  map {
    Tr({-class=>"", },
      map {
        td({-style=>"padding: 0rem 1rem; width:33.3%",},
          a({-href=>$c->url_for('поиск транспорта')->query(c=>$_->{id}), -class=>"hover fs12 black-text nowrap",},
            span($_->{title}),
            sup({-class=>"chip fs8 teal-text"}, $_->{count}),
          ),
        );
      } @{$c->stash('топ-категории')}[($_*3)..($_*3+2)],
    );
    
  } (0..($rows-1)),

),),
),