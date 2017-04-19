$c->layout('main', handler=>'ep',);
my $data = $c->stash('данные');

h1("Транспорт/услуга"),
#~ div({-style=>"white-space: pre-wrap;"},
  #~ $c->dumper($data),
#~ ),

div({-class=>"row"},

div({-class=>"col s12 m8 l8",},
  div({-class=>"card teal lighten-5",},
    div({-class=>"card-content",},
      h3('Категория'),
      div({-class=>"",},  (map {span({-class=>"breadcrumb black-text text-darken-4",}, $_->{title})} @{$data->{'категории'}}),),
    ),
  ),
  
  div({-class=>"card blue lighten-5",},
    div({-class=>"card-content",},
      h3('Основной адрес'),
      p({-class=>"chip white",}, $data->{"адрес"}),
    ),
  ),
  
  # дальность
  div({-class=>"card lime lighten-5",},
    div({-class=>"card-content",},
      h3('Режим выезда'),
      ul({-class=>"",}, map {li({}, i({-class=>"material-icons",}, 'check'), span($_->{title}))} @{$data->{"типы адреса"}}),
    ),
  ),
  
  div({-class=>"card teal lighten-5",},
    div({-class=>"card-content",},
      h3('Оплата'),
      ul({-class=>"collection000",},
        li({-class=>"collection-item000",},
          div(span("Повременная: "), span({-class=>"chip white black-text"}, $data->{price_hour} || '-'), span(" руб/час"),),
        ),
        li({-class=>"collection-item000",},
          div(span("Минимальное время: "), span({-class=>"chip white black-text"}, $data->{min_hour} || '-'),  span(" час"),),
        ),
        li({-class=>"collection-item000",},
          div(span("Километраж: "), span({-class=>"chip white black-text"}, $data->{price_km} || '-'),  span(" руб/км"),),
        ),
      ),
    ),
  ),
  
  div({-class=>"card brown lighten-5",},
    div({-class=>"card-content",},
      h3('Описание'),
      p({-class=>"", -style=>"white-space:pre;"}, esc($data->{"descr"}),),
    ),
  ),
  
  div({-class=>"card amber lighten-5",},
    div({-class=>"card-content",},
      h3('Статус на сегодня'),
      p({-class=>(defined $data->{"status"} ? $data->{"status"} ?"green green-text" : "red red-text" : "grey grey-text")." text-darken-4 lighten-3 chip", -style=>""}, defined $data->{"status"} ? $data->{"status"} ?"Свободен" : "Занят" : "Не определен",),
    ),
  ),
  
  div({-class=>"card orange lighten-5",},
    div({-class=>"card-content",},
      h3({-class=>"deep-orange-text",}, 'Использованные телефоны'),
      $data->{"показы телефонов"}
      ? ul({-class=>"collection"}, map {
        li({-class=>"collection-item"},
          span({-class=>"chip ".($_->{result} > 50 ? 'green-text' : '')}, $_->{"состояние"}),
          span({-class=>"deep-orange-text"},"+7 ".$_->{"телефон"}),
          span({-class=>"fs8 grey-text"}, $_->{"дата"}),
        )
      } @{$data->{"показы телефонов"}})
      : p("Получение телефонов этого транспорта через ", a({-href=>$c->url_for("поиск транспорта",)->query(c=>$data->{category})}, "создание заявки")),
    ),
  ),


),

div({-class=>"col s12 m4 l4"},
  ul({-class=>"collection",},
    (map {li({-class=>"collection-item",}, img({-src=>"$data->{img_path}$_", -style=>"width: 100%;",}),)} @{$data->{img}}),
    !@{$data->{img} || []} && li({-class=>"deep-purple-text center",},"Нет фото"),
  ),
),

), # end class=row