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
  <title>Panel de control de vehiculos</title> 
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
	<input action="action" type="button" value="Atras" onclick="window.history.go(-1);" />
	<br/><br/><br/><br/>
	<table style="display: true" border=1 id="tabla">
	
	<%  
	QueryResult<Map<String,Object>> result=(QueryResult<Map<String, Object>>)request.getAttribute("listaNodosResult");
    Iterator<Map<String, Object>> lista=result.iterator();

    if (lista.hasNext()) {
		// Dibujamos el encabezado de la tabla
	    Map<String,Object> linea1 = lista.next();
	
		// Nos quedamos con el contenido de la primera linea
        Map<String,Object> fila = linea1;

    	float delta_t = Float.parseFloat(fila.get("delta_t").toString());
	    String vehiculo = fila.get("vehiculo").toString();
	    String fecha = fila.get("fecha").toString();
    	// int velocidad=Integer.parseInt(fila.get("velocidad").toString());
    	// float latitud=Float.parseFloat(fila.get("latitud").toString());
    	// float longitud=Float.parseFloat(fila.get("longitud").toString());

    	String color_background="yellowgreen";
    	String consulta;
    	
		int contador=0;
		int num_viaje=0;

		float delta_t_anterior=0;
		String fecha_anterior = "";
		String fecha_anterior_entera = "";
		
	    out.println("<H1>Trips of "+vehiculo+" vehicle</H1>");
		
		out.print("<tr>");
		// Dibujamos el contenido de la tabla
	    do {
	    	color_background="lightgreen";
		    vehiculo = fila.get("vehiculo").toString();
		    delta_t = Float.parseFloat(fila.get("delta_t").toString());
		    
		    fecha = fila.get("fecha").toString();
	    	
	    	// We have arrived to an end of trip. Draw a button for it in the screen and go for the next trip
			if (delta_t > 300 && delta_t_anterior < 100 && (fecha_anterior.equals("") || fecha_anterior.equals(fecha.substring(0,10))))  {
		    	// Draw 8 circles per line
		    	if ((contador++ % 8) == 0) {
		    		out.print("</tr><tr>");
		    	}
				num_viaje++;
				
				consulta="MATCH (v)-[r:HA_ESTADO_EN]->(p) "+
						"WITH v.vehiculoID as vehiculo, p.longitud as longitud, p.latitud as latitud, "+
						"r.record_id as record_id, toInt(r.velocidad) as velocidad, "+
						"ToFloat(r.delta_t) as delta_t, r.fecha as fecha "+
						"WHERE vehiculo=\""+vehiculo+"\" "+
						"AND fecha <=\""+fecha+"\" "+
						"AND fecha >\""+fecha_anterior+"\" "+
						"RETURN DISTINCT vehiculo, fecha, record_id, latitud, longitud, velocidad, "+
						"delta_t ORDER BY fecha";
				
		    	out.print("<td bgcolor='"+color_background+"' title='Vehicle's "+vehiculo+" trip #" +num_viaje+ "'>"+
	    			  "<H3 align='center'> " +
	    			  "<form action='cypher' method='post' target='_top'>" +
	    				"<input type='hidden' name='consultaCypher' "+
	    						"value='"+consulta+"' />"+
						"<input type='hidden' name='pantalla' value='formularioviajesdetalle' />" +
	    			   	"<input type='submit' style='width:125px;font-size:10px' name='texto-cypher' value='Trip #"+num_viaje+"'/>"	+
	    			  "</form>" +
	    			  "<input type='text' style='width:120px;font-size:10px' align='left' value='Start: "+fecha_anterior_entera+"'/>"+
   	    			  "<input type='text' style='width:120px;font-size:10px' align='left' value='End: "+fecha+"'/>"+
	    			  "</H3>" +
	    		      "</td>");
			}
			delta_t_anterior = delta_t;
			fecha_anterior = fecha.substring(0,10);
			fecha_anterior_entera = fecha;
	    	
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
		out.print("El vehiculo no tiene viajes que cumplan las condiciones");
	}
	%>
		

	  	
	</table>
</body>
</html>