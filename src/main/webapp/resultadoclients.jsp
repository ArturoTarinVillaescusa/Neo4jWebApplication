<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Map.Entry" %>
<%@ page import="java.util.Collection" %>
<%@ page import="org.neo4j.graphdb.Result" %>
<%@ page import="org.neo4j.rest.graphdb.util.QueryResult" %>

<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html> 
<head> 
  <meta http-equiv="content-type" content="text/html; charset=UTF-8"> 
  <title>Vehicle's details</title> 
  <script src="http://maps.google.com/maps/api/js?sensor=false"></script>
  <script type="text/javascript" src="https://www.google.com/jsapi"></script>
  <!--script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js"></script-->
  <script src="js/d3/3.5.5/d3.min.js"></script>
  <script src="js/jquery-2.1.4.js"></script>
	
  <script type="text/javascript">
    google.load('visualization', '1', {'packages': ['table', 'map', 'corechart', 'bar', 'gauge']});
	
			window.onload=construirPanel();
			
			// Launch Cypher query and redraw the Control Panel every 30 seconds
			var timer = setInterval("construirPanel()", 3000);
			
			function lowestLimitUpdate(velocidadmin) {
				document.querySelector('#velocidad').value = velocidadmin;
				document.getElementById('textovelmin').innerHTML = 'Vehicles with speed over '+velocidadmin+' km/h';
				document.querySelector('#cypher-in').value = 
				'MATCH ()-[h:HA_ESTADO_EN]->(g:Gps) WITH MAX(toInt(g.velocidad)) AS velocidad, g.vehicle_id AS vehiculo, g.client_id AS cliente WHERE velocidad > '+velocidadmin+' AND '+document.querySelector('#velocidadmax').value+' > velocidad AND cliente =~ ".*'+document.getElementById('clientname1').value+'.*" RETURN DISTINCT cliente, vehiculo, velocidad ORDER BY cliente, vehiculo DESC';
			}
			
			function highestLimitUpdate(velocidadmax) {
				document.querySelector('#velocidadmax').value = velocidadmax;
				document.getElementById('textovelmax').innerHTML = 'Vehicles with speed under '+velocidadmax+' km/h';
				document.querySelector('#cypher-in').value = 
				'MATCH ()-[h:HA_ESTADO_EN]->(g:Gps) WITH MAX(toInt(g.velocidad)) AS velocidad, g.vehicle_id AS vehiculo, g.client_id AS cliente WHERE velocidad > '+document.querySelector('#velocidad').value+' AND '+velocidadmax+' > velocidad AND cliente =~ ".*'+document.getElementById('clientname1').value+'.*" RETURN DISTINCT cliente, vehiculo, velocidad ORDER BY cliente, vehiculo DESC';
			}
			
			function nameUpdate() {
				document.querySelector('#cypher-in').value = 
				'MATCH ()-[h:HA_ESTADO_EN]->(g:Gps) WITH MAX(toInt(g.velocidad)) AS velocidad, g.vehicle_id AS vehiculo, g.client_id AS cliente WHERE velocidad > '+document.querySelector('#velocidad').value+' AND '+document.querySelector('#velocidadmax').value+' > velocidad AND cliente =~ ".*'+document.getElementById('clientname1').value+'.*" RETURN DISTINCT cliente, vehiculo, velocidad ORDER BY cliente, vehiculo DESC';				
			}			

			function crea_columna(cliente, vehiculo, velocidad) {
				var color_background='lightgreen';
				
				if (velocidad > 120) {
					color_background='red';
				} else if (velocidad > 110) {
					color_background='yellow';
				}
				
				var campoConsulta = document.createElement('input'); // Create Input Field for Name
				campoConsulta.setAttribute('type', 'hidden');
				campoConsulta.setAttribute('name', 'consultaCypher');
				campoConsulta.setAttribute('value',
						'MATCH ()-[h:HA_ESTADO_EN]->(g:Gps) WITH g.vehicle_id as vehiculo, toFloat(g.longitud) as longitud, g.client_id as cliente, toFloat(g.latitud) as latitud, toInt(g.velocidad) as velocidad, g.fecha as fecha WHERE vehiculo = \''+vehiculo+'\' AND velocidad > '+document.getElementById('velocidad').value+' AND '+document.getElementById('velocidadmax').value+' > velocidad RETURN DISTINCT cliente, vehiculo, latitud, longitud, velocidad, fecha ORDER BY cliente, vehiculo, fecha desc');
				
				// Create Input Fields
				var campoDiv = document.createElement('div');
				campoDiv.setAttribute("class", "bloque_google");
				campoDiv.setAttribute("id", "gauge_div_"+vehiculo);
				campoDiv.setAttribute("onclick", "this.parentNode.submit();");
				campoDiv.setAttribute("style", "width: 200px; height: 220px");
				
				var campoPantalla = document.createElement('input'); 
				campoPantalla.setAttribute("type", "hidden");
				campoPantalla.setAttribute("name", "pantalla");
				campoPantalla.setAttribute("value", "resultadoclients");

				var campoLimVelocidad = document.createElement('input'); 
				campoLimVelocidad.setAttribute("type", "hidden");
				campoLimVelocidad.setAttribute("name", "limitevelocidad");
				campoLimVelocidad.setAttribute("value", document.getElementById('velocidad').value);

				var submitElement = document.createElement('input'); // Append Submit Button
				submitElement.setAttribute("type", "submit");
				submitElement.setAttribute('style', 'width:125px;font-size:10px;');
				submitElement.setAttribute("name", "texto-cypher");
				submitElement.setAttribute("value", cliente);

				var formulario = document.createElement('form');
				formulario.setAttribute("action", "cypher"); // Setting Action to submit to the servlet
				formulario.setAttribute("method", "post"); // Setting Method post
				formulario.setAttribute("target", "_top"); // Open in a new window
				formulario.appendChild(campoConsulta);
				formulario.appendChild(campoDiv);
				formulario.appendChild(campoPantalla);
				formulario.appendChild(campoLimVelocidad);
				// formulario.appendChild(submitElement);
				
				var cabecera=document.createElement('H3');
				cabecera.setAttribute('align', 'center');
				cabecera.setAttribute('id', velocidad+'_cabecera');

				cabecera.appendChild(formulario);

				var texto1=document.createElement('input');
				texto1.setAttribute('id', velocidad+'_vel');
				texto1.setAttribute('align', 'left');
				texto1.setAttribute('style', 'width:120px;font-size:10px;');
				texto1.setAttribute('type', 'text');
				texto1.setAttribute('value', 'Reached '+velocidad+' KM/h');
				texto1.setAttribute('readonly', 'true');

				var columna = document.createElement('td');
				columna.setAttribute('id', velocidad);
				columna.setAttribute('color', 'white');
				columna.appendChild(cabecera);
				// columna.appendChild(texto1);
				columna.appendChild(document.createElement('br'));
				columna.title = 'Click to see '+vehiculo+' trips';

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
					var vehiculo=tablaDatos[i][1];
					var velocidad=tablaDatos[i][2];
					
					if ((i % 4) == 0) {
						row_tabla_pro = body_tabla_pro.appendChild(document.createElement('tr'));
					}
					//alert(row_tabla_pro.innerHTML);					
					row_tabla_pro.appendChild(crea_columna(cliente, vehiculo, velocidad));		
				}
				//alert(row_tabla_pro.innerHTML);
			}
			
			function construirPanel() {
				

				try {
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

						dibujarTabla(tablaDatos);
						loadNodegaugeDatos();

					})
					.fail(function (jqXHR, textStatus, errorThrown) {
						$('#messageArea').html('<h3>' + textStatus + ' : ' + errorThrown + '</h3>')
					});

				} catch(e) { 

				  alert("name:" + e.name + "\nmessage:" + e.message) 

				} 
				
				
			}
			$(function () {
				$('#consultar').click(function () {
					google.load('visualization', '1', {packages:['table', 'map', 'corechart', 'bar'], language: 'en', callback: construirPanel});
				});
			});
			
			
	        // Create a pie chart, passing some options
			var pieChart = new google.visualization.ChartWrapper({
			  'chartType': 'PieChart',
			  'containerId': 'chart_div',
			  'options': {
				'width': 300,
				'height': 300,
				'pieSliceText': 'value',
				'legend': 'right'
			  }
			});
	
  </script>
</head> 

<link rel="stylesheet" href="css/main.css">

<body onload=' location.href="#begin"' >
	<a name="begin"></a> 
	<!--<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="window.history.go(-1);" />-->
	<h2 align="center">Vehicles Control Pannel</h2>
	<br/><br/><br/><br/>
	
	<table style="display: none" border=1 id="tabla">

	<%  
	QueryResult<Map<String,Object>> result=(QueryResult<Map<String, Object>>)request.getAttribute("listaNodosResult");
    Iterator<Map<String, Object>> lista=result.iterator();  

    if (lista.hasNext()) {
		// Dibujamos el encabezado de la tabla
	    Map<String,Object> linea1 = lista.next();
	
		for ( Entry<String,Object> encabezado : linea1.entrySet() )
	        out.print("<td><b>" + encabezado.getKey() + "</b></td>");
		out.print("</tr>");
	
		// Nos quedamos con el contenido de la primera linea
        Map<String,Object> fila = linea1;
		
		// Dibujamos el contenido de la tabla
	    do {
	        //out.print("<tr><td>" + fila.get("usuarioID") + "</td><td>" + fila.get("latittud") + fila.get("longitud") + "</td><td>" + "</td></tr>");
			
			out.print("<tr>");
			for ( Entry<String,Object> column : fila.entrySet() )
	            out.print("<td>" + column.getValue() + "</td>");
			out.print("</tr>");
			
			// Si quedan mas lineas
			if (lista.hasNext())
				fila=lista.next();
	    } while ( lista.hasNext() );
		
		// Dibujamos la linea final
		out.print("<tr>");
		for ( Entry<String,Object> column : fila.entrySet() )
	        out.print("<td>" + column.getValue() + "</td>");
		out.print("</tr>");
    } else {
		out.print("Los vehículos del cliente no han superado este límite");
	}
	%>
	</table>
	
	<table>
		<th><div id="messageArea">Calculating. Please, hold on ...</div></th>
		<tr>
			<td  width="50%">
				<table>
					<tr>
							<%  
							QueryResult<Map<String,Object>> resultado2=(QueryResult<Map<String, Object>>)request.getAttribute("listaNodosResult");
							Iterator<Map<String, Object>> listadivs2=resultado2.iterator();  
							Map<String,Object> filadivs2 = listadivs2.next();
							
							for ( Entry<String,Object> column : filadivs2.entrySet() ) {
								if ( column.getKey().equals("cliente") )
									out.print("<td><input name='cypher' id='cypher-in' type='hidden' value='MATCH ()-[h:HA_ESTADO_EN]->(g:Gps) WITH MAX(toInt(g.velocidad)) AS velocidad, g.vehicle_id AS vehiculo, g.client_id AS cliente WHERE velocidad > 90 AND 200 > velocidad AND cliente = \""+column.getValue()+"\"  RETURN DISTINCT cliente, vehiculo, velocidad ORDER BY cliente, vehiculo DESC' /></td>");
							}
							%>
					
						
							<label id="textovelmin">Vehicles with speed over 90 km/h</label>
							<output for="fader" hidden="true" id="velocidad">90</output>
							<input type="range" min="0" max="200" value="90" id="fader" step="1" oninput="lowestLimitUpdate(value)"/>
						<td><div id="filter_div"></div></td>
					</tr>
					<tr>
						<td>
							<label id="textovelmax">Vehicles with speed under 200 km/h</label>
							<output for="faderspeedmax" hidden="true" id="velocidadmax">200</output>
							<input type="range" min="0" max="200" value="200" id="faderspeedmax" step="1" oninput="highestLimitUpdate(value)"/>
						</td>
						<td><div id="filtermaxspeed_div"></div></td>
					</tr>
					<tr>
						<td>
							<!--<label>Client name:</label>-->
							
							<%  
							QueryResult<Map<String,Object>> resultado1=(QueryResult<Map<String, Object>>)request.getAttribute("listaNodosResult");
							Iterator<Map<String, Object>> listadivs1=resultado1.iterator();  
							Map<String,Object> filadivs1 = listadivs1.next();
							
							for ( Entry<String,Object> column : filadivs1.entrySet() ) {
								if ( column.getKey().equals("cliente") )
									out.print("<input type='hidden' id='clientname1' value='"+column.getValue()+"' oninput='nameUpdate()'/>");
							}
							%>
						</td>
					</tr>
				</table>			
			</td>
			<td width="50%">
				
	<table align="center" >
		<tbody id="pro">
		</tbody>
	</table>	

				</td>
			</tr>
		</table>	
	<script>
	
		// ******************** DRAW GAUGE ****************************************************
		// List of nodes
		var gaugeDatos = [];
		
		
		loadNodegaugeDatos();
		
		// Extracts and pushes into the location list all the node data contained in 
	    // the html table. This html table was created from the data returned by the Cypher query
		function loadNodegaugeDatos() {
			bodyHtml      = document.getElementsByTagName("body")[0];
			tableHtml     = bodyHtml.getElementsByTagName("table")[0];
			tableBody = tableHtml.getElementsByTagName("tbody")[0];
			numRows = tableBody.getElementsByTagName("tr").length;
			numCols = tableBody.getElementsByTagName("th").length;

			var options = {
			  width: 150, height: 150,
			  redFrom: 120, redTo: 260,
			  yellowFrom:110, yellowTo: 119,
			  greenFrom:0, greenTo: 109,
			  minorTicks: 5,
			  max: 260
			};
			
			var gauge;
			
			for (var i = 1; i < numRows; i++) {
				velocidad=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[1].childNodes[0].data;
				vehiculo=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[2].childNodes[0].data;
				
				gaugeDatos = [];
				gaugeDatos.push(['Label', 'Value']);
				gaugeDatos.push([vehiculo, parseInt(velocidad)]);
				
				texto = 'gauge_div_'+vehiculo;
				
				data = google.visualization.arrayToDataTable(gaugeDatos);
				// alert(texto);
				
				try {
					gauge = new google.visualization.Gauge(document.getElementById(texto));
					gauge.draw(data, options);			
					// google.visualization.events.addListener(gauge, 'onclick', alert(texto));
				} catch(e) { 

				  // alert("name:" + e.name + "\nmessage:" + e.message) 

				} 
			}
		}
		// ******************** DRAW GAUGE END **************************************************	
	</script>

</body>
</html>