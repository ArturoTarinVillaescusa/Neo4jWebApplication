<jsp:root xmlns:jsp="http://java.sun.com/JSP/Page" xmlns="http://www.w3.org/1999/xhtml" version="2.0"
          xmlns:c="http://java.sun.com/jsp/jstl/core"
        >
    <jsp:directive.page contentType="text/html; ISO-8859-1"/>
    <!--@elvariable id="node" type="org.neo4j.graphdb.Node"-->

    <html>
	<head> 
		<meta http-equiv="content-type" content="text/html; charset=UTF-8"/> 
		<script src="js/jquery-2.1.4.js"></script>
		<script>
			var recien_buscado = true;
			function cargaListaUsuarios(nombre) {
				var tablaDatos = [];
				var cypherQuery="MATCH (p:Paciente) WHERE UPPER(p.nombre)=~UPPER('.*"+nombre+".*') RETURN p.nHC, p.nombre, p.fecha_nacimiento, p.longitud, p.latitud, p.poblacion";
				$.ajaxSetup({
					headers: { 
						"Authorization": 'Basic ' + window.btoa("neo4j:arturo")
					}
				});
				
				$.ajax({
					// Neo4j REST web service
					url: "http://localhost:7474/db/data/transaction/commit",
					type: 'POST',
					data: JSON.stringify({ "statements": [{ "statement": cypherQuery }] }),
					contentType: 'application/json',
					accept: 'application/json; charset=UTF-8'                
				}).done(function (data) {
					// Data contains the entire resultset. Each separate record is a data.value item, containing the key/value pairs.
					$.each(data.results[0].data, function (k, v) {
						var cadena = v.row+'';
						var vector=cadena.split(',');
						
						document.getElementById('nHC').value=vector[0];
						document.getElementById('nombre').value=vector[1];
						document.getElementById('fecha_nacimiento').value=vector[2];
						document.getElementById('latitud').value=vector[3];
						document.getElementById('longitud').value=vector[4];
						document.getElementById('poblacion').value=vector[5];
					});
				})
				.fail(function (jqXHR, textStatus, errorThrown) {
					$('#messageArea').html('<h3>' + textStatus + ' : ' + errorThrown + '</h3>')
				});
				
			}
						
			function modificaUsuario(cypherQuery) {
				var tablaDatos = [];
				
				$.ajaxSetup({
					headers: { 
						"Authorization": 'Basic ' + window.btoa("neo4j:arturo")
					}
				});
				
				$.ajax({
					// Neo4j REST web service
					url: "http://localhost:7474/db/data/transaction/commit",
					type: 'POST',
					data: JSON.stringify({ "statements": [{ "statement": cypherQuery }] }),
					contentType: 'application/json',
					accept: 'application/json; charset=UTF-8'                
				}).done(function (data) {
					// Data contains the entire resultset. Each separate record is a data.value item, containing the key/value pairs.
					$.each(data.results[0].data, function (k, v) {
						var cadena = v.row+'';
						var vector=cadena.split(',');
						var id=vector[0];
						var nombre=vector[1];
						
						$('#messageArea').html('Se ha modificado el usuario '+nombre+'.');
					});
				})
				.fail(function (jqXHR, textStatus, errorThrown) {
					$('#messageArea').html('<h3>' + textStatus + ' : ' + errorThrown + '</h3>')
				});

				
			}
			$(function () {
				$('#modificar').click(function () {
					var cypherQuery="MATCH (p:Paciente {nHC: "+document.getElementById('nHC').value+"}) SET p.nombre = '"+document.getElementById('nombre').value+"', p.fecha_nacimiento = '"+document.getElementById('fecha_nacimiento').value+"', p.latitud = "+document.getElementById('latitud').value+", p.longitud = "+document.getElementById('longitud').value+", p.poblacion = '"+document.getElementById('poblacion').value+"' RETURN p.nHC, p.nombre";
					modificaUsuario(cypherQuery);
				});
				$('#limpiar').click(function () {
					document.getElementById('nHC').value='';
					document.getElementById('nombre').value='';
					document.getElementById('fecha_nacimiento').value='';
					document.getElementById('latitud').value='';
					document.getElementById('longitud').value='';
					document.getElementById('poblacion').value='';
					recien_buscado=true;
					$('#messageArea').html('');
				});
			});
			
		</script>
	</head> 

    <body>

		<table>
			  <tr>
				<input type="hidden" id="nHC" />
				<td><label for="fader">Nombre: </label><input type="text" id="nombre" onchange="if (recien_buscado==true) {cargaListaUsuarios(this.value);recien_buscado=false;}"/></td>
				<td><div id="messageArea"></div> </td>
			  </tr>
			  <tr>
				<td><label for="fader">Fecha nacimiento: </label><input type="text" id="fecha_nacimiento" /></td>
			  </tr>
			  <tr>
				<td><label for="fader">Poblacion: </label><input type="text" id="poblacion" /></td>
			  </tr>
			  <tr>
				<td><label for="fader">Latitud: </label><input type="text" id="latitud" /></td>
			  </tr>
			  <tr>
				<td><label for="fader">Longitud: </label><input type="text" id="longitud" /></td>
			  </tr>
			  <tr>
				<td><input name="post cypher" type="button" value="Limpiar formulario" id="limpiar" /></td>
				<td><input name="post cypher" type="button" value="Modificar" id="modificar" /></td>
			  </tr>
		</table>				
    </body>
    </html>
</jsp:root>