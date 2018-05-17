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
  <link rel="stylesheet" href="css/main.css">	
  <script type="text/javascript">
			//google.load('visualization', '1', {'packages': ['table', 'map', 'corechart', 'bar', 'gauge']});
   
			window.onload=construirPanel();
			
			// Launch Cypher query and redraw the Control Panel every 30 seconds
			var timer = setInterval("construirPanel()", 1000);
			
			function lowestLimitUpdate(velocidadmin) {
				document.querySelector('#velocidad').value = velocidadmin;
				document.getElementById('textovelmin').innerHTML = 'Vehicles reaching '+velocidadmin+' km/h';
				document.querySelector('#cypher-vehicles').value = 
				'MATCH ()-[h:HA_ESTADO_EN]->(g:Gps) WITH MAX(ToInt(g.velocidad)) AS velocidad, g.vehicle_id AS vehiculo WHERE velocidad > '+velocidadmin+' AND '+document.querySelector('#velocidadmax').value+' > velocidad RETURN DISTINCT vehiculo, velocidad ORDER BY velocidad, vehiculo DESC';
			}
			
			function highestLimitUpdate(velocidadmax) {
				document.querySelector('#velocidadmax').value = velocidadmax;
				document.getElementById('textovelmax').innerHTML = 'Vehicles not reached '+velocidadmax+' km/h';
				document.querySelector('#cypher-vehicles').value = 
				'MATCH ()-[h:HA_ESTADO_EN]->(g:Gps) WITH MAX(ToInt(g.velocidad)) AS velocidad, g.vehicle_id AS vehiculo WHERE velocidad > '+document.querySelector('#velocidad').value+' AND '+velocidadmax+' > velocidad RETURN DISTINCT vehiculo, velocidad ORDER BY velocidad, vehiculo DESC';
			}
			
			function crea_columna(vehiculo, velocidad) {
				var color_background='lightgreen';
				var cara='height:80px;width:100px;vertical-align:bottom;background-size: 150px 125px;background-image:url("images/verde.png");';

				
				if (velocidad > 120) {
					color_background='red';
					var cara='height:80px;width:100px;vertical-align:bottom;background-size: 150px 125px;background-image:url("images/rojo.png");';
				} else if (velocidad > 110) {
					color_background='yellow';
					var cara='height:80px;width:100px;vertical-align:bottom;background-size: 150px 125px;background-image:url("images/amarillo.png");';
				}
				
				var campoConsulta = document.createElement('input'); // Create Input Field for Name
				campoConsulta.setAttribute('type', 'hidden');
				campoConsulta.setAttribute('name', 'consultaCypher');
				campoConsulta.setAttribute('value',
						'MATCH ()-[h:HA_ESTADO_EN]->(g:Gps) ' +
						'WITH g.client_id AS cliente, g.vehicle_id AS vehiculo, g.latitud AS latitud, g.longitud AS longitud, g.velocidad AS velocidad, g.fecha AS fecha, g.delta_t AS delta_t '+
						'WHERE vehiculo = \''+vehiculo+'\' ' +
						'RETURN DISTINCT cliente, vehiculo, latitud, longitud, velocidad, fecha, delta_t '+
	 					'ORDER BY cliente, vehiculo, fecha ');
				// Create Input Fields
				var campoPantalla = document.createElement('input'); 
				campoPantalla.setAttribute("type", "hidden");
				campoPantalla.setAttribute("name", "pantalla");
				campoPantalla.setAttribute("value", "vehicles_1");

				var campoLimVelocidad = document.createElement('input'); 
				campoLimVelocidad.setAttribute("type", "hidden");
				campoLimVelocidad.setAttribute("name", "limitevelocidad");
				campoLimVelocidad.setAttribute("value", document.getElementById('velocidad').value);

				var submitElement = document.createElement('input'); // Append Submit Button
				submitElement.setAttribute("type", "submit");
				submitElement.setAttribute('style', 'width:125px;font-size:10px;');
				submitElement.setAttribute("name", "texto-cypher");
				submitElement.setAttribute("value", vehiculo);

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
				texto1.setAttribute('style', 'width:120px;font-size:10px;');
				texto1.setAttribute('type', 'text');
				texto1.setAttribute('value', 'gauge_div_'+vehiculo+', '+velocidad);
				texto1.setAttribute('readonly', 'true');

				var columna = document.createElement('td');
				columna.setAttribute('id', velocidad);
				columna.setAttribute('color', 'white');
				columna.setAttribute('style', cara);				
				columna.appendChild(cabecera);
				//columna.appendChild(texto1);
				columna.appendChild(document.createElement('br'));
				columna.title = vehiculo+' reached '+velocidad+' Km/h';

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
					var vehiculo=tablaDatos[i][0];
					var velocidad=tablaDatos[i][1];
					
					if ((i % 5) == 0) {
						row_tabla_pro = body_tabla_pro.appendChild(document.createElement('tr'));
					}
					//alert(row_tabla_pro.innerHTML);					
					row_tabla_pro.appendChild(crea_columna(vehiculo, velocidad));		
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
						data: JSON.stringify({ "statements": [{ "statement": $('#cypher-vehicles').val() }] }),
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
					})
					.fail(function (jqXHR, textStatus, errorThrown) {
						$('#messageArea').html('<h3>' + textStatus + ' : ' + errorThrown + '</h3>')
					});

				} catch(e) { 

				  alert("name:" + e.name + "\nmessage:" + e.message) 

				} 
				
				
			}
			//$(function () {
			//	$('#consultar').click(function () {
			//		google.load('visualization', '1', {packages:['table', 'map', 'corechart', 'bar', 'gauge'], language: 'en', callback: construirPanel});
			//	});
			//});
			//
	        //// Create a pie chart, passing some options
			//var pieChart = new google.visualization.ChartWrapper({
			//  'chartType': 'PieChart',
			//  'containerId': 'chart_div',
			//  'options': {
			//	'width': 300,
			//	'height': 300,
			//	'pieSliceText': 'value',
			//	'legend': 'right'
			//  }
			//});
		</script>
	</head> 

    <body>
		<table align="center">
			<h2 align="center">Vehicles Control Pannel</h2>
		</table>    
 
		<table border="1">
			<th><div id="messageArea">Calculating. Please, hold on ...</div></th>
			<tr>
				<td  width="50%">
					<table>
						<tr>
							<td>
								<input name="cypher" id="cypher-vehicles" type="hidden" value="MATCH ()-[h:HA_ESTADO_EN]->(g:Gps) WITH MAX(ToInt(g.velocidad)) AS velocidad, g.vehicle_id AS vehiculo WHERE velocidad > 100 AND 200 > velocidad RETURN DISTINCT vehiculo, velocidad ORDER BY velocidad, vehiculo DESC" />
							</td>
						</tr>
						<tr>
							<td>
								<label id="textovelmin">Vehicles reaching 119 km/h</label>
								<output for="fader" hidden="true" id="velocidad">119</output>
								<input type="range" min="0" max="200" value="119" id="fader" step="1" oninput="lowestLimitUpdate(value)"/>
							</td>
						</tr>
						<tr>
							<td>
								<label id="textovelmax">Vehicles not reached 200 km/h</label>
								<output for="faderspeedmax" hidden="true" id="velocidadmax">200</output>
								<input type="range" min="0" max="200" value="200" id="faderspeedmax" step="1" oninput="highestLimitUpdate(value)"/>
							</td>
						</tr>
					</table>			
				</td>
				<td width="50%">
								
					<table bgcolor="lightblue" align="center" >
						<tbody id="pro">
						</tbody>
					</table>	

				</td>
			</tr>
		</table>							
    </body>
    </html>