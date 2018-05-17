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
  <title>Detail of speeds</title> 
  <script async defer
        src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCZZ0BCr7EjYgducaxKJTRxON7vFieCsMs&signed_in=true"></script>

  <!--<script src="http://maps.google.com/maps/api/js?sensor=false"></script>-->
  <script type="text/javascript" src="https://www.google.com/jsapi"></script>
  <!--script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js"></script-->
  <script src="js/d3/3.5.5/d3.min.js"></script>

  <script type="text/javascript">
    google.load('visualization', '1', {'packages': ['table', 'map', 'corechart', 'bar', 'annotationchart']});
  </script>
</head> 

<link rel="stylesheet" href="css/main.css">

<body onload='document.getElementById("messageArea").innerHTML=""; location.href="#map1"' >
	<b><div id="messageArea">Calculating. Please, hold on ...</div></b>
	<a name="map1"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center">Trip 1 <a style="visibility:visible" id="#map1" href="#map2">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div1" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
	
	<a name="map2"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map1">Previous trip</a> Trip 2 <a style="visibility:hidden" id="#map2" href="#map3">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div2" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
	
	<a name="map3"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map2">Previous trip</a> Trip 3 <a style="visibility:hidden" id="#map3" href="#map4">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div3" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>

	<a name="map4"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map3">Previous trip</a> Trip 4 <a style="visibility:hidden" id="#map4" href="#map5">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div4" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
	
	<a name="map5"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map4">Previous trip</a> Trip 5 <a style="visibility:hidden" id="#map5" href="#map6">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div5" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map6"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map5">Previous trip</a> Trip 6 <a style="visibility:hidden" id="#map6" href="#map7">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div6" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map7"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map6">Previous trip</a> Trip 7 <a style="visibility:hidden" id="#map7" href="#map8">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div7" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map8"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map7">Previous trip</a> Trip 8 <a style="visibility:hidden" id="#map8" href="#map9">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div8" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map9"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map8">Previous trip</a> Trip 9 <a style="visibility:hidden" id="#map9" href="#map10">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div9" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map10"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map9">Previous trip</a> Trip 10 <a style="visibility:hidden" id="#map10" href="#map11">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div10" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map11"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map10">Previous trip</a> Trip 11 <a style="visibility:hidden" id="#map11" href="#map12">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div11" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map12"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map11">Previous trip</a> Trip 12 <a style="visibility:hidden" id="#map12" href="#map13">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div12" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map13"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map12">Previous trip</a> Trip 13 <a style="visibility:hidden" id="#map13" href="#map14">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div13" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map14"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map13">Previous trip</a> Trip 14 <a style="visibility:hidden" id="#map14" href="#map15">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div14" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map15"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map14">Previous trip</a> Trip 15 <a style="visibility:hidden" id="#map15" href="#map16">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div15" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map16"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map15">Previous trip</a> Trip 16 <a style="visibility:hidden" id="#map16" href="#map17">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div16" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map17"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map16">Previous trip</a> Trip 17 <a style="visibility:hidden" id="#map17" href="#map18">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div17" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map18"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map17">Previous trip</a> Trip 18 <a style="visibility:hidden" id="#map18" href="#map19">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div18" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map19"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map18">Previous trip</a> Trip 19 <a style="visibility:hidden" id="#map19" href="#map20">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div19" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map20"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map19">Previous trip</a> Trip 20 <a style="visibility:hidden" id="#map20" href="#map21">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div20" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map21"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map20">Previous trip</a> Trip 21 <a style="visibility:hidden" id="#map21" href="#map22">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div21" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map22"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map21">Previous trip</a> Trip 22 <a style="visibility:hidden" id="#map22" href="#map23">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div22" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map23"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map22">Previous trip</a> Trip 23 <a style="visibility:hidden" id="#map23" href="#map24">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div23" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map24"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map23">Previous trip</a> Trip 24 <a style="visibility:hidden" id="#map24" href="#map25">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div24" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map25"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map24">Previous trip</a> Trip 25 <a style="visibility:hidden" id="#map25" href="#map26">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div25" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map26"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map25">Previous trip</a> Trip 26 <a style="visibility:hidden" id="#map26" href="#map27">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div26" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map27"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map26">Previous trip</a> Trip 27 <a style="visibility:hidden" id="#map27" href="#map28">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div27" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map28"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map27">Previous trip</a> Trip 28 <a style="visibility:hidden" id="#map28" href="#map29">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div28" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map29"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map28">Previous trip</a> Trip 29 <a style="visibility:hidden" id="#map29" href="#map30">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div29" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="map30"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map29">Previous trip</a> Trip 30 <a style="visibility:hidden" id="#map30" href="#map31">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div30" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	
	<a name="map31"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map30">Previous trip</a> Trip 31 <a style="visibility:hidden" id="#map31" href="#map32">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div31" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		

	<a name="map32"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map31">Previous trip</a> Trip 32 <a style="visibility:hidden" id="#map32" href="#map33">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div32" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	
	<a name="map33"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map32">Previous trip</a> Trip 33 <a style="visibility:hidden" id="#map33" href="#map34">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div33" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	
	<a name="map34"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map33">Previous trip</a> Trip 34 <a style="visibility:hidden" id="#map34" href="#map35">Next trip</a> <a href="#annotation">Vehicle speed chart</a> <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="mapa_div34" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>		
	
	<a name="annotation"></a> 
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map1">Back to first trip</a> Vehicle speed chart <a href="#lastingchart">Trip lastings chart</a></h4>
	<div class="bloque_google" id="annotation_div" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
	
	<a name="lastingchart"></a>
	<input action="action" type="button" style="background-image:url('images/back.png');width:45px;height:45px" onclick="location.href = 'indice.jsp#/vehicles'" />
	<h4 align="center"><a href="#map1">Back to first trip</a> <a href="#annotation">Vehicle speed chart</a> Trip lastings chart</h4>	
	<div class="bloque_google" id="chart_div" style="width: 1250px; height: 620px;"></div>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
	
	<div id="my_visualization_DIV"></div>
	<div class="bloque_google" id="tabla_div" style="width: 1200px; height: 620px;"></div>

		
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
	<script>
		// ******************** DRAW MAP ****************************************************
	try {
		// create the maps
		var myOptions = {
			zoom: 7,
			center: new google.maps.LatLng("40.41153868", "-4.0"),
			mapTypeId: google.maps.MapTypeId.ROADMAP,
		}

		eval('mapa_div1 = new google.maps.Map(document.getElementById("mapa_div1"), myOptions);');

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

		var marker;
					
		var infowindow = new google.maps.InfoWindow({
		  maxWidth: 160
		});

		var markers = new Array();

		loadNodeLocations();
		
		var j = 1;
		// Add the markers and node information to the map
		for (var i = 0; i < locations.length; i++) {  
			// var icono = 'http://mt.google.com/vt/icon/name=icons/spotlight/measle_green_8px.png&scale=1';
			var icono = 'http://maps.gstatic.com/mapfiles/markers2/measle_blue.png';
			var velocidad = locations[i][3];
			var delta_t = locations[i][4];
			var delta_t_anterior = 0;
			
			if (i > 0)
			  delta_t_anterior = locations[i-1][4];
			
			if (velocidad > 110)
			  icono = iconURLPrefix + 'yellow-dot.png';
			if (velocidad > 120)
			  icono = iconURLPrefix + 'red-dot.png';
			
			// If start of trip
			if (i == 0)
				icono = 'http://maps.google.com/mapfiles/arrow.png';
				//icono = 'https://maps.gstatic.com/mapfiles/ms2/micons/truck.png';
			// If end of trip
			if (i == (locations.length-1))
				icono = 'https://maps.gstatic.com/mapfiles/ms2/micons/lodging.png';
			
			if (delta_t_anterior > 300) {
			  icono = 'http://maps.google.com/mapfiles/arrow.png';
			}
			
			// End of a trip
			if (delta_t > 300) {
				icono = 'https://maps.gstatic.com/mapfiles/ms2/micons/lodging.png';
			}
			
            if (delta_t >= 15 && 30 > delta_t)
				icono = 'https://maps.gstatic.com/mapfiles/ms2/micons/restaurant.png';
			
			if (delta_t >3 && 5 > delta_t && velocidad < 10)
				icono = 'http://www.google.com/mapfiles/traffic.png';
			
			// Marker coordinates with the icon representing the node
			eval('marker = new google.maps.Marker({position: new google.maps.LatLng(locations[i][1], locations[i][2]),map: mapa_div'+j+',icon: icono})');

			eval('google.maps.event.addListener(marker, "mouseover", (function(marker, i) { return function() { infowindow.setContent(locations[i][0]); infowindow.open(mapa_div'+j+', marker); } })(marker, i));');
			
			// push the new marker into the list
			markers.push(marker);
	
			// When user clicks the icon, this node information will be shown
			// google.maps.event.addListener(marker, 'mouseover', (function(marker, i) {
			// return function() {
			//   infowindow.setContent(locations[i][0]);
			//   eval('infowindow.open(mapa_div'+j+', marker);');
			// }
			// })(marker, i));
			
			// Start of a trip
			if (delta_t_anterior > 300) {
			  icono = 'http://maps.google.com/mapfiles/arrow.png';
			}
			
			var idmapa = 'mapa_div'+j;
			// End of a trip
			if (delta_t > 300 && delta_t_anterior < 100) {
				autoCenter(j);

				icono = 'https://maps.gstatic.com/mapfiles/ms2/micons/lodging.png';
				eval('document.getElementById("#map'+j+'").style.visibility="visible";');
				j++;
				eval('mapa_div'+j+' = new google.maps.Map(document.getElementById("mapa_div'+j+'"), myOptions);');
				eval('var trafficLayer = new google.maps.TrafficLayer(); trafficLayer.setMap(mapa_div'+j+');');

			}
			
			
		}
	} catch(e) { 

	  alert("name:" + e.name + "\nmessage:" + e.message) 

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
				delta_t=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[1].childNodes[0].data;
				longitud=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[2].childNodes[0].data;
				fecha=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[3].childNodes[0].data;
				cliente=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[4].childNodes[0].data;
				velocidad=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[5].childNodes[0].data;
				vehiculo=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[6].childNodes[0].data;
				locations.push(['<h4>Vehicle: '+cliente+','+vehiculo+'<br/> Speed: '+velocidad+' Km/h<br/> Downtime: '+delta_t+' minutes<br/> Date: '+fecha+'<br/> Latitude: '+latitud+', Longitude: '+longitud+'</h4>', latitud, longitud, velocidad, delta_t]);
			}
		}
		
		function autoCenter(j) {
		  //  Create a new viewpoint bound
		  var bounds = new google.maps.LatLngBounds();
		  //  Go through each marker
		  for (var i = 0; i < markers.length; i++) {  
					bounds.extend(markers[i].position);
		  }
		  //  Fit these bounds to the map
		  eval('mapa_div'+j+'.fitBounds(bounds);');
		}
		
		
		// ******************** DRAW MAP END ****************************************************

		// ******************** DRAW ANNOTATION ****************************************************
		
        var data1 = new google.visualization.DataTable();
		vehiculo=tableBody.getElementsByTagName("tr")[1].getElementsByTagName("td")[5].childNodes[0].data;
        data1.addColumn('date', 'Fecha');
        data1.addColumn('number', 'Speed of '+vehiculo);
		
		for (var i = 1; i < numRows; i++) {
			latitud=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[0].childNodes[0].data;
			longitud=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[2].childNodes[0].data;
			fecha=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[3].childNodes[0].data;
			cliente=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[4].childNodes[0].data;
			velocidad=parseInt(tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[5].childNodes[0].data);
			vehiculo=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[6].childNodes[0].data;

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
				vehiculo=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[6].childNodes[0].data;

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

			datosGrafica.push(['Start trip time', 'Hours']);
			
			for (var i = 1; i < numRows; i++) {
				fecha=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[0].childNodes[0].data;
				delta_t=tableBody.getElementsByTagName("tr")[i].getElementsByTagName("td")[3].childNodes[0].data;
				
				// Start of a trip
				//if (i == 1)
				//	fecha_inicio = fecha;
				//if (delta_t > 300) {
				//   fecha_fin = fecha;
				//   // diferencia=fecha_fin-fecha_inicio;
				//   fecha_inicio = tableBody.getElementsByTagName("tr")[i+1].getElementsByTagName("td")[3].childNodes[0].data;
				//   alert('fecha inicio '+fecha_inicio+', fecha fin '+fecha_fin);
				//}
				if (i == 1) {
					if (delta_t < 10 )
						fecha_inicio = fecha;
					else						
						fecha_inicio = tableBody.getElementsByTagName("tr")[i+1].getElementsByTagName("td")[0].childNodes[0].data;
				}
				
				if (delta_t > 100) {
					if ((delta_t_anterior < 100) && (i > 1))
						fecha_fin = tableBody.getElementsByTagName("tr")[i-1].getElementsByTagName("td")[0].childNodes[0].data;
					else
						fecha_fin = fecha;

					vfecha=fecha_inicio.substring(0, 10).split('-');
					vhora=fecha_inicio.substring(11, 20).split(':');	
					
					f1 = new Date(vfecha[0], vfecha[1], vfecha[2], vhora[0], vhora[1], vhora[2]);

					vfecha=fecha_fin.substring(0, 10).split('-');
					vhora=fecha_fin.substring(11, 20).split(':');	
					
					f2 = new Date(vfecha[0], vfecha[1], vfecha[2], vhora[0], vhora[1], vhora[2]);
					
					var timeDiff = Math.abs(f2.getTime() - f1.getTime());
					var diffHours = Math.ceil(timeDiff / (1000 * 3600)); 
					
					// alert('i '+i+'\n fecha '+fecha+'\nfecha_inicio '+fecha_inicio+'\n fecha_fin '+fecha_fin+'\n delta_t '+delta_t+'\n diffHours '+diffHours);
					datosGrafica.push([fecha, diffHours]);
					
					if (i < (numRows-1))
						fecha_inicio = tableBody.getElementsByTagName("tr")[i+1].getElementsByTagName("td")[0].childNodes[0].data;
				}			
			}
		}
		
        var dat_graf = google.visualization.arrayToDataTable(datosGrafica); 
        var options = {
          chart: {
            title: 'Trips lastings',
            subtitle: 'Vehicle ' + vehiculo,
          },
          bars: 'vertical' // Required for Material Bar Charts.
        };

        var chart1 = new google.charts.Bar(document.getElementById('chart_div'));
        chart1.draw(dat_graf, options);
				

		// ******************** DRAW CHART END ****************************************************
		
		
	  </script> 
	  	
	</table>
</body>
</html>