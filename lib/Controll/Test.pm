package Controll::Test;
use Mojo::Base 'Mojolicious::Controller';
use RFC::RFC822::Address;
use Email;

sub email {
  my $c = shift;
  
  my $to = $c->vars('email');
  
  if (RFC::RFC822::Address::valid($to)) {
    my $smtp = $c->config->{smtp};
    my $email = Email->new(
      ssl => $smtp->{ssl},
      host=>$smtp->{host},
      port=>$smtp->{port},
      smtp_user =>$smtp->{user},
      smtp_pw =>$smtp->{pw},
    );
    my $send = $email->send(
      subject => "Восстановление пароля",
      from => $smtp->{user},
      to => $to,
      #~ cc=>'info@',
      body =>"Это тестовое письмо.\n\nС уважением, сервис грузопереревозок ЛовиГазель",
    );
    return $c->render(text=>$send);
  }
  $c->render(text=>"Неверный емайл: $to");
  
}

1;