<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html> 
<head> 
  <meta http-equiv="content-type" content="text/html; charset=UTF-8"> 
  <title>POIs Control Pannel</title> 
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
			
			function lowestLimitUpdate(visitsmin) {
				document.querySelector('#minvisits').value = visitsmin;
				document.getElementById('visitasmin').innerHTML = 'POIs visited in more than '+visitsmin+' occassions';
				document.querySelector('#cypher-pois').value = 
				'MATCH (v:Vehiculo)-[r:HA_ESTADO_EN_POI]->(p:Poi) WITH p.latitude as latitud, p.longitude as longitud, count(*) as count WHERE count > '+visitsmin+' RETURN latitud, longitud, count order by count desc';
			}
			
			function crea_columna(lat_poi, long_poi, visitas) {
				var color_background='lightgreen';
				var cara='height:80px;width:80px;vertical-align:bottom;background-size: 149px 70px;background-image:url("images/poigreen.png");';

				
				if (visitas > 3) {
					color_background='red';
					var cara='height:80px;width:100px;vertical-align:bottom;background-size: 149px 70px;background-image:url("images/poired.png");';
				} else if (visitas > 2) {
					color_background='yellow';
					var cara='height:80px;width:100px;vertical-align:bottom;background-size: 149px 70px;background-image:url("images/poiyellow.png");';
				}
				
				var campoConsulta = document.createElement('input'); // Create Input Field for Name
				campoConsulta.setAttribute('type', 'hidden');
				campoConsulta.setAttribute('name', 'consultaCypher');
				campoConsulta.setAttribute('value',
						'MATCH (v:Vehiculo)-[r:HA_ESTADO_EN_POI]->(p:Poi) ' +
	 					'WITH p.vehicle_id as vehiculo, toFloat(p.longitude) as longitud, '+
	 					'p.client_id as cliente, toFloat(p.latitude) as latitud, '+
	 					'toInt(p.velocidad) as velocidad, p.fecha as fecha, p.delta_t AS delta_t '+
	 					'WHERE latitud = '+lat_poi+' AND longitud = '+long_poi+' '+
						//'AND velocidad > '+document.getElementById('velocidad').value+' '+
						//'AND '+document.getElementById('velocidadmax').value+' > velocidad '+
	 					'RETURN DISTINCT cliente, vehiculo, latitud, longitud, velocidad, fecha, delta_t '+
	 					'ORDER BY cliente, vehiculo, fecha ');
				
				// Create Input Fields
				var campoPantalla = document.createElement('input'); 
				campoPantalla.setAttribute("type", "hidden");
				campoPantalla.setAttribute("name", "pantalla");
				campoPantalla.setAttribute("value", "pois");

				var campoLimVelocidad = document.createElement('input'); 
				campoLimVelocidad.setAttribute("type", "hidden");
				campoLimVelocidad.setAttribute("name", "limitevelocidad");
				campoLimVelocidad.setAttribute("value", document.getElementById('minvisits').value);

				var submitElement = document.createElement('input'); // Append Submit Button
				submitElement.setAttribute("type", "submit");
				submitElement.setAttribute('style', 'width:125px;font-size:10px;');
				submitElement.setAttribute("name", "texto-cypher");
				submitElement.setAttribute("value", 'Poi: '+lat_poi+', '+long_poi);

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
				cabecera.setAttribute('id', visitas+'_cabecera');

				cabecera.appendChild(formulario);

				var texto1=document.createElement('input');
				texto1.setAttribute('id', visitas+'_vel');
				texto1.setAttribute('align', 'left');
				texto1.setAttribute('style', 'width:120px;font-size:10px;');
				texto1.setAttribute('type', 'text');
				texto1.setAttribute('value', 'gauge_div_'+lat_poi+', '+visitas);
				texto1.setAttribute('readonly', 'true');

				var columna = document.createElement('td');
				columna.setAttribute('id', visitas);
				columna.setAttribute('color', 'white');
				columna.setAttribute('style', cara);				
				columna.appendChild(cabecera);
				//columna.appendChild(texto1);
				columna.appendChild(document.createElement('br'));
				columna.title = visitas+' vehicles crossed this POI. Click to see in the map';

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
					var lat_poi=tablaDatos[i][0];
					var long_poi=tablaDatos[i][1];
					var visitas=tablaDatos[i][2];
					
					if ((i % 5) == 0) {
						row_tabla_pro = body_tabla_pro.appendChild(document.createElement('tr'));
					}
					//alert(row_tabla_pro.innerHTML);					
					row_tabla_pro.appendChild(crea_columna(lat_poi, long_poi, visitas));		
				}
				//alert(row_tabla_pro.innerHTML);
			}
			
			function construirPanel() {
				

				try {
					var tablaDatos = [];
					$.ajaxSetup({
						cache: false,
						headers: { 
							"Authorization": 'Basic ' + window.btoa("neo4j:arturo")
						}
					});
					
					$.ajax({
						// Neo4j REST web service
						url: "http://localhost:7474/db/data/transaction/commit",
						cache: false,
						type: 'POST',
						data: JSON.stringify({ "statements": [{ "statement": $('#cypher-pois').val() }] }),
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

	</script>
</head> 

<body>
	<table align="center">
		<h2 align="center">POIs Control Pannel</h2>
	</table>    

	<table>
		<th><div id="messageArea">Calculating. Please, hold on ...</div></th>
		<tr>
			<td  width="50%">
				<table>
					<tr>
						<td>
							<input name="cypher" id="cypher-pois" type="hidden" value="MATCH (v:Vehiculo)-[r:HA_ESTADO_EN_POI]->(p:Poi) WITH p.latitude as latitud, p.longitude as longitud, count(*) as count WHERE count > 1 RETURN latitud, longitud, count order by count desc" />
						</td>
					</tr>
					<tr>
						<td>
							<label id="visitasmin">POIs visited in more than 1 occassion</label>
							<output for="fader" hidden="true" id="minvisits">1</output>
							<input type="range" min="1" max="10" value="1" id="fader" step="1" oninput="lowestLimitUpdate(value)"/>
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