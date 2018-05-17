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

  <script type="text/javascript">
    google.load('visualization', '1', {'packages': ['table', 'map', 'corechart', 'bar']});
  </script>
</head> 

<link rel="stylesheet" href="css/main.css">

<body>
	<input action="action" type="button" value="Go back" onclick="window.history.go(-1);" />
	<br/><br/><br/><br/>
	<table style="display: true" border=1 id="tabla">
	
	<%  
	QueryResult<Map<String,Object>> result=(QueryResult<Map<String, Object>>)request.getAttribute("listaNodosResult");
    Iterator<Map<String, Object>> lista=result.iterator();
    
    String limitevelocidad = ""+request.getAttribute("limitevelocidad");

    if (lista.hasNext()) {
		// Dibujamos el encabezado de la tabla
	    Map<String,Object> linea1 = lista.next();
	
		// Nos quedamos con el contenido de la primera linea
        Map<String,Object> fila = linea1;

    	String cliente = fila.get("cliente").toString();
	    String vehiculo = fila.get("vehiculo").toString();
    	int velocidad=Integer.parseInt(fila.get("velocidad").toString());
    	// float latitud=Float.parseFloat(fila.get("latitud").toString());
    	// float longitud=Float.parseFloat(fila.get("longitud").toString());

    	String color_background="yellowgreen";
    	
		int contador=0;

	    out.println("<H1>Customer's "+cliente+" vehicles that exceeded the speed limit</H1>");
		
		out.print("<tr>");
		// Dibujamos el contenido de la tabla
	    do {
	    	color_background="yellowgreen";
		    vehiculo = fila.get("vehiculo").toString();
	    	velocidad=Integer.parseInt(fila.get("velocidad").toString());

	    	// Draw 8 circles per line
	    	if ((contador++ % 8) == 0) {
	    		out.print("</tr><tr>");
	    	}
	    	
	    	// Changes colour if threshold has been tresspassed
			if (velocidad > 110)
				color_background="yellow";
			if (velocidad > 120)
				color_background="red";
				
	    	out.print("<td bgcolor='"+color_background+"' title='La velocidad maxima del vehiculo "+vehiculo+" ha sido "+velocidad+" Km/h'>"+
	    			  "<H3 align='center'> " +
	    			  "<form action='cypher' method='post' target='_top'>" +
	    				"<input type='hidden' name='consultaCypher' "+
	    			  			"value=\"MATCH (c)-[]->(v)-[r:HA_ESTADO_EN]->(p) " +
								    "WITH v.vehiculoID as vehiculo, toFloat(p.longitud) as longitud, "+
									"c.clienteID as cliente, toFloat(p.latitud) as latitud, "+
									"toInt(r.velocidad) as velocidad, r.fecha as fecha "+
									"WHERE cliente = \'"+cliente+"\' AND  vehiculo = \'"+vehiculo+"\' " +
									"AND velocidad > " +limitevelocidad+ " "+
									"RETURN DISTINCT cliente, vehiculo, latitud, longitud, velocidad, fecha "+
									"ORDER BY cliente, vehiculo, fecha desc\" />" +
						"<input type='hidden' name='pantalla' value='formulariovehiculos' />" +
	    			   	"<input type='submit' style='width:125px;font-size:10px' name='texto-cypher' value='Vehicle	 "+vehiculo+"'/>"	+
	    			  "</form>" +
	    			  "<input type='text' style='width:120px;font-size:10px' align='left' value='Exceeded "+velocidad+" Km/h'/>" +
	    			  "</H3>" +
	    		      "</td>");

	        //out.print("<tr><td>" + fila.get("latitud") + fila.get("longitud") + "</td><td>" + fila.get("fecha") + 
	        //		"</td><td>" + fila.get("cliente") + "</td><td>" + fila.get("velocidad") + "</td><td>" + fila.get("vehiculo") + 
	        //		  "</td></tr>");
			
			// Si quedan mas lineas
			if (lista.hasNext())
				fila=lista.next();
	    } while ( lista.hasNext() );
    	out.print("</tr");
		
		// Dibujamos la linea final
		//out.print("<tr>");
        //out.print("<tr><td>" + fila.get("latitud") + fila.get("longitud") + "</td><td>" + fila.get("fecha") + 
        //		"</td><td>" + fila.get("cliente") + "</td><td>" + fila.get("velocidad") + "</td><td>" + fila.get("vehiculo") + 
        //		  "</td></tr>");
		//out.print("</tr>");

    } else {
		out.print("El cliente no tiene vehiculos que cumplan las condiciones");
	}
	%>
		

	  	
	</table>
</body>
</html>