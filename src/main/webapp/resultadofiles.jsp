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
  <title>Geological Measurement Samples in file</title> 
  <script src="http://maps.google.com/maps/api/js?sensor=false"></script>
  <script type="text/javascript" src="https://www.google.com/jsapi"></script>
  <!--script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js"></script-->
  <script src="js/d3/3.5.5/d3.min.js"></script>
  <script src="js/jquery-2.1.4.js"></script>
	
  <script type="text/javascript">
    google.load('visualization', '1', {'packages': ['table', 'map', 'corechart', 'bar', 'gauge', 'annotationchart']});
	
			window.onload=construirPanel();
			
			// Launch Cypher query and redraw the Control Panel every 30 seconds
			var timer = setInterval("construirPanel()", 3000);
			
			function lowestLlsUpdate(llsmin) {
				document.querySelector('#llsmin').value = llsmin;
				document.getElementById('LLSmin').innerHTML = 'Single laterolog over '+llsmin;
				document.querySelector('#cypher-in').value = 
				'MATCH (g:GpsMuestra)-[r:TOMO_MUESTRAS_EN]->(g1:GpsMuestra) WITH ToFloat(g.LLS) AS LLS, ToFloat(g.SFLA) AS SFLA, ToFloat(g.MSFL) AS MSFL, ToFloat(g.ACOU) AS ACOU, ToFloat(g.DEPTH) AS DEPTH, ToFloat(g.GR) AS GR, ToFloat(g.NPLS) AS NPLS, ToFloat(g.RHOB) AS RHOB, ToFloat(g.Bit) AS Bit, ToFloat(g.NPHI) AS NPHI, ToFloat(g.DRHO) AS DRHO, ToFloat(g.ILD) AS ILD, g.file AS file WHERE LLS > '+document.querySelector('#llsmin').value+' AND SFLA > 50 AND MSFL > 10 AND ACOU > 200 AND DEPTH > '+document.querySelector('#depthmin').value+' AND GR > '+document.querySelector('#grmin').value+' AND NPLS > 0.1 AND RHOB > '+document.querySelector('#rhobmin').value+' AND Bit > 310 AND NPHI > 0.1 AND DRHO > 0 AND ILD > 10 RETURN LLS, SFLA, MSFL, ACOU, DEPTH, GR, NPLS, RHOB, Bit, NPHI, DRHO, ILD, file ORDER BY LLS, SFLA, MSFL, ACOU, DEPTH, GR, NPLS, RHOB, Bit, NPHI, DRHO, ILD';
			}
			
			function lowestDepthUpdate(depthmin) {
				document.querySelector('#depthmin').value = depthmin;
				document.getElementById('DEPTHmin').innerHTML = 'Depth over '+depthmin+' meter';
				document.querySelector('#cypher-in').value = 
				'MATCH (g:GpsMuestra)-[r:TOMO_MUESTRAS_EN]->(g1:GpsMuestra) WITH ToFloat(g.LLS) AS LLS, ToFloat(g.SFLA) AS SFLA, ToFloat(g.MSFL) AS MSFL, ToFloat(g.ACOU) AS ACOU, ToFloat(g.DEPTH) AS DEPTH, ToFloat(g.GR) AS GR, ToFloat(g.NPLS) AS NPLS, ToFloat(g.RHOB) AS RHOB, ToFloat(g.Bit) AS Bit, ToFloat(g.NPHI) AS NPHI, ToFloat(g.DRHO) AS DRHO, ToFloat(g.ILD) AS ILD, g.file AS file WHERE LLS > '+document.querySelector('#llsmin').value+' AND SFLA > 50 AND MSFL > 10 AND ACOU > 200 AND DEPTH > '+document.querySelector('#depthmin').value+' AND GR > '+document.querySelector('#grmin').value+' AND NPLS > 0.1 AND RHOB > '+document.querySelector('#rhobmin').value+' AND Bit > 310 AND NPHI > 0.1 AND DRHO > 0 AND ILD > 10 RETURN LLS, SFLA, MSFL, ACOU, DEPTH, GR, NPLS, RHOB, Bit, NPHI, DRHO, ILD, file ORDER BY LLS, SFLA, MSFL, ACOU, DEPTH, GR, NPLS, RHOB, Bit, NPHI, DRHO, ILD';
			}
			
			function lowestGrUpdate(grmin) {
				document.querySelector('#grmin').value = grmin;
				document.getElementById('GRmin').innerHTML = 'Gamma Ray over '+grmin;
				document.querySelector('#cypher-in').value = 
				'MATCH (g:GpsMuestra)-[r:TOMO_MUESTRAS_EN]->(g1:GpsMuestra) WITH ToFloat(g.LLS) AS LLS, ToFloat(g.SFLA) AS SFLA, ToFloat(g.MSFL) AS MSFL, ToFloat(g.ACOU) AS ACOU, ToFloat(g.DEPTH) AS DEPTH, ToFloat(g.GR) AS GR, ToFloat(g.NPLS) AS NPLS, ToFloat(g.RHOB) AS RHOB, ToFloat(g.Bit) AS Bit, ToFloat(g.NPHI) AS NPHI, ToFloat(g.DRHO) AS DRHO, ToFloat(g.ILD) AS ILD, g.file AS file WHERE LLS > '+document.querySelector('#llsmin').value+' AND SFLA > 50 AND MSFL > 10 AND ACOU > 200 AND DEPTH > '+document.querySelector('#depthmin').value+' AND GR > '+document.querySelector('#grmin').value+' AND NPLS > 0.1 AND RHOB > '+document.querySelector('#rhobmin').value+' AND Bit > 310 AND NPHI > 0.1 AND DRHO > 0 AND ILD > 10 RETURN LLS, SFLA, MSFL, ACOU, DEPTH, GR, NPLS, RHOB, Bit, NPHI, DRHO, ILD, file ORDER BY LLS, SFLA, MSFL, ACOU, DEPTH, GR, NPLS, RHOB, Bit, NPHI, DRHO, ILD';
			}
			
			function lowestRhobUpdate(rhobmin) {
				document.querySelector('#rhobmin').value = rhobmin;
				document.getElementById('RHOBmin').innerHTML = 'Bulk density over '+rhobmin;
				document.querySelector('#cypher-in').value = 
				'MATCH (g:GpsMuestra)-[r:TOMO_MUESTRAS_EN]->(g1:GpsMuestra) WITH ToFloat(g.LLS) AS LLS, ToFloat(g.SFLA) AS SFLA, ToFloat(g.MSFL) AS MSFL, ToFloat(g.ACOU) AS ACOU, ToFloat(g.DEPTH) AS DEPTH, ToFloat(g.GR) AS GR, ToFloat(g.NPLS) AS NPLS, ToFloat(g.RHOB) AS RHOB, ToFloat(g.Bit) AS Bit, ToFloat(g.NPHI) AS NPHI, ToFloat(g.DRHO) AS DRHO, ToFloat(g.ILD) AS ILD, g.file AS file WHERE LLS > '+document.querySelector('#llsmin').value+' AND SFLA > 50 AND MSFL > 10 AND ACOU > 200 AND DEPTH > '+document.querySelector('#depthmin').value+' AND GR > '+document.querySelector('#grmin').value+' AND NPLS > 0.1 AND RHOB > '+document.querySelector('#rhobmin').value+' AND Bit > 310 AND NPHI > 0.1 AND DRHO > 0 AND ILD > 10 RETURN LLS, SFLA, MSFL, ACOU, DEPTH, GR, NPLS, RHOB, Bit, NPHI, DRHO, ILD, file ORDER BY LLS, SFLA, MSFL, ACOU, DEPTH, GR, NPLS, RHOB, Bit, NPHI, DRHO, ILD';				
			}
			
			function crea_columna(i, lls, gr, depth, rhob) {
				var color_background='lightgreen';
				
				if (depth > 120) {
					color_background='red';
				} else if (depth > 110) {
					color_background='yellow';
				}
				
				var campoConsulta = document.createElement('input'); // Create Input Field for Name
				campoConsulta.setAttribute('type', 'hidden');
				campoConsulta.setAttribute('name', 'consultaCypher');





				campoConsulta.setAttribute('value',
						'MATCH (g:GpsMuestra)-[r:TOMO_MUESTRAS_EN]->(g1:GpsMuestra) WITH ToFloat(g.LLS) AS LLS, ToFloat(g.SFLA) AS SFLA, ToFloat(g.MSFL) AS MSFL, ToFloat(g.ACOU) AS ACOU, ToFloat(g.DEPTH) AS DEPTH, ToFloat(g.GR) AS GR, ToFloat(g.NPLS) AS NPLS, ToFloat(g.RHOB) AS RHOB, ToFloat(g.Bit) AS Bit, ToFloat(g.NPHI) AS NPHI, ToFloat(g.DRHO) AS DRHO, ToFloat(g.ILD) AS ILD, g.latitude AS latitude, g.longitude AS longitude, g.file AS file WHERE LLS = '+lls+' AND SFLA > 50 AND MSFL > 10 AND ACOU > 200 AND DEPTH = '+depth+' AND GR > 20 AND NPLS > 0.1 AND RHOB > 2000 AND Bit > 310 AND NPHI > 0.1 AND DRHO > 0 AND ILD > 10 RETURN latitude, longitude, LLS, SFLA, MSFL, ACOU, DEPTH, GR, NPLS, RHOB, Bit, NPHI, DRHO, ILD, file ORDER BY LLS, SFLA, MSFL, ACOU, DEPTH, GR, NPLS, RHOB, Bit, NPHI, DRHO, ILD');

				
				// Create Input Fields
				var texto1=document.createElement('input');
				texto1.setAttribute('id', depth+'_vel');
				texto1.setAttribute('align', 'left');
				texto1.setAttribute('style', 'width:150px;font-size:20px;');
				texto1.setAttribute('type', 'text');
				texto1.setAttribute('value', 'Data Sample #'+i);
				texto1.setAttribute('readonly', 'true');
				
				var estiloGauges = "width: 150px; height: 150px";
				
				var campoDivDepth = document.createElement('div');
				campoDivDepth.setAttribute("class", "bloque_google");
				campoDivDepth.setAttribute("id", "gauge_div_depth"+i);
				campoDivDepth.setAttribute("onclick", "this.parentNode.submit();");
				campoDivDepth.setAttribute("style", estiloGauges);
				
				var campoDivGr = document.createElement('div');
				campoDivGr.setAttribute("class", "bloque_google");
				campoDivGr.setAttribute("id", "gauge_div_gr"+i);
				campoDivGr.setAttribute("onclick", "this.parentNode.submit();");
				campoDivGr.setAttribute("style", estiloGauges);

				var campoDivLls = document.createElement('div');
				campoDivLls.setAttribute("class", "bloque_google");
				campoDivLls.setAttribute("id", "gauge_div_lls"+i);
				campoDivLls.setAttribute("onclick", "this.parentNode.submit();");
				campoDivLls.setAttribute("style", estiloGauges);

				var campoDivRhob = document.createElement('div');
				campoDivRhob.setAttribute("class", "bloque_google");
				campoDivRhob.setAttribute("id", "gauge_div_rhob"+i);
				campoDivRhob.setAttribute("onclick", "this.parentNode.submit();");
				campoDivRhob.setAttribute("style", estiloGauges);
				
				var tabla   = document.createElement("table");
				var tblBody = document.createElement("tbody");
				var fila1 = document.createElement("tr");
				var casilla1fila1 = document.createElement("td");
				casilla1fila1.appendChild(campoDivDepth);
				var casilla2fila1 = document.createElement("td");
				casilla2fila1.appendChild(campoDivGr);
				fila1.appendChild(casilla1fila1);
				fila1.appendChild(casilla2fila1);
				var fila2 = document.createElement("tr");
				var casilla1fila2 = document.createElement("td");
				casilla1fila2.appendChild(campoDivLls);
				var casilla2fila2 = document.createElement("td");
				casilla2fila2.appendChild(campoDivRhob);
				fila2.appendChild(casilla1fila2);
				fila2.appendChild(casilla2fila2);
				tblBody.appendChild(fila1);
				tblBody.appendChild(fila2);
				tabla.appendChild(tblBody);
				tabla.setAttribute("border", "2");
				tabla.setAttribute("onclick", "this.parentNode.submit();");
				tabla.setAttribute("style", "width: 150px; height: 220px");
				
				var campoPantalla = document.createElement('input'); 
				campoPantalla.setAttribute("type", "hidden");
				campoPantalla.setAttribute("name", "pantalla");
				campoPantalla.setAttribute("value", "resultadofiles");

				var campoLimVelocidad = document.createElement('input'); 
				campoLimVelocidad.setAttribute("type", "hidden");
				campoLimVelocidad.setAttribute("name", "limitevelocidad");
				campoLimVelocidad.setAttribute("value", document.getElementById('llsmin').value);

				var submitElement = document.createElement('input'); // Append Submit Button
				submitElement.setAttribute("type", "submit");
				submitElement.setAttribute('style', 'width:125px;font-size:10px;');
				submitElement.setAttribute("name", "texto-cypher");
				submitElement.setAttribute("value", lls);

				var formulario = document.createElement('form');
				formulario.setAttribute("action", "cypher"); // Setting Action to submit to the servlet
				formulario.setAttribute("method", "post"); // Setting Method post
				formulario.setAttribute("target", "_top"); // Open in a new window
				formulario.appendChild(campoConsulta);
				formulario.appendChild(tabla);
				formulario.appendChild(campoPantalla);
				formulario.appendChild(campoLimVelocidad);
				// formulario.appendChild(submitElement);

				var cabecera=document.createElement('H3');
				cabecera.setAttribute('align', 'center');
				cabecera.setAttribute('id', depth+'_cabecera');

				cabecera.appendChild(formulario);

				var columna = document.createElement('td');
				columna.setAttribute('id', depth);
				columna.setAttribute('color', 'white');
				columna.appendChild(texto1);
				columna.appendChild(cabecera);
				columna.appendChild(document.createElement('br'));
				columna.title = 'Click to locate data sample #'+i+' measures in the map';

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
					var lls=tablaDatos[i][0];
					var depth=tablaDatos[i][4];
					var gr=tablaDatos[i][5];
					var rhob=tablaDatos[i][7];
					var file=tablaDatos[i][12];
					
					if ((i % 3) == 0) {
						row_tabla_pro = body_tabla_pro.appendChild(document.createElement('tr'));
					}
					//alert(row_tabla_pro.innerHTML);
					if (i < (tablaDatos.length -1))
						row_tabla_pro.appendChild(crea_columna(i, lls, gr, depth, rhob));		
				}
				document.getElementById('titulo').innerHTML='Geological Measurements Samples found in file "'+file.substring(file.lastIndexOf('\\')+1)+"\"";

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
				
						tablaDatos.push([vectortitulos[0], vectortitulos[1], vectortitulos[2], vectortitulos[3], vectortitulos[4], vectortitulos[5], vectortitulos[6], vectortitulos[7], vectortitulos[8], vectortitulos[9], vectortitulos[10], vectortitulos[11], vectortitulos[12]]);
						$.each(data.results[0].data, function (k, v) {
							var cadena = v.row+'';
							var vector=cadena.split(',');
							tablaDatos.push([vector[0], vector[1], vector[2], vector[3], vector[4], vector[5], vector[6], vector[7], vector[8], vector[9], vector[10], vector[11], vector[12]]);
						});
						$('#messageArea').html('');
						
						// alert(tablaDatos);
						dibujarTabla(tablaDatos);
						loadNodegaugeDatos(tablaDatos);


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
	<h2 id="titulo" align="center">Geological Measurements Samples</h2>
	<h2 align="center"><a href="#chart1">See bulk density & depth chart</a>  <a href="#chart2">See gamma ray & single laterolog chart</a></h2>

	<br/><br/><br/><br/>
	
	<table>
		<th><div id="messageArea">Calculating. Please, hold on ...</div></th>
		<tr valign="top">
			<td  width="50%">
				<table>
					<tr>

							<%  
							QueryResult<Map<String,Object>> resultado2=(QueryResult<Map<String, Object>>)request.getAttribute("listaNodosResult");
							Iterator<Map<String, Object>> listadivs2=resultado2.iterator();  
							Map<String,Object> filadivs2 = listadivs2.next();
							
							for ( Entry<String,Object> column : filadivs2.entrySet() ) {
								if ( column.getKey().equals("DEPTH") )
									out.print("<td><input name='cypher' id='cypher-in' type='hidden' value='MATCH (g:GpsMuestra)-[r:TOMO_MUESTRAS_EN]->(g1:GpsMuestra) WITH ToFloat(g.LLS) AS LLS, ToFloat(g.SFLA) AS SFLA, ToFloat(g.MSFL) AS MSFL, ToFloat(g.ACOU) AS ACOU, ToFloat(g.DEPTH) AS DEPTH, ToFloat(g.GR) AS GR, ToFloat(g.NPLS) AS NPLS, ToFloat(g.RHOB) AS RHOB, ToFloat(g.Bit) AS Bit, ToFloat(g.NPHI) AS NPHI, ToFloat(g.DRHO) AS DRHO, ToFloat(g.ILD) AS ILD, g.file AS file WHERE LLS > 10 AND SFLA > 50 AND MSFL > 10 AND ACOU > 200 AND DEPTH > 2000 AND GR > 20 AND NPLS > 0.1 AND RHOB > 2000 AND Bit > 310 AND NPHI > 0.1 AND DRHO > 0 AND ILD > 10 RETURN LLS, SFLA, MSFL, ACOU, DEPTH, GR, NPLS, RHOB, Bit, NPHI, DRHO, ILD, file ORDER BY LLS, SFLA, MSFL, ACOU, DEPTH, GR, NPLS, RHOB, Bit, NPHI, DRHO, ILD' /></td>");

							}
							%>
					
						
							<label id="LLSmin">Single laterolog over 10</label>
							<output for="faderLLS" hidden="true" id="llsmin">10</output>
							<input type="range" min="0" max="200" value="10" id="faderLLS" step="1" oninput="lowestLlsUpdate(value)"/>
						<td><div id="filter_div"></div></td>
					</tr>
					<tr>
						<td>
							<label id="DEPTHmin">Depth over 2000 meter</label>
							<output for="faderDEPTH" hidden="true" id="depthmin">2000</output>
							<input type="range" min="0" max="3000" value="2000" id="faderDEPTH" step="1" oninput="lowestDepthUpdate(value)"/>
						</td>
					</tr>
					<tr>
						<td>
							<label id="GRmin">Gamma Ray over 20</label>
							<output for="faderGR" hidden="true" id="grmin">20</output>
							<input type="range" min="0" max="50" value="20" id="faderGR" step="1" oninput="lowestGrUpdate(value)"/>
						</td>
					</tr>	
					<tr>
						<td>
							<label id="RHOBmin">Bulk density over 2000</label>
							<output for="faderDEPTH" hidden="true" id="rhobmin">2000</output>
							<input type="range" min="0" max="2700" value="2000" id="faderRHOB" step="1" oninput="lowestRhobUpdate(value)"/>
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
		<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
		<a name="chart1"></a> 
		<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/clients'" />
		<h2 align="center"><a href="#begin">Measurement filters</a>  Bulk density & depth chart  <a href="#chart2">Gamma ray & Single laterolog chart</a> </h2>
		<div class="bloque_google" id="chart1_div" style="width: 1250px; height: 620px;"></div>		
		<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
		<a name="chart2"></a> 
		<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/clients'" />
		<h2 align="center"><a href="#begin">Measurement filters</a>  <a href="#chart1"> Bulk density & depth chart</a>  Gamma ray & Single laterolog chart</h2>
		<div class="bloque_google" id="chart2_div" style="width: 1250px; height: 620px;"></div>		
	<script>
	
		// ******************** DRAW GAUGE ****************************************************

		
		// Extracts and pushes into the location list all the node data contained in 
	    // the html table. This html table was created from the data returned by the Cypher query
		function loadNodegaugeDatos(tablaDatos) {
			
			var data1 = new google.visualization.DataTable();
			data1.addColumn('string', 'Samples');
			data1.addColumn('number', 'Bulk density');
			data1.addColumn('number', 'Depth');

			var data2 = new google.visualization.DataTable();
			data2.addColumn('string', 'Samples');
	        data2.addColumn('number', 'Gamma ray index');
			data2.addColumn('number', 'Single laterolog');
            
			var chart1 = new google.visualization.AreaChart(document.getElementById('chart1_div'));
			var chart2 = new google.visualization.AreaChart(document.getElementById('chart2_div'));
            
			var options = {
			  displayAnnotations: true
			};

			var options_depth = {
			  width: 150, height: 150,
			  redFrom: 2501, redTo: 3000,
			  yellowFrom:2101, yellowTo: 2500,
			  greenFrom:0, greenTo: 2100,
			  minorTicks: 5,
			  max: 3000
			};

			var options_gr = {
			  width: 150, height: 150,
			  redFrom: 41, redTo: 50,
			  yellowFrom:25, yellowTo: 41,
			  greenFrom:0, greenTo: 25,
			  minorTicks: 5,
			  max: 50
			};

			var options_lls = {
			  width: 150, height: 150,
			  redFrom: 61, redTo: 70,
			  yellowFrom:50, yellowTo: 61,
			  greenFrom:0, greenTo: 50,
			  minorTicks: 5,
			  max: 70
			};

			var options_rhob = {
			  width: 150, height: 150,
			  redFrom: 2501, redTo: 3000,
			  yellowFrom:2101, yellowTo: 2500,
			  greenFrom:0, greenTo: 2100,
			  minorTicks: 5,
			  max: 3000
			};
						
			var gauge;

			// Remove first row of headers in the array
			tablaDatos.shift();
			
			for (var i in tablaDatos) {
				var lls=tablaDatos[i][0];
				var depth=tablaDatos[i][4];
				var gr=tablaDatos[i][5];
				var rhob=tablaDatos[i][7];
				
				gaugeDepth = [];
				gaugeDepth.push(['Label', 'Value']);
				gaugeDepth.push(['Depth', parseFloat(depth)]);
				
				textoDepth = 'gauge_div_depth'+i;
				
				dataDepth = google.visualization.arrayToDataTable(gaugeDepth);
				// alert(texto);

				// GR = gamma ray index
				gaugeGr = [];
				gaugeGr.push(['Label', 'Value']);
				gaugeGr.push(['Gamma Ray', parseFloat(gr)]);
				
				textoGr = 'gauge_div_gr'+i;
				
				dataGr = google.visualization.arrayToDataTable(gaugeGr);

				// LLS = single laterolog
				gaugeLls = [];
				gaugeLls.push(['Label', 'Value']);
				gaugeLls.push(['Single laterolog', parseFloat(lls)]);
				
				textoLls = 'gauge_div_lls'+i;
				
				dataLls = google.visualization.arrayToDataTable(gaugeLls);
				
				// RHOB = bulk density
				gaugeRhob = [];
				gaugeRhob.push(['Label', 'Value']);
				gaugeRhob.push(['Bulk density', parseFloat(rhob)]);
				
				textoRhob = 'gauge_div_rhob'+i;
				
				dataRhob = google.visualization.arrayToDataTable(gaugeRhob);
				
				try {
					gaugeDepth = new google.visualization.Gauge(document.getElementById(textoDepth));
					gaugeDepth.draw(dataDepth, options_depth);
					gaugeGr = new google.visualization.Gauge(document.getElementById(textoGr));
					gaugeGr.draw(dataGr, options_gr);			
					gaugeLls = new google.visualization.Gauge(document.getElementById(textoLls));
					gaugeLls.draw(dataLls, options_lls);
					gaugeRhob = new google.visualization.Gauge(document.getElementById(textoRhob));
					gaugeRhob.draw(dataRhob, options_rhob);
					data1.addRow(['Sample #'+i, parseFloat(rhob), parseFloat(depth)]);
					data2.addRow(['Sample #'+i, parseFloat(gr), parseFloat(lls)]);
					// google.visualization.events.addListener(gaugeDepth, 'onclick', alert(textoDepth));
				} catch(e) { 
				  alert("i: "+i+"textoDepth: "+textoDepth+"name: " + e.name + "\nmessage:" + e.message) 
				} 
			}

			chart1.draw(data1, options);
			chart2.draw(data2, options);
			
		}
		// ******************** DRAW GAUGE END **************************************************	
	</script>
	

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
</body>
</html>