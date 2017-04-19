package Model::Discogs;

use Mojo::Base 'Model::Base';#'DBIx::Mojo::Model';

#~ use Mojo::Util qw(dumper);

has pg_schema=>'discogs';

sub new {
  state $self = shift->SUPER::new(mt=>{tag_start=>'{%', tag_end=>'%}', expression_mark000 => '',}, template_vars=>{}, @_);
  $self->template_vars->{schema} ||= $self->pg_schema;
  #~ warn dumper $self;
  return $self;
}

sub done_release_img {
  my $self = ref $_[0] ? shift : shift->new;
  #~ return 1;
  my $release = shift;
  #~ $self->dbh->selectrow_hashref($self->sth('new releases_img_done'), undef, (shift, shift, shift));
  my $r = $self->dbh->selectrow_hashref($self->sth('done release img'), undef, ($release->{img_urls}, scalar @{$release->{img_fails} || []} ? $release->{img_fails} : undef, $release->{id}));
  #~ say "\t=== Done model release img [$r->{id}] ===";
  return $r;
}

sub count_release_year_img {
  my $self = ref $_[0] ? shift : shift->new;
  $self->dbh->selectrow_hashref($self->sth('count release img'), undef, (shift,));
}

sub del_release_new {
  my $self = ref $_[0] ? shift : shift->new;
  $self->dbh->selectrow_hashref($self->sth('del релизы_новые'), undef, (shift));
}

sub формат {
  my $self = ref $_[0] ? shift : shift->new;
  $self->dbh->selectrow_hashref($self->sth('формат'), undef, (shift));
  
}

sub label {
  my $self = ref $_[0] ? shift : shift->new;
  #~ $self->dbh->selectrow_hashref($self->sth('label'), undef, (shift));
  $self->получить_или_вставить($self->pg_schema, 'label', ['id'], id=>shift, name=>shift);
}

#~ sub label_name {
  #~ my $self = ref $_[0] ? shift : shift->new;
  #~ $self->получить_или_вставить($self->pg_schema, 'label', ['name'], id=>shift, name=>shift);
#~ }

sub label_id {
  my $self = ref $_[0] ? shift : shift->new;
  $self->dbh->selectrow_hashref($self->sth('label id'), undef, (shift));
}

sub label_and_update {
  my $self = ref $_[0] ? shift : shift->new;
  $self->обновить_или_вставить($self->pg_schema, 'label', @_);#['id'], id=>shift, name=>shift
}

sub genre {
  my $self = ref $_[0] ? shift : shift->new;
  #~ my ($name, $aid) = @_;
  #~ $self->dbh->selectrow_hashref($self->sth('new genre'), undef, ($name))
    #~ || $self->dbh->selectrow_hashref($self->sth('genre'), undef, ($name, $aid));
  $self->получить_или_вставить($self->pg_schema, 'genre', ['name'], name=>shift);
}

sub style {
  my $self = ref $_[0] ? shift : shift->new;
  #~ my ($name, $aid) = @_;
  #~ $self->dbh->selectrow_hashref($self->sth('new style'), undef, ($name))
    #~ || $self->dbh->selectrow_hashref($self->sth('style'), undef, ($name, $aid));
  $self->получить_или_вставить($self->pg_schema, 'style', ['name'], name=>shift);
}

sub country {
  my $self = ref $_[0] ? shift : shift->new;
  #~ $self->dbh->selectrow_hashref($self->sth('country by name'), undef, (shift));
  $self->получить_или_вставить($self->pg_schema, 'country', ['name'], name=>shift);
}

#~ sub new_country {
  #~ my $self = ref $_[0] ? shift : shift->new;
  #~ $self->dbh->selectrow_hashref($self->sth('new country'), undef, (@_));
  
#~ }

sub artist_id {
  my $self = ref $_[0] ? shift : shift->new;
  $self->dbh->selectrow_hashref($self->sth('artist id'), undef, (shift));
}

sub artist {
  my $self = ref $_[0] ? shift : shift->new;
  #~ $self->dbh->selectrow_hashref($self->sth('new artist'), undef, (@_));
  $self->получить_или_вставить($self->pg_schema, 'artist', @_);#['id'], id=>shift, name=>shift
}

sub artist_and_update {
  my $self = ref $_[0] ? shift : shift->new;
  $self->обновить_или_вставить($self->pg_schema, 'artist', @_);#['id'], id=>shift, name=>shift
}

sub roles {
  my $self = ref $_[0] ? shift : shift->new;
  $self->получить_или_вставить($self->pg_schema, 'roles', ['roles'], roles=>shift);
  
}

sub extraartist {
  my $self = ref $_[0] ? shift : shift->new;
  $self->обновить_или_вставить($self->pg_schema, 'extraartists', ['parent_aid','position',], @_);#['id'], id=>shift, name=>shift
  
}

sub release {
  my $self = ref $_[0] ? shift : shift->new;
  $self->обновить_или_вставить($self->pg_schema, 'release', @_);#['id'], id=>shift, name=>shift
  
}

sub releases_labels {
  my $self = ref $_[0] ? shift : shift->new;
  $self->обновить_или_вставить($self->pg_schema, 'releases_labels', ['release_aid', "position"], @_);
}

sub releases_artists {
  my $self = ref $_[0] ? shift : shift->new;
  $self->обновить_или_вставить($self->pg_schema, 'releases_artists', ['release_aid', "position"],  @_);
}

sub releases_formats {
  my $self = ref $_[0] ? shift : shift->new;
  $self->обновить_или_вставить($self->pg_schema, 'releases_formats', ['release_aid', "position"], @_);
}

sub track {
  my $self = ref $_[0] ? shift : shift->new;
  $self->обновить_или_вставить($self->pg_schema, 'track', ['release_aid', "trackno"], @_);
  
}

sub data_quality {
  my $self = ref $_[0] ? shift : shift->new;
  $self->получить_или_вставить($self->pg_schema, 'data_quality', ['name'], name=>shift);
}

1;

__DATA__
@@ table release img
-- Закачка картинок релизов
create table discogs.releases_img_done (
  aid integer not null primary key,
  img text[], -- img null - это не найден релиз; img = [] это нет картинок
  fail text[] -- список ошибочных img src,
  release_id  integer unique
);

@@ table мастера_новые
create table discogs."мастера_новые" (
  id int not null primary key,
  ts timestamp without time zone NOT NULL DEFAULT now(),
  url varchar not null
);

@@ table релизы_новые
create table discogs."релизы_новые" (
  id int not null primary key,
  ts timestamp without time zone NOT NULL DEFAULT now(),
  url varchar not null
);

@@ new мастера_новые
insert into discogs."мастера_новые" (id, url) values (?,?)
returning *;

@@ id master
select id
from discogs.master
where id=?;

@@ id мастера_новые
select id
from discogs."мастера_новые"
where id=?;

@@ new релизы_новые
insert into discogs."релизы_новые" (id, url) values (?,?)
returning *;

@@ id release
select id
from discogs.release
where id=?;

@@ id релизы_новые
select id
from discogs."релизы_новые"
where id=?;

@@ по списку мастера_новые
-- Обработка списка

SET local enable_seqscan TO off;

select n.*
from discogs."мастера_новые" n
  left join discogs.master m on n.id=m.id
where m.id is null
order by n.id
{%= $limit %}
;

@@ new master
insert into discogs.master (id, main_release) values (?,?)
returning *;

@@ del мастера_новые
delete
from discogs."мастера_новые"
where id=?
returning *;

@@ по списку релизы_новые
-- Обработка списка
SET local enable_seqscan TO off;

select n.*
from discogs."релизы_новые" n
  left join discogs.release r on n.id=r.id
where {%= $where %}
order by n.id
{%= $limit %}
;

@@ del релизы_новые
delete
from discogs."релизы_новые"
where id=?
returning *;

@@ new releases_img_done
-- Бот по картинкам
insert into discogs.releases_img_done (release_id, img, fail) values (?,?,?)
returning *;

@@ done release img
update discogs.release
set img_urls=?, img_fails=?
where id=?
returning *;

@@ картинки релизов по годам?cached=1
-- Бот по картинкам img.pl
-- Создан индекс в таблице discogs.release "released_trgm_idx" gin (released gin_trgm_ops)
-- SET enable_seqscan TO off;

with t as (
select r.id
from discogs.release r
  join discogs.releases_formats f on r.id=f.release_id
  -- left join discogs.master m on r.master_id=m.id
  -- left join discogs.releases_img_done i on r.id=i.release_id
where
  f.format_aid = 6 -- 11131438 --| Vinyl
  and r.released ~ ? -- год
  -- and i.release_id is null -- не обработанные
  and r.img_urls is null  ------ CREATE INDEX ON release ((COALESCE(img_urls,'{-}'))) WHERE img_urls IS NULL;
  -- and r.img_done is null
{%= $limit %}
)
update discogs.release r
-- set img_done = '0001-01-01'::timestamp
set img_urls = '{0}'
from t
where r.id = t.id
returning {%= $select %};
;

@@ reset release img_done
-- сбросить зависшие/прерванные
-- SET enable_seqscan TO off;

update discogs.release
--- set img_done=null
set img_urls = null
where 
  img_urls =  '{0}' -------- CREATE INDEX ON release (img_urls) WHERE img_urls = '{0}';
  and released ~ ? -- год
  -- and img_urls is null
  -- and img_done='0001-01-01'::timestamp
;

@@ count release img
-- сколько не обработано релизов
select count(r.*) as "осталось обработать релизов: "
from discogs.release r
  join discogs.releases_formats f on r.id=f.release_id
where
  f.format_aid = 6 -- 11131438 --| Vinyl
  and r.released ~ ? -- год
  and r.img_urls is null
;

@@ формат
select *
from discogs.format
where lower(regexp_replace(name, '\s+', '', 'g')) = lower(regexp_replace(?::text, '\s+', '', 'g'));

@@ label
select *
from discogs.label
where lower(regexp_replace(name, '\s+', '', 'g')) = lower(regexp_replace(?::text, '\s+', '', 'g'));

@@ label id
select *
from discogs.label
where id = ?;

@@ genre
select *
from discogs.genre
where lower(regexp_replace(name, '\s+', '', 'g')) = lower(regexp_replace(?::text, '\s+', '', 'g'))
  or aid = ?;

@@ style
select *
from discogs.style
where lower(regexp_replace(name, '\s+', '', 'g')) = lower(regexp_replace(?::text, '\s+', '', 'g'))
  or aid = ?;

@@ country by name
select *
from discogs.country
where lower(regexp_replace(name, '\s+', '', 'g')) = lower(regexp_replace(?::text, '\s+', '', 'g'));

@@ artist id
select *
from discogs.artist
where id = ?;

