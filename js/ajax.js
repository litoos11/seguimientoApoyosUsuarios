 
//Constantes
var READY_STATE_UNINITIALIZED=0; 
var READY_STATE_LOADING=1; 
var READY_STATE_LOADED=2;
var READY_STATE_INTERACTIVE=3; 
var READY_STATE_COMPLETE=4;
 
//Variables
var ajax = null;
var btnInsertar = document.querySelector("#aInsertar");
var btnBuscar = document.querySelector("#aBuscar");

var divRespuesta = document.querySelector('#respuesta');
var divConsulta = document.querySelector('#consulta'); 

//Funciones
function objetoAJAX(){
	//Validamos que navegador es IE u otro
	if (window.XMLHttpRequest){
		return new XMLHttpRequest();
	}else if(window.ActiveXObject){
		return new ActiveXObject("Microsoft.XMLHTTP");
	}
}

function insertarRegistro(evento){

	// alert("Procesa el formulario");
	evento.preventDefault();

	// console.log(evento.target.length);

	var nombre = new Array();
	var valor = new Array();
	var hijosForm = evento.target;
	var datos = "";

	var text = new Array();


	for(var i = 1; i < hijosForm.length; i++){
		nombre[i] = hijosForm[i].name;
		valor[i] = hijosForm[i].value;

		if(i==3 || i==4){
			text[i] = hijosForm[i].options[hijosForm[i].selectedIndex].text;
			datos = datos += "texto"+i+"="+text[i]+"&";
			// alert(datos);
		}


		datos = datos += nombre[i]+"="+valor[i]+"&";
	  //console.log(datos);
	}
	ejecutarAjax(datos);
}	

function buscarRegistro(evento){
	evento.preventDefault();
	var nombre = new Array();
	var valor = new Array();
	var hijosForm = evento.target;
	var datos = "";

	for(var i = 1; i < hijosForm.length; i++){
		nombre[i] = hijosForm[i].name;
		valor[i] = hijosForm[i].value;

		datos = datos += nombre[i]+"="+valor[i]+"&";
		console.log(datos);
	}
	ejecutarAjax(datos);

}

function enviarDatos(){
	if(ajax.readyState == READY_STATE_COMPLETE){
		if(ajax.status == 200){
			if(ajax.responseText.indexOf("data-no-recargar")>-1){				
    			divConsulta.innerHTML = ajax.responseText; 
    			while(divRespuesta.hasChildNodes()){
					divRespuesta.removeChild(divRespuesta.firstChild);
				}
    			divRespuesta.style.display = "none";
    			if(location.hash === '#respuesta'){ 
    				window.location.href = "#";
    			}
			}			
			else {
				divRespuesta.innerHTML = ajax.responseText;	
			}

			if(ajax.responseText.indexOf("data-insertar")>-1){				
				document.querySelector("#alta-registro").addEventListener("submit", insertarRegistro);
			}

			if(ajax.responseText.indexOf("data-buscar")>-1){
				document.querySelector("#buscar-registro").addEventListener("submit", buscarRegistro);
			}			

			if(ajax.responseText.indexOf("data-recargar")>-1){
				if(location.hash === '#respuesta'){ 
    				window.location.href = "?p=1";
    				}
			}
		
		}else{			// alert("nooo");
			alert("El servidor No contestó\nError "+ajax.status+": "+ajax.statusText);
		}
	}
}

function ejecutarAjax(datos) {
	ajax = objetoAJAX();
	ajax.onreadystatechange = enviarDatos;
	ajax.open("POST", "controlador.cgi", true);
	ajax.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	ajax.send(datos);
}

function llamarFormAlta(evento){
	// evento.preventDefault();
	divRespuesta.style.display = "block";
	var datos = "transaccion=frm-insertar";
	ejecutarAjax(datos);
}

function llamaFormBuscar(evento){
	divRespuesta.style.display = "block";
	var datos = "transaccion=frm-buscar";
	ejecutarAjax(datos);
}

function alCargarDocumento(){
	btnInsertar.addEventListener("click", llamarFormAlta);
	btnBuscar.addEventListener("click", llamaFormBuscar);
}

//Eventos
window.addEventListener("load", alCargarDocumento);
