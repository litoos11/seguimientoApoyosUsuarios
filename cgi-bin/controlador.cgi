#!/usr/bin/perl
use Vistas;
use Inserta;

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

my $cgi = new CGI;

my ($transaccion, $resp, $nombre, $usuario, $num_actividad, $num_sucursal, $nombre_sucursal, $nombre_actividad, $buscar, $descripcion);
$transaccion = $cgi->param("transaccion");


sub ejecutarTransaccion($transaccion){
	if($transaccion eq "frm-insertar"){
		# Mostrar el formulario de alta
		&Vistas::llamarFormInsertar();
	}elsif($transaccion eq "frm-buscar"){
		# Mostrar el formulario de busqueda
		&Vistas::llamarFormBuscar();
	}elsif($transaccion eq "guardar"){
		# Inserta los datos a la bade de datos
		$nombre           = $cgi->param("txt_nombre");
		$usuario          = $cgi->param("txt_usuario");
		$num_actividad    = $cgi->param("actividad_slc");
		$num_sucursal     = $cgi->param("sucursal_slc");
		$nombre_sucursal  = $cgi->param("texto3");
		$nombre_actividad = $cgi->param("texto4");
		$descripcion = $cgi->param("txta_descripcion");

		&Inserta::guardarRegistro($nombre, $usuario, $num_actividad, $num_sucursal, $nombre_sucursal, $nombre_actividad, $descripcion, $descripcion);		
	}elsif($transaccion eq "buscar"){
		# Realiza la busqueda en la base de datos
		$buscar = $cgi->param("txt_buscar");
		
		&Vistas::buscarRegistro($buscar);
	}
}

&ejecutarTransaccion($transaccion);
