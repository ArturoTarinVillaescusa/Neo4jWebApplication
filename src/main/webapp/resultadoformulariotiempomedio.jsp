<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Map.Entry" %>
<%@ page import="java.util.Collection" %>
<%@ page import="org.neo4j.graphdb.Result" %>
<%@ page import="org.neo4j.rest.graphdb.util.QueryResult" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>

<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html> 
<head> 
  <meta http-equiv="content-type" content="text/html; charset=UTF-8"> 
  <title>Mean time per trip control pannel</title> 
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

    if (lista.hasNext()) {
		// Dibujamos el encabezado de la tabla
	    Map<String,Object> linea1 = lista.next();
	
		// Nos quedamos con el contenido de la primera linea
        Map<String,Object> fila = linea1;

		int contador=0;
		int num_viaje=0;
		float duracion=0;

		// First point of a trip
    	float delta_t;
	    String vehiculo = fila.get("vehiculo").toString();
	    String fecha;

		// Last point of a trip
		float delta_t_final=0;
		String fecha_final = "";
		String fecha_final_entera = "";
		
		// Just in case the day changes from trip to trip
		String fecha_final_ant = "";
		String fecha_final_entera_ant = "";
		
    	String color_background="yellowgreen";
    	String consulta;
    	
		SimpleDateFormat formato = new SimpleDateFormat("yyyy-mm-dd hh:mm:ss");
		
		// Dibujamos el contenido de la tabla

	    out.println("<H1>Trips of vehicle "+vehiculo+"</H1>");
		
		out.print("<tr>");
				
	    do {
			// First point of the trip
			delta_t = Float.parseFloat(fila.get("delta_t").toString());			
			fecha = fila.get("fecha").toString();
			
			// Loop to search the last point of the trip
			do {
				fecha_final_entera_ant = fila.get("fecha").toString();
				fecha_final_ant = fecha_final_entera_ant.substring(0, 10);
				fila=lista.next();
				delta_t_final = Float.parseFloat(fila.get("delta_t").toString());			
				vehiculo = fila.get("vehiculo").toString();
				fecha_final_entera = fila.get("fecha").toString();
				fecha_final=fecha_final_entera.substring(0, 10);
			} while (delta_t_final < 300 && lista.hasNext() && fecha.substring(0, 10).equals(fecha_final));
			
			// If last point with delta_t > 300 and day changed, we keep last day date instead of new one
			if (!fecha.substring(0, 10).equals(fecha_final)) {
				fecha_final = fecha_final_ant;
				fecha_final_entera = fecha_final_entera_ant;
			}
			
	    	color_background="lightgreen";
		    
			// out.println("fecha_final_entera "+fecha_final_entera + " delta_t_final "+delta_t_final);
	    	// We have arrived to an end of trip. Draw a button for it in the screen and go for the next trip
			if (delta_t_final > 300)  {
				
				if (!fecha_final_entera.equals(""))
					duracion=(formato.parse(fecha_final_entera).getTime())/1000/60/60 - (formato.parse(fecha).getTime())/1000/60/60;
				
				if (duracion > 0) {
					// Draw 8 circles per line
					if ((contador++ % 8) == 0) {
						out.print("</tr><tr>");
					}
					
					num_viaje++;

					if (duracion > 8)
						color_background="yellow";
					if (duracion > 9)
						color_background="red";
					
					consulta="MATCH (v)-[r:HA_ESTADO_EN]->(p) "+
							"WITH v.vehiculoID as vehiculo, p.longitud as longitud, p.latitud as latitud, "+
							"r.record_id as record_id, toInt(r.velocidad) as velocidad, "+
							"ToFloat(r.delta_t) as delta_t, r.fecha as fecha "+
							"WHERE vehiculo=\""+vehiculo+"\" "+
							"AND fecha >=\""+fecha+"\" "+
							"AND fecha <=\""+fecha_final_entera+"\" "+
							"RETURN DISTINCT vehiculo, fecha, record_id, latitud, longitud, velocidad, "+
							"delta_t ORDER BY fecha";

					out.print("<td bgcolor='"+color_background+"' title='"+vehiculo+" trip #" +num_viaje+ "'>"+
						  "<H3 align='center'> " +
						  "<form action='cypher' method='post' target='_top'>" +
							"<input type='hidden' name='consultaCypher' "+
									"value='"+consulta+"' />"+
							"<input type='hidden' name='pantalla' value='formularioviajesdetalle' />" +
							"<input type='submit' style='width:125px;font-size:10px' name='texto-cypher' value='Trip #"+num_viaje+"'/>"	+
						  "</form>" +
						  // "<input type='text' style='width:120px;font-size:10px' align='left' value='Start: "+fecha+"'/>"+
						  // "<input type='text' style='width:120px;font-size:10px' align='left' value='End: "+fecha_final_entera+"'/>"+
						  "<input type='text' style='width:120px;font-size:10px' align='left' value='"+fecha_final+": "+duracion+" hours'/>"+
						  "</H3>" +
						  "</td>");
				}
			}

	        // out.print("<tr><td>lista.hasNext() " + lista.hasNext() + "</td><td>delta_t " + delta_t + 
	        //		"</td><td>delta_t_final " + delta_t_final + "</td><td>fecha_final_entera " + fecha_final_entera +
			//		"</td><td>" + fila.get("f vehiculo") + "</td></tr>");
			
			if (lista.hasNext()) {
				fila=lista.next();
			}
			
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