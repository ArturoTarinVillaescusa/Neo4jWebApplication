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
			
			function outputUpdate(limtiempo) {
				document.querySelector('#limtiempo').value = limtiempo;
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
			
			function crea_columna(vehiculo, duration) {
				var campoConsulta = document.createElement('input'); // Create Input Field for Name
				campoConsulta.setAttribute('type', 'hidden');
				campoConsulta.setAttribute('name', 'consultaCypher');
				campoConsulta.setAttribute('value', 
						'MATCH (v)-[r:HA_ESTADO_EN]->(p) WITH v.vehiculoID as vehiculo, r.fecha as fecha, ToFloat(r.delta_t) as delta_t '+
						'WHERE vehiculo=\''+vehiculo+'\' AND (delta_t = 0 OR delta_t > 300) '+
						'RETURN vehiculo, fecha, delta_t order by vehiculo, fecha');
				/*
						'MATCH (v)-[r:HA_ESTADO_EN]->(p) '+
						'WITH v.vehiculoID as vehiculo, p.longitud as longitud, p.latitud as latitud, r.record_id as record_id, '+
						'toInt(r.velocidad) as velocidad, ToFloat(r.delta_t) as delta_t, r.fecha as fecha '+
						'WHERE vehiculo=\''+vehiculo+'\' '+
						'RETURN DISTINCT vehiculo, fecha, record_id, latitud, longitud, velocidad, delta_t ORDER BY fecha');
				*/
						
				// Create Input Fields
				var campoPantalla = document.createElement('input'); 
				campoPantalla.setAttribute("type", "hidden");
				campoPantalla.setAttribute("name", "pantalla");
				campoPantalla.setAttribute("value", "formulariotiempoviajes");

				var campoLimViaje = document.createElement('input'); 
				campoLimViaje.setAttribute("type", "hidden");
				campoLimViaje.setAttribute("name", "limiteviaje");
				campoLimViaje.setAttribute("value", document.getElementById('limtiempo').value);

				var submitElement = document.createElement('input'); // Append Submit Button
				submitElement.setAttribute("type", "submit");
				submitElement.setAttribute('style', 'width:70px;font-size:10px');
				submitElement.setAttribute("name", "texto-cypher");
				submitElement.setAttribute("value", vehiculo);

				var formulario = document.createElement('form');
				formulario.setAttribute("action", "cypher"); // Setting Action to submit to the servlet
				formulario.setAttribute("method", "post"); // Setting Method post
				formulario.setAttribute("target", "_top"); // Open in a new window
				formulario.appendChild(campoConsulta);
				formulario.appendChild(campoPantalla);
				formulario.appendChild(campoLimViaje);
				formulario.appendChild(submitElement);
				
				var cabecera=document.createElement('H3');
				cabecera.setAttribute('align', 'center');
				cabecera.setAttribute('id', vehiculo+'_cabecera');

				cabecera.appendChild(formulario);

				var texto1=document.createElement('input');
				texto1.setAttribute('id', vehiculo+'_viajes');
				texto1.setAttribute('align', 'left');
				texto1.setAttribute('style', 'width:70px;font-size:10px');
				texto1.setAttribute('type', 'text');
				texto1.setAttribute('value', 'Max. trip: '+duration+' hours');
				texto1.setAttribute('readonly', 'true');

				var color_background='lightgreen';
				if (duration > 8)
					color_background='yellow';
				if (duration > 10)
					color_background='red';

				var columna = document.createElement('td');
				columna.setAttribute('id', vehiculo);
				columna.setAttribute('color', 'white');
				columna.setAttribute('bgcolor', color_background);
				columna.appendChild(cabecera);
				columna.appendChild(texto1);
				columna.appendChild(document.createElement('br'));
				columna.title = 'Max. trip: '+duration+' hours';

				return columna;
			}
			
			function dibujarTabla (tablaDatos) {

				var body_tabla_pro = document.getElementById('pro');
				var row_tabla_pro = body_tabla_pro.appendChild(document.createElement('tr'));
			
				// Clean table rows
				body_tabla_pro.innerHTML = '';

				// Remove first row of headers in the array
				tablaDatos.shift();
				
				var vehiculo;
				var fecha;
				var delta_t;
				var vehiculo_temporal_ant;
				var fecha_temporal_ant;
				var delta_t_temporal_ant;
				var vehiculo_temporal;
				var fecha_temporal;
				var delta_t_temporal;				
				var j;
				var i = 0;
				var duration=0;
				var max_duration=0;
				var linea=0;

				// alert(tablaDatos.length);
				
				for (var x in tablaDatos) {

					vehiculo=new String(tablaDatos[i][0]);
					fecha = new Date(tablaDatos[i][1]);
					delta_t=parseInt(tablaDatos[i][2]);
						
					j = i+1;
					
					// Loop to find next vehicle
					do {
						vehiculo_temporal_ant=new String(tablaDatos[j][0]);
						fecha_temporal_ant=new Date(tablaDatos[j][1]);
						delta_t_temporal_ant=parseInt(tablaDatos[j][2]);
						
						vehiculo_temporal=new String(tablaDatos[j+1][0]);
						fecha_temporal=new Date(tablaDatos[j+1][1]);
						delta_t_temporal=parseInt(tablaDatos[j+1][2]);

						//if (vehiculo == 'C010_V3541') {
						//	alert('FUERA DEL IF\ni '+i+ 'j '+j+ '\nvehiculo '+vehiculo+'\nfecha '+fecha+'\nfecha_temporal '+fecha_temporal+' delta_t_temporal '+delta_t_temporal+'\nfecha_temporal_ant '+fecha_temporal_ant+' delta_t_temporal_ant '+delta_t_temporal_ant+'\nduration '+duration+' max_duration '+max_duration);
						//}
						
						// If end date is different day then take previous date as end date
						if (tablaDatos[i][1].substring(0, 10) != tablaDatos[j][1].substring(0, 10)) {
							vehiculo_temporal=vehiculo_temporal_ant;
							fecha_temporal=fecha_temporal_ant;
							delta_t_temporal=delta_t_temporal_ant;
						}
						
						if ((tablaDatos[i][1].substring(0, 10) == tablaDatos[j][1].substring(0, 10)) ) {
							duration = fecha_temporal - fecha;
							// Convert to hours
							duration = duration / 1000 / 60 / 60;
						
							//if (vehiculo == 'C010_V3541') {
							//	alert('i '+i+ ' j '+j+ '\nvehiculo '+vehiculo+'\nfecha '+fecha+'\nfecha_temporal '+fecha_temporal+' delta_t_temporal '+delta_t_temporal+'\nfecha_temporal_ant '+fecha_temporal_ant+' delta_t_temporal_ant '+delta_t_temporal_ant+'\nduration '+duration+' max_duration '+max_duration);
							//}							
								
							if (24 > duration) {
								if (duration > max_duration) {
									max_duration=Math.round(duration);
									//if (vehiculo == 'C010_V3541') {
									//	alert('ACTUALIZADO :::::::>\ni '+i+ 'j '+j+ '\nvehiculo '+vehiculo+'\nfecha '+fecha+'\nfecha_temporal '+fecha_temporal+' delta_t_temporal '+delta_t_temporal+'\nfecha_temporal_ant '+fecha_temporal_ant+' delta_t_temporal_ant '+delta_t_temporal_ant+'\nduration '+duration+' max_duration '+max_duration);
									//}
									
								}
							}
							fecha = new Date(tablaDatos[j+1][1]);
							
						}

						j++;
					} while (vehiculo.valueOf() == vehiculo_temporal.valueOf());
					
					
					if ((linea % 10) == 0) {
						row_tabla_pro = body_tabla_pro.appendChild(document.createElement('tr'));
					}
					//alert(row_tabla_pro.innerHTML);
					
					if (max_duration > document.getElementById('limtiempo').value) {
						row_tabla_pro.appendChild(crea_columna(vehiculo, max_duration));
						linea++;
					}
				    
				    i = j;

				    duration=0;
					max_duration=0;
				}
				alert('solucionado');
				alert('duration '+duration);

				
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
					tablaDatos.push([vectortitulos[0], vectortitulos[1], vectortitulos[2]]);					
					$.each(data.results[0].data, function (k, v) {
						var cadena = v.row+'';
						var vector=cadena.split(',');
						tablaDatos.push([vector[0], vector[1], vector[2]]);
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
			<h1>Trip durations</h1>
		</table>				
		<div id="messageArea">Calculating. Please, hold on ...</div>
			
		<br/><br/>	
		<table align="center">
			<tbody id="pro">
			</tbody>
		</table>				

		<table>
			  <tr>
				<td><input name="cypher" id="cypher-in" type="hidden" value="MATCH (v)-[r:HA_ESTADO_EN]->(p) WITH v.vehiculoID as vehiculo, r.fecha as fecha, ToFloat(r.delta_t) as delta_t WHERE delta_t = 0 OR delta_t > 300 RETURN vehiculo, fecha, delta_t order by vehiculo, fecha" /></td>
					<label for="fader">Trips during more than (hours): </label>
					<output for="fader" id="limtiempo">7</output>
					<input type="range" min="0" max="20" value="7" id="fader" step="1" oninput="outputUpdate(value)"/>
				<td><!-- input name="post cypher" type="button" value="Comenzar a controlar" id="consultar" /--></td>
			  </tr>
		</table>					
	
    </body>
    </html>
</jsp:root>