<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head> 
	<meta http-equiv="content-type" content="text/html; charset=UTF-8"/> 
	<script src="js/jquery-2.1.4.js"></script>
	<script type="text/javascript" src="https://www.google.com/jsapi"></script>
	<!--script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js"></script-->
	<script src="js/d3/3.5.5/d3.min.js"></script>
    <link rel="stylesheet" href="css/main.css">

	<script>
		window.onload=construirPanel();
		
		// Launch Cypher query and redraw the Control Panel every 30 seconds
		var timer = setInterval("construirPanel()", 1000);

		function selectsUpdate() {
			var where_block = '';
			var formatos = document.getElementById('formatos'),
			   options = formatos.getElementsByTagName('option'),
			   values  = [];

				for (var i=options.length; i--;) {
					if (options[i].selected) {
						if (where_block == '')
							where_block='WHERE (file_type ="'+options[i].value+'"';
						else
							where_block=where_block+' OR file_type ="'+options[i].value+'"';
					}					
				}
			
			var authors = document.getElementById('authors'),
			    options1 = authors.getElementsByTagName('option');
				
				for (var i = options1.length; i--;)
					if (options1[i].selected)
						where_block=where_block+' OR author ="'+options1[i].value+'"';

			var lastauthors = document.getElementById('lastauthors'),
			    options2 = lastauthors.getElementsByTagName('option');
				
				for (var i = options2.length; i--;)
					if (options2[i].selected)
						where_block=where_block+' OR last_author ="'+options2[i].value+'"';

			if (where_block.endsWith('OR author ="" OR last_author =""') && !where_block.endsWith('"pdf" OR author ="" OR last_author =""'))
				where_block=where_block+') AND file_type <> "pdf" AND file_name =~ ".*'+document.getElementById('filename').value+'.*"';
			else
				where_block=where_block+') AND file_name =~ ".*'+document.getElementById('filename').value+'.*"';
					
			document.querySelector('#cypher-files').value = 
			'MATCH (n:File) WITH n.file_type AS file_type, n.file_name AS file_name, n.texto AS texto, n.author AS author, n.file_route AS file_route, (n.free_space_on_disk)/1024/1024/1024 AS free_space_on_disk, n.last_author AS last_author '+ where_block+' RETURN file_name, author, file_route, last_author, substring(texto, 0, 100), free_space_on_disk ORDER BY file_name LIMIT 100';
		}
		
		function crea_columna(file_name, texto, author, file_route, last_author, free_space_on_disk) {
			var color_background='lightgreen';
			var cara='height:80px;width:100px;vertical-align:bottom;background-size: 117px 55px;background-image:url("images/bluedrawer.png");';

			// Create Input Fields
			// SEARCHED OIL TERMS AT http://petrowiki.org/PetroWiki
			// LLD = dual laterolog
			// LLS = single laterolog
			// SFL = shallow laterolog
			// MSFL = micro spherically focused log
			// DEPTH = we find it to be depth in meters
			// GR = gamma ray index
			// RHOB = bulk density
			// NPHI = neutron porosity
			// IDL = deep-induction measurement
			var campoConsulta = document.createElement('input'); // Create Input Field for Name
			campoConsulta.setAttribute('type', 'hidden');
			campoConsulta.setAttribute('name', 'consultaCypher');
			campoConsulta.setAttribute('value',
					'MATCH (g:GpsMuestra)-[r:TOMO_MUESTRAS_EN]->(g1:GpsMuestra) '+
					'WITH ToFloat(g.LLS) AS LLS, ToFloat(g.SFLA) AS SFLA, ToFloat(g.MSFL) AS MSFL, ToFloat(g.ACOU) AS ACOU, '+
					'ToFloat(g.DEPTH) AS DEPTH, ToFloat(g.GR) AS GR, ToFloat(g.NPLS) AS NPLS, ToFloat(g.RHOB) AS RHOB, '+
					'ToFloat(g.Bit) AS Bit, ToFloat(g.NPHI) AS NPHI, ToFloat(g.DRHO) AS DRHO, ToFloat(g.ILD) AS ILD, g.file AS file '+
					// Cambiamos barras de directorio simples por dobles para que Cypher no falle
					// 'WHERE file = "'+file_route.replace(/[\\\/]/gi, '\\\\')+'" '+
					'WHERE file =~ ".*'+file_name+'" '+
					'AND DEPTH > 2000 AND GR > 20 AND ILD > 10 '+
					// 'AND LLS > 10 AND SFLA > 50 AND MSFL > 10 AND ACOU > 200 AND DEPTH > 400 AND GR > 20 AND NPLS > 0.1 AND RHOB > 2000 '+
					// 'AND Bit > 310 AND NPHI > 0.1 AND DRHO > 0 AND ILD > 10 '+
					'RETURN LLS, SFLA, MSFL, ACOU, DEPTH, GR, NPLS, RHOB, Bit, NPHI, DRHO, ILD, file '+
					'ORDER BY LLS, SFLA, MSFL, ACOU, DEPTH, GR, NPLS, RHOB, Bit, NPHI, DRHO, ILD');
			
			var campoPantalla = document.createElement('input'); 
			campoPantalla.setAttribute("type", "hidden");
			campoPantalla.setAttribute("name", "pantalla");
			campoPantalla.setAttribute("value", "files");
			
			var campoFichero = document.createElement('input'); 
			campoFichero.setAttribute("type", "hidden");
			campoFichero.setAttribute("name", "fichero");
			campoFichero.setAttribute("value", file_route.substring(52));			
			
			var submitElement = document.createElement('input'); // Append Submit Button
			submitElement.setAttribute("type", "submit");
			submitElement.setAttribute('style', 'width:85px;font-size:10px;');
			submitElement.setAttribute("name", "texto-cypher");
			submitElement.setAttribute("value", file_name);

			var formulario = document.createElement('form');
			if (file_route.endsWith("3deuler.jpg")
				|| file_route.endsWith("3deuler_symbols.png")
				|| file_route.endsWith("Bouguer_gravity.jpg")
				|| file_route.endsWith("Bouguer_gravity_1VD.jpg")
				|| file_route.endsWith("Seagull Shoals #1_Corrected Log Data.las")
				|| file_route.endsWith("Seagull Shoals No 1 Edited DT GR ILD.LAS")
				|| file_route.endsWith("Seagull Shoals No 1 Final Geological Report.pdf")
				|| file_route.endsWith("Seagull Shoals No 1 Raw DT GR ILD.LAS")
				|| file_route.endsWith("Seagull_Shoal_1.png")				//no
				|| file_route.endsWith("Seagull_Shoal_1_scatter.png")		//no
				|| file_route.endsWith("magnetics_RTP_DM4000.jpg")		//no
				|| file_route.endsWith("magnetics_RTP_HG.jpg")			//no
				|| file_route.endsWith("structural_interpretation.jpg") 
				|| file_route.endsWith("wells.dbf")
				|| file_route.endsWith("wells.prj")
				|| file_route.endsWith("wells.shp")
				|| file_route.endsWith("wells.shx")) {
					
				campoConsulta.setAttribute('value',
					'MATCH (n:Group) WITH n.group_type AS group_type, n.area_id AS area_id, n.location AS location, n.file AS file, '+
					'n.owner AS owner, n.latitude AS latitude, n.longitude AS longitude, '+
					'n.coordenate_type AS coordenate_type '+
					'WHERE file =~ ".*'+file_name.substring(0, file_name.indexOf("."))+'.*" '+
					'RETURN file, location, group_type, latitude, longitude, coordenate_type, owner, area_id ' +
					'ORDER BY file');					
				campoPantalla.setAttribute("value", "areasfiles");
				formulario.setAttribute("action", "cypher"); // Setting Action to submit to the servlet	
			}
			else if (file_route.toLowerCase().endsWith(".las"))
				formulario.setAttribute("action", "cypher"); // Setting Action to submit to the servlet
			else
				formulario.setAttribute("action", "http://localhost:8080/docs"+file_route.substring(52)); // Open the file in the browser
			
			// Si no eres superadministrador o autor, no puedes ver el documento
			if (!((document.getElementById('user').value == 'Arturo') ||(document.getElementById('user').value == author) || (document.getElementById('user').value == last_author))) {
				submitElement.setAttribute("type", "button");
				submitElement.setAttribute('style', 'width:85px;font-size:10px;');
				submitElement.setAttribute("onclick", "alert('Only a document author or a superuser can see the content of this file')");
			}
			
			formulario.setAttribute("method", "post"); // Setting Method post
			formulario.setAttribute("target", "_blank"); // Open in a new window
			formulario.appendChild(campoConsulta);
			formulario.appendChild(campoFichero);
			formulario.appendChild(campoPantalla);
			formulario.appendChild(submitElement);
			var cabecera=document.createElement('H3');
			cabecera.setAttribute('align', 'center');
			cabecera.setAttribute('id', file_name+'_cabecera');

			cabecera.appendChild(formulario);

			var texto1=document.createElement('input');
			texto1.setAttribute('id', file_name+'_vel');
			texto1.setAttribute('align', 'left');
			texto1.setAttribute('style', 'width:120px;font-size:10px;');
			texto1.setAttribute('type', 'text');
			texto1.setAttribute('value', 'A vehicle  reached '+file_name+' KM/h');
			texto1.setAttribute('readonly', 'true');

			var columna = document.createElement('td');
			columna.setAttribute('id', file_name);
			columna.setAttribute('color', 'white');
			columna.setAttribute('style', cara);
			columna.setAttribute('bgcolor', color_background);
			columna.appendChild(cabecera);
			// columna.appendChild(texto1);
			columna.appendChild(document.createElement('br'));
			
			// Si no eres superadministrador o autor, no puedes ver el resumen del documento
			if (!((document.getElementById('user').value == 'Arturo') ||(document.getElementById('user').value == author) || (document.getElementById('user').value == last_author))) {
				columna.title = file_name+'\n\nRoute: '+file_route;
			} else {
				columna.title = file_name+'\n\nRoute: '+file_route+'\n\nFree disk: '+free_space_on_disk+' Giga Bytes\n\nAuthor: '+author+'\n\nLast author: '+last_author+'\n\nContent:\n'+texto+'\n...';
			}
			
			return columna;
		}

		function crea_columna_vacia(file_name, texto, author, file_route, last_author, free_space_on_disk) {
			var color_background='lightblue';
			var cara='height:80px;width:100px;vertical-align:bottom;background-size: 117px 55px;';
			
			// Create Input Fields
			var submitElement = document.createElement('input'); // Append Submit Button
			submitElement.setAttribute("type", "submit");
			submitElement.setAttribute('style', 'width:85px;font-size:10px;');
			submitElement.setAttribute("name", "texto-cypher");
			submitElement.setAttribute("value", file_name);

			var formulario = document.createElement('form');
			formulario.setAttribute("action", "http://localhost:8080/docs"+file_route.substring(52)); // Setting Action to submit to the servlet
			formulario.setAttribute("method", "post"); // Setting Method post
			formulario.setAttribute("target", "_blank"); // Open in a new window
			formulario.appendChild(submitElement);
			
			var cabecera=document.createElement('H3');
			cabecera.setAttribute('align', 'center');
			cabecera.setAttribute('id', file_name+'_cabecera');

			cabecera.appendChild(formulario);

			var texto1=document.createElement('label');
			texto1.setAttribute('id', file_name+'_vel');
			texto1.setAttribute('align', 'left');
			texto1.setAttribute('style', 'width:80px;font-size:10px;background-color: lightblue;');
			texto1.setAttribute('type', 'text');
			texto1.setAttribute('value', '');
			texto1.setAttribute('readonly', 'true');

			var columna = document.createElement('td');
			columna.setAttribute('id', file_name);
			columna.setAttribute('color', 'white');
			columna.setAttribute('style', cara);
			columna.setAttribute('style', 'width:420px;');
			columna.setAttribute('bgcolor', color_background);
			// columna.appendChild(cabecera);
			columna.appendChild(texto1);
			columna.appendChild(document.createElement('br'));
			columna.title = file_name+'\n\nRoute: '+file_route+'\n\nFree disk: '+free_space_on_disk+'\n\nAuthor: '+author+'\n\nLast author: '+last_author+'\n\nContent:\n'+texto+'\n...';

			return columna;
		}
		
		function dibujarTabla (tablaDatos) {
			var body_tabla_pro = document.getElementById('pro');
			var row_tabla_pro = body_tabla_pro.appendChild(document.createElement('tr'));
			
			// Clean table rows
			body_tabla_pro.innerHTML = '';

			// Remove first row of headers in the array
			tablaDatos.shift();
			
			var contador = 0;
			for (var i in tablaDatos) {
				contador++;
				var file_name=tablaDatos[i][0];
				var author=tablaDatos[i][1];
				var file_route=tablaDatos[i][2];
				var last_author=tablaDatos[i][3];
				var texto=tablaDatos[i][4];
				var free_space_on_disk=tablaDatos[i][5];

				if ((i % 9) == 0) {
					row_tabla_pro = body_tabla_pro.appendChild(document.createElement('tr'));
				}
				//alert(row_tabla_pro.innerHTML);					
				row_tabla_pro.appendChild(crea_columna(file_name, texto, author, file_route, last_author, free_space_on_disk));		
			}
			
			for (var j=contador+1; j < 9; j++) {
				row_tabla_pro.appendChild(crea_columna_vacia('', '', '', '', '', ''));
			}
			
			//alert(row_tabla_pro.innerHTML);
		}
		
		function construirPanel() {
			var tablaDatos = [];
			//alert(document.getElementById('cypher-files').value);
			
			$.ajaxSetup({
				cache: true,
				headers: { 
					"Authorization": 'Basic ' + window.btoa("neo4j:arturo")
				}
			});		
			
			$.ajax({
				// Neo4j REST web service
				url: "http://localhost:7474/db/data/transaction/commit",
				cache: true,
				type: 'POST',
				data: JSON.stringify({ "statements": [{ "statement": $('#cypher-files').val() }] }),
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
					tablaDatos.push([vector[0], vector[1], vector[2], vector[3], vector[4], vector[5], vector[6]]);
				});
				$('#messageArea').html('');

				//alert(tablaDatos);

				dibujarTabla(tablaDatos);

			})
			.fail(function (jqXHR, textStatus, errorThrown) {
				$('#messageArea').html('<h3>' + textStatus + ' : ' + errorThrown + '</h3>')
			});

			
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

<body>

	<table align="center">
		<h2 align="center">Files Control Pannel</h2>
	</table>    

	<table >
		<th><div id="messageArea">Calculating. Please, hold on ...</div></th>
		<tr valign="top">
			<td  width="50%">
				<table >
					<tr valign="top">
						<td>
							<input name="user" id="user" type="hidden" value="<%= request.getParameter("user")%>" />
							<input name="cypher" id="cypher-files" type="hidden" value="MATCH (n:File) WITH n.file_type AS file_type, n.file_name AS file_name, n.texto AS texto, n.author AS author, n.file_route AS file_route, n.last_author AS last_author, (n.free_space_on_disk)/1024/1024/1024 AS free_space_on_disk WHERE file_type = 'pdf' OR file_type = 'doc' RETURN file_name, author, file_route, last_author, substring(texto, 0, 100), free_space_on_disk ORDER BY file_name LIMIT 100" />
						</td>
					
						<td style="width:70px;vertical-align:top;">
							<label style="width:70px;align:left;">File name:</label><br>
							<input type="text" id="filename" style="width:70px;align:left;" oninput="selectsUpdate()"/>
						</td>						
						<td>
							File format
							<select onchange="selectsUpdate()" id="formatos" name="formatos" size="5" multiple="multiple">
								<option value="2mod">2mod</option>
								<option value="3deuler">3deuler</option>
								<!--
								<option value="_">_</option>
								<option value="_auto-update">_auto-update</option>
								<option value="_registration">_registration</option>
								<option value="_resources">_resources</option>
								<option value="asc">asc</option>
								-->
								<option value="auto-update">auto-update</option>
								<option value="aux">aux</option>
								<!--
								<option value="bouguer_gravity">bouguer_gravity</option>
								<option value="bouguer_gravity_1vd">bouguer_gravity_1vd</option>
								<option value="bouguer_gravity_2vd">bouguer_gravity_2vd</option>
								<option value="bouguer_gravity_coherence">bouguer_gravity_coherence</option>
								<option value="bouguer_gravity_dm11000">bouguer_gravity_dm11000</option>
								<option value="bouguer_gravity_dm2000">bouguer_gravity_dm2000</option>
								<option value="bouguer_gravity_dm3000">bouguer_gravity_dm3000</option>
								<option value="bouguer_gravity_dm4300">bouguer_gravity_dm4300</option>
								<option value="bouguer_gravity_hg">bouguer_gravity_hg</option>
								<option value="bouguer_gravity_ta">bouguer_gravity_ta</option>
								<option value="bouguer_gravity_tg">bouguer_gravity_tg</option>
								-->
								<option value="coderesources">coderesource</option>
								<option value="conf">conf</option>
								<option value="csv">csv</option>
								<option value="db">db</option>
								<option value="dbf">dbf</option>
								<option value="dll">dll</option>
								<option value="doc">doc</option>
								<option value="docx">docx</option>
								<option value="dti3s">dti3s</option>
								<option value="dxf">dxf</option>
								<option value="dylib">dylib</option>
								<option value="ers">ers</option>
								<option value="exe">exe</option>
								<option value="format_list">format_list</option>
								<option value="gxf">gxf</option>
								<option value="icns">icns</option>
								<option value="ico">ico</option>
								<option value="inf">inf</option>
								<!--
								<option value="installer">installer</option>
								-->
								<option value="jpg">jpg</option></option>
								<option value="las">las</option>
								<option value="list_dir">list_dir</option>
								<option value="list_files">list_files</option>
								<option value="list_files_2">list_files_2</option>
								<option value="log">log</option>
								<option value="lsa">lsa</option>
								<!--
								<option value="magnetics_rtp">magnetics_rtp</option>
								<option value="magnetics_rtp_1vd">magnetics_rtp_1vd</option>
								<option value="magnetics_rtp_dm1800">magnetics_rtp_dm1800</option>
								<option value="magnetics_rtp_dm2700">magnetics_rtp_dm2700</option>
								<option value="magnetics_rtp_dm4000">magnetics_rtp_dm4000</option>
								<option value="magnetics_rtp_hg">magnetics_rtp_hg</option>
								<option value="magnetics_rtp_pass_below4000">magnetics_rtp_pass_below4000</option>
								<option value="magnetics_rtp_ta">magnetics_rtp_ta</option>
								<option value="magnetics_rtp_tg">magnetics_rtp_tg</option>
								<option value="magnetics_tmi">magnetics_tmi</option>
								-->
								<option value="manifest">manifest</option>
								<option value="mdb">mdb</option>
								<option value="mxd">mxd</option>
								<option value="nib">nib</option>
								<option value="ods">ods</option>
								<option value="pdf" selected="selected">pdf</option>
								<option value="plist">plist</option>
								<option value="png">png</option>
								<option value="ppt">ppt</option>
								<option value="prj">prj</option>
								<option value="qm">qm</option>
								<!--
								<option value="qtcore">qtcore</option>
								<option value="qtgui">qtgui</option>
								<option value="qtnetwork">qtnetwork</option>
								<option value="qtxml">qtxml</option>
								-->
								<option value="registration">registration</option>
								<option value="rrd">rrd</option>
								<option value="sbn">sbn</option>
								<option value="sbx">sbx</option>
								<option value="segd">segd</option>
								<option value="shp">shp</option>
								<option value="shx">shx</option>
								<option value="setfile">setfile</option>
								<option value="setfileleopard">setfileleopard</option>
								<option value="sgy">sgy</option>
								<option value="shellv5">shellv5</option>
								<option value="shp">shp</option>
								<option value="shx">shx</option>
								<option value="tif">tif</option>
								<option value="txt">txt</option>
								<option value="vel">vel</option>
								<option value="vsd">vsd</option>
								<option value="xls">xls</option>
								<option value="xlsx">xlsx</option>
								<option value="xyz">xyz</option>
								<option value="zip">zip</option>
							</select>
						</td>
						
						<td>
							Author
							<select onchange="selectsUpdate()" id="authors" name="authors" size="4" >
								<option value="" selected="selected"></option>
								<option value="duncanw">duncanw</option>
								<option value="rheinbockel">rheinbockel</option>
								<option value="obsgeo">obsgeo</option>
							</select>
						</td>
						
						<td>
							Last author
							<select onchange="selectsUpdate()" id="lastauthors" name="lastauthors" size="3" >
								<option value="" selected="selected"></option>
								<option value="WAYNE">WAYNE</option>
								<option value="johnm">johnm</option>
							</select>
						</td>						
						
					</tr>

				</table>			
			</td>
			<td width="50%">
				<table bgcolor="lightblue" align="center">
					<tbody id="pro">
						<tr><td/><td/><td/><td/></tr>
					</tbody>
				</table>				
			
			</td>
		</tr>
	</table>
</body>
</html>