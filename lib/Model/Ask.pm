package Model::Ask;
use Mojo::Base 'Model::Base';

my $main_table ="заявки";

sub new {
  state $self = shift->SUPER::new(@_);
  $self->template_vars->{tables}{main} = $main_table;
  $self->dbh->do($self->sth('таблицы'));
  $self->dbh->do($self->sth('функции'));
  return $self;
}

sub сохранить {
  my ($self, $data) = @_;
  return $self->обновить_или_вставить($self->template_vars->{schema}, $main_table, ["id"], $data, );  
}

sub сохранить_состояние {
  my ($self, $data) = @_;
  return $self->вставить($self->template_vars->{schema}, "состояния заявок", undef, $data, );  
}

sub список {#  пользователя
  my ($self, $user_id) = @_;
  $self->dbh->selectall_arrayref($self->sth('список'), { Slice=> {} }, $user_id);
}

sub позиция {# с учетом доступа
  my ($self, $id, $user_id) = @_;
  $self->dbh->selectrow_hashref($self->sth('позиция'), undef, $id, $user_id);
}

sub состояния_заявки {#  
  my ($self, $id) = @_;
  $self->dbh->selectall_arrayref($self->sth('состояния заявки'), { Slice=> {} }, $id);
}

sub состояние_заявки {
  my ($self, $id) = @_;
  $self->dbh->selectrow_array($self->sth('текущее состояние заявки'), undef, $id);
}

#~ sub кнопка_состояния {
  #~ my ($self, $id) = @_;
  #~ $self->dbh->selectrow_hashref($self->sth('кнопка состояния'), undef, $id);
#~ }

sub список_для_моего_транспорта {#  исп
  my ($self, $uid) = @_;
  $self->dbh->selectall_arrayref($self->sth('список для моего транспорта'), { Slice=> {} }, $uid);
}

sub новые_заявки_для_моего_транспорта {#  исп
  my ($self, $uid) = @_;
  $self->dbh->selectall_arrayref($self->sth('новые заявки для моего транспорта'), { Slice=> {} }, $uid);
}

sub состояния_заявки_по_транспорту000 {#  
  my ($self, $id, $tran_id) = @_;
  $self->dbh->selectall_arrayref($self->sth('состояния заявки по транспорту'), { Slice=> {} }, $id, $tran_id);
}

sub доступ_к_состояниям_заявки {
  my ($self, $uid, $ask) = @_;
  $self->dbh->selectrow_hashref($self->sth('доступ к состояниям заявки'), undef, ($uid, $ask) x 2);
}

sub показ_телефона {
  my ($self, $id,) = @_;
  return $self->dbh->selectrow_hashref($self->sth('показ телефона'), undef, ($id));
    #~ || {error=>"Не найден телефон, возможно, транспорта нет или не активирован"};
}

sub результат_показа_телефона {
  my ($self, $data) = @_;
  $self->вставить($self->template_vars->{schema}, "показы телефонов", [], $data,);#["object","tel", "caller"] , {"upd_ts"=>"now()"}
}

sub есть_новые_заявки {# из главного меню header.html.cgi.pl
  my ($self, $uid,) = @_;
  $self->dbh->selectrow_array($self->sth('есть новые заявки для моего транспорта'), undef, ($uid));
}

sub есть_заявки {# из главного меню header.html.cgi.pl
  my ($self, $uid,) = @_;
  $self->dbh->selectrow_array($self->sth('есть заявки для моего транспорта'), undef, ($uid));
}

sub есть_мои_заявки {# из главного меню header.html.cgi.pl
  my ($self, $uid,) = @_;
  $self->dbh->selectrow_array($self->sth('есть мои заявки'), undef, ($uid));
}

1;

__DATA__
@@ таблицы
create table IF NOT EXISTS "{%= $schema %}"."{%= $tables->{main} %}" (
  id integer  NOT NULL DEFAULT nextval('{%= $sequence %}'::regclass) primary key,
  ts  timestamp without time zone NOT NULL DEFAULT now(),
  category int not null,
  addr_type int not null, -- крыжик типов действия адресов: [<местные перевозки в пределах адреса>, <межгород>, <международные перевозвки из/в адреса>]
  address uuid not null,
  date timestamp without time zone not null,
  tel text not null,
  comment text,
  disabled boolean
  --transport int null
);

create table IF NOT EXISTS "{%= $schema %}"."состояния заявок" (
/*
В этой таблице нет состояний Просроченная и Активная, которые вычисляются по дате заявки
*/
  ---id integer  NOT NULL DEFAULT nextval('{%= $sequence %}'::regclass) primary key,
  ts  timestamp without time zone NOT NULL DEFAULT now(),
  --"ид связи"  int not null, -- связь транспорт->заявка или заявка/транспорт
  "заявка" int not null,
  ---"транспорт" int not null,
  "установил" int not null, -- ид заказчика или исполнителя
  "состояние" int2 not null, -- из функции "Коды состояния"()
  "коммент" text
  ---unique("заявка", ts), --- индекс выборки состояний по транспорту?
  ---unique("заявка", "транспорт", "установил", "состояние")
);
CREATE OR REPLACE FUNCTION ts_md5(ts timestamp) 
RETURNS char(32) AS $BODY$
select md5($1::text)::char(32);
$BODY$
LANGUAGE sql
IMMUTABLE;
---- Обязательно IMMUTABLE функция для индекса
create unique index IF NOT EXISTS "состояния заявок_заявка_ts_md5_udx" on  "состояния заявок"  ("заявка", ts_md5(ts));

@@ список?cached=1
select a.*,
  to_char(a.date, 'TMday DD.MM.YYYY в HH24:MI') as "дата выезда",
  to_char(a.ts - interval '2 hours', 'TMday DD.MM.YYYY в HH24:MI') || ' (MSK)' as "дата создания",
  t.id as transport,
  ---array[ -- два состояния для просроченных и активных по дате
    {%= $dict->render('коды состояния') %} -- текущее явное состояние (по табл состояний)
    ---case when s."код состояния"<50 and tz."интервал" < interval '0 second' then 20 when s."код состояния"<50 then 50 else null end -- случаи для отказных и отклоненных
  ---]::int[] 
  as "состояние" -- текущее последнее
from "{%= $schema %}"."{%= $tables->{main} %}" a
  join "{%= $schema %}"."{%= $tables->{refs} %}" ru on a.id=ru.id2
  left join ( {%= $dict->render('связь заявка/транспорт') %} ) t on a.id=t.ask_id
  left join lateral (select * from "история состояний заявки"(a.id) order by ts desc limit 1) s on true --- только последнее/текущее
  , fias."дата по адресу"(a.address, a.date) tz -- uuid, timestamp
  
where ru.id1=? -- user
--order by a.ts
;

@@ список для моего транспорта
-- по состоянию в таблице "состояния заявок"
-- через связь заявка/транспорт!!!
select a.*,
  to_char(a.date, 'TMday DD.MM.YYYY в HH24:MI') as "дата выезда",
  t.id as "транспорт",
  t.id as transport
  --- состояния отдельный запрос ---s."код состояния", s."состояние",  s."дата состояния"
from "{%= $schema %}"."{%= $tables->{refs} %}" ru
  join "{%= $schema %}"."транспорт" t on ru.id2=t.id
  join ( {%= $dict->render('связь заявка/транспорт') %} ) ta on t.id=ta.id
/*
  join lateral (-- получить массив моих транспортов в заявках
    select "заявка", array_agg("транспорт") as "транспорт"--, max(ts) as ts
    from (
      select "транспорт", "заявка", max(ts) as ts
      from "{%= $schema %}"."состояния заявок"
      where "транспорт"=t.id
      group by "транспорт", "заявка"
      order by 2, 3 desc
    ) g
    group by "заявка"
  ) ta on true
*/
  join "{%= $schema %}"."{%= $tables->{main} %}" a on a.id=ta.ask_id
  --состояния отдельный запрос--join lateral (select * from "история состояний заявки"(a.id) where ta."транспорт"[1]="транспорт" order by ts desc limit 1) s on true --- только последнее/текущее
  
where ru.id1=?-- исполнитель


@@ новые заявки для моего транспорта
-- через связь транспорт/заявка!!!
select a.*,
  to_char(a.date, 'TMday DD.MM.YYYY в HH24:MI') as "дата выезда",
  t.id as "транспорт?", t.id as _transport, -- это еще не тот транспорт
  ---s."заявка" as "состояние/заявка", -- если null значит новая заявка
  to_char(r.ts - interval '2 hours', 'TMday DD.MM.YYYY в HH24:MI') || ' (MSK)' as "дата состояния" -- 
  ---p.id as "заказчик"
from "{%= $schema %}"."{%= $tables->{refs} %}" ru
  join "{%= $schema %}"."транспорт" t on ru.id2=t.id
  join "{%= $schema %}"."{%= $tables->{refs} %}" r on t.id=r.id1
  join "{%= $schema %}"."заявки" a on r.id2=a.id
  ---join "{%= $schema %}"."{%= $tables->{refs} %}" ra on ra.id2=a.id -- связь с заказчиком
  ---join "{%= $schema %}"."{%= $tables->{profiles} %}" p on ra.id1=p.id
  ---left join "{%= $schema %}"."состояния заявок" s on a.id=s."заявка"
  ---left join lateral (select * from "состояния заявок" where "заявка"=a.id order by ts desc limit 1) s on true
  
where ru.id1=?-- исполнитель
  ---and s."заявка" is null
  and (t."status" or not(t."status")) -- and tz."завтра"))


@@ есть новые заявки для моего транспорта?cached=1
select count(distinct a.id) as cnt
from ( {%= $dict->render('новые заявки для моего транспорта') %} ) a;

@@ есть заявки для моего транспорта?cached=1
select count(distinct a.id) as cnt
from ( {%= $dict->render('список для моего транспорта') %} ) a;

@@ есть мои заявки?cached=1
select count(a.id) as cnt
from "{%= $schema %}"."{%= $tables->{main} %}" a
  join "{%= $schema %}"."{%= $tables->{refs} %}" ru on a.id=ru.id2
where ru.id1=?


@@ позиция?cached=1
-- с учетом доступа
select a.*,
  t.id as transport,
   to_char(a.ts - interval '2 hours', 'TMday DD.MM.YYYY в HH24:MI') || ' (MSK)' as "дата создания",
   to_char(tz."MSK", 'TMday DD.MM.YYYY в HH24:MI') || ' (MSK)' as "дата",
   c.id as "код состояния",
   c."состояние" as "состояние" -- текущее состояние по дате
from "{%= $schema %}"."{%= $tables->{main} %}" a
  join "{%= $schema %}"."{%= $tables->{refs} %}" ru on a.id=ru.id2
  left join ( {%= $dict->render('связь заявка/транспорт') %} ) t on a.id=t.ask_id
  , fias."дата по адресу"(a.address, a.date) tz -- uuid, timestamp
  , "Коды состояния"() c
-- привязки транспортов и состояния обслуживания отдельно список

where a.id=? and ru.id1=?
  and c.id = case
    when tz."интервал" < interval '0 second' then 20 -- просроченные
    else 50 -- еще активные
  end
;


@@ состояния заявки?cached=1
-- только по таблице!
select *
from "история состояний заявки"(?)
order by ts --- сортировка в перле с учетом просроченности может быть после 
;

@@ состояния заявки по транспорту000?cached=1
-- только по таблице!
select *
from "история состояний заявки"(?)
where "транспорт"=?
---order by ts desc
;

@@ текущее состояние заявки0000?cached=1
select --a.*,
  ---to_char(a.date, 'TMday DD.MM.YYYY в HH24:MI') as "дата выезда",
  --t.id as transport,
  ----coalesce(s."код состояния", 10) as "код состояния",
  {%= $dict->render('коды состояния') %} as "код состояния"
  
from "{%= $schema %}"."{%= $tables->{main} %}" a
  left join 
  ( {%= $dict->render('связь заявка/транспорт') %} ) t on a.id=t.ask_id
  left join lateral (select * from "история состояний заявки"(a.id) order by ts desc limit 1) s on true
  , fias."дата по адресу"(a.address, a.date) tz -- uuid, timestamp
where a.id=?;

@@ текущее состояние заявки?cached=1
select "код состояния"
from "история состояний заявки"(?::int)
order by ts desc
limit 1;



@@ кнопка состояния0000
SELECT *
FROM "кнопка состояния"(?); -- код состояния

@@ коды состояния
-- подселект
  case
    when s."код состояния" is not null then s."код состояния" -- 
    --when t.id is not null then  -- принятые
    when tz."интервал" < interval '0 second' then 20 -- просроченные
    else 50 -- еще активные
  end

@@ связь заявка/транспорт
select r.id1 as ask_id, t.id
from "{%= $schema %}"."транспорт" t
  join "{%= $schema %}"."{%= $tables->{refs} %}" r on t.id=r.id2



@@ доступ к состояниям заявки
-- или заказчик или исполнитель транспорта привязанного к заявке
select *
from "{%= $schema %}"."{%= $tables->{refs} %}"
where 
  id1=? -- заказчик
  and id2=? -- заявка
  UNION
select r2.*
from 
  "{%= $schema %}"."{%= $tables->{refs} %}" r1 -- связь с исполнителем
  join "{%= $schema %}"."транспорт" t on r1.id2=t.id
  join "{%= $schema %}"."{%= $tables->{refs} %}" r2 on r2.id2=t.id -- связь заявки с транспортом

where 

r1.id1=? -- исполнитель
  and r2.id1=? -- заявка

@@ показ телефона
select tel
from "{%= $schema %}"."заявки"
where id=?;

@@ функции
CREATE or REPLACE FUNCTION "Коды состояния"()
RETURNS TABLE("id" int, "состояние" text, "заголовок списка" text, "заголовок кнопки" text, "class-bg" text, "class-text" text, "icon" text, "ид кнопки" int) AS $func$
/* После изменений копипастить
  SELECT array_to_json(array_agg(t)) FROM "Коды состояния"() t
  в файл static/controllers/states/data.js
*/
SELECT *
FROM (VALUES
  (1, 'Созданная', 'Созданные', 'Создание', '', 'black-text', null, null),
  (10, 'Новая', 'Новые', 'Новая', '', 'black-text', 'icon-hand-paper-o fs12', null),
  (50, 'Активная', 'Активные', 'Активно', 'deep-purple', 'deep-purple-text', 'icon-ok-2 fs12', null),
  (20, 'Просроченная', 'Просроченные', 'Просрочено', 'grey darken-2', 'grey-text text-darken-2', 'icon-stopwatch fs12', null),
  
  
  (60, 'Принятая', 'Принятые', 'Заказ принят', 'green darken-3', 'green-text text-darken-3', 'icon-handshake-o fs12', 1),
  (100, 'Завершенная', 'Завершенные', 'Завершено', 'lime darken-4', 'lime-text text-darken-4', 'icon-thumbs-up fs12', null),
  (101, 'Завершенная', 'Завершенные', 'Завершено', 'lime darken-4', 'lime-text text-darken-4', 'icon-thumbs-up fs12', null), -- 100 + оценка 1
  (102, 'Завершенная', 'Завершенные', 'Завершено', 'lime darken-4', 'lime-text text-darken-4', 'icon-thumbs-up fs12', null), -- 100 + оценка 2
  (103, 'Завершенная', 'Завершенные', 'Завершено', 'lime darken-4', 'lime-text text-darken-4', 'icon-thumbs-up fs12', null), -- 100 + оценка 3
  (104, 'Завершенная', 'Завершенные', 'Завершено', 'lime darken-4', 'lime-text text-darken-4', 'icon-thumbs-up fs12', null), -- 100 + оценка 4
  (105, 'Завершенная', 'Завершенные', 'Завершено', 'lime darken-4', 'lime-text text-darken-4', 'icon-thumbs-up fs12', null), -- 100 + оценка 5
  -----------------------------------------------
  (30, 'Отказная', 'Отказанные', 'Отказано', 'red darken-3', 'red-text text-darken-3', 'icon-thumbs-down fs12', 2), -- не принятая исполнителем
  (40, 'Отклонённая', 'Отклонённые', 'Не подходит', 'red darken-1', 'red-text text-darken-1', 'icon-thumbs-down fs12', 3), --- отклонено заказчиком, условия
  (45, 'Отмененная', 'Отмененные', 'Отмена', 'red', 'red-text', 'icon-thumbs-down fs12', null),-- после того как была принятая
  -----------------------------------------------
  -----------------------------------------------
  ---(2, 'Нет связи', null, null, 'yellow darken-3', 'yellow-text text-darken-3', 'phonelink_erase', 4),
  (2, 'Нет связи', null, null, 'yellow darken-3', 'yellow-text text-darken-3', 'icon-mobile-alt icon-stack-1x fs18, icon-cancel icon-stack-1x red-text', 4),
  (4, 'Не отвечает', null, null, 'yellow darken-4', 'yellow-text text-darken-4', 'icon-mobile-alt icon-stack-1x fs18, icon-cancel icon-stack-1x red-text', 5),
  (6, 'Позвоню позже', null, null, 'grey darken-2', 'grey-text text-darken-2', 'icon-bell-off', 6)
) AS s ("id", "состояние", "заголовок списка", "заголовок кнопки", "фон", "текст", "icon", button_id);
$func$ LANGUAGE SQL;

---copy (SELECT array_to_json(array_agg(t)) FROM "Коды состояния"() t) to '/tmp/lg-ask-states.json';

CREATE or REPLACE FUNCTION "история состояний заявки"(int)
RETURNS TABLE("ts" timestamp,  "дата состояния" text, "установил состояние" int, "код состояния" int, "состояние" text, "коммент" text, "оценка" int, "ts_md5" char(32)) AS $func$
-- без контроля доступа
select s.ts, to_char(s.ts - interval '2 hours', 'TMday DD.MM.YYYY в HH24:MI') || ' (MSK)' as "дата",
  s."установил", c.id as "код состояния", c."состояние", s."коммент", case when s."состояние" >= 100 then s."состояние"-100 else null end as "оценка", ts_md5(s.ts) as "ts_md5"
from "{%= $schema %}"."состояния заявок" s
  join "Коды состояния"() c on s."состояние"=c.id
  ---join "{%= $schema %}"."{%= $tables->{refs} %}" r on s."заявка"=r.id1 -- обязательно в связке с транспортом
  ---join "{%= $schema %}"."транспорт" t on r.id2=t.id
-- тут может where order limit

where s."заявка"=$1
--order by s.ts

$func$ LANGUAGE SQL;

/*
CREATE or REPLACE FUNCTION "кнопка состояния"(int)
RETURNS SETOF "кнопки показа телефона" AS $func$
SELECT ("кнопки"::"кнопки показа телефона").*
FROM "Коды состояния"()
where id=$1; -- код состояния
$func$ LANGUAGE SQL;
*/

/*
CREATE or REPLACE FUNCTION "история состояний заявки по транспорту"(int, int)
RETURNS TABLE("транспорт" int, "ts" timestamp,  "дата" text, "установил" int, "код состояния" int, "состояние" text, "коммент" text) AS $func$
select *
from "история состояний заявки"($1)
where "транспорт" = $2
;
$func$ LANGUAGE SQL;
*/

CREATE OR REPLACE FUNCTION "триггер/заявки/новые"()
/*
Зеркальный триггер для "триггер/транспорт/новые заявки"()
*/
RETURNS TRIGGER AS $func$
DECLARE

trans int[];

BEGIN
select array_agg(distinct st.id) into trans
from "заявки" a
  join "поиск транспорта"(a.category, a.addr_type, a.address) st on true
  join fias."дата по адресу"(a.address, a.date) tz on true -- uuid, timestamp
  left join ( -- связь заявка/транспорт
    select r.id1 as ask_trans  ---, t.id as trans_ref
    from "{%= $schema %}"."{%= $tables->{refs} %}" r
      join "{%= $schema %}"."транспорт" t on r."id2"=t.id
  ) at on a.id=at.ask_trans
where
  a.id=NEW.id -- заявка
  and not(coalesce(a.disabled, false))
  and (st."status" or not(st."status")) -- and tz."завтра"))
  and tz."интервал" > interval '0 second'  -- еще не просрочено
  and at.ask_trans is null -- нестыкованная заявка
;

-- удаление связей транспорт/заявка
-- выборочное удаление
WITH trans_ask AS (select unnest(trans) as id1)
DELETE from "{%= $schema %}"."{%= $tables->{refs} %}" r
USING (
  select r.*
  from "{%= $schema %}"."транспорт" t
    join "{%= $schema %}"."{%= $tables->{refs} %}" r on t.id=r.id1
    join "{%= $schema %}"."заявки" a on r.id2=a.id
  where a.id=NEW.id
  ) rta
  left join trans_ask ta on rta.id1=ta.id1
where r.id=rta.id and ta.id1 is null;

-- вставка связей транспорт/заявка
-- выборочная вставка
WITH trans_ask AS (select unnest(trans) as id1)
INSERT INTO "{%= $schema %}"."{%= $tables->{refs} %}" (id1, id2)
select ta.id1, NEW.id as id2
from trans_ask ta
  left join (
    select r.*
    from "{%= $schema %}"."транспорт" t
      join "{%= $schema %}"."{%= $tables->{refs} %}" r on t.id=r.id1
      join "{%= $schema %}"."заявки" a on r.id2=a.id
    where a.id=NEW.id
  ) r on ta.id1=r.id1
where r.id1 is null;

RETURN NULL; -- возвращаемое значение для триггера AFTER не имеет значения

END;
$func$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS  "заявки/новые" ON  "{%= $schema %}"."заявки";

CREATE TRIGGER "заявки/новые"
AFTER INSERT OR UPDATE on "{%= $schema %}"."заявки"
    FOR EACH ROW EXECUTE PROCEDURE "триггер/заявки/новые"();