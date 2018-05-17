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
  <title>Detalle de elemento de Cuadro de Control</title> 
  <script src="http://maps.google.com/maps/api/js?sensor=false"></script>
  <script type="text/javascript" src="https://www.google.com/jsapi"></script>
  <!--script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js"></script-->
  <script src="js/d3/3.5.5/d3.min.js"></script>

  <script type="text/javascript">
    google.load('visualization', '1', {'packages': ['table', 'map', 'corechart', 'bar']});
  </script>
</head> 

<link rel="stylesheet" href="css/main.css">

<body>
	<div class="bloque_google" id="mapa_div" style="width: 1200px; height: 500px;"></div>
		
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
		out.print("No hay datos");
	}
	%>
	<script>
		// ******************** DRAW MAP ****************************************************
		
		// List of node locations
		var locations = [];
		
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
		  mapTypeControl: false,
		  streetViewControl: false,
		  panControl: false,
		  zoomControlOptions: {
			 position: google.maps.ControlPosition.LEFT_BOTTOM
		  }
		});

		var infowindow = new google.maps.InfoWindow({
		  maxWidth: 160
		});

		var markers = new Array();
		
		var iconCounter = 0;
		 
		loadNodeLocations();
		
		// Add the markers and node information to the map
		for (var i = 0; i < locations.length; i++) {  
			  var icono = iconURLPrefix + 'green-dot.png';
			  var velocidad = locations[i][3];

			  if (velocidad > 110)
				  icono = iconURLPrefix + 'yellow-dot.png';
			  if (velocidad > 120)
				  icono = iconURLPrefix + 'red-dot.png';
			  
			  // Marker coordinates with the icon representing the node
			  var marker = new google.maps.Marker({
				position: new google.maps.LatLng(locations[i][1], locations[i][2]),
				map: map,
				icon: icono
			  });
			  
			  // push the new marker into the list
			  markers.push(marker);
	
			  // When user clicks the icon, this node information will be shown
			  google.maps.event.addListener(marker, 'click', (function(marker, i) {
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

		// Extracts and pushes into the location list all the node data contained in 
	    // the html table. This html table was created from the data returned by the Cypher query
		function loadNodeLocations() {
			bodyHtml      = document.getElementsByTagName("body")[0];
			tableHtml     = bodyHtml.getElementsByTagName("table")[0];
			tableBody = tableHtml.getElementsByTagName("tbody")[0];
			numRows = tableBody.getElementsByTagName("tr").length;
			
			for (var i = 1; i < numRows; i++) {
				latitud=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[0].childNodes[0].data;
				longitud=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[1].childNodes[0].data;
				fecha=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[2].childNodes[0].data;
				cliente=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[3].childNodes[0].data;
				velocidad=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[4].childNodes[0].data;
				vehiculo=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[5].childNodes[0].data;
				locations.push(['<h4>Vehiculo: '+cliente+','+vehiculo+'<br/> Velocidad: '+velocidad+'<br/> Fecha: '+fecha+
				                '<br/> Latitud: '+latitud+', Longitud: '+longitud+'</h4>', latitud, longitud, velocidad]);
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
		}
		autoCenter();
		
		// ******************** DRAW MAP END ****************************************************
				
	  </script> 
	  	
	</table>
</body>
</html>