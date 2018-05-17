package bulkloaders;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.neo4j.graphdb.DynamicLabel;
import org.neo4j.graphdb.DynamicRelationshipType;
import org.neo4j.graphdb.Label;
import org.neo4j.graphdb.RelationshipType;
import org.neo4j.io.fs.FileUtils;
import org.neo4j.unsafe.batchinsert.BatchInserter;
import org.neo4j.unsafe.batchinsert.BatchInserters;

public class BatchInserter_companyz_01 {

	
	// http://maxdemarzi.com/2012/02/28/batch-importer-part-1/
	// http://maxdemarzi.com/2012/02/28/batch-importer-part-2/
	// http://maxdemarzi.com/2012/07/02/batch-importer-part-3/
	// https://github.com/jexp/batch-import
	public static void main(String[] args) {
		BatchInserter inserter = null;
		
		// guardar timestamp inicio
		long inicio = System.currentTimeMillis();
		  
		try
		{
			//////////////////////////////////////////////////////////////////////////
			
			// Variables para extraer el contenido de los archivos de texto y posteriormente almacenarlo en Neo4j
		    List<List<String>> registros = new ArrayList<>();
		    List<String> campos = new ArrayList<>();
		    List<String> etiquetas = new ArrayList<>();
		    Map<String, Object> atributos = new HashMap<>();
		    
		    // Durante la carga guardamos los identificadores de los nodos que leemos del texto, para evitar crear duplicados de una misma clave
		    Map<String, Long> users = new HashMap<>();
		    Map<String, Long> clientes = new HashMap<>();
		    Map<String, Long> vehiculos = new HashMap<>();
		    Map<String, Long> gpss = new HashMap<>();
		    Map<String, Long> pois = new HashMap<>();
		    Map<String, Long> tiene_creados = new HashMap<>();
		    Map<String, Long> haestadoen_creados = new HashMap<>();
		    Map<String, Long> haestadoenpoi_creados = new HashMap<>();

			// Creamos una nueva base de datos Neo4j
	        File graphDb = new File("C:\\Users\\Arturo\\Documents\\DISCO_CLUSTER\\companyzv5.graphdb");

	        if (graphDb.exists()) {
	            try {
	            	// Si existe la base de datos la borramos
					FileUtils.deleteRecursively(graphDb);
					
					// Si existe la base de datos la renombramos incluyendo el milisegungo actual y creamos una nueva
	            	// FileUtils.renameFile(graphDb, new File(graphDb.getName()+"Copia-"+System.currentTimeMillis()));
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
	        }
	        
	        // Parametros para ocnfigurar la base de datos
	        Map<String, String> config = new HashMap<String, String>();
	        config.put("allow_store_upgrade=true", "true");
	        
	        // Puntero a la base de datos
		    inserter = BatchInserters.inserter( graphDb.getAbsolutePath(), config );			
		    
		    
		    //////// Nodos e �ndices /////////////////////////
		    
		    Label etiquetaNodoUser = DynamicLabel.label( "User" );
		    long idNodoUser = -1;
			// CREATE INDEX ON :User(user_id);
		    inserter.createDeferredSchemaIndex( etiquetaNodoUser ).on( "user_id" ).create();

		    Label etiquetaNodoCliente = DynamicLabel.label( "Cliente" );
		    long idNodoCliente = -1;
			// CREATE INDEX ON :Cliente(clienteID);
		    inserter.createDeferredSchemaIndex( etiquetaNodoCliente ).on( "clienteID" ).create();

		    Label etiquetaNodoVehiculo = DynamicLabel.label( "Vehiculo" );
		    long idNodoVehiculo = -1;
			// CREATE INDEX ON :Vehiculo(vehiculoID);
		    inserter.createDeferredSchemaIndex( etiquetaNodoCliente ).on( "vehiculoID" ).create();

		    Label etiquetaNodoGps = DynamicLabel.label( "Gps" );
		    long idNodoGps = -1;
			// CREATE INDEX ON :Gps(latitud);
		    inserter.createDeferredSchemaIndex( etiquetaNodoGps ).on( "latitud" ).create();
			// CREATE INDEX ON :Gps(longitud);
		    inserter.createDeferredSchemaIndex( etiquetaNodoGps ).on( "longitud" ).create();

		    Label etiquetaNodoPOI = DynamicLabel.label( "Poi" );
		    long idNodoPoi = -1;
			// CREATE INDEX ON :Poi(latitud);
		    inserter.createDeferredSchemaIndex( etiquetaNodoPOI ).on( "latitud" ).create();
			// CREATE INDEX ON :Poi(longitud);
		    inserter.createDeferredSchemaIndex( etiquetaNodoPOI ).on( "longitud" ).create();
		    
		    // Relaciones
		    RelationshipType tiene = DynamicRelationshipType.withName( "TIENE" );
		    long idRelacionTiene = -1;
		    
		    RelationshipType ha_estado_en = DynamicRelationshipType.withName( "HA_ESTADO_EN" );
		    long idRelacionHaEstadoEn = -1;

		    RelationshipType ha_estado_en_poi = DynamicRelationshipType.withName( "HA_ESTADO_EN_POI" );
		    long idRelacionHaEstadoEnPoi = -1;
		    
			String fila;
			String valor;
		    
		    //////////////////// INICIO	01_Users_List.csv 	///////////////////////////////////////////

		    // Recorremos todas las filas del archivo 01_Users_List.csv
			try (BufferedReader br = 
				new BufferedReader(new FileReader("C:\\Users\\Arturo\\Documents\\BIG DATA\\PRODUCTOS\\companyz\\01_Users_List.csv")))
			{


				fila = br.readLine();
			
				// Leemos los identificadores del las columnas
				for (String etiqueta : fila.split("\\t")) {
					etiquetas.add(etiqueta);
				}
				
				// Leemos las filas separando los valores de las columnas
				while ((fila = br.readLine()) != null)
					
//					USING PERIODIC COMMIT 1000
//					LOAD CSV WITH HEADERS FROM "file:///mnt/hgfs/Downloads/01_Users_List.csv" AS row
//					FIELDTERMINATOR '\t'
//					WITH row
//					MERGE (c:User {user_id:user_id})
//					ON CREATE SET 	u.password=row.user_id+'01';
//										
					
					for (String campo : fila.split("\\t")) {
						// y creamos los nodos y les asignamos los atributos
						campos.add(campo);
					}
					
					// Rellenamos los atributos del nodo User.
					valor = campos.get(etiquetas.indexOf("user_id")).substring(0, 4);
					
					// Buscamos el identificador del User de la l�nea actual
					// en los nodos de User que ya han sido insertados en la base de datos
					if (!users.isEmpty() && users.containsKey(valor))
						idNodoUser = users.get(valor);
					
					// Si no ha sido insertado ya este nodo User, lo insertamos
					if (idNodoUser == -1) {
						atributos.put( "user_id", valor );

						// Insertamos el nodo User
						idNodoUser = inserter.createNode( atributos, etiquetaNodoUser );

						// Guardamos el identificador en la lista de insertados, para evitar crear duplicados
						users.put( campos.get(etiquetas.indexOf("user_id")).substring(0, 4), idNodoUser);
						
					}
					
					// Rellenamos los atributos del nodo User
					valor = campos.get(etiquetas.indexOf("user_id"));
					
					// Buscamos el identificador del User de la l�nea actual
					// en los nodos de User que ya han sido insertados en la base de datos
					if (!users.isEmpty() && users.containsKey(valor))
						idNodoUser = users.get(valor);
					
					// Si no ha sido insertado ya este nodo User, lo insertamos
					if (idNodoUser == -1) {
						// Rellenamos los atributos del nodo User
						atributos.put( "user_id", valor);
						atributos.put( "user_password", valor+"01");
						
						
						// Buscamos el identificador del User de la l�nea actual
						// en los nodos de User que ya han sido insertados en la base de datos
						if (!users.isEmpty() && users.containsKey(valor))
							idNodoUser = users.get(valor);
						
						// Insertamos el nodo User
						idNodoUser = inserter.createNode( atributos, etiquetaNodoUser );

						// Guardamos el identificador en la lista de insertados, para evitar crear duplicados
						users.put( campos.get(etiquetas.indexOf("user_id")), idNodoUser);
						
					}

					// atributos = new HashMap<>(50);
					// campos = new ArrayList<>(50);
					
					// Limpiamos las variables de identificador para la siguiente l�nea
					idNodoUser = -1;
				}

			} catch (IOException e) {
		        inserter.shutdown();
			}
			
			//////////////////// FIN 01_Users_List.csv 	///////////////////////////////////////////
			
		
/*			


		    
		    // Recorremos todas las filas del archivo que queremos importar a NEO4J
			try (BufferedReader br = 
				new BufferedReader(new FileReader("C:\\Users\\Arturo\\Documents\\BIG DATA\\PRODUCTOS\\companyz\\01_Vehicle_Stats_2015_01.csv")))
			{


				fila = br.readLine();
			
				// Leemos los identificadores del las columnas
				for (String etiqueta : fila.split("\\t")) {
					etiquetas.add(etiqueta);
				}
				
				// Leemos las filas separando los valores de las columnas
				while ((fila = br.readLine()) != null) {

				    ////////////////////////////////	01_Vehicle_Stats_2015_01.csv     /////////////////////////////////////////////
					
//					USING PERIODIC COMMIT 1000
//					LOAD CSV WITH HEADERS FROM "file:///mnt/hgfs/Downloads/01_Vehicle_Stats_2015_01.csv" AS row
//					FIELDTERMINATOR '\t'
//					WITH row
//					MERGE (c:Cliente {clienteID:SUBSTRING(row.vehicleID,0,4)})
//					MERGE (v:Vehiculo {vehiculoID:row.vehicleID})
//					ON CREATE SET 	v.numberPoints=row.numberPoints, v.numberPOI=row.numberPOI,
//									v.maxspeed=row.maxspeed, v.maxodometer=row.maxodometer, v.minodometer=row.minodometer,
//									v.traveledkm=row.traveledkm, v.latitude_max=row.latitude_max,
//									v.latitude_min=row.latitude_min, v.longitude_max=row.longitude_max,
//									v.longitude_min=row.longitude_min, v.fecha_max=row.fecha_max, v.fecha_min=row.fecha_min,
//									v.tiempoenactividad=row.tiempoenactividad
//					MERGE (c)-[t:TIENE]->(v);
//										
					atributos = new HashMap<>(50);
					campos = new ArrayList<>(50);
					
					for (String campo : fila.split("\\t")) {
						// y creamos los nodos y les asignamos los atributos
						campos.add(campo);
					}
					
					// Rellenamos los atributos del nodo Cliente. En este archivo el cliente se obtiene desde
					// los cuatro primeros caracteres de la columna vehicleID 
					valor = campos.get(etiquetas.indexOf("vehicleID")).substring(0, 4);
					
					// Buscamos el identificador del Cliente de la l�nea actual
					// en los nodos de Cliente que ya han sido insertados
					if (!clientes.isEmpty() && clientes.containsKey(valor))
						idNodoCliente = clientes.get(valor);
					
					// Si no ha sido insertado ya este nodo Cliente, lo insertamos
					if (idNodoCliente == -1) {
						atributos.put( "clienteID", valor );

						// Insertamos el nodo Cliente
						idNodoCliente = inserter.createNode( atributos, etiquetaNodoCliente );

						// Guardamos el identificador para evitar crear duplicados
						clientes.put( campos.get(etiquetas.indexOf("vehicleID")).substring(0, 4), idNodoCliente);
						
					}
					
					atributos = new HashMap<>(50);
					
					// Rellenamos los atributos del nodo Vehiculo
					valor = campos.get(etiquetas.indexOf("vehicleID"));
					
					// Buscamos el identificador del Vehiculo de la l�nea actual
					// en los nodos de Vehiculo que ya han sido insertados
					if (!vehiculos.isEmpty() && vehiculos.containsKey(valor))
						idNodoVehiculo = vehiculos.get(valor);
					
					// Si no ha sido insertado ya este nodo Cliente, lo insertamos
					if (idNodoVehiculo == -1) {
						// Rellenamos los atributos del nodo Vehiculo
						atributos.put( "vehiculoID", valor);
						
						valor = campos.get(etiquetas.indexOf("numberPoints"));
						atributos.put( "numberPoints", valor);
						valor = campos.get(etiquetas.indexOf("numberPOI"));
						atributos.put( "numberPOI", valor);
						valor = campos.get(etiquetas.indexOf("maxspeed"));
						atributos.put( "maxspeed", valor);
						valor = campos.get(etiquetas.indexOf("maxodometer"));
						atributos.put( "maxodometer", valor);
						valor = campos.get(etiquetas.indexOf("minodometer"));
						atributos.put( "minodometer", valor);
						valor = campos.get(etiquetas.indexOf("traveledkm"));
						atributos.put( "traveledkm", valor);
						valor = campos.get(etiquetas.indexOf("latitude_max"));
						atributos.put( "latitude_max", valor);
						valor = campos.get(etiquetas.indexOf("latitude_min"));
						atributos.put( "latitude_min", valor);
						valor = campos.get(etiquetas.indexOf("longitude_max"));
						atributos.put( "longitude_max", valor);
						valor = campos.get(etiquetas.indexOf("longitude_min"));
						atributos.put( "longitude_min", valor);
						valor = campos.get(etiquetas.indexOf("fecha_max"));
						atributos.put( "fecha_max", valor);
						valor = campos.get(etiquetas.indexOf("fecha_min"));
						atributos.put( "fecha_min", valor);
						valor = campos.get(etiquetas.indexOf("tiempoenactividad"));
						atributos.put( "tiempoenactividad", valor);
						
						// Buscamos el identificador del Vehiculo de la l�nea actual
						// en los nodos de Vehiculo que ya han sido insertados
						if (!vehiculos.isEmpty() && vehiculos.containsKey(valor))
							idNodoVehiculo = vehiculos.get(valor);
						// Insertamos el nodo Vehiculo
						idNodoVehiculo = inserter.createNode( atributos, etiquetaNodoVehiculo );

						// Guardamos el identificador para evitar crear duplicados
						vehiculos.put( campos.get(etiquetas.indexOf("vehicleID")), idNodoVehiculo);
						
					}
					
					// Buscamos el si existe creada una relacion TIENE entre Cliente y el Vehiculo de la l�nea actual
					// en la lista de relaciones TIENE creadas con anterioridad
					if (!tiene_creados.isEmpty() && tiene_creados.containsKey(idNodoCliente+"_"+idNodoVehiculo))
						idRelacionTiene = tiene_creados.get(idNodoCliente+"_"+idNodoVehiculo);
						
					// Si no ha sido insertado ya esta relacion TIENE, la insertamos
					if (idRelacionTiene == -1) {
						// Insertamos la relacion TIENE
						idRelacionTiene = inserter.createRelationship( idNodoCliente, idNodoVehiculo, tiene, null );
					}

					
					// Guardamos el identificador para evitar crear duplicados
					tiene_creados.put( idNodoCliente+"_"+idNodoVehiculo, idRelacionTiene);
					
				    
					// Reiniciamos 
					idNodoVehiculo = -1;
					idNodoCliente = -1;
					idRelacionTiene = -1;
				}

			} catch (IOException e) {
				e.printStackTrace();
			}
			
		    //////////////////////////////// FINAL DE 01_Vehicle_Stats_2015_01.csv <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

		    ////////////////////////////////	03_gps_positions.txt     /////////////////////////////////////////////


//			USING PERIODIC COMMIT 1000
//			LOAD CSV WITH HEADERS FROM "file:///mnt/hgfs/Downloads/03_gps_positions.txt" AS row
//			FIELDTERMINATOR '\t'
//			WITH row
//			MERGE (c:Cliente {clienteID:row.client_id})
//			MERGE (v:Vehiculo {vehiculoID:row.vehicle_id})
//			MERGE (g:Gps {latitud:row.latitud, longitud:row.longitud})
//			ON CREATE SET g.kilometros_recorridos=row.distance_km, g.delta_t=row.delta_t, g.velocidad=row.velocidad, 
//			g.aceleracion=row.aceleracion, g.orientacion=row.orientacion, g.estadovehiculo=row.estadovehiculoid_delta,	
//			g.estadoviaje=row.estadoviajeid_delta
//			MERGE (v)-[e:HA_ESTADO_EN {fecha:row.fecha}]->(g)
//			MERGE (c)-[t:TIENE ]->(v);
//
//			
		    idNodoCliente = -1;
		    idNodoVehiculo = -1;
		    idNodoGps = -1;
		    etiquetas = new ArrayList<>();
		    
		    // Recorremos todas las filas del archivo que queremos importar a NEO4J
			try (BufferedReader br = 
				new BufferedReader(new FileReader("C:\\Users\\Arturo\\Documents\\BIG DATA\\PRODUCTOS\\companyz\\03_gps_positions.txt")))
			{

				fila = br.readLine();
			
				etiquetas = new ArrayList<>();
				// Leemos los identificadores del las columnas
				for (String etiqueta : fila.split("\\t")) {
					etiquetas.add(etiqueta);
				}
				
				// Leemos las filas separando los valores de las columnas
				while ((fila = br.readLine()) != null) {
	
					atributos = new HashMap<>(50);
					campos = new ArrayList<>(50);
					
					for (String campo : fila.split("\\t")) {
						// y creamos los nodos y les asignamos los atributos
						campos.add(campo);
					}
					
					// Rellenamos los atributos del nodo Cliente. En este archivo el cliente se obtiene de la columna client_id 
					valor = campos.get(etiquetas.indexOf("client_id"));
					
					// Buscamos el identificador del Cliente de la l�nea actual
					// en los nodos de Cliente que ya han sido insertados
					if (!clientes.isEmpty() && clientes.containsKey(valor))
						idNodoCliente = clientes.get(valor);
					
					// Si no ha sido insertado ya este nodo Cliente, lo insertamos
					if (idNodoCliente == -1) {
						atributos.put( "clienteID", valor );

						// Insertamos el nodo Cliente
						idNodoCliente = inserter.createNode( atributos, etiquetaNodoCliente );

						// Guardamos el identificador para evitar crear duplicados
						clientes.put( campos.get(etiquetas.indexOf("client_id")), idNodoCliente);
						
					}
					
					atributos = new HashMap<>(50);
					
					// Rellenamos los atributos del nodo Vehiculo
					valor = campos.get(etiquetas.indexOf("vehicle_id"));
					
					// Buscamos el identificador del Vehiculo de la l�nea actual
					// en los nodos de Vehiculo que ya han sido insertados
					if (!vehiculos.isEmpty() && vehiculos.containsKey(valor))
						idNodoVehiculo = vehiculos.get(valor);

					// Si no ha sido insertado ya este nodo Cliente, lo insertamos
					if (idNodoVehiculo == -1) {
						// Rellenamos los atributos del nodo Vehiculo
						atributos.put( "vehiculoID", valor);
						
						// Insertamos el nodo Vehiculo
						idNodoVehiculo = inserter.createNode( atributos, etiquetaNodoVehiculo );

						// Guardamos el identificador para evitar crear duplicados
						vehiculos.put( campos.get(etiquetas.indexOf("vehicle_id")), idNodoVehiculo);
						
					}

					atributos = new HashMap<>(50);
					
					// Rellenamos los atributos del nodo Gps
					valor = campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud"));
					
					// Buscamos el identificador del punto Gps de la l�nea actual
					// en los nodos de Vehiculo que ya han sido insertados
					if (!gpss.isEmpty() && gpss.containsKey(valor))
						idNodoGps = gpss.get(valor);

					// Si no ha sido insertado ya este nodo Cliente, lo insertamos
					if (idNodoGps == -1) {
						// Rellenamos los atributos del nodo Vehiculo
						valor = campos.get(etiquetas.indexOf("latitud"));
						atributos.put( "latitud", valor);
						valor = campos.get(etiquetas.indexOf("longitud"));
						atributos.put( "longitud", valor);
						atributos.put( "espoi", "No");
						
						// Insertamos el nodo Vehiculo
						idNodoGps = inserter.createNode( atributos, etiquetaNodoGps );

						// Guardamos el identificador para evitar crear duplicados
						gpss.put( campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud")), idNodoGps);
						
					}
					
					// Buscamos el si existe creada una relacion TIENE entre Cliente y el Vehiculo de la l�nea actual
					// en la lista de relaciones TIENE creadas con anterioridad
					if (!tiene_creados.isEmpty() && tiene_creados.containsKey(idNodoCliente+"_"+idNodoVehiculo))
						idRelacionTiene = tiene_creados.get(idNodoCliente+"_"+idNodoVehiculo);
						
					// Si no ha sido insertado ya esta relacion TIENE, la insertamos
					if (idRelacionTiene == -1) {
						// Insertamos la relacion TIENE
						idRelacionTiene = inserter.createRelationship( idNodoCliente, idNodoVehiculo, tiene, null );
					}

					// Guardamos el identificador para evitar crear duplicados
					tiene_creados.put( idNodoCliente+"_"+idNodoVehiculo, idRelacionTiene);

				    
				    // Buscamos el si existe creada una relacion HA_ESTADO_EN entre el Vehiculo y el punto Gps de la l�nea actual
					// en la lista de relaciones HA_ESTADO_EN creadas con anterioridad
					if (!haestadoen_creados.isEmpty() && haestadoen_creados.containsKey(idNodoVehiculo+"_"+idNodoGps))	
						idRelacionHaEstadoEn = haestadoen_creados.get(idNodoVehiculo+"_"+idNodoGps);

					// Si no ha sido insertado ya esta relacion TIENE, la insertamos
					if (idRelacionHaEstadoEn == -1) {
					
					    atributos = new HashMap<>(50);

						valor = campos.get(etiquetas.indexOf("fecha"));
						atributos.put( "fecha", valor);
						valor = campos.get(etiquetas.indexOf("distance_km"));
						atributos.put( "kilometros_recorridos", valor);
						valor = campos.get(etiquetas.indexOf("delta_t"));
						atributos.put( "delta_t", valor);
						valor = campos.get(etiquetas.indexOf("record_id"));
						atributos.put( "record_id", valor);
						valor = campos.get(etiquetas.indexOf("velocidad"));
						atributos.put( "velocidad", valor);
						valor = campos.get(etiquetas.indexOf("aceleracion"));
						atributos.put( "aceleracion", valor);
						valor = campos.get(etiquetas.indexOf("orientacion"));
						atributos.put( "orientacion", valor);
						valor = campos.get(etiquetas.indexOf("estadovehiculoid_delta"));
						atributos.put( "estadovehiculo", valor);
						valor = campos.get(etiquetas.indexOf("estadoviajeid_delta"));
						atributos.put( "estadoviaje", valor);
						
						idRelacionHaEstadoEn = inserter.createRelationship( idNodoVehiculo, idNodoGps, ha_estado_en, atributos );
					
					}

					// Guardamos el identificador para evitar crear duplicados
					haestadoen_creados.put( idNodoVehiculo+"_"+idNodoGps, idRelacionHaEstadoEn);
					
					// Reiniciamos 
					idNodoVehiculo = -1;
					idNodoCliente = -1;
					idNodoGps = -1;
					idRelacionHaEstadoEn = -1;					
				}

			} catch (IOException e) {
				e.printStackTrace();
			}
			
		    //////////////////////////////// FINAL DE 03_gps_positions.txt <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

		    ////////////////////////////////	extract_26_vehicles_poi.txt     ///////////////////////////////////////////////
			//
			// es como 03_gps_positions.txt con menos filas y con un campo nuevo, poi_id que relaciona registros de este archivo
			// con los del archivo extract_26_vehicles_poi.txt
			// el campo espoi vale "Si"
			//
			
//			USING PERIODIC COMMIT 1000
//			LOAD CSV WITH HEADERS FROM "file:///mnt/hgfs/Downloads/extract_26_vehicles_poi.txt" AS row
//			FIELDTERMINATOR '\t'
//			WITH row
//			MERGE (v:Vehiculo {vehiculoID:row.vehicle_id})
//			MERGE (g:Gps {latitud:row.latitud, longitud:row.longitud, espoi:'No'})
//			MERGE (v)-[e:HA_ESTADO_EN]->(g)
//			ON CREATE SET e.fecha=SUBSTRING(row.fechautc,0,16), e.velocidad=row.velocidad, e.orientacion=row.orientacion,
//						  e.poi_id=row.poi_id, e.distance_km=row.distancia_km, e.delta_t=row.delta_t,
//						  e.aceleracion=row.aceleracion, e.estadovehiculoid_delta=row.estadovehiculoid_delta,
//						  e.estadoviajeid_delta=row.estadoviajeid_delta;
			
		    idNodoCliente = -1;
		    idNodoVehiculo = -1;
		    idNodoGps = -1;
		    etiquetas = new ArrayList<>();
		    
		    // Recorremos todas las filas del archivo que queremos importar a NEO4J
			try (BufferedReader br = 
				new BufferedReader(new FileReader("C:\\Users\\Arturo\\Documents\\BIG DATA\\PRODUCTOS\\companyz\\extract_26_vehicles_poi.txt")))
			{

				fila = br.readLine();
			
				etiquetas = new ArrayList<>();
				// Leemos los identificadores del las columnas
				for (String etiqueta : fila.split("\\t")) {
					etiquetas.add(etiqueta);
				}
				
				// Leemos las filas separando los valores de las columnas
				while ((fila = br.readLine()) != null) {
	
					atributos = new HashMap<>(50);
					campos = new ArrayList<>(50);
					
					for (String campo : fila.split("\\t")) {
						// y creamos los nodos y les asignamos los atributos
						campos.add(campo);
					}

					atributos = new HashMap<>(50);
					
					// Rellenamos los atributos del nodo Vehiculo
					valor = campos.get(etiquetas.indexOf("vehicle_id"));
					
					// Buscamos el identificador del vehiculo de la l�nea actual
					// en los nodos de Vehiculo que ya han sido insertados
					if (!vehiculos.isEmpty() && vehiculos.containsKey(valor))
						idNodoVehiculo = vehiculos.get(valor);

					// Si no ha sido insertado ya este nodo Cliente, lo insertamos
					if (idNodoVehiculo == -1) {
						// Rellenamos los atributos del nodo Vehiculo
						atributos.put( "vehiculoID", valor);
						
						// Insertamos el nodo Vehiculo
						idNodoVehiculo = inserter.createNode( atributos, etiquetaNodoVehiculo );

						// Guardamos el identificador para evitar crear duplicados
						vehiculos.put( campos.get(etiquetas.indexOf("vehicle_id")), idNodoVehiculo);
						
					}

					atributos = new HashMap<>(50);
					
					// Rellenamos los atributos del nodo Gps
					valor = campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud"));
					
					// Buscamos el identificador del vehiculo de la l�nea actual
					// en los nodos de Vehiculo que ya han sido insertados
					if (!gpss.isEmpty() && gpss.containsKey(valor))
						idNodoGps = gpss.get(valor);

					// Si no ha sido insertado ya este nodo Cliente, lo insertamos
					if (idNodoGps == -1) {
						// Rellenamos los atributos del nodo Vehiculo
						valor = campos.get(etiquetas.indexOf("latitud"));
						atributos.put( "latitud", valor);
						valor = campos.get(etiquetas.indexOf("longitud"));
						atributos.put( "longitud", valor);
						atributos.put( "espoi", "Si");
												
						// Insertamos el nodo Vehiculo
						idNodoGps = inserter.createNode( atributos, etiquetaNodoGps );

						// Guardamos el identificador para evitar crear duplicados
						gpss.put( campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud")), idNodoGps);
						
					}

				    // Buscamos el si existe creada una relacion HA_ESTADO_EN entre el Vehiculo y el punto Gps de la l�nea actual
					// en la lista de relaciones HA_ESTADO_EN creadas con anterioridad
					if (!haestadoen_creados.isEmpty() && haestadoen_creados.containsKey(idNodoVehiculo+"_"+idNodoGps))					
						idRelacionHaEstadoEn = haestadoen_creados.get(idNodoVehiculo+"_"+idNodoGps);

					// Si no ha sido insertado ya esta relacion TIENE, la insertamos
					if (idRelacionHaEstadoEn == -1) {
					    atributos = new HashMap<>(50);

						valor = campos.get(etiquetas.indexOf("fechautc"));
						atributos.put( "fecha", valor);
						valor = campos.get(etiquetas.indexOf("velocidad"));
						atributos.put( "velocidad", valor);
						valor = campos.get(etiquetas.indexOf("orientacion"));
						atributos.put( "orientacion", valor);
						valor = campos.get(etiquetas.indexOf("aceleracion"));
						atributos.put( "aceleracion", valor);
						valor = campos.get(etiquetas.indexOf("poi_id"));
						atributos.put( "poi_id", valor);
						valor = campos.get(etiquetas.indexOf("distancia_km"));
						atributos.put( "distancia_km", valor);
						valor = campos.get(etiquetas.indexOf("delta_t"));
						atributos.put( "delta_t", valor);
						valor = campos.get(etiquetas.indexOf("estadovehiculoid_delta"));
						atributos.put( "estadovehiculo", valor);
						valor = campos.get(etiquetas.indexOf("estadoviajeid_delta"));
						atributos.put( "estadoviaje", valor);
						
						idRelacionHaEstadoEn = inserter.createRelationship( idNodoVehiculo, idNodoGps, ha_estado_en, atributos );					
					
					}

					// Guardamos el identificador para evitar crear duplicados
					haestadoen_creados.put( idNodoVehiculo+"_"+idNodoGps, idRelacionHaEstadoEn);
				    
					// Reiniciamos 
					idNodoVehiculo = -1;
					idNodoCliente = -1;
					idNodoGps = -1;
					idRelacionHaEstadoEn = -1;
				}

			} catch (IOException e) {
				e.printStackTrace();
			}
			
		    //////////////////////////////// FINAL DE extract_26_vehicles_poi.txt <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

		    ////////////////////////////////	extract_26_vehicles_poi.txt     ///////////////////////////////////////////////
			//
			// es como el anterior, pero crea nodos POI
			//
			
//			USING PERIODIC COMMIT 1000
//			LOAD CSV WITH HEADERS FROM "file:///mnt/hgfs/Downloads/extract_26_vehicles_poi.txt" AS row
//			FIELDTERMINATOR '\t'
//			WITH row
//			MERGE (v:Vehiculo {vehiculoID:row.vehicle_id})
//			MERGE (p:Poi {latitud:row.latitud, longitud:row.longitud})
//			MERGE (v)-[e:HA_ESTADO_EN_POI]->(p)
//			ON CREATE SET e.fecha=SUBSTRING(row.fechautc,0,16), e.velocidad=row.velocidad, e.orientacion=row.orientacion,
//						  e.poi_id=row.poi_id, e.distance_km=row.distancia_km, e.delta_t=row.delta_t,
//						  e.aceleracion=row.aceleracion, e.estadovehiculoid_delta=row.estadovehiculoid_delta,
//						  e.estadoviajeid_delta=row.estadoviajeid_delta;
				
		    idNodoCliente = -1;
		    idNodoVehiculo = -1;
		    idNodoPoi = -1;
		    etiquetas = new ArrayList<>();
		    
		    // Recorremos todas las filas del archivo que queremos importar a NEO4J
			try (BufferedReader br = 
				new BufferedReader(new FileReader("C:\\Users\\Arturo\\Documents\\BIG DATA\\PRODUCTOS\\companyz\\extract_26_vehicles_poi.txt")))
			{

				fila = br.readLine();
			
				etiquetas = new ArrayList<>();
				// Leemos los identificadores del las columnas
				for (String etiqueta : fila.split("\\t")) {
					etiquetas.add(etiqueta);
				}
				
				// Leemos las filas separando los valores de las columnas
				while ((fila = br.readLine()) != null) {
	
					atributos = new HashMap<>(50);
					campos = new ArrayList<>(50);
					
					for (String campo : fila.split("\\t")) {
						// y creamos los nodos y les asignamos los atributos
						campos.add(campo);
					}

					atributos = new HashMap<>(50);
					
					// Rellenamos los atributos del nodo Vehiculo
					valor = campos.get(etiquetas.indexOf("vehicle_id"));
					
					// Buscamos el identificador del vehiculo de la l�nea actual
					// en los nodos de Vehiculo que ya han sido insertados
					if (!vehiculos.isEmpty() && vehiculos.containsKey(valor))
						idNodoVehiculo = vehiculos.get(valor);

					// Si no ha sido insertado ya este nodo Cliente, lo insertamos
					if (idNodoVehiculo == -1) {
						// Rellenamos los atributos del nodo Vehiculo
						atributos.put( "vehiculoID", valor);
						
						// Insertamos el nodo Vehiculo
						idNodoVehiculo = inserter.createNode( atributos, etiquetaNodoVehiculo );

						// Guardamos el identificador para evitar crear duplicados
						vehiculos.put( campos.get(etiquetas.indexOf("vehicle_id")), idNodoVehiculo);
						
					}

					atributos = new HashMap<>(50);
					
					// Rellenamos los atributos del nodo Poi
					valor = campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud"));
					
					// Buscamos el identificador del Poi de la l�nea actual
					// en los nodos de Poi que ya han sido insertados
					if (!pois.isEmpty() && pois.containsKey(valor))
						idNodoPoi = pois.get(valor);

					// Si no ha sido insertado ya este nodo Poi, lo insertamos
					if (idNodoPoi == -1) {
						// Rellenamos los atributos del nodo Poi
						valor = campos.get(etiquetas.indexOf("latitud"));
						atributos.put( "latitud", valor);
						valor = campos.get(etiquetas.indexOf("longitud"));
						atributos.put( "longitud", valor);
												
						// Insertamos el nodo Poi
						idNodoPoi = inserter.createNode( atributos, etiquetaNodoPOI );

						// Guardamos el identificador para evitar crear duplicados
						pois.put( campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud")), idNodoPoi);
						
					}

				    // Buscamos el si existe creada una relacion HA_ESTADO_EN_POI entre el Vehiculo y el Poi de la l�nea actual
					// en la lista de relaciones HA_ESTADO_EN_POI creadas con anterioridad
					if (!haestadoenpoi_creados.isEmpty() && haestadoenpoi_creados.containsKey(idNodoVehiculo+"_"+idNodoPoi))					
						idRelacionHaEstadoEnPoi = haestadoenpoi_creados.get(idNodoVehiculo+"_"+idNodoPoi);

					// Si no ha sido insertado ya esta relacion HA_ESTADO_EN_POI, la insertamos
					if (idRelacionHaEstadoEnPoi == -1) {
					    atributos = new HashMap<>(50);

						valor = campos.get(etiquetas.indexOf("fechautc"));
						atributos.put( "fecha", valor);
						valor = campos.get(etiquetas.indexOf("velocidad"));
						atributos.put( "velocidad", valor);
						valor = campos.get(etiquetas.indexOf("orientacion"));
						atributos.put( "orientacion", valor);
						valor = campos.get(etiquetas.indexOf("aceleracion"));
						atributos.put( "aceleracion", valor);
						valor = campos.get(etiquetas.indexOf("poi_id"));
						atributos.put( "poi_id", valor);
						valor = campos.get(etiquetas.indexOf("distancia_km"));
						atributos.put( "distancia_km", valor);
						valor = campos.get(etiquetas.indexOf("delta_t"));
						atributos.put( "delta_t", valor);
						valor = campos.get(etiquetas.indexOf("estadovehiculoid_delta"));
						atributos.put( "estadovehiculo", valor);
						valor = campos.get(etiquetas.indexOf("estadoviajeid_delta"));
						atributos.put( "estadoviaje", valor);
						
						idRelacionHaEstadoEnPoi = inserter.createRelationship( idNodoVehiculo, idNodoPoi, ha_estado_en_poi, atributos );					
					
					}

					// Guardamos el identificador para evitar crear duplicados
					haestadoenpoi_creados.put( idNodoVehiculo+"_"+idNodoPoi, idRelacionHaEstadoEnPoi);
				    
					// Reiniciamos 
					idNodoVehiculo = -1;
					idNodoCliente = -1;
					idNodoPoi = -1;
					idRelacionHaEstadoEnPoi = -1;
				}

			} catch (IOException e) {
				e.printStackTrace();
			}
			
		    //////////////////////////////// FINAL DE extract_26_vehicles_poi.txt <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
			
			
			
		    ////////////////////////////////	extract_26_vehicles.txt     ///////////////////////////////////////////////
			//
			// es como 03_gps_positions.txt con menos filas y con un campo nuevo, poi_id que relaciona registros de este archivo
			// con los del archivo extract_26_vehicles_poi.txt
			// el campo espoi vale "No"
			//
			
//			USING PERIODIC COMMIT 1000
//			LOAD CSV WITH HEADERS FROM "file:///mnt/hgfs/Downloads/extract_26_vehicles.txt" AS row
//			FIELDTERMINATOR '\t'
//			WITH row
//			MERGE (v:Vehiculo {vehiculoID:row.vehicle_id})
//			MERGE (g:Gps {latitud:row.latitud, longitud:row.longitud, espoi:'No'})
//			MERGE (v)-[e:HA_ESTADO_EN]->(g)
//			ON CREATE SET e.fecha=SUBSTRING(row.fechautc,0,16), e.velocidad=row.velocidad, e.orientacion=row.orientacion,
//						  e.poi_id=row.poi_id, e.distance_km=row.distancia_km, e.delta_t=row.delta_t,
//						  e.aceleracion=row.aceleracion, e.estadovehiculoid_delta=row.estadovehiculoid_delta,
//						  e.estadoviajeid_delta=row.estadoviajeid_delta;
			
		    idNodoCliente = -1;
		    idNodoVehiculo = -1;
		    idNodoGps = -1;
		    etiquetas = new ArrayList<>();
		    
		    // Recorremos todas las filas del archivo que queremos importar a NEO4J
			try (BufferedReader br = 
				new BufferedReader(new FileReader("C:\\Users\\Arturo\\Documents\\BIG DATA\\PRODUCTOS\\companyz\\extract_26_vehicles.txt")))
			{

				fila = br.readLine();
			
				etiquetas = new ArrayList<>();
				// Leemos los identificadores del las columnas
				for (String etiqueta : fila.split("\\t")) {
					etiquetas.add(etiqueta);
				}
				
				// Leemos las filas separando los valores de las columnas
				while ((fila = br.readLine()) != null) {
	
					atributos = new HashMap<>(50);
					campos = new ArrayList<>(50);
					
					for (String campo : fila.split("\\t")) {
						// y creamos los nodos y les asignamos los atributos
						campos.add(campo);
					}

					atributos = new HashMap<>(50);
					
					// Rellenamos los atributos del nodo Vehiculo
					valor = campos.get(etiquetas.indexOf("vehicle_id"));
					
					// Buscamos el identificador del vehiculo de la l�nea actual
					// en los nodos de Vehiculo que ya han sido insertados
					if (!vehiculos.isEmpty() && vehiculos.containsKey(valor))
						idNodoVehiculo = vehiculos.get(valor);

					// Si no ha sido insertado ya este nodo Cliente, lo insertamos
					if (idNodoVehiculo == -1) {
						// Rellenamos los atributos del nodo Vehiculo
						atributos.put( "vehiculoID", valor);
						
						// Insertamos el nodo Vehiculo
						idNodoVehiculo = inserter.createNode( atributos, etiquetaNodoVehiculo );

						// Guardamos el identificador para evitar crear duplicados
						vehiculos.put( campos.get(etiquetas.indexOf("vehicle_id")), idNodoVehiculo);
						
					}

					atributos = new HashMap<>(50);
					
					// Rellenamos los atributos del nodo Gps
					valor = campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud"));
					
					// Buscamos el identificador del vehiculo de la l�nea actual
					// en los nodos de Vehiculo que ya han sido insertados
					if (!gpss.isEmpty() && gpss.containsKey(valor))
						idNodoGps = gpss.get(valor);

					// Si no ha sido insertado ya este nodo Cliente, lo insertamos
					if (idNodoGps == -1) {
						// Rellenamos los atributos del nodo Vehiculo
						valor = campos.get(etiquetas.indexOf("latitud"));
						atributos.put( "latitud", valor);
						valor = campos.get(etiquetas.indexOf("longitud"));
						atributos.put( "longitud", valor);
						atributos.put( "espoi", "No");
												
						// Insertamos el nodo Vehiculo
						idNodoGps = inserter.createNode( atributos, etiquetaNodoGps );

						// Guardamos el identificador para evitar crear duplicados
						gpss.put( campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud")), idNodoGps);
						
					}

				    // Buscamos el si existe creada una relacion HA_ESTADO_EN entre el Vehiculo y el punto Gps de la l�nea actual
					// en la lista de relaciones HA_ESTADO_EN creadas con anterioridad
					if (!haestadoen_creados.isEmpty() && haestadoen_creados.containsKey(idNodoVehiculo+"_"+idNodoGps))					
						idRelacionHaEstadoEn = haestadoen_creados.get(idNodoVehiculo+"_"+idNodoGps);
					
					// Si no ha sido insertado ya esta relacion TIENE, la insertamos
					if (idRelacionHaEstadoEn == -1) {
					    atributos = new HashMap<>(50);

						valor = campos.get(etiquetas.indexOf("fechautc"));
						atributos.put( "fecha", valor);
						valor = campos.get(etiquetas.indexOf("velocidad"));
						atributos.put( "velocidad", valor);
						valor = campos.get(etiquetas.indexOf("orientacion"));
						atributos.put( "orientacion", valor);
						valor = campos.get(etiquetas.indexOf("aceleracion"));
						atributos.put( "aceleracion", valor);
						valor = campos.get(etiquetas.indexOf("poi_id"));
						atributos.put( "poi_id", valor);
						valor = campos.get(etiquetas.indexOf("distancia_km"));
						atributos.put( "distancia_km", valor);
						valor = campos.get(etiquetas.indexOf("delta_t"));
						atributos.put( "delta_t", valor);
						valor = campos.get(etiquetas.indexOf("estadovehiculoid_delta"));
						atributos.put( "estadovehiculoid_delta", valor);
						valor = campos.get(etiquetas.indexOf("estadoviajeid_delta"));
						atributos.put( "estadoviajeid_delta", valor);
						
						idRelacionHaEstadoEn = inserter.createRelationship( idNodoVehiculo, idNodoGps, ha_estado_en, atributos );
					
					}

					// Guardamos el identificador para evitar crear duplicados
					haestadoen_creados.put( idNodoVehiculo+"_"+idNodoGps, idRelacionHaEstadoEn);
				
					
					// Reiniciamos 
					idNodoVehiculo = -1;
					idNodoCliente = -1;
					idNodoGps = -1;
					idRelacionHaEstadoEn = -1;
				}

			} catch (IOException e) {
				e.printStackTrace();
			}
			
		    //////////////////////////////// FINAL DE extract_26_vehicles.txt <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

		    ////////////////////////////////	extract_neo4j_all_header.csv     /////////////////////////////////////////////

//			USING PERIODIC COMMIT 1000
//			LOAD CSV WITH HEADERS FROM "file:///mnt/hgfs/Downloads/extract_neo4j_all_header.csv" AS row
//			FIELDTERMINATOR '\t'
//			WITH row
//			MERGE (v:Vehiculo {vehiculoID:row.vehicle_id})
//			MERGE (u:Ubicacion {latitud:row.latitud, longitud:row.longitud})
//			ON CREATE SET u.localizacion=COALESCE(row.localizacion,'')
//			MERGE (v)-[e:HA_ESTADO_EN]->(u)
//			ON CREATE SET e.fecha=SUBSTRING(row.fechautc,0,16), e.velocidad=row.velocidad, e.orientacion=row.orientacion;

//
//		    idNodoCliente = -1;
//		    idNodoVehiculo = -1;
//		    idNodoUbicacion = -1;
//		    etiquetas = new ArrayList<>();
//		    
//		    // Recorremos todas las filas del archivo que queremos importar a NEO4J
//			try (BufferedReader br = 
//				new BufferedReader(new FileReader("C:\\Users\\Arturo\\Documents\\BIG DATA\\PRODUCTOS\\companyz\\extract_neo4j_all_header.csv")))
//			{
//
//				fila = br.readLine();
//			
//				etiquetas = new ArrayList<>();
//				// Leemos los identificadores del las columnas
//				for (String etiqueta : fila.split("\\t")) {
//					etiquetas.add(etiqueta);
//				}
//				
//				// Leemos las filas separando los valores de las columnas
//				while ((fila = br.readLine()) != null) {
//	
//					atributos = new HashMap<>(50);
//					campos = new ArrayList<>(50);
//					
//					for (String campo : fila.split("\\t")) {
//						// y creamos los nodos y les asignamos los atributos
//						campos.add(campo);
//					}
//
//					atributos = new HashMap<>(50);
//					
//					// Rellenamos los atributos del nodo Vehiculo
//					valor = campos.get(etiquetas.indexOf("vehicle_id"));
//					
//					// Buscamos el identificador del vehiculo de la l�nea actual
//					// en los nodos de Vehiculo que ya han sido insertados
//					if (!vehiculos.isEmpty() && vehiculos.containsKey(valor))
//						idNodoVehiculo = vehiculos.get(valor);
//
//					// Si no ha sido insertado ya este nodo Cliente, lo insertamos
//					if (idNodoVehiculo == -1) {
//						// Rellenamos los atributos del nodo Vehiculo
//						atributos.put( "vehiculoID", valor);
//
//						// Insertamos el nodo Vehiculo
//						idNodoVehiculo = inserter.createNode( atributos, etiquetaNodoVehiculo );
//
//						// Guardamos el identificador para evitar crear duplicados
//						vehiculos.put( valor, idNodoVehiculo);
//					}
//
//					atributos = new HashMap<>(50);
//					
//					// Rellenamos los atributos del nodo Ubicacion
//					valor = campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud"));
//					
//					// Buscamos el identificador del vehiculo de la l�nea actual
//					// en los nodos de Vehiculo que ya han sido insertados
//					if (!ubicaciones.isEmpty() && ubicaciones.containsKey(valor))
//						idNodoUbicacion = ubicaciones.get(valor);
//
//					// Si no ha sido insertado ya este nodo Cliente, lo insertamos
//					if (idNodoUbicacion == -1) {
//						// Rellenamos los atributos del nodo Vehiculo
//						valor = campos.get(etiquetas.indexOf("latitud"));
//						atributos.put( "latitud", valor);
//						valor = campos.get(etiquetas.indexOf("longitud"));
//						atributos.put( "longitud", valor);
//						valor = campos.get(etiquetas.indexOf("localizacion"));
//						atributos.put( "localizacion", valor);
//						
//						// Insertamos el nodo Vehiculo
//						idNodoUbicacion = inserter.createNode( atributos, etiquetaNodoUbicacion );
//
//						// Guardamos el identificador para evitar crear duplicados
//						ubicaciones.put( campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud")), idNodoUbicacion);
//					}
//									    
//				    atributos = new HashMap<>(50);
//
//					valor = campos.get(etiquetas.indexOf("fechautc"));
//					atributos.put( "fecha", valor);
//					valor = campos.get(etiquetas.indexOf("velocidad"));
//					atributos.put( "velocidad", valor);
//					valor = campos.get(etiquetas.indexOf("orientacion"));
//					atributos.put( "orientacion", valor);
//					
//				    inserter.createRelationship( idNodoVehiculo, idNodoUbicacion, paso_por, atributos );
//				    
//					// Reiniciamos 
//					idNodoVehiculo = -1;
//					idNodoCliente = -1;
//					idNodoUbicacion = -1;
				}

			} catch (IOException e) {
				e.printStackTrace();
			}

		    //////////////////////////////// FINAL DE extract_neo4j_all_header.csv <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*/				
			
		// AL FINAL DE TODA LA CARGA, CERRAMOS EL PUNTERO DE LA BASE DE DATOS
		inserter.shutdown();
		
		// calcular tiempo transcurrido
		long fin = System.currentTimeMillis();
		
	    System.out.println("Segundos: "+(fin-inicio)/1000);		
	}

}
