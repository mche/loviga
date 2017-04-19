$c->layout('main', handler=>'ep',);


#~ a({-class=>"btn btn-large black-text teal lighten-1", -href=>$c->url_for('мой транспорт')}, "Мой транспорт")

my $select_id = $c->param('select_id') || ($c->req->url->fragment =~ /(\d+)/)[0];
#~ $c->app->log->debug($c->req->url, $c->req->url->fragment);
my $count = scalar @{$c->stash('список')};


div({-class=>"right-align"},
  a({-class=>"btn", href=>$c->url_for("форма транспорта", id=>0),},
    i({ -class=>"material-icons"}, 'add'),
    span({}, "Добавить"),
  ),
),

h3($c->title." ($count)"),


ul({-class=>"collection", "ng-app"=>"ListTransport", "ng-controller"=>"ControllListTransport as ctrl", "data-form-url"=>$c->url_for('форма транспорта'),},
  map {
    li({-id=>"transport$_->{id}", -class=>"collection-item click000 ". ($select_id && $_->{id} eq $select_id ? " selected " : "") . ($_->{disabled} ? " disabled " : ""),  },#"ng-click"=>"ctrl.openTransport($_->{id})", "data-transport-id"=>$_->{id},
      a({-href=>$c->url_for('форма транспорта', id=>$_->{id}), -class=>"waves-effect waves-teal ",},
        span({-class="",}, "Занят/свободен"),
        img({-src=>$_->{img_url}, -alt=>"", -class=>"circle", -style=>" height: 45px; width000:45px; vertical-align: middle;",}),
        #~ div({-style=>"white-space: pre-wrap;"}$c->dumper($_)),
        #~ $_->{id},
        span(map(span({-class=>"breadcrumb teal-text"}, $_->{title}), @{$_->{"категории"}}),),
      ),
      
      $_->{disabled} ? i({-class=>"material-icons right",}, "visibility_off",) : '',
    
    );
  }  @{$c->stash('список')},
  
),


