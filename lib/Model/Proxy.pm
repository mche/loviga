package Model::Proxy;

use Mojo::Base 'DBIx::Mojo::Model';

#~ use Mojo::Util qw(dumper);

sub new {
  state $self = shift->SUPER::new(mt=>{tag_start=>'{%', tag_end=>'%}',}, template_vars=>{table => "vinylhub.proxy",}, @_, );
}

sub proxy_list {
  my $self = ref $_[0] ? shift : shift->new;
  $self->dbh->selectall_arrayref($self->sth('proxy list', order=>"order by ts"), {Slice=>{}}, );
}

sub new_proxy {
  my $self = ref $_[0] ? shift : shift->new;
  $self->dbh->selectrow_hashref($self->sth('new proxy'), undef, (@_));
}

sub use_proxy {
  my $self = ref $_[0] ? shift : shift->new;
  $self->dbh->selectrow_hashref($self->sth('use proxy'));
  
}

sub status_proxy {
  my $self = ref $_[0] ? shift : shift->new;
  $self->dbh->selectrow_hashref($self->sth('status proxy'), undef, (@_));
  
}

1;

__DATA__
@@ table proxy
create table {%= $table %} (
  proxy varchar not null unique,
  ts timestamp without time zone NOT NULL DEFAULT now(),
  status char(1) null,
  last_use timestamp without time zone null,
  type text not null
);

@@ proxy list
select * from {%= $table %}
{%= $where %}
{%= $order %}
;

@@ get proxy
select *
from {%= $table %}
where proxy=?;

@@ new proxy
insert into {%= $table %} (proxy, type)
( select v.*
from (VALUES (?::varchar, ?::text))  v (proxy,type)
  left join {%= $table %} p on v.proxy=p.proxy
where p.proxy is null
) returning *;

@@ use proxy
update {%= $table %} p
set last_use=now()
where ctid in (
  select ctid
  from {%= $table %}
  where coalesce(status, ''::char(1)) <> 'B' and coalesce(last_use, now() - interval '1 minute') <= now() - interval '1 minute'
  order by status, ts
  limit 1
)
returning *;

@@ status proxy
update {%= $table %}
set status =?
where proxy=?
returning *;
