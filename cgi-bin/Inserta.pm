#!/usr/bin/perl -w
package Inserta;

use ConectarDB; #modulo de conexion a base da datos

use strict;
use CGI qw(:standard :utf8);# qw(:standard :utf8) Necesario para escribir acentos y ñ en el PDF
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use POSIX qw/ strftime /;
use Encode;

use PDF::API2;


my $tiempo =strftime( "%Y-%m-%d %H:%M:%S", localtime(time) );

#Crea un objeto CGI
my $cgi = new CGI;

#Crea un objeto Session
my $session = new CGI::Session;

#Cargamos la session 
$session->load();

#Declaramos variables que vamos a utilizar
my ($mysql, $consulta, $nombre, $usuario, $num_actividad, $num_sucursal, $nombre_actividad, $nombre_sucursal, $usuario_soporte, $respuesta, $descripcion);

print $cgi->header();

# Obtenemos los valores que vienen en la url
$usuario_soporte = $session->param('idusuario');

	# print $nombre.$usuario.$actividad.$sucursal.$usuario_soporte;
	
sub guardarRegistro($arg1,$arg2,$arg3,$arg4,$arg5,$arg6,$arg7){
	$nombre           = $_[0];
	$usuario          = $_[1];
	$num_actividad    = $_[2];
	$num_sucursal     = $_[3];
	$nombre_sucursal  = $_[4];
	$nombre_actividad = $_[5];
	$descripcion      = $_[6];

	if ($nombre eq "" or $usuario eq "" or $num_actividad eq "- - -" or $num_sucursal eq "- - -" or $usuario_soporte eq ""){
		$respuesta = "<div class='error' data-recargar>Ocurri&oacute un error NO se puden guardar campos nulos.</div>";
	}else{
		$mysql = ConectarDB->connect();
			$consulta = $mysql->prepare("INSERT INTO apoyos (id_apoyos, nombre_usuario, id_usuario, actividad_realizada, sucursal, fecha, usuario_soporte, descripcion) VALUES
			(?,?,?,?,?,?,?,?)");				
			# if($consulta->execute(0, encode('utf-8',$nombre), encode('utf-8',$usuario), $actividad, $sucursal, $tiempo, encode('utf-8',$usuario_soporte))){
			if($consulta->execute(0, $nombre, $usuario, $num_actividad, $num_sucursal, $tiempo, encode('utf-8',$usuario_soporte), $descripcion)){
				$respuesta = "<div class='exito' data-recargar>Se insert&oacute con &eacutexito el registro.</div>";

				#################### Guardamos en PDF los datos############################
				# Create a blank PDF file
				my $pdf = PDF::API2->new();
				
				# Abre la plantilla del pdf
				$pdf = PDF::API2->open('../pdf/ayuda.pdf');
				
				# Agrega una hoja en blanco
				# $page = $pdf->page();
				
				# Obtiene un pagina existente
				my $page_number = 1;
				my $page = $pdf->openpage($page_number);
				
				# Asigna el tamaño de la hoja
				$page->mediabox('Letter');
				
				# Agrega un fuente al pdf
				my $font = $pdf->corefont('Helvetica-Bold');
				
				# Agrega una fuente externa TTF a el PDF
				$font = $pdf->ttfont('../fonts/Chalet.ttf');
				
				# Agergar texto al pdf
				my $text = $page->text();
				$text->font($font, 10);
				$text->translate(135, 724);
				$text->text($usuario);
				
				$text = $page->text();
				$text->font($font, 10);
				$text->translate(335, 724);
				$text->text($nombre);

				$text = $page->text();
				$text->font($font, 10);
				$text->translate(160, 711);
				$text->text($nombre_sucursal);

				$text = $page->text();
		    	$text->font($font, 10);
		    	$text->translate(60, 697);
		    	$text->text($nombre_actividad);

		    	$text = $page->text();
		    	$text->font($font, 10);
		    	$text->translate(220, 697);
		    	$text->text($tiempo);

		    	$text = $page->text();
		    	$text->font($font, 10);
		    	$text->translate(435, 697);
		    	$text->text($usuario_soporte);
				
		    	$text = $page->text();
		    	$text->font($font, 8);
		    	$text->translate(90,650);
		    	$text->text($descripcion);

				# Guarda el PDF				
  				# $pdf->saveas('/home/equipo3/Documentos/AOS/Ayudas/'.$usuario.' '.$tiempo.'.pdf');
  				my $nuevo_tiempo = $tiempo;
  				$nuevo_tiempo =~ s/\s/-/g;
  				
  				$pdf->saveas('../pdf_generado/'.$usuario.''.$nuevo_tiempo.'.pdf');


				#################### Finaliza guardado ############################

			}else{
				$respuesta = "<div class='error' data-recargar>Ocurri&oacute un error NO se guardaron los datos.</div>";
			}

			$mysql->disconnect;
	}
	
return printf($respuesta);
}
