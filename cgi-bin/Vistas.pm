#!/usr/bin/perl -w
package Vistas;

use ConectarDB; #modulo de conexion a base da datos

use strict;
use CGI;# qw(:standard :utf8)
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use POSIX;


#CRea un objeto CGI
my $cgi = new CGI;

#Crea un objeto Session
my $session = new CGI::Session;

#Cargamos la session 
$session->load();

my ($mysql, $consulta, $tabla, $fila, $suc, $lista, $act, $buscar);



sub listaActividades{

	$mysql = ConectarDB->connect();
	$consulta = $mysql->prepare("SELECT * FROM catalogo_operacion ORDER BY nombre ASC");

		$lista = "<select name='actividad_slc' id='actividad' required class='actividad'>";
		$lista .= "<option value='' >- - -</option>";
	if($consulta->execute){
		while($act = $consulta->fetchrow_hashref()){
			$lista .= "<option class='actividad' value=".$act->{'id_operacion'}.">".$act->{'nombre'}."</option>";
		}
		$consulta->finish;			
	}
	$lista .= "</select>";

	$mysql->disconnect;

	return $lista;	
}


sub listaSucursales{

	$mysql = ConectarDB->connect();
	$consulta = $mysql->prepare("SELECT * FROM catalogo_sucursales ORDER BY region ASC");

		$lista = "<select name='sucursal_slc' id='sucursal' required class='sucursal'>";
		$lista .= "<option value='' >- - -</option>";
	if($consulta->execute){
		while($suc = $consulta->fetchrow_hashref()){
			$lista .= "<option class='sucursal' value=".$suc->{'id_sucursal'}.">".$suc->{'region'}.' - '.$suc->{'nombre'}."</option>";
		}
		$consulta->finish;			
	}
	$lista .= "</select>";

	$mysql->disconnect;

	return $lista;	
}


sub consultaAyudas{

	$mysql = ConectarDB->connect();
	my $sql = "SELECT id_apoyos, nombre_usuario, id_usuario, actividad_realizada, sucursal, fecha, usuario_soporte, T2.nombre AS nombre_actividad, region, T3.nombre AS nombre_sucursal FROM  apoyos AS T1 INNER JOIN catalogo_operacion AS T2 ON T1.actividad_realizada = T2.id_operacion INNER JOIN catalogo_sucursales AS T3 ON T1.sucursal = T3.id_sucursal ORDER BY fecha DESC";
	$consulta = $mysql->prepare($sql);

				my $paginacion;
	
	# Ejecutamos la consulta
	if($consulta->execute){		
		my $totalRegistros = $consulta->rows;
		if($totalRegistros == 0){
			$tabla = "<div class='error'>Error: No hay registros. La Base de Datos esta vac&iacutea</div>";
		}else{


				#########  INICIA PAGINACIÓN  #########
				# Limitar mi consulta SQL
				my $regXPag = 12;
				my $pagina;
				my $inicio;

				# Examinar la página a mostrar y el inicio del registro a mostrar
				if($cgi->param("p")){
					$pagina = $cgi->param("p");
				}

				if(!$pagina){
					$inicio = 0;
					$pagina = 1;
				}else{
					$inicio = ($pagina - 1) * $regXPag;
				}

				# Calculó el total de páginas
				my $totalPaginas = ceil($totalRegistros/$regXPag);

				$sql .= " LIMIT ".$inicio.",".$regXPag;				
				$consulta = $mysql->prepare($sql);
				$consulta->execute;
				# Despliegue  de la paginación
				$paginacion = "<div class='paginacion'>";
					$paginacion .= "<p>";
						$paginacion .= "N&uacutemero de resultados: <b>$totalRegistros</b>. ";
						$paginacion .= "Mostrando <b>$regXPag</b> resultados por p&aacutegina. ";
						$paginacion .= "P&aacutegina <b>$pagina</b> de <b>$totalPaginas</b>.";
					$paginacion .= "</p>";

					if($totalPaginas>1){
						$paginacion .= "<p>";
							$paginacion .= ($pagina != 1) ? "<a href='?p=".($pagina - 1)."'>&laquo</a>" : "";
							
							for(my $i = 1; $i <= $totalPaginas; $i++){

								# si muestro el indice la pagina actual no coloco enlace.
								my $actual = "<span class='actual'>$pagina</span>";
								# si el indice no corresponde a la pagina mostrada actualmente, coloco el enlace para ir a esa pagina.
								my $enlace = "<a href='?p=$i'>$i</a> ";
								$paginacion .= ($pagina == $i ) ? $actual : $enlace;
							}

							$paginacion .= ($pagina != $totalPaginas) ? "<a href='?p=".($pagina + 1)."'>&raquo</a>" : "";
						$paginacion .= "</p>";
					}
				$paginacion .= "</div>";


			########## TERMINA PAGINACIÓN ##########


			$tabla = "<table id='tabla-apoyos' class='tabla'>";
				$tabla .= "<thead>";
					$tabla .= "<tr>	";			
						$tabla .= "<th>Id apoyo</th>";
						$tabla .= "<th>Nombre</th>";
						$tabla .= "<th>Usuario</th>";
						$tabla .= "<th>Actividad</th>";
						$tabla .= "<th>Sucursal</th>";
						$tabla .= "<th>Fecha</th>";
						$tabla .= "<th>Soporte</th>";
					$tabla .= "</tr>";
				$tabla .= "</thead>";
				$tabla .= "<tbody>";
					while ($fila = $consulta->fetchrow_hashref()){
						$tabla .= "<tr>";
							$tabla .= "<td>".$fila->{'id_apoyos'}."</td>";

							my $nueva_fechas = $fila->{'fecha'};
							$nueva_fechas =~ s/\s/-/g;
							$tabla .= "<td><h2><a href='../pdf_generado/".$fila->{'id_usuario'}."".$nueva_fechas.".pdf' target='_blank' class='abrePdf' >".$fila->{'nombre_usuario'}."</h2></td>";

							$tabla .= "<td>".$fila->{'id_usuario'}."</td>";
							$tabla .= "<td>".$fila->{'nombre_actividad'}."</td>";
							# $tabla .= "<td>".$actividad[$fila->{'actividad_realizada'}]."</td>";
							$tabla .= "<td>".$fila->{'region'}." - ".$fila->{'nombre_sucursal'}."</td>";
							# $tabla .= "<td>".$sucursal[$fila->{'sucursal'}]."</td>";
							$tabla .= "<td>".$fila->{'fecha'}."</td>";
							$tabla .= "<td>".$fila->{'usuario_soporte'}."</td>";
						$tabla .= "</tr>";
					}					
				$consulta->finish;
				$tabla .= "</tbody>";
			$tabla .= "</table>";		
		}
	}else{
		 $tabla = "error al hacer la consulta";
	}
	$mysql->disconnect;

	return $tabla.$paginacion;
}

sub llamarFormInsertar{
	my $form = "<html>";
	$form .= "<div class='pop_up'>";
		$form .= "<a href='principal.cgi' title='Close' class='close'>X</a>";			

		$form .= "<form action='' id='alta-registro' class ='formulario' method='POST' data-insertar >";
		$form .= "<fieldset>";
			$form .= "<div>";
				$form .= "<label for=''>Nombre</label>";
				$form .= "<input type='text' name='txt_nombre' id='nombre' required placeholder='Nombre del usuario' >";
			$form .= "</div>";
			$form .= "<div>";
				$form .= "<label for=''>Usuario</label>";
				$form .= "<input type='text' name ='txt_usuario' id='usuario' required placeholder='ejem: 003565acasas' >";
			$form .= "</div>";
			$form .= "<div>";
				$form .= "<label for=''>Sucursal</label>";
			$form .= "</div>";
			$form .= "<div>";
				$form .= listaSucursales();			
			$form .= "</div>";	
			$form .= "<div>";
				$form .= "<label for=''>Actividad Realizada</label>";
			$form .= "</div>";
			$form .= "<div>";
				$form .=  listaActividades();				
			$form .= "</div>";		
			$form .= "<div>";
				$form .= "<textarea rows='6' cols='40' name='txta_descripcion' id='txta_descripcion' class='txta_descripcion'>";
				$form .= "</textarea>";
			$form .= "</div>";		
			$form .= "<div>";
			$form .= "<input type='submit' value='Guardar' name='btn_guardar' id='btn_guardar' class='btn_guardar'>";	
			$form .= "<input type='hidden' id='transaccion' name='transaccion' value='guardar' />";
			$form .= "</div>";
		$form .= "</fieldset>";
			$form .= "</form>";
	$form .= "</div>";
$form .= "</html>";

return printf($form);
}


sub llamarFormBuscar{
	my $formBuscar = "<html>";
	$formBuscar .= "<div class='pop_up'>";
		$formBuscar .= "<a href='principal.cgi' title='Close' class='close'>X</a>";	
		$formBuscar .= "<form action='' id='buscar-registro' class='frmBuscar' method='GET' accept-charset='UTF-8' data-buscar>";
		$formBuscar .= "<fieldset>";
			$formBuscar .= "<div>";
				$formBuscar .= "<label for=''>Buscar</label>";
				$formBuscar .= "<input type='text' name='txt_buscar' id='txtBuscar' placeholder='Texto a buscar'>";
			$formBuscar .= "</div>";
			$formBuscar .= "<div>";
				$formBuscar .= "<input type='submit' name='btn_buscar' id='btn_buscar' class='btn_buscar' value='Buscar' >";	
				$formBuscar .= "<input type='hidden' id='transaccion' name='transaccion' value='buscar' />";
			$formBuscar .= "</div>";
		$formBuscar .= "</fieldset>";
		$formBuscar .= "</form>";
	$formBuscar .= "</div>";
	$formBuscar .= "</html>";

return printf($formBuscar);
}

sub buscarRegistro($arg){
	$buscar = $_[0];

	$mysql = ConectarDB->connect();
	$consulta = $mysql->prepare("SELECT id_apoyos, nombre_usuario, id_usuario, actividad_realizada, sucursal, fecha, usuario_soporte, T2.nombre AS nombre_actividad, region, T3.nombre AS nombre_sucursal FROM  apoyos AS T1 INNER JOIN catalogo_operacion AS T2 ON T1.actividad_realizada = T2.id_operacion INNER JOIN catalogo_sucursales AS T3 ON T1.sucursal = T3.id_sucursal WHERE nombre_usuario LIKE '%" .$buscar. "%' OR T3.nombre LIKE '%" .$buscar. "%' OR T1.sucursal LIKE '%" .$buscar. "%' OR T3.region LIKE '%" .$buscar. "%' ORDER BY fecha DESC");

	
	# Ejecutamos la consulta
	if($consulta->execute){		
		my $totalRegistros = $consulta->rows;
		if($totalRegistros == 0){
			$tabla = "<div class='error' data-recargar>Error: No hay registros que coincidan con esta consulta.</div>";
		}else{
			$tabla = "<table id='tabla-apoyos' class='tabla' data-no-recargar>";
				$tabla .= "<thead>";
					$tabla .= "<tr>	";			
						$tabla .= "<th>Id apoyo</th>";
						$tabla .= "<th>Nombre</th>";
						$tabla .= "<th>Usuario</th>";
						$tabla .= "<th>Actividad</th>";
						$tabla .= "<th>Sucursal</th>";
						$tabla .= "<th>Fecha</th>";
						$tabla .= "<th>Soporte</th>";
					$tabla .= "</tr>";
				$tabla .= "</thead>";
				$tabla .= "<tbody>";
					while ($fila = $consulta->fetchrow_hashref()){
						$tabla .= "<tr>";
							$tabla .= "<td>".$fila->{'id_apoyos'}."</td>";
							# $tabla .= "<td><h2>".$fila->{'nombre_usuario'}."</h2></td>";
							my $nueva_fechas = $fila->{'fecha'};
							$nueva_fechas =~ s/\s/-/g;
							$tabla .= "<td><h2><a href='../pdf_generado/".$fila->{'id_usuario'}."".$nueva_fechas.".pdf' target='_blank' class='abrePdf' >".$fila->{'nombre_usuario'}."</h2></td>";

							$tabla .= "<td>".$fila->{'id_usuario'}."</td>";
							$tabla .= "<td>".$fila->{'nombre_actividad'}."</td>";
							# $tabla .= "<td>".$actividad[$fila->{'actividad_realizada'}]."</td>";
							$tabla .= "<td>".$fila->{'region'}." - ".$fila->{'nombre_sucursal'}."</td>";
							# $tabla .= "<td>".$sucursal[$fila->{'sucursal'}]."</td>";
							$tabla .= "<td>".$fila->{'fecha'}."</td>";
							$tabla .= "<td>".$fila->{'usuario_soporte'}."</td>";
						$tabla .= "</tr>";
					}					
				$consulta->finish;
				$tabla .= "</tbody>";
			$tabla .= "</table>";		
			
		}
	}else{
		 $tabla = "error al hacer la consulta";
	}
	$mysql->disconnect;

	return printf ($tabla);
}

1;
