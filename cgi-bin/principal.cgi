#!/usr/bin/perl

use ConectarDB; #modulo de conexion a base da datos
use Vistas;

use strict;
use CGI qw(:standard :utf8);#
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use Template;


#CRea un objeto CGI
my $cgi = new CGI;

my ($nombre, $contrasena, $id, $input,$input_error, $vars);

#Crea un objeto Session
my $session = new CGI::Session;

#Cargamos la session 
$session->load();


my $sucursales = Vistas::listaSucursales();
my $actividad  = Vistas::listaActividades();

$nombre     = $session->param('nombre');
$contrasena = $session->param('contrasena');
$id         = $session->param('idusuario');

my @autenticar = $session->param;

# Objeto Tempate 
my $template = Template->new(
	INCLUDE_PATH => '../html',
	ENCODING     => 'UTF-8',
	INTERPOLATE  => 1 );

$input = 'principal.html';
$input_error = 'errores.html';

if(@autenticar eq 0){
	$session->delete();
	$session->flush();
	$vars = {
		error => 4 };
	$template->process($input_error, $vars) || die $template->error();

}elsif($session->is_expired){
	$session->delete();
	$session->flush();
	$vars = {
		error => 5 };
	$template->process($input_error, $vars) || die $template->error();

}else{	
	my $consulta = &Vistas::consultaAyudas();	
	$vars = {
		consulta => $consulta,
		nombre   => $nombre };

	my $html = $template->process($input, $vars) || die $template->error(); 
}
