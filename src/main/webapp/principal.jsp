<!DOCTYPE html>
<html>
   <head>

	<meta http-equiv="content-type" content="text/html; charset=UTF-8"/> 
	<script src="js/jquery-2.1.4.js"></script>
	<script type="text/javascript" src="https://www.google.com/jsapi"></script>
	<!--script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js"></script-->
	<script src="js/d3/3.5.5/d3.min.js"></script>
   </head>
   <body>
		<div class="section">
			<div class="container" align="center" >
				<table>
				<tr>
				<td>
				<form action="files.jsp" id="files" method="post" target="_blank">
					<input type="hidden" id="user" name="user" value="<%= request.getParameter("user")%>"/>
					<input type="submit" value="SEARCH FILES" style="font-size:21px;color:white;background-image:url('images/files.png');background-size: 205px 205px;width:205px;height:205px"  title="Search files" />
				</form>
				</td>
				<td>
				<form action="duplicatedfiles.jsp" id="duplicatedfiles" method="post" target="_blank">
					<input type="hidden" id="user" name="user" value="<%= request.getParameter("user")%>"/>
					<input type="submit" value="SHOW DUPLICATED FILES" style="font-size:14px;color:white;background-image:url('images/files.png');background-size: 205px 205px;width:205px;height:205px"  title="Show duplicated files" />
				</form>
				</td>
				<td>
				<form action="ValenciaWalk/index.html" id="manchesterwalk" method="post" target="_blank">
					<input type="hidden" id="user" name="user" value="<%= request.getParameter("user")%>"/>
					<input type="submit" value="3D INTERACTIVE WALK" style="font-size:14px;color:white;background-image:url('images/street.png');background-size: 205px 205px;width:205px;height:205px"  title="3D Interactive Walk!" />
				</form>
				
				</td>
				</tr>
				</table>
				<!--
				<button class="button" onClick="window.open('vehicles.jsp', '_blank', 'toolbar=0,location=0,menubar=0,width=700,height=500,top=100, left=300');" style="background-image:url('images/verde.png');background-size: 205px 205px;width:205px;height:205px" title="Vehicles control pannel"></button>
				<button class="button" onClick="window.open('pois.jsp', '_blank', 'toolbar=0,location=0,menubar=0,width=700,height=500,top=100, left=700');" style="background-image:url('images/poigreen.png');background-size: 205px 205px;width:205px;height:205px" title="POIs control pannel"></button>
				-->
			</div>

			<div align="center" class="container">
				<img src="images/presentacion.png" width="900" height="400"/>
			</div>
			
			<div class="container">
				<p><a href="http://www.dtistar.com" target="_blank">Supported by DTI Star Systems</a></p>
			</div>			
			<!-- /.container -->

		</div>   
   </body>
</html>
 