<!DOCTYPE html>
<html>
<head>

	<meta http-equiv="content-type" content="text/html; charset=UTF-8"/> 
	<script src="js/jquery-2.1.4.js"></script>
	<script type="text/javascript" src="https://www.google.com/jsapi"></script>
	<!--script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js"></script-->
	<script src="js/d3/3.5.5/d3.min.js"></script>
	
<script>

	function selectsUpdate() {
				
		document.querySelector('#cypher-files').value = 
		'MATCH (u:User) WITH u.user_id AS user_id, u.password AS password WHERE user_id = "'+document.getElementById('user').value+'" AND password = "'+document.getElementById('pwd').value+'" RETURN user_id, password';
	}

	function checkform() {		
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
			if (data.results[0].data.length > 0) {
				$.each(data.results[0].data, function (k, v) {
					var cadena = v.row+'';
					var vector=cadena.split(',');
					var usuario=vector[0];
					var clave=vector[1];
					
					document.getElementById("principal").submit();
				});
				$('#messageArea').html('');
			} else {
				alert("Wrong username or password!")
			}

		})
		.fail(function (jqXHR, textStatus, errorThrown) {
			$('#messageArea').html('<h3>' + textStatus + ' : ' + errorThrown + '</h3>')
		});
	}
</script>
</head>




<body bgcolor=lightblue>

	<div align=center><h1>Welcome to companyx Plus!</h1></div>
	<div align=center>
		<form action="principal.jsp" id="principal" method="post" onsubmit="checkform()" target="_top">
			<table>
				<th><div id="messageArea"></div></th>
				<tr>
					<td>
						<input name="cypher" id="cypher-files" type="hidden" value="MATCH (u:User) WITH u.user_id AS user_id, u.password AS password WHERE user_id = '' AND password = '' RETURN user_id, password" />
					</td>
				</tr>
				<tr><td>Username:</td><td><input type="text" id="user" name="user" required='required' oninput="selectsUpdate()" autofocus/></tr>
				<tr><td>Password:</td><td><input type="password" id="pwd" name="pwd" oninput="selectsUpdate()" required='required' /></tr>
				<tr/><tr/><tr/><tr/><tr/><tr/><tr/><tr/><tr/><tr/>
			</table>
			<input type="button" id="login" value="Login" onclick="checkform()"/>
		</form>
	</div>
	<div align=center><img src="images/presentacion.png" width="1000" height="400"/></div>

    <div class="container">
        <p><a href="http://www.dtistar.com" target="_blank">Supported by DTI Star Systems</a></p>
    </div>
	
</body>
</html>
