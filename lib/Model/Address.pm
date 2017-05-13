package Model::Address;
use Mojo::Base 'Model::Base';


sub new {
  state $self = shift->SUPER::new(@_);
  #~ $self->{template_vars}{tables}{main} = $main_table;
  $self->dbh->do($self->sth('функции'));
  return $self;
}

#~ has addr_type => sub { ['Местные перевозки/услуги (для городов и районов)', 'Междугородные перевозки', 'Международные перевозки']; };

sub addr_type {
   my ($self) = @_;
   $self->dbh->selectall_arrayref($self->sth('addr_type'), { Slice=> {} },);
}

sub поиск {# транспорта пользователя
  my ($self, $arr, $limit) = @_;
  $self->dbh->selectall_arrayref($self->sth('поиск'), { Slice=> {} }, $arr, $limit || 10);
}

sub поиск_город {# транспорта пользователя
  my ($self, $re, $limit) = @_;
  $self->dbh->selectall_arrayref($self->sth('поиск город'), { Slice=> {} }, $re, $limit || 10);
}

sub полный_адрес {
  my ($self, $uuid) = @_;
  
  $self->dbh->selectrow_hashref($self->sth('полный адрес'), undef, $uuid);
}

sub полный_адрес_формат {
  my ($self, $data) = @_;
  my $short = $data->{SHORTNAME};
  my $formal = $data->{FORMALNAME};
  return {
    id=>$data->{id}[0],
    uuid => $data->{AOGUID}[0],
    full => join(", ", map {
      my $name = $formal->[$_] =~ /\s/ ? '"'.$formal->[$_].'"' : $formal->[$_];
      $short->[$_] =~ /обл|край|р-н|АО/
        ? sprintf("%s %s", $name, $short->[$_])
        : sprintf("%s %s", $short->[$_], $name);
    } grep defined $short->[$_], 0..$#$short),
  };
}

1;

__DATA__
@@ поиск?cached=1
select *
from fias.search_address(?::text[]) -- '{\\mкрасный яр, \\mсамар}'
order by array_to_string("AOLEVEL", '')::int, weight desc, array_to_string("FORMALNAME", '')
limit ?
;

@@ поиск город?cached=1
select *
from fias.search_address_1(?::text) -- '{\\mкрасн.*\\mяр.*}'
order by array_to_string("AOLEVEL", '')::int, array_to_string("FORMALNAME", '')
limit ?
;

@@ полный адрес
select * from fias.aoguid_parents_array(?::uuid)
;

@@ addr_type
--- копи-пастуй SELECT array_to_json(array_agg(t)) FROM (select * from "типы адреса"() order by idx) t;
--- напрямую в address/type.js(40)
select * from "типы адреса"() order by idx;


@@ функции
CREATE or REPLACE FUNCTION "типы адреса"()
RETURNS TABLE("text" text, idx int) AS $func$

select "text"::text, idx::int from unnest(array[
  'Местные перевозки/услуги (для городов и районов)',
  'Междугородные перевозки',
  'Заграничные перевозки'
  ]::text[]) WITH ORDINALITY un(text, idx);

$func$ LANGUAGE SQL;

------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fias."локальные адреса"(uuid)
/*
От указанного AOGUID подняться до уровня района/города
и затем рекурсивно выбрать все подчиненные AOGUIDы
Используется для поиска транспорта с локальным типом перевозок
*/
RETURNS TABLE("AOGUID" uuid, "AOLEVEL" int2) AS $func$

WITH RECURSIVE rc AS (
  SELECT "AOGUID", "AOLEVEL"
  FROM fias."AddressObjects"
  WHERE "AOGUID" in (--'51f21baa-c804-4737-9d5f-9da7a3bb1598'
    select "AOGUID"
    from fias.aoguid_parents($1)
    where "SHORTNAME" = any(array['р-н', 'г', 'г.о.'])
    order by "AOLEVEL"
    limit 1
  )
   UNION
  SELECT a."AOGUID", a."AOLEVEL"
  FROM fias."AddressObjects" a, rc
  WHERE a."PARENTGUID" = rc."AOGUID"
)

SELECT *
FROM rc;

$func$ LANGUAGE SQL;
