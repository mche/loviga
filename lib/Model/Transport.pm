package Model::Transport;
use Mojo::Base 'Model::Base';

my $main_table ="транспорт";

sub new {
  state $self = shift->SUPER::new(@_);
  $self->template_vars->{tables}{main} = $main_table;
  #~ $self->{template_vars}{tables}{show_tel} = "показ телефона";
  #~ die dumper($self->{template_vars});
  $self->dbh->do($self->sth('таблицы'));
  $self->dbh->do($self->sth('функции'));
  return $self;
}

sub есть_транспорт {# из главного меню header.html.cgi.pl
  my $self = ref($_[0]) ? shift : shift->new;
  my $uid = shift;
  $self->dbh->selectrow_array($self->sth('есть транспорт'), undef, ($uid));
}

sub проверка_телефонов {
  my $self = ref($_[0]) ? shift : shift->new;
  my ($uid, $tel) = @_;
  $self->dbh->selectcol_arrayref($self->sth('проверка телефонов'), undef, ( $uid, $tel, ));
}

sub сохранить {
  my ($self, $data) = @_;
  return $self->вставить_или_обновить($self->template_vars->{schema}, $main_table, ["id"], $data, );#{upd_ts=>"to_timestamp(?::numeric)"}
}

sub позиция {# с учетом доступа
  my ($self, $id, $user_id) = @_;
  $self->dbh->selectrow_hashref($self->sth('позиция'), undef, $id, $user_id);
}

sub позиция_без_доступа {
  my ($self, $id) = @_;
  $self->dbh->selectrow_hashref($self->sth('позиция без доступа'), undef, $id, );
}

sub показ_телефона {
  my ($self, $id, $tel_idx,) = @_;
  return $self->dbh->selectrow_hashref($self->sth('один телефон'), undef, ($id, $tel_idx))
    || {error=>"Не найден телефон, возможно, транспорта нет или не активирован"};
}


sub результат_показа_телефона {
  my ($self, $data) = @_;
  #~ $tel ||= do {
    #~ my $t = $self->dbh->selectrow_hashref($self->sth('один телефон'), undef, ($id, $tel_idx))
      #~ or return {error=>"Не найден телефон по индексу, возможно, транспорта нет или не активирован"};
    #~ $t->{tel};
  #~ };
  $self->вставить($self->template_vars->{schema}, "показы телефонов", [], $data,);#["object","tel", "caller"] , {"upd_ts"=>"now()"}
}

sub показы_телефонов {# для пользователя
  my ($self, $id, $uid, $tel) = @_;
  my $list = $self->dbh->selectall_arrayref($self->sth('показы телефонов'), { Slice=> {} }, $id, $uid, ($tel) x 2);
  map {delete @$_{qw(caller object ts)}} @$list;
  $list;
}

sub типы_адреса_позиции {# одна позиция
  my ($self, $id,) = @_;
  $self->dbh->selectall_arrayref($self->sth('типы адреса позиции'), { Slice=> {} }, $id);
}

sub список {# транспорта пользователя
  my ($self, $user_id) = @_;
  $self->dbh->selectall_arrayref($self->sth('список'), { Slice=> {} }, $user_id);
}

sub поиск_транспорта  {
  my ($self, $cat, $type, $uuid, $date) = @_;
  $self->dbh->selectall_arrayref($self->sth('поиск транспорта'), { Slice=> {} }, $cat, $type, ($uuid) x 2, $date);
}

sub количество_адресных_типов {# предпоиск после выбора категории для радио-перекл типов
    my ($self, $cat) = @_;
  $self->dbh->selectall_arrayref($self->sth('количество адресных типов в категории'), { Slice=> {} }, $cat);
}

sub первый_адрес {
  my ($self, $id) = @_;
  $self->dbh->selectrow_hashref($self->sth('первый адрес'), undef, $id);
}

sub изменить_статус {
  my ($self, $uid, $id,) = @_;
  $self->dbh->selectrow_hashref($self->sth('изменить статус'), undef, $id, $uid);
  
}

sub изменить_отключение {
  my ($self, $uid, $id,) = @_;
  $self->dbh->selectrow_hashref($self->sth('изменить отключение'), undef, $id, $uid);
  
}

sub сохранить_картинку {
  my ($self, $idx, $name, $id,) = @_;
  $self->dbh->selectrow_array($self->sth('сохранить картинку'), undef, $idx, $name, $id);
  
}

sub удалить_картинку {
  my ($self, $name, $id,) = @_;
  $self->dbh->selectrow_array($self->sth('удалить картинку'), undef, $name, $id);
}

1;

__DATA__
@@ таблицы
create table IF NOT EXISTS "{%= $schema %}"."{%= $tables->{main} %}" (
  id integer  NOT NULL DEFAULT nextval('{%= $sequence %}'::regclass) primary key,
  ts  timestamp without time zone NOT NULL DEFAULT now(),
  title text,
  category int not null,
  disabled boolean,
  img text[],
  descr text,
  address uuid[] not null,
  address_dsbl boolean[], -- размерность соотв колонке address
  addr_type boolean[] not null, -- массив крыжиков типов действия адресов: [<местные перевозки в пределах адреса>, <межгород>, <международные перевозвки из/в адреса>]
  price_hour int, -- цена за час
  min_hour int, -- минимально часов
  price_km int, -- цена за км
  tel text[] not null,
  status boolean default true, -- статус текущего дня истина-свободен, ложь-занят
  status_ts timestamp not null default now() -- посылать new Date().getTime() деленное на 1000 , т.е. UTC время клиента
);

create table IF NOT EXISTS "{%= $schema %}"."показы телефонов" (
  ts  timestamp without time zone NOT NULL DEFAULT now(),
  object int not null,-- транспорт или заявка
  tel text not null,
  caller int not null,-- заказчик или исполнитель
  result int not null-- состояние, "Коды состояний"()
  ---upd_ts timestamp without time zone NOT NULL,
  ---unique (object, tel, caller)

);

@@ позиция?cached=1
-- с доступом
select t.*
from "{%= $schema %}"."{%= $tables->{main} %}" t
  join "{%= $schema %}"."{%= $tables->{refs} %}" r on t.id=r.id2
where t.id=? and r.id1=?;

@@ позиция без доступа?cached=1
select t.*, p.id as uid
from "{%= $schema %}"."{%= $tables->{main} %}" t,
  "{%= $tables->{refs} %}" r, -- чей транспорт
  "{%= $tables->{profiles} %}" p -- чей транспорт
where t.id=?
  and t.id=r.id2 -- чей транспорт
  and r.id1=p.id -- чей транспорт
  ;


@@ один телефон?cached=1
-- для показа телефона
select un_tel.*, t.id
from  "транспорт" t,
  unnest(t.tel) WITH ORDINALITY un_tel(tel, tel_idx)
where
  t.id=?
  and un_tel.tel_idx=? -- or un_tel.tel= )
  and t.status is not null
  ---and now() - t.status_ts < "интервал неопр статуса транспорта"()
;

@@ показы телефонов
-- и для заявок
select t.*, c."состояние",
  "формат телефона"(tel) as "телефон",
  to_char(ts - interval '2 hours', 'TMday DD.MM.YYYY в HH24:MI') || ' (MSK)' as "дата"
from "{%= $schema %}"."показы телефонов" t
  join "Коды состояния"() c on t."result"=c.id
where t.object=?
  and t.caller=?
  and (? is null or t.tel=?) -- можно не указывать телефон
order by ts desc;


@@ типы адреса позиции
select un.*, ta.text as title
from "{%= $schema %}"."{%= $tables->{main} %}" t,
  unnest(t.addr_type) WITH ORDINALITY un(val, idx),
  "типы адреса"() ta
where t.id=?
  and un.idx=ta.idx
  and un.val
order by idx
;

@@ список
-- текущий исп
select t.*
from "{%= $schema %}"."{%= $tables->{main} %}" t
  join "{%= $schema %}"."{%= $tables->{refs} %}" r on t.id=r.id2
where r.id1=?
order by ts
;

@@ поиск транспорта?cached=1
select t.*,
  p.id as uid,
  case 
    when t."status" then 'свободен'
    when not(t."status") and tz."завтра" then 'завтра свободен'
    when not(t."status") then 'занят'
    --- (t."status" or now() - status_ts < "интервал неопр статуса транспорта"()) -- если занят, но это было не больше интервала
    else 'не активирован'
  end as "статус"
  --- (t."status" or (not(t."status") and tz."завтра")) as "свободен"-- для принятия заявок и на будущее
  
from
  "поиск транспорта"(?, ?, ?) t,
  fias."дата по адресу"(?, ?) tz, -- uuid, timestamp
  "{%= $schema %}"."{%= $tables->{refs} %}" r, -- чей транспорт
  "{%= $schema %}"."{%= $tables->{profiles} %}" p -- чей транспорт
where
  tz."интервал" > interval '0 second'  -- еще не просрочено
  and t.id=r.id2 -- чей транспорт
  and r.id1=p.id -- чей транспорт
;


@@ количество адресных типов в категории?cached=1
select t.*, coalesce(c.count, 0) as cnt
from "типы адреса"() t
  left join (
  select  idx, count(id) as count
  from (
    select distinct t.id, un_at.idx
    from "транспорт" t,
    unnest(t.addr_type) WITH ORDINALITY un_at(val, idx)---,
    ---unnest(t.address_dsbl) un_adsbl пусть все адреса отключает
    where 
      not(coalesce(t.disabled, false))
      and un_at.val = true
      ----and not(coalesce(un_adsbl::boolean, false))
      ----and t.category in (select id from "конечные категории транспорта"(%))
      and ? in (select id from "родители категории транспорта"(t.category, false))
      -- and t."status" is not null -- может перестал заходить, неопределенность делается каждые сутки в 00:00
    ) s
  group by idx
  ) c on t.idx=c.idx
;

@@ первый адрес
--базовый адрес
select addr.*
from "транспорт" t, fias.aoguid_parents_array(t.address[1]) as addr
where t.id=?;


@@ изменить статус?cached=1
update "транспорт" t
set "status" = not(coalesce(t."status", false))
  ---status_ts = coalesce(to_timestamp(--вопрос--), now())
from "{%= $schema %}"."{%= $tables->{refs} %}" r
where t.id=? and r.id1=? and r.id2=t.id
returning "status"
;

@@ изменить отключение?cached=1
update "транспорт" t
set "disabled" = not(coalesce(t."disabled", false))
  ---status_ts = coalesce(to_timestamp(--вопрос--), now())
from "{%= $schema %}"."{%= $tables->{refs} %}" r
where t.id=? and r.id1=? and r.id2=t.id
returning "disabled"
;

@@ есть транспорт?cached=1
select count(r.*) as cnt
from "{%= $schema %}"."{%= $tables->{refs} %}" r
  join "{%= $schema %}"."{%= $tables->{main} %}" t on r.id2=t.id
where r.id1=?;

@@ проверка телефонов
-- перед сохранением транспорта
select t.tel
from 
  "{%= $schema %}"."{%= $tables->{profiles} %}" p
  join "{%= $schema %}"."{%= $tables->{refs} %}" r on p.id=r.id1
  join (
    select id, unnest(tel) as tel
    from "{%= $schema %}"."{%= $tables->{main} %}"
  ) t on  t.id=r.id2
where p.id <> ? -- не этот пользователь
  and t.tel = any(?);

@@ сохранить картинку
update "{%= $schema %}"."{%= $tables->{main} %}"
set img[?::int] = ?::text
where id=?
returning img;

@@ удалить картинку
update "{%= $schema %}"."{%= $tables->{main} %}"
set img = array_remove(img, ?::text)
where id=?
returning img;

@@ функции
CREATE or REPLACE FUNCTION "поиск транспорта"(int, int, uuid)--, timestamp
-- 1 - категория
-- 2 - тип адреса
-- 3 - адрес
-- тут нет проверки на простроченность (дата не используется) и обработки статуса/занятости транспорта
RETURNS SETOF "транспорт"
AS $func$
DECLARE

addrs uuid[];
undef_status_interval interval := "интервал неопр статуса транспорта"();

--

BEGIN

IF $2 = 1 THEN -- локальный поиск
  --select "AOGUID" into local_addr from fias.aoguid_parents($3) where "SHORTNAME" = any(array['р-н', 'г']) order by "AOLEVEL" limit 1;
  --select array_agg("AOGUID") into addrs from fias."подчин адреса на один уровень"(local_addr); -- на уровень ниже все
  select array_agg("AOGUID") into addrs from fias."локальные адреса"($3);
ELSE -- межгород и загран
  select "AOGUID" into addrs from fias.aoguid_parents_array($3); -- наоборот все уровни выше
END IF;

RETURN QUERY select distinct t.* ---не получится добавлять колонки, t."status" as "свободен", (not(t."status") and tz."завтра") as "если завтра - свободен?"
from
  "транспорт" t,
  ---fias."дата по адресу"(-3, -4) tz,
  unnest(t.address)  WITH ORDINALITY un_addr(val, idx),
  unnest(t.address_dsbl) WITH ORDINALITY un_adsbl(val, idx)
where
  not(coalesce(t.disabled, false))
  and un_addr.idx=un_adsbl.idx
  ---and tz."интервал" > interval '0 second'  -- еще не просрочено
  ---and (t."status" or (not(t."status") and tz."завтра")) -- занят, но на завтра пожалуйста
  -- and (t."status" or now() - status_ts < undef_status_interval) -- если занят, но это было не больше интервала
  and not(coalesce(un_adsbl.val::boolean, false))
  ---and t.category in (select id from "конечные категории транспорта"(%)) --2135
  and $1 in (select id from "родители категории транспорта"(t.category, false))
  and coalesce(t.addr_type[$2], false) = true -- тут всегда 1?
  and un_addr.val = any(addrs)
;
END
$func$ LANGUAGE plpgsql; -- лучше простого sql http://stackoverflow.com/questions/24755468/difference-between-language-sql-and-language-plpgsql-in-postgresql-functions

CREATE or REPLACE FUNCTION "интервал неопр статуса транспорта"()
RETURNS interval AS $func$
select interval '2 days';
$func$ LANGUAGE SQL;

CREATE or REPLACE FUNCTION fias."дата по адресу"(in uuid, in timestamp, out "интервал" interval, out "завтра" boolean, out "MSK" timestamp)
-- входная дата(2) привязана к входному адресу(1)
-- по топовому адресу входного адреса получаем UTC час и устанавливаем интервал "прошлое/сегодня/завтра+"
-- Выход:
-- отрицательный интервал - дата для заявки в прошлом
-- интревал от 0 до 24 часов - еще идет "сегодня" в том адресе
-- интервал > 24 часов - дата заявки в будущем
---RETURNS ROW(interval, boolean)
AS $func$

select
  $2 - (now() + (tz."UTC hour"-5) * interval '1 hours')::timestamp,
  $2::date > (now() + (tz."UTC hour"-5) * interval '1 hours')::date,
  $2 - (tz."UTC hour"-3) * interval '1 hours'
from fias."aoguid_parents"($1) ao
  join fias."ТЗ субъектов"() tz on ao."AOGUID"=tz."AOGUID"
where ao."AOLEVEL"=1;

$func$ LANGUAGE SQL;

CREATE or REPLACE FUNCTION "формат телефона"(text)
RETURNS text AS $func$
SELECT '(' || regexp_replace(array_to_string(regexp_matches($1, '(\d{1,3})\D*(\d{1,3})?\D*(\d{1,2})?\D*(\d{1,2})?'), '-'), '^(\d+)-', '\1) ');
$func$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION "триггер/транспорт/новые заявки"()
/*
Зеркальный триггер для "триггер/заявки/новые"()
*/
RETURNS TRIGGER AS $func$
DECLARE

asks int[];

BEGIN
select array_agg(distinct a.id) into asks
from "заявки" a
  join "поиск транспорта"(a.category, a.addr_type, a.address) st on true
  join fias."дата по адресу"(a.address, a.date) tz on true -- uuid, timestamp
  left join ( -- связь заявка/транспорт
    select r.id1 as ask_trans  ---, t.id as trans_ref
    from "{%= $schema %}"."{%= $tables->{refs} %}" r
      ---join "{%= $schema %}"."транспорт" t on r."id2"=t.id
    where r."id2"=NEW.id
  ) at on a.id=at.ask_trans
where
  st.id=NEW.id -- транспорт
  and not(coalesce(a.disabled, false))
  and (st."status" or not(st."status")) -- and tz."завтра"))
  and tz."интервал" > interval '0 second'  -- еще не просрочено
  and at.ask_trans is null -- нестыкованная заявка
;

-- удаление связей транспорт/заявка
-- выборочное удаление
WITH trans_ask AS (select unnest(asks) as id2)
DELETE from "{%= $schema %}"."{%= $tables->{refs} %}" r
USING (
  select r.*
  from "{%= $schema %}"."транспорт" t
    join "{%= $schema %}"."{%= $tables->{refs} %}" r on t.id=r.id1
    join "{%= $schema %}"."заявки" a on r.id2=a.id
  where t.id=NEW.id
  ) rta
  left join trans_ask ta on rta.id2=ta.id2
where r.id=rta.id and ta.id2 is null;

-- вставка связей транспорт/заявка
-- выборочная вставка
WITH trans_ask AS (select unnest(asks) as id2)
INSERT INTO "{%= $schema %}"."{%= $tables->{refs} %}" (id1, id2)
select NEW.id as id1, ta.id2
from trans_ask ta 
  left join (
    select r.*
    from "{%= $schema %}"."транспорт" t
      join "{%= $schema %}"."{%= $tables->{refs} %}" r on t.id=r.id1
      join "{%= $schema %}"."заявки" a on r.id2=a.id
    where t.id=NEW.id
  ) r on ta.id2=r.id2
where r.id2 is null;

RETURN NULL; -- возвращаемое значение для триггера AFTER не имеет значения

END;
$func$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS  "транспорт/новые заявки" ON "{%= $schema %}"."транспорт";

CREATE TRIGGER "транспорт/новые заявки"
AFTER INSERT OR UPDATE on "{%= $schema %}"."транспорт"
    FOR EACH ROW EXECUTE PROCEDURE "триггер/транспорт/новые заявки"();