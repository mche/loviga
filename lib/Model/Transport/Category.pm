package Model::Transport::Category;
use Mojo::Base 'Model::Base';
#~ use Mojo::Util qw(dumper);

#~ has sth_cached => 1;
my $main_table ="категории транспорта";

sub new {
  state $self = shift->SUPER::new(@_);
  $self->{template_vars}{tables}{main} = $main_table;
  #~ die dumper($self->{template_vars});
  $self->dbh->do($self->sth('таблицы'));
  $self->dbh->do($self->sth('функции'));
  return $self;
}

sub expand_node {
  my ($self, $parent_id) = @_;
  return $self->dbh->selectall_arrayref($self->sth('узлы родителя'), {Slice=>{}}, $parent_id);
  
}

sub category_count {
  my ($self) = @_;
  return $self->dbh->selectall_hashref($self->sth('количество категорий транспорта'), 'id',);
}

sub сохранить_категорию {
  my ($self, $hashref) = @_;
  return $self->вставить_или_обновить($self->{template_vars}{schema}, $main_table, ["id"], $hashref);
  
}

sub индексный_путь_категории {
  my ($self, $category_id) = @_;
  $self->dbh->selectrow_array($self->sth('индексный путь категории'), undef, $category_id);
}

sub родители_категории {
  my ($self, $category_id) = @_;
  $self->dbh->selectall_arrayref($self->sth('родители категории'), { Slice=> {} }, ($category_id) x 1);
}

sub категории_для_поиска {
  my ($self,) = @_;
  $self->dbh->selectall_arrayref($self->sth('категории для поиска'), { Slice=> {} },);
}

sub топ_категории_счет {
  my ($self,) = @_;
  $self->dbh->selectall_arrayref($self->sth('топ-категории/счет'), { Slice=> {} },);
}

1;

__DATA__
@@ таблицы
create table IF NOT EXISTS "{%= $schema %}"."{%= $tables->{main} %}" (
  id integer  NOT NULL DEFAULT nextval('{%= $sequence %}'::regclass) primary key,
  ts  timestamp without time zone NOT NULL DEFAULT now(),
  title text not null,
  parent int not null,
  childs int[] not null default '{}'::int[],
  disabled boolean,
  img text --- имя файла в спец каталоге см $img_path Controll::Transport::Category;
);
--- корень дерева категорий
--- insert into "{%= $schema %}"."{%= $tables->{main} %}" (title, parent) values ('Категории транспорта', 0) returning *;

@@ узлы родителя?cached=1
select t.*
from
  (
    SELECT x.*
    FROM "{%= $schema %}"."{%= $tables->{main} %}" t,
      unnest(childs)  WITH ORDINALITY x(child_id, child_order)
    where t.id=?
  ) arr -- развернул массив потомков с их порядком
  join "{%= $schema %}"."{%= $tables->{main} %}" t on arr.child_id=t.id
order by arr.child_order
;

@@ индексный путь категории?cached=1
WITH x AS (
  SELECT * FROM "родители категории транспорта"(?, true)
)

select array_agg(idx)::int[]
from (
  select id1, idx-1 as idx, x2.id
    from
      x as x1
        join x as x2 on x1.id=x2.parent,
      unnest(x1.childs) WITH ORDINALITY x0(id1, idx)
    order by x2.level desc
) q 
where id1 =id
;

@@ родители категории
SELECT c.*
FROM "родители категории транспорта"(?, false) x
  join "категории транспорта" c on x.id=c.id
order by x.level desc
;

@@ количество категорий транспорта?cached=1
WITH cc AS (
  WITH RECURSIVE rc AS (
    select c1.id as "last_id", c1.id, c1.parent, 1 AS level
    from "категории транспорта" c1
      left join "категории транспорта" c2 on c1.id=c2.parent
    where c2.parent is null
      and not(coalesce(c1.disabled, false))
    
     UNION
     
     SELECT rc."last_id", up.id, up.parent, rc.level + 1 AS level
     FROM "категории транспорта" up
        JOIN rc ON up.id = rc.parent
    -- where up.parent<>0 --   кроме топа
    -- where not(coalesce(up.disabled, false))
  )
  SELECT rc.id, count(t.id)
  FROM rc
    left join
/*  пусть блокирует все адреса    ( select distinct t.id, t.category
      from
        "транспорт" t,
        unnest(t.address_dsbl) un_adsbl
        where
          not(coalesce(t.disabled, false))
          ---and not(coalesce(un_adsbl::boolean, false))
      ) t
*/
    "транспорт" t on rc."last_id" = t.category
  where
    not(coalesce(t.disabled, false))
  group by rc.id
  --order by level
)

select *
from cc
;

@@ топ-категории/счет?cached=1
WITH RECURSIVE rc AS (
  select c1.id as "top_id", c1.id, c1.parent, c1.title, x.top_order, 1 AS level
  from 
    (select x.*
    from "категории транспорта" c, unnest(childs)  WITH ORDINALITY x(top_id, top_order)
    where id=22
    ) x
    join "категории транспорта" c1 on c1.id=x.top_id
  where  not(coalesce(c1.disabled, false))
  
   UNION
   
   SELECT rc."top_id", ch.id, ch.parent, rc.title, rc.top_order, rc.level + 1 AS level
   FROM "категории транспорта" ch
      JOIN rc ON ch.parent = rc.id
    where not(coalesce(ch.disabled, false))
)
SELECT rc.top_id as id, rc.title, count(t.id) as count
FROM rc
  left join
/*  пусть блокирует все адреса    ( select distinct t.id, t.category
    from
      "транспорт" t,
      unnest(t.address_dsbl) un_adsbl
      where
        not(coalesce(t.disabled, false))
        ---and not(coalesce(un_adsbl::boolean, false))
    ) t
*/
  "транспорт" t on rc."id" = t.category
where 
  not(coalesce(t.disabled, false))
group by rc.top_id, rc.title, rc.top_order
order by rc.top_order;

@@ категории для поиска?cached=1
select id, path,
  img[case
  when array_position(img, null) = 1 then 0
  when array_position(img, null) is null then array_length(img, 1)
  else array_position(img, null) - 1
  end] as img
from (
select c.id, array_agg(pc.title) as path, array_agg(pc.img) as img
from "категории транспорта" c 
join lateral (select cc.* from "родители категории транспорта"(c.id, null) cc order by level desc)  pc on true
where ---"сборка названий категории транспорта"(c."id") ~ '\mямо'
  c.id <> 22
group by c.id
order by array_to_string(array_agg(pc.title), '/')
) q
;

@@ функции
CREATE or REPLACE FUNCTION "конечные категории транспорта"(int)
RETURNS TABLE("id" int, parent int, parents int[], level int, disabled boolean) AS $func$
-- только конечные пункты дерева от текущей позиции
-- explain 
WITH xx AS (
  WITH RECURSIVE rc AS (
     SELECT id, parent, array[]::int[]  as parents, 1 AS level, disabled
     FROM "категории транспорта"
     WHERE id = $1
     UNION
     SELECT c.id, c.parent, array_append(rc.parents, c.parent) as parents, rc.level + 1 AS level, c.disabled
     FROM "категории транспорта" c
        JOIN rc ON c.parent = rc.id
     --where c.parent<>0 --   кроме топа
  )
  SELECT *
  FROM rc
  --order by level desc
)

select x1.*
from xx as x1 left join xx as x2 on x1.id=x2.parent
where x2.parent is null;

$func$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION "родители категории транспорта"(int, boolean)
-- 1 парам - нижняя категория, 2 парам - флаг включения топовой категории (нужно для индексного пути)
RETURNS TABLE("id" int, title text, img text, parent int, childs int[], level int)
AS $func$

WITH RECURSIVE rc AS (
   SELECT id, title, img, parent, childs, 1::int AS level
   FROM "категории транспорта"
   WHERE id = $1
   UNION
   SELECT c.id, c.title, c.img, c.parent, c.childs, rc.level + 1 AS level
   FROM "категории транспорта" c
      JOIN rc ON c.id = rc.parent
   where coalesce($2, false) or c.parent<>0 --   кроме топа
)
SELECT *
FROM rc
--order by level desc

$func$ LANGUAGE SQL;

---select c.id, array_to_string(array_agg(pc.title), '/') from "категории транспорта" c join lateral (select cc.* from "родители категории транспорта"(c.id, null) cc order by level desc)  pc on true group by c.id;


CREATE OR REPLACE FUNCTION "сборка названий категории транспорта"(int)
RETURNS text
AS $func$
select array_to_string(array_agg(c.title), '/')
from (select * from "родители категории транспорта"($1, null) c order by level desc) c
---group by c.id
;
$func$ LANGUAGE SQL
---- Обязательно IMMUTABLE функция для индекса;
IMMUTABLE;


CREATE INDEX IF NOT EXISTS "категории транс_сборка названий_gin" on "категории транспорта" USING gin ("сборка названий категории транспорта"("id") gin_trgm_ops);

/*
select array_to_json(array_agg(c))
from (
select c.id, array_agg(pc.title) as path
from "категории транспорта" c 
join lateral (select cc.* from "родители категории транспорта"(c.id, null) cc order by level desc)  pc on true
where ---"сборка названий категории транспорта"(c."id") ~ '\mямо'
  c.id <> 22
group by c.id
order by array_to_string(array_agg(pc.title), '/')
) c
;
*/
