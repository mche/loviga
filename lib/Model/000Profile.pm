package POS::Profile;
use DBIx::POS::Template;

sub new {
  my $class= shift;
  my %arg = @_;
  #~ $arg{template} = $arg{template} ? merge($arg{template}, $defaults) : $defaults;
  #~ $class->SUPER::new(__FILE__, %arg);
  DBIx::POS::Template->new(__FILE__, %arg);
}

=pod

=encoding utf8

=head3 Warn

B<POD ERRORS> here is normal because DBIx::POS::Template used.

=head1 SQL definitions

=head2 profile oauth.users

=name profile oauth.users

=desc

Весь список внешних профилей 

=sql

  select u.*, s.name as site_name
  from vinylhub."oauth.sites" s
    join vinylhub."oauth.users" u on s.id = u.site_id
    join vinylhub.refs r on u.id=r.id2
  
  where s.id=? and r.id1=? -- профиль ид


=cut

1;
