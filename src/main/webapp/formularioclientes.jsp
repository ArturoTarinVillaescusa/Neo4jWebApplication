<jsp:root xmlns:jsp="http://java.sun.com/JSP/Page" xmlns="http://www.w3.org/1999/xhtml" version="2.0"
          xmlns:c="http://java.sun.com/jsp/jstl/core"
        >
    <jsp:directive.page contentType="text/html; ISO-8859-1"/>
    <!--@elvariable id="node" type="org.neo4j.graphdb.Node"-->

    <html>
	<head> 
		<meta http-equiv="content-type" content="text/html; charset=UTF-8"/> 
		<script src="js/jquery-2.1.4.js"></script>
		<script type="text/javascript" src="https://www.google.com/jsapi"></script>
		<!--script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js"></script-->
		<script src="js/d3/3.5.5/d3.min.js"></script>

		<script>
			window.onload=construirPanel();
			
			// Launch Cypher query and redraw the Control Panel every 30 seconds
			var timer = setInterval("construirPanel()", 3000);
			
			function outputUpdate(velocidad) {
				document.querySelector('#velocidad').value = velocidad;
				document.querySelector('#cypher-in').value = 
				'MATCH (c)-[r:TIENE]->(v)-[]->() '+
				'WITH MAX(ToInt(v.maxspeed)) AS velocidad, c.clienteID AS cliente '+
				'WHERE velocidad &gt; '+velocidad+' RETURN DISTINCT cliente, velocidad ORDER BY cliente, velocidad DESC';
				
				document.querySelector('#consultaCypher').value=
				'MATCH (c)-[]->(v)-[r:HA_ESTADO_EN]->(p) WITH v.vehiculoID as vehiculo, '+
				'p.longitud as longitud, c.clienteID as cliente, p.latitud as latitud, toInt(r.velocidad) as velocidad, '+
				'r.fecha as fecha WHERE velocidad &gt; '+velocidad+
				' RETURN DISTINCT cliente, vehiculo, latitud, longitud, velocidad, fecha ORDER BY cliente, vehiculo, fecha DESC';

			}
			
			function dibujarGrafo (tablaDatos) {
				// Clear the whiteboard
				d3.select("svg").remove();
				
				var width = 960,
					height = 500;

				var color = d3.scale.category20();

				var force = d3.layout.force()
					.charge(-120)
					.linkDistance(170)
					.size([width, height]);

				var svg = d3.select("body").append("svg")
					.attr("width", width)
					.attr("height", height);

	   
				// Example
				var textoparajson = '{  "nodes":['+
				  '  {"name":"aaaa","group":1},'+
				  '  {"name":"eeeeeeeeeee","group":1},'+
				  '  {"name":"uuuuuuuuuuuuuuu","group":8}'+
				  '],'+
				  '"links":['+
				  '  {"source":0,"target":2,"value":2}'+
				  '] }';

				var textonodos = '{  "nodes":[';
				var textolinks = ' "links":[';

				for (var i in tablaDatos) {
				  if (i > 0 ) {
					vehiculo=tablaDatos[i][1];
					numveces=tablaDatos[i][4].valueOf();
					longitud=tablaDatos[i][2];
					latitud=tablaDatos[i][3];
					
					textonodos = textonodos + ' {"name":"Vehiculo: ' + vehiculo + ' , Veces que ha estado aqui: ' + numveces + '","group":1},';
					textolinks = textolinks + ' {"source":' + (i-1) + ',"target":1,"value":1},';
				  }
				}
				
				textonodos = textonodos.substr(0, textonodos.length - 1) + '],';
				textolinks = textolinks.substr(0, textolinks.length - 1) + '] }';
				textoparajson = textonodos + textolinks;

				var graph =  JSON.parse(textoparajson);
				
				  force
					  .nodes(graph.nodes)
					  .links(graph.links)
					  .start();

				  var link = svg.selectAll(".link")
					  .data(graph.links)
					.enter().append("line")
					  .attr("class", "link")
					  .style("stroke-width", function(d) { return Math.sqrt(d.value); });

				  var node = svg.selectAll(".node")
					  .data(graph.nodes)
					.enter().append("circle")
					  .attr("class", "node")
					  .attr("r", 14)
					  .style("fill", function(d) { return color(d.group); })
					  .call(force.drag);

				  node.append("title")
					  .text(function(d) { return d.name; });

				  force.on("tick", function() {
					link.attr("x1", function(d) { return d.source.x; })
						.attr("y1", function(d) { return d.source.y; })
						.attr("x2", function(d) { return d.target.x; })
						.attr("y2", function(d) { return d.target.y; });

					node.attr("cx", function(d) { return d.x; })
						.attr("cy", function(d) { return d.y; });
				  });
			}
			
			function crea_columna(cliente, velocidad, latitud, longitud, numveces) {
				var campoConsulta = document.createElement('input'); // Create Input Field for Name
				campoConsulta.setAttribute('type', 'hidden');
				campoConsulta.setAttribute('name', 'consultaCypher');
				campoConsulta.setAttribute('value',
						'MATCH (c)-[r:TIENE]->(v)-[]->() '+
						'WITH ToInt(v.maxspeed) AS velocidad, v.vehiculoID as vehiculo, c.clienteID AS cliente '+
						'WHERE velocidad &gt; '+document.getElementById('velocidad').value+' AND cliente = \''+cliente+'\' '+
						'RETURN DISTINCT cliente, vehiculo, velocidad ORDER BY cliente, vehiculo DESC');
				
				// Create Input Fields
				var campoPantalla = document.createElement('input'); 
				campoPantalla.setAttribute("type", "hidden");
				campoPantalla.setAttribute("name", "pantalla");
				campoPantalla.setAttribute("value", "formularioclientes");

				var campoLimVelocidad = document.createElement('input'); 
				campoLimVelocidad.setAttribute("type", "hidden");
				campoLimVelocidad.setAttribute("name", "limitevelocidad");
				campoLimVelocidad.setAttribute("value", document.getElementById('velocidad').value);

				var submitElement = document.createElement('input'); // Append Submit Button
				submitElement.setAttribute("type", "submit");
				submitElement.setAttribute('style', 'width:125px;font-size:10px');
				submitElement.setAttribute("name", "texto-cypher");
				submitElement.setAttribute("value", cliente);

				var formulario = document.createElement('form');
				formulario.setAttribute("action", "cypher"); // Setting Action to submit to the servlet
				formulario.setAttribute("method", "post"); // Setting Method post
				formulario.setAttribute("target", "_top"); // Open in a new window
				formulario.appendChild(campoConsulta);
				formulario.appendChild(campoPantalla);
				formulario.appendChild(campoLimVelocidad);
				formulario.appendChild(submitElement);
				
				var cabecera=document.createElement('H3');
				cabecera.setAttribute('align', 'center');
				cabecera.setAttribute('id', velocidad+'_cabecera');

				cabecera.appendChild(formulario);

				var texto1=document.createElement('input');
				texto1.setAttribute('id', velocidad+'_vel');
				texto1.setAttribute('align', 'left');
				texto1.setAttribute('style', 'width:120px;font-size:10px');
				texto1.setAttribute('type', 'text');
				texto1.setAttribute('value', 'A vehicle  reached '+velocidad+' KM/h');
				texto1.setAttribute('readonly', 'true');

				var color_background='lightgreen';
				if (velocidad > 110)
					color_background='yellow';
				if (velocidad > 120)
					color_background='red';
				
				var columna = document.createElement('td');
				columna.setAttribute('id', velocidad);
				columna.setAttribute('color', 'white');
				columna.setAttribute('bgcolor', color_background);
				columna.appendChild(cabecera);
				columna.appendChild(texto1);
				columna.appendChild(document.createElement('br'));
				columna.title = cliente+' has a vehicle that reached '+velocidad+' KM/h';

				return columna;
			}
			
			function dibujarTabla (tablaDatos) {
				var body_tabla_pro = document.getElementById('pro');
				var row_tabla_pro = body_tabla_pro.appendChild(document.createElement('tr'));
				
				// Clean table rows
				body_tabla_pro.innerHTML = '';

				// Remove first row of headers in the array
				tablaDatos.shift();
				
				for (var i in tablaDatos) {
					var cliente=tablaDatos[i][0];
					var velocidad=tablaDatos[i][1];
					var latitud=tablaDatos[i][2];
					var longitud=tablaDatos[i][3];
					var numveces=tablaDatos[i][4];
					numveces=parseInt(numveces);
				
					if ((i % 8) == 0) {
						row_tabla_pro = body_tabla_pro.appendChild(document.createElement('tr'));
					}
					//alert(row_tabla_pro.innerHTML);					
					row_tabla_pro.appendChild(crea_columna(cliente, velocidad, latitud, longitud, numveces));		
				}
				//alert(row_tabla_pro.innerHTML);
			}
			
			function construirPanel() {
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
					data: JSON.stringify({ "statements": [{ "statement": $('#cypher-in').val() }] }),
					contentType: 'application/json',
					accept: 'application/json; charset=UTF-8'                
				}).done(function (data) {
					// Data contains the entire resultset. Each separate record is a data.value item, containing the key/value pairs.
					var titulos = data.results[0].columns+'';
					var vectortitulos=titulos.split(',');
					tablaDatos.push([vectortitulos[0], vectortitulos[1], vectortitulos[2], vectortitulos[3], vectortitulos[4], vectortitulos[5], vectortitulos[6]]);					
					$.each(data.results[0].data, function (k, v) {
						var cadena = v.row+'';
						var vector=cadena.split(',');
						tablaDatos.push([vector[0], vector[1], vector[2], vector[3], vector[4], vector[5]]);
					});
					$('#messageArea').html('');

					/* 
					
					DESCOMENTARLO SI SE NECESITA DIBUJAR EL GRAFO D3JS
					
					// We paint the graph when the query is finished
					var data = google.visualization.arrayToDataTable(tablaDatos);
					if (tablaDatos.length > 2) {
						dibujarGrafo(tablaDatos);
					} else {
						// Clear the whiteboard
						d3.select("svg").remove();
					}
					*/
					dibujarTabla(tablaDatos);

				})
				.fail(function (jqXHR, textStatus, errorThrown) {
					$('#messageArea').html('<h3>' + textStatus + ' : ' + errorThrown + '</h3>')
				});

				
			}
			$(function () {
				$('#consultar').click(function () {
					google.load('visualization', '1', {packages:['table', 'map', 'corechart', 'bar'], language: 'en', callback: construirPanel});
				});
			});
			
		</script>
	</head> 

    <body>
		<table align="center">
			<h2>Customers vehicle's speed (km/h)</h2>
		</table>    
    
		<div id="messageArea">Calculating. Please, hold on ...</div>
		
		<form action="cypher" method="post" target="_top" >
			<input name="consultaCypher" id="consultaCypher" type="hidden"
					value="MATCH (c)-[]->(v)-[r:HA_ESTADO_EN]->(p) WITH v.vehiculoID as vehiculo, p.longitud as longitud, c.clienteID as cliente, p.latitud as latitud, toInt(r.velocidad) as velocidad, r.fecha as fecha WHERE velocidad > 120 RETURN DISTINCT cliente, vehiculo, latitud, longitud, velocidad, fecha ORDER BY cliente, vehiculo, fecha desc, latitud, longitud" />
			<input name="pantalla" type="hidden" value="formulariofrecuentamucho_mapa" />
			<input id="texto-cypher" type="submit" value="All vehicles excesses in a map" />
		</form>		
		<br/><br/>	
		<table align="center">
			<tbody id="pro">
			</tbody>
		</table>				

		<table>
			  <tr>
				<td><input name="cypher" id="cypher-in" type="hidden" value="MATCH (c)-[r:TIENE]->(v)-[]->() WITH MAX(ToInt(v.maxspeed)) AS velocidad, c.clienteID AS cliente WHERE velocidad > 120 RETURN DISTINCT cliente, velocidad ORDER BY cliente, velocidad DESC" /></td>
					<label for="fader">Customers with vehicle's who's speed (km/h) exceeded: </label>
					<output for="fader" id="velocidad">120</output>
					<input type="range" min="0" max="200" value="120" id="fader" step="1" oninput="outputUpdate(value)"/>
				<td><!-- input name="post cypher" type="button" value="Comenzar a controlar" id="consultar" /--></td>
			  </tr>
		</table>					
	
    </body>
    </html>
</jsp:root>