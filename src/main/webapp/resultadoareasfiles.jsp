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
  <title>Measurements report</title> 
  <script src="http://maps.google.com/maps/api/js?sensor=false"></script>
  <script type="text/javascript" src="https://www.google.com/jsapi"></script>
  <!--script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js"></script-->
  <script src="js/d3/3.5.5/d3.min.js"></script>

  <script type="text/javascript">
    google.load('visualization', '1', {'packages': ['table', 'map', 'corechart', 'bar', 'annotationchart', 'columnchart']});
  </script>
</head> 

<link rel="stylesheet" href="css/main.css">

<body onload=' location.href="#map"' >
	<a name="map"></a> 
	<!--<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/clients'" />-->
	<h2 align="center">File locations</h2>
	
	<div>
		<div class="bloque_google" id="mapa_div" style="width: 1250px; height: 490px;"></div>
		<br/>
		<div class="bloque_google" id="elevation_chart" style="width: 1250px"></div>

		<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
		<a name="annotation"></a> 
		<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/clients'" />
		<h2 align="center"><a href="#map">File locations</a> Measurements chart</h2>
		<div class="bloque_google" id="annotation_div" style="width: 1250px; height: 620px;"></div>
		<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
		<div class="bloque_google" id="chart_div" style="width: 1250px; height: 620px;"></div>
		<div id="my_visualization_DIV"></div>
		<div class="bloque_google" id="tabla_div" style="width: 1200px; height: 620px;"></div>
	</div>
		
	<table style="display: true" border=1 id="tabla">
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
	        //out.print("<tr><td>" + fila.get("usuarioID") + "</td><td>" + fila.get("latitud") + fila.get("longitud") + "</td><td>" + "</td></tr>");
			
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
	<script>
		// ******************** DRAW MAP ****************************************************
		// Ver ejemplo para ruta de vuelo en
		// http://jsfiddle.net/doktormolle/2nAgr/
		
		// List of node locations
		var locations = [];
		
		var datosLinea = [];
		
		var datosArea1 = [];

		var datosArea2 = [];
		
		// Setup the different icons and shadows
		var iconURLPrefix = 'http://maps.google.com/mapfiles/ms/icons/';
		
		var icons = [
		  iconURLPrefix + 'red-dot.png',
		  iconURLPrefix + 'green-dot.png',
		  iconURLPrefix + 'blue-dot.png',
		  iconURLPrefix + 'orange-dot.png',
		  iconURLPrefix + 'purple-dot.png',
		  iconURLPrefix + 'pink-dot.png',      
		  iconURLPrefix + 'yellow-dot.png'
		]
		var iconsLength = icons.length;

		var map = new google.maps.Map(document.getElementById('mapa_div'), {
		  zoom: 10,
		  center: new google.maps.LatLng("40.41153868","-3.70362707"), // Map centered in Madrid
		  mapTypeId: google.maps.MapTypeId.ROADMAP,
		  mapTypeControl: true,
		  streetViewControl: true,
		  panControl: true,
		  zoomControlOptions: {
			 position: google.maps.ControlPosition.LEFT_BOTTOM
		  }
		});

		// Add earthquake layer
		
		// Get the earthquake data (JSONP format)
		// This feed is a copy from the USGS feed, you can find the originals here:
		//   http://earthquake.usgs.gov/earthquakes/feed/v1.0/geojson.php
		var script = document.createElement('script');
		script.setAttribute('src', 'https://storage.googleapis.com/maps-devrel/quakes.geo.json');
		document.getElementsByTagName('head')[0].appendChild(script);

		// Defines the callback function referenced in the jsonp file.
		function eqfeed_callback(data) {
		  map.data.addGeoJson(data);
		}
		
		map.data.setStyle(styleFeature);
		
		function styleFeature(feature) {
		  var low = [151, 83, 34];   // color of mag 1.0
		  var high = [5, 69, 54];  // color of mag 6.0 and above
		  var minMag = 1.0;
		  var maxMag = 6.0;

		  // fraction represents where the value sits between the min and max
		  var fraction = (Math.min(feature.getProperty('mag'), maxMag) - minMag) /
			  (maxMag - minMag);

		  var color = interpolateHsl(low, high, fraction);

		  return {
			icon: {
			  path: google.maps.SymbolPath.CIRCLE,
			  strokeWeight: 0.5,
			  strokeColor: '#fff',
			  fillColor: color,
			  fillOpacity: 2 / feature.getProperty('mag'),
			  // while an exponent would technically be correct, quadratic looks nicer
			  scale: Math.pow(feature.getProperty('mag'), 2)
			},
			zIndex: Math.floor(feature.getProperty('mag'))
		  };
		}

		function interpolateHsl(lowHsl, highHsl, fraction) {
		  var color = [];
		  for (var i = 0; i < 3; i++) {
			// Calculate color based on the fraction.
			color[i] = (highHsl[i] - lowHsl[i]) * fraction + lowHsl[i];
		  }

		  return 'hsl(' + color[0] + ',' + color[1] + '%,' + color[2] + '%)';
		}

		// Add traffic layer
		var trafficLayer = new google.maps.TrafficLayer();
		trafficLayer.setMap(map);
		
		var infowindow = new google.maps.InfoWindow({
		  maxWidth: 160
		});

		var markers = new Array();
		
		var iconCounter = 0;
		loadNodeLocations();
		// Add the markers and node information to the map
		for (var i = 0; i < locations.length; i++) { 
    		  // var icono = 'http://mt.google.com/vt/icon/name=icons/spotlight/measle_green_8px.png&scale=1';
			  var icono = 'images/oilpumpjack.png';
			  var velocidad = locations[i][3];

			  // if (velocidad > 110)
				 //  icono = iconURLPrefix + 'yellow-dot.png';
			  // if (velocidad > 120)
				 //  icono = iconURLPrefix + 'red-dot.png';
			  // 
			  // Marker coordinates with the icon representing the node
			  var marker = new google.maps.Marker({
				position: new google.maps.LatLng(locations[i][1], locations[i][2]),
				map: map,
				icon: icono
			  });
			  
			  // push the new marker into the list
			  markers.push(marker);
	
			  // When user clicks the icon, this node information will be shown
			  google.maps.event.addListener(marker, 'mouseover', (function(marker, i) {
				return function() {
				  infowindow.setContent(locations[i][0]);
				  infowindow.open(map, marker);
				}
			  })(marker, i));
			  
			  iconCounter++;
			  
			  // We only have a limited number of possible icon colors, so we may have to restart the counter
			  if(iconCounter >= iconsLength) {
				iconCounter = 0;
			  }
		}
		
		/*
		  var datosLinea = [
			{lat: -4.650758, lng: 54.222692},  	
			{lat: -4.501729, lng: 54.924578}
		  ];
		alert(datosLinea);
		*/
		
		 var linea = new google.maps.Polyline({
			path: datosLinea,
			geodesic: true,
			strokeColor: '#FF0000',
			strokeOpacity: 1.0,
			strokeWeight: 2
		  });

		  linea.setMap(map);

		/*
		  var datosArea1 = [
			{lat: -4.650758, lng: 54.222692},  	
			{lat: -4.501729, lng: 54.924578},
			{lat: -4.750757789611816, lng: 54.72269058227539},
			{lat: -4.900757789611816, lng: 54.10269058227539},
		  ];

		  */

		  // Construct the polygon Rectangulo_1
		  var area1 = new google.maps.Polygon({
			paths: datosArea1,
			strokeColor: '#FF0000',
			strokeOpacity: 0.8,
			strokeWeight: 2,
			fillColor: '#FF0000',
			fillOpacity: 0.35
		  });
		  
		  area1.setMap(map);

		  // Construct the polygon Rectangulo_2
		  var area2 = new google.maps.Polygon({
			paths: datosArea2,
			strokeColor: '#FF0000',
			strokeOpacity: 0.8,
			strokeWeight: 2,
			fillColor: '#FF0000',
			fillOpacity: 0.35
		  });
		  
		  area2.setMap(map);

		  // Construct the elevation chart
		  // Create an ElevationService.
		  var elevator = new google.maps.ElevationService;

		  // Draw the path, using the Visualization API and the Elevation service.
		  displayPathElevation(datosLinea, elevator, map);

		function displayPathElevation(datosLinea, elevator, map) {
		  // Display a polyline of the elevation path.
		  new google.maps.Polyline({
			path: datosLinea,
			strokeColor: '#0000CC',
			opacity: 0.4,
			map: map
		  });
		  // Create a PathElevationRequest object using this array.
		  // Ask for 256 samples along that path.
		  // Initiate the path request.
		  elevator.getElevationAlongPath({
			'path': datosLinea,
			'samples': 256
		  }, plotElevation);
		}

		// Takes an array of ElevationResult objects, draws the path on the map
		// and plots the elevation profile on a Visualization API ColumnChart.
		function plotElevation(elevations, status) {
		  var chartDiv = document.getElementById('elevation_chart');
		  if (status !== google.maps.ElevationStatus.OK) {
			// Show the error code inside the chartDiv.
			chartDiv.innerHTML = 'Cannot show elevation: request failed because ' +
				status;
			return;
		  }
		  // Create a new chart in the elevation_chart DIV.
		  var chart = new google.visualization.ColumnChart(chartDiv);

		  // Extract the data from which to populate the chart.
		  // Because the samples are equidistant, the 'Sample'
		  // column here does double duty as distance along the
		  // X axis.
		  var data = new google.visualization.DataTable();
		  data.addColumn('string', 'Sample');
		  data.addColumn('number', 'Elevation');
		  for (var i = 0; i < elevations.length; i++) {
			data.addRow(['', elevations[i].elevation]);
		  }

		  // Draw the chart using the data within its DIV.
		  chart.draw(data, {
			height: 150,
			legend: 'none',
			titleY: 'Depth (m)'
		  });
		}		

		// Extracts and pushes into the location list all the node data contained in 
	    // the html table. This html table was created from the data returned by the Cypher query
		function loadNodeLocations() {
			bodyHtml      = document.getElementsByTagName("body")[0];
			tableHtml     = bodyHtml.getElementsByTagName("table")[0];
			tableBody = tableHtml.getElementsByTagName("tbody")[0];
			numRows = tableBody.getElementsByTagName("tr").length;
			
			for (var i = 1; i < numRows; i++) {
				latitud=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[6].childNodes[0].data;
				longitud=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[5].childNodes[0].data;
				file=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[3].childNodes[0].data;
				coordenate_type=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[7].childNodes[0].data;
				group_type=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[0].childNodes[0].data;
				area_id='';
				if (group_type == 'Area')
					area_id=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[1].childNodes[0].data;
				locations.push(['<h4>File: '+file+'<br/> Coordenate type: '+coordenate_type+
				                '<br/> Group type: '+group_type+'<br/> Latitude: '+latitud+', Longitude: '+longitud+'</h4>', latitud, longitud]);
								
				datosLinea.push(new google.maps.LatLng(parseFloat(latitud), parseFloat(longitud)));
				if (area_id=='Rectangulo_1')
					datosArea1.push(new google.maps.LatLng(parseFloat(latitud), parseFloat(longitud)));
				if (area_id=='Rectangulo_2')
					datosArea2.push(new google.maps.LatLng(parseFloat(latitud), parseFloat(longitud)));
			}
			
			
		}
		
		function autoCenter() {
			//  Create a new viewpoint bound
			var bounds = new google.maps.LatLngBounds();
			//  Go through each marker
			for (var i = 0; i < markers.length; i++) {  
						bounds.extend(markers[i].position);
			}
	
			//  Fit these bounds to the map
			map.fitBounds(bounds);
			
			var listener = google.maps.event.addListener(map, "idle", function() { 
			  if (map.getZoom() > 16) map.setZoom(3); 
			  google.maps.event.removeListener(listener); 
			});		  
		}
		autoCenter();
		
		// ******************** DRAW MAP END ****************************************************

		// ******************** DRAW ANNOTATION ****************************************************
		
        var data1 = new google.visualization.DataTable();
		vehiculo=tableBody.getElementsByTagName("tr")[1].getElementsByTagName("td")[5].childNodes[0].data;
        data1.addColumn('date', 'Fecha');
        data1.addColumn('number', 'Speed of '+vehiculo);
		
		for (var i = 1; i < numRows; i++) {
			latitud=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[0].childNodes[0].data;
			longitud=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[1].childNodes[0].data;
			fecha=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[2].childNodes[0].data;
			cliente=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[3].childNodes[0].data;
			velocidad=parseInt(tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[4].childNodes[0].data);
			vehiculo=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[5].childNodes[0].data;

			vfecha=fecha.substring(0, 10).split('-');
			vhora=fecha.substring(11, 20).split(':');
			
			data1.addRow([new Date(vfecha[0], vfecha[1], vfecha[2], vhora[0], vhora[1], vhora[2]), velocidad]);
		}		

        var chart1 = new google.visualization.AnnotationChart(document.getElementById('annotation_div'));

        var options1 = {
          displayAnnotations: true
        };

        chart1.draw(data1, options1);

		// ******************** DRAW ANNOTATION END ****************************************************
		
		// ******************** DRAW TABLE ****************************************************

		// List of nodes
		var tablaDatos = [];
		
		
		loadNodetablaDatos();
		
		// Extracts and pushes into the location list all the node data contained in 
	    // the html table. This html table was created from the data returned by the Cypher query
		function loadNodetablaDatos() {
			bodyHtml      = document.getElementsByTagName("body")[0];
			tableHtml     = bodyHtml.getElementsByTagName("table")[0];
			tableBody = tableHtml.getElementsByTagName("tbody")[0];
			numRows = tableBody.getElementsByTagName("tr").length;
			numCols = tableBody.getElementsByTagName("th").length;
			
			tablaDatos.push(['Cliente', 'Vehiculo', 'Latitud', 'Longitud', 'Velocidad', 'Fecha']);
			for (var i = 1; i < numRows; i++) {
				latitud=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[0].childNodes[0].data;
				longitud=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[1].childNodes[0].data;
				fecha=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[2].childNodes[0].data;
				cliente=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[3].childNodes[0].data;
				velocidad=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[4].childNodes[0].data;
				vehiculo=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[5].childNodes[0].data;

				tablaDatos.push([cliente, vehiculo, latitud, longitud, velocidad, fecha]);
			}
		}
		
        var data = google.visualization.arrayToDataTable(tablaDatos);
		document.getElementById('tabla_div');
		var table = new google.visualization.Table(document.getElementById('tabla_div'));
        table.draw(data, {showRowNumber: false});

		// ******************** DRAW TABLE END ****************************************************
		
		// ******************** DRAW CHART ****************************************************
		
		// List of nodes
		var datosGrafica = [];
		// Sort the data of both axis
		datosGrafica.sort([{column: 0}, {column: 1}]);
		
		
		loaddatosGrafica();
		
		// Extracts and pushes into the location list all the node data contained in 
	    // the html table. This html table was created from the data returned by the Cypher query
		function loaddatosGrafica() {
			bodyHtml      = document.getElementsByTagName("body")[0];
			tableHtml     = bodyHtml.getElementsByTagName("table")[0];
			tableBody = tableHtml.getElementsByTagName("tbody")[0];
			numRows = tableBody.getElementsByTagName("tr").length;
			numCols = tableBody.getElementsByTagName("th").length;
			
			datosGrafica.push(['Tiempo', 'Velocidad']);
			for (var i = 0; i < numRows; i++) {
				latitud=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[3].childNodes[0].data;
				vehiculo=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[1].childNodes[0].data;
				velocidad=parseInt(tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[4].childNodes[0].data);
				longitud=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[2].childNodes[0].data;
				coordenadas=latitud+','+longitud;
				fecha=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[5].childNodes[0].data;
				datosGrafica.push([fecha, velocidad]);
			}
		}
		
        var dat_graf = google.visualization.arrayToDataTable(datosGrafica); 
        var options = {
          chart: {
            title: 'Velocidades del vehiculo '+vehiculo,
            subtitle: 'Vehiculo ' + vehiculo,
          },
          bars: 'horizontal' // Required for Material Bar Charts.
        };

        var chart1 = new google.charts.Bar(document.getElementById('chart_div'));
        chart1.draw(dat_graf, options);
				

		// ******************** DRAW CHART END ****************************************************

		// ******************** DRAW D3JS GRAPH ****************************************************
		/*
		LO DESCOMENTAMOS SI LE VEMOS UTILIDAD. MANTENEMOS EL EJEMPLO POR SI SE NECESITA APLICAR EN LA APLICACION
		
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
		
		loadNodosGrafo();
		
		function loadNodosGrafo() {
			bodyHtml      = document.getElementsByTagName("body")[0];
			tableHtml     = bodyHtml.getElementsByTagName("table")[0];
			tableBody = tableHtml.getElementsByTagName("tbody")[0];
			numRows = tableBody.getElementsByTagName("tr").length;
			numCols = tableBody.getElementsByTagName("th").length;
			
			for (var i = 1; i < numRows; i++) {
				velocidad=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[2].childNodes[0].data;
				velocidad=velocidad.valueOf();
				velocidad=velocidad*1;
	
				longitud=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[1].childNodes[0].data;
				longitud=longitud.substr(0,(longitud.length)-4)+longitud.substr(-3);
				latitud=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[0].childNodes[0].data;
				latitud=latitud.substr(0,(latitud.length)-4)+latitud.substr(-3);
				
				nodo=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[3].childNodes[0].data;
				textonodos = textonodos + ' {"name":"nodo: ' + nodo + ' , Velocidad: ' + velocidad + '","group":1},';
				textolinks = textolinks + ' {"source":' + (i-1) + ',"target":1,"value":1},';
			}
			textonodos = textonodos.substr(0, textonodos.length - 1) + '],';
			textolinks = textolinks.substr(0, textolinks.length - 1) + '] }';
			textoparajson = textonodos + textolinks;
		}
	
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
		*/
		// ******************** DRAW D3JS GRAPH END ****************************************************
		
	  </script> 
	  	
	</table>
</body>
</html>