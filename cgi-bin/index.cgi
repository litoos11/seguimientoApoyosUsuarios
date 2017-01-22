#!/usr/bin/perl -w

use strict;
use CGI qw(:standard :utf8);
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use Template;

print header();

#Crea un objeto Session
my $session = new CGI::Session;

#Cargamos la session 
$session->load();

my @autenticar = $session->param;


my $template = Template->new(
	INCLUDE_PATH => '../html',
	ENCODING     => 'UTF-8');

my $input = 'index.html';
my $input_redireccion = 'redireccion.html';


if(@autenticar eq 0){
	# binmode(STDOUT, ":utf8");
	$template->process($input) || die $template->error(); 

}else{
	$template->process($input_redireccion) || die $template->error(); 
}


exit(1);