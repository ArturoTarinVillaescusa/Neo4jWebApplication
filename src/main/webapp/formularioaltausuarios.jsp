<jsp:root xmlns:jsp="http://java.sun.com/JSP/Page" xmlns="http://www.w3.org/1999/xhtml" version="2.0"
          xmlns:c="http://java.sun.com/jsp/jstl/core"
        >
    <jsp:directive.page contentType="text/html; ISO-8859-1"/>
    <!--@elvariable id="node" type="org.neo4j.graphdb.Node"-->

    <html>
	<head> 
		<meta http-equiv="content-type" content="text/html; charset=UTF-8"/> 
		<script src="js/jquery-2.1.4.js"></script>
		<!-- script type="text/javascript" src="https://www.google.com/jsapi"></script-->

		<script>
			function altaUsuario(cypherQuery) {
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
						
						$('#messageArea').html('Se ha creado el usuario '+nombre+'. SE EL HA ASIGNADO EL nHC '+id+'.');
					});
				})
				.fail(function (jqXHR, textStatus, errorThrown) {
					$('#messageArea').html('<h3>' + textStatus + ' : ' + errorThrown + '</h3>')
				});

				
			}
			$(function () {
				$('#guardar').click(function () {
					var cypherQuery=
					// get unique nHC
					"MERGE (nhc:nHC{name:'nhc'}) "+
					"ON CREATE SET nhc.count = 1 "+
					"ON MATCH SET nhc.count = nhc.count + 1 "+
					"WITH nhc.count AS uid "+
					// create Person node
					"CREATE (p:Paciente{nHC:uid, nombre : '"+$('#nombre').val()+"', fecha_nacimiento: '"+$('#fecha_nacimiento').val()+"', latitud: "+
						$('#latitud').val()+", longitud: "+$('#longitud').val()+", poblacion: '"+$('#poblacion').val()+"' }) RETURN p.nHC, p.nombre ";

					altaUsuario(cypherQuery);
				});
			});
			
		</script>
	</head> 

    <body>
		<table>
			  <tr>
				<td><label for="fader">Nombre: </label><input type="text" id="nombre" /></td>
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
				<td><input name="post cypher" type="button" value="Guardar" id="guardar" /></td>
			  </tr>
		</table>				
    </body>
    </html>
</jsp:root>