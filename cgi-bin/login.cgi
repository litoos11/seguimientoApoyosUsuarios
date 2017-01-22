#!/usr/bin/perl -w
use ConectarDB; #modulo de conexion a base da datos

use strict;
use CGI;#qw(:standard :utf8)
use CGI::Carp qw(fatalsToBrowser);
use CGI::Session;
use Template;

my $cgi = new CGI;
#obtenemos los parametros del form html
my $user = $cgi->param("name", $cgi->param("name"));
my $pass = $cgi->param("pass", $cgi->param("pass"));
 
# Declaramos las variables
my ($mysql, $consulta, $nombre, $contrasena, $id_usuario, $activo, $vars, $input);

# Objeto Tempate 
my $template = Template->new(
	INCLUDE_PATH => '../html',
	ENCODING     => 'UTF-8',
	INTERPOLATE  => 1 );

$input = 'errores.html';

#Filtrar lod tipos de datos instroducidos en el form html
if($user !~ /^[a-zA-Z0-9áéíóú]+$/ or $pass !~ /^[a-zA-Z0-9áéíóú]+$/){
	$vars = {
		error => 1 };
	$template->process($input, $vars) || die $template->error(); 

}else{
# Conectamos con la DB
$mysql = ConectarDB->connect();

#SQL Query
$consulta = $mysql->prepare("Select * from usuarios where usuario = '". $user ."' and password = '".$pass."'");
# Ejecutamos la consulta
$consulta->execute;

my $encontrar = 0;

# Obtener datos de la consulta por nombre de cada elemeto 	
while (my $dato = $consulta->fetchrow_hashref()) {
	$encontrar  = 1;
	$id_usuario = $dato->{'usuario'};
	$contrasena = $dato->{'password'};
	$nombre     = $dato->{'nombre'};
	$activo     = $dato->{'activo'};
}

$mysql->disconnect;

if ($encontrar eq 1) {	
	if($activo == 1){

	my $session = new CGI::Session;
	$session->save_param($cgi);
	$session->expires("+1h");
	$session->flush();
	$session->param('idusuario', $id_usuario);
	$session->param('nombre', $nombre);
	$session->param('contrasena', $contrasena);

	print $session->header(-location => "principal.cgi");

	}else{
		$vars   = {
		error   => 2,
		usuario => $user };
		$template->process($input, $vars) || die $template->error(); 
	}
	
}else{
	$vars = {
		error      => 3,
		usuario    => $user,
		contrasena => $pass };
	$template->process($input, $vars) || die $template->error(); 
}

}

