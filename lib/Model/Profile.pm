package Model::Profile;
use Mojo::Base 'Model::Base';

sub new {
  state $self = shift->SUPER::new(@_);
  #~ $self->template_vars->{tables}{main} = $main_table;
  #~ $self->{template_vars}{tables}{show_tel} = "показ телефона";
  #~ die dumper($self->{template_vars});
  #~ $self->dbh->do($self->sth('таблицы'));
  $self->dbh->do($self->sth('функции'));
  return $self;
}


sub names {
  my $self = ref $_[0] ? shift : shift->new;
  $self->dbh->selectrow_hashref($self->sth('names'), undef, (reverse @_));
}

sub сохранить {
  my ($self, $data) = @_;
  return $self->вставить_или_обновить($self->{template_vars}{schema}, $self->{template_vars}{tables}{profiles}, ["id"], $data);
  
}

sub app_config {
  my ($self, $platform) = @_;
  $self->dbh->selectrow_array($self->sth('app config'), undef, ($platform));
}

1;

__DATA__
@@ names
update "{%= $schema %}"."{%= $tables->{profiles} %}"
set names =?
where id=?
returning *;

@@ app config
select "config"::json as config
from "Конфиг приложения"()
where "platform"=?;

@@ функции
select null;
/* коммент чтобы не затирать версию, меняй в консоли
CREATE or REPLACE FUNCTION "Конфиг приложения"()
RETURNS TABLE("platform" text, "config" text) AS $func$
SELECT *
FROM (VALUES
  ('android', '{"VERSION": 0.0026190, "appName": "ЛовиГа"}')
) AS s ("platform", "config");
$func$ LANGUAGE SQL;
*/
