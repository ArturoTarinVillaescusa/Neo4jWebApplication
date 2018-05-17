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

public class CopyOfPruebaBatchInserter {

	
	// http://maxdemarzi.com/2012/02/28/batch-importer-part-1/
	// http://maxdemarzi.com/2012/02/28/batch-importer-part-2/
	// http://maxdemarzi.com/2012/07/02/batch-importer-part-3/
	// https://github.com/jexp/batch-import
	public static void main(String[] args) {
		BatchInserter inserter = null;
		try
		{
		    List<List<String>> registros = new ArrayList<>();
		    List<String> campos = new ArrayList<>();
		    List<String> etiquetas = new ArrayList<>();
		    Map<String, Object> atributos = new HashMap<>();
		    
		    // Guardamos los identificadores de los nodos para evitar crear duplicados de una misma clave
		    Map<String, Long> clientes = new HashMap<>();
		    Map<String, Long> vehiculos = new HashMap<>();
		    Map<String, Long> gpss = new HashMap<>();
		    Map<String, Long> ubicaciones = new HashMap<>();

			// Creamos una nueva base de datos Neo4j
	        File graphDb = new File("C:\\Users\\Arturo\\Documents\\DISCO_CLUSTER_NEO4J\\companyyv5.graphdb");
	        if (graphDb.exists()) {
	            try {
					FileUtils.deleteRecursively(graphDb);
	            	// FileUtils.renameFile(graphDb, new File(graphDb.getName()+"Copia-"+System.currentTimeMillis()));
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
	        }
		    inserter = BatchInserters.inserter( graphDb.getAbsolutePath() );

		    ////////////////////////////////	01_Vehicle_Stats_2015_01.csv     /////////////////////////////////////////////
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

		    Label etiquetaNodoUbicacion = DynamicLabel.label( "Ubicacion" );
		    long idNodoUbicacion = -1;
			// CREATE INDEX ON :Ubicacion(latitud);
		    inserter.createDeferredSchemaIndex( etiquetaNodoUbicacion ).on( "latitud" ).create();
			// CREATE INDEX ON :Ubicacion(longitud);
		    inserter.createDeferredSchemaIndex( etiquetaNodoUbicacion ).on( "longitud" ).create();
		    
		    RelationshipType tiene = DynamicRelationshipType.withName( "TIENE" );
		    RelationshipType ha_estado_en = DynamicRelationshipType.withName( "HA_ESTADO_EN" );
		    RelationshipType paso_por = DynamicRelationshipType.withName( "PASO_POR" );

			String fila;
			String valor;
		    
		    // Recorremos todas las filas del archivo que queremos importar a NEO4J
			try (BufferedReader br = 
				new BufferedReader(new FileReader("C:\\Users\\Arturo\\Documents\\BIG DATA\\CLIENTES\\companyy\\01_Vehicle_Stats_2015_01.csv")))
			{


				fila = br.readLine();
			
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
					
					// Rellenamos los atributos del nodo Cliente. En este archivo el cliente se obtiene desde
					// los cuatro primeros caracteres de la columna vehicleID 
					valor = campos.get(etiquetas.indexOf("vehicleID")).substring(0, 4);
					
					// Buscamos el identificador del cliente de la l�nea actual
					// en los nodos de Cliente que ya han sido insertados
					if (!clientes.isEmpty() && clientes.containsKey(valor))
						idNodoCliente = clientes.get(valor);
					
					// Si no ha sido insertado ya este nodo Cliente, lo insertamos
					if (idNodoCliente == -1) {
						atributos.put( "clienteID", valor );
						
						// Insertamos el nodo Cliente
						idNodoCliente = inserter.createNode( atributos, etiquetaNodoCliente );
						
						// Guardamos el identificador para evitar crear duplicados
						clientes.put( valor, idNodoCliente);
						
					}
					
					atributos = new HashMap<>(50);
					
					// Rellenamos los atributos del nodo Vehiculo
					valor = campos.get(etiquetas.indexOf("vehicleID"));
					
					// Buscamos el identificador del vehiculo de la l�nea actual
					// en los nodos de Vehiculo que ya han sido insertados
					if (!vehiculos.isEmpty() && vehiculos.containsKey(valor))
						idNodoVehiculo = vehiculos.get(valor);
					
					/*
					USING PERIODIC COMMIT 1000
					LOAD CSV WITH HEADERS FROM "file:///mnt/hgfs/Downloads/01_Vehicle_Stats_2015_01.csv" AS row
					FIELDTERMINATOR '\t'
					WITH row
					MERGE (c:Cliente {clienteID:SUBSTRING(row.vehicleID,0,4)})
					MERGE (v:Vehiculo {vehiculoID:row.vehicleID})
					ON CREATE SET 	v.numberPoints=row.numberPoints, v.numberPOI=row.numberPOI,
									v.maxspeed=row.maxspeed, v.maxodometer=row.maxodometer, v.minodometer=row.minodometer,
									v.traveledkm=row.traveledkm, v.latitude_max=row.latitude_max,
									v.latitude_min=row.latitude_min, v.longitude_max=row.longitude_max,
									v.longitude_min=row.longitude_min, v.fecha_max=row.fecha_max, v.fecha_min=row.fecha_min,
									v.tiempoenactividad=row.tiempoenactividad
					MERGE (c)-[t:TIENE]->(v);
				 */
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
						
						// Insertamos el nodo Vehiculo
						idNodoVehiculo = inserter.createNode( atributos, etiquetaNodoVehiculo );

						// Guardamos el identificador para evitar crear duplicados
						vehiculos.put( valor, idNodoVehiculo);
					}
					
				    inserter.createRelationship( idNodoCliente, idNodoVehiculo, tiene, null );
				    
					// Reiniciamos 
					idNodoVehiculo = -1;
					// Reiniciamos 
					idNodoCliente = -1;
				}

			} catch (IOException e) {
				e.printStackTrace();
			}
			
		    //////////////////////////////// FINAL DE 01_Vehicle_Stats_2015_01.csv <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

		    ////////////////////////////////	03_gps_positions.txt     /////////////////////////////////////////////

			/*
			USING PERIODIC COMMIT 1000
			LOAD CSV WITH HEADERS FROM "file:///mnt/hgfs/Downloads/03_gps_positions.txt" AS row
			FIELDTERMINATOR '\t'
			WITH row
			MERGE (c:Cliente {clienteID:row.client_id})
			MERGE (v:Vehiculo {vehiculoID:row.vehicle_id})
			MERGE (g:Gps {latitud:row.latitud, longitud:row.longitud})
			ON CREATE SET g.kilometros_recorridos=row.distance_km, g.delta_t=row.delta_t, g.velocidad=row.velocidad, 
			g.aceleracion=row.aceleracion, g.orientacion=row.orientacion, g.estadovehiculo=row.estadovehiculoid_delta,	
			g.estadoviaje=row.estadoviajeid_delta
			MERGE (v)-[e:HA_ESTADO_EN {fecha:row.fecha}]->(g)
			MERGE (c)-[t:TIENE ]->(v);
		 */
			
		    idNodoCliente = -1;
		    idNodoVehiculo = -1;
		    idNodoGps = -1;
		    etiquetas = new ArrayList<>();
		    
		    // Recorremos todas las filas del archivo que queremos importar a NEO4J
			try (BufferedReader br = 
				new BufferedReader(new FileReader("C:\\Users\\Arturo\\Documents\\BIG DATA\\CLIENTES\\companyy\\03_gps_positions.txt")))
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
					
					// Buscamos el identificador del cliente de la l�nea actual
					// en los nodos de Cliente que ya han sido insertados
					if (!clientes.isEmpty() && clientes.containsKey(valor))
						idNodoCliente = clientes.get(valor);
					
					// Si no ha sido insertado ya este nodo Cliente, lo insertamos
					if (idNodoCliente == -1) {
						atributos.put( "clienteID", valor );
						
						// Insertamos el nodo Cliente
						idNodoCliente = inserter.createNode( atributos, etiquetaNodoCliente );
						
						// Guardamos el identificador para evitar crear duplicados
						clientes.put( valor, idNodoCliente);
						
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
						vehiculos.put( valor, idNodoVehiculo);
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
						
						// Insertamos el nodo Vehiculo
						idNodoGps = inserter.createNode( atributos, etiquetaNodoGps );

						// Guardamos el identificador para evitar crear duplicados
						gpss.put( campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud")), idNodoGps);
					}
					
				    inserter.createRelationship( idNodoCliente, idNodoVehiculo, tiene, null );
				    
				    atributos = new HashMap<>(50);

					valor = campos.get(etiquetas.indexOf("distance_km"));
					atributos.put( "kilometros_recorridos", valor);
					valor = campos.get(etiquetas.indexOf("delta_t"));
					atributos.put( "delta_t", valor);
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
					
				    inserter.createRelationship( idNodoVehiculo, idNodoGps, ha_estado_en, atributos );
				    
					// Reiniciamos 
					idNodoVehiculo = -1;
					idNodoCliente = -1;
					idNodoGps = -1;
				}

			} catch (IOException e) {
				e.printStackTrace();
			}
			
		    //////////////////////////////// FINAL DE 03_gps_positions.txt <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

		    ////////////////////////////////	extract_neo4j_all_header.csv     /////////////////////////////////////////////
			/*
			USING PERIODIC COMMIT 1000
			LOAD CSV WITH HEADERS FROM "file:///mnt/hgfs/Downloads/extract_neo4j_all_header.csv" AS row
			FIELDTERMINATOR '\t'
			WITH row
			MERGE (v:Vehiculo {vehiculoID:row.vehicle_id})
			MERGE (u:Ubicacion {latitud:row.latitud, longitud:row.longitud})
			ON CREATE SET u.localizacion=COALESCE(row.localizacion,'')
			MERGE (v)-[e:HA_ESTADO_EN]->(u)
			ON CREATE SET e.fecha=SUBSTRING(row.fechautc,0,16), e.velocidad=row.velocidad, e.orientacion=row.orientacion;
			 */
		    idNodoCliente = -1;
		    idNodoVehiculo = -1;
		    idNodoUbicacion = -1;
		    etiquetas = new ArrayList<>();
		    
		    // Recorremos todas las filas del archivo que queremos importar a NEO4J
			try (BufferedReader br = 
				new BufferedReader(new FileReader("C:\\Users\\Arturo\\Documents\\BIG DATA\\CLIENTES\\companyy\\extract_neo4j_all_header.csv")))
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
						vehiculos.put( valor, idNodoVehiculo);
					}

					atributos = new HashMap<>(50);
					
					// Rellenamos los atributos del nodo Ubicacion
					valor = campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud"));
					
					// Buscamos el identificador del vehiculo de la l�nea actual
					// en los nodos de Vehiculo que ya han sido insertados
					if (!ubicaciones.isEmpty() && ubicaciones.containsKey(valor))
						idNodoUbicacion = ubicaciones.get(valor);

					// Si no ha sido insertado ya este nodo Cliente, lo insertamos
					if (idNodoUbicacion == -1) {
						// Rellenamos los atributos del nodo Vehiculo
						valor = campos.get(etiquetas.indexOf("latitud"));
						atributos.put( "latitud", valor);
						valor = campos.get(etiquetas.indexOf("longitud"));
						atributos.put( "longitud", valor);
						valor = campos.get(etiquetas.indexOf("localizacion"));
						atributos.put( "localizacion", valor);
						
						// Insertamos el nodo Vehiculo
						idNodoUbicacion = inserter.createNode( atributos, etiquetaNodoUbicacion );

						// Guardamos el identificador para evitar crear duplicados
						ubicaciones.put( campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud")), idNodoUbicacion);
					}
									    
				    atributos = new HashMap<>(50);

					valor = campos.get(etiquetas.indexOf("fechautc"));
					atributos.put( "fecha", valor);
					valor = campos.get(etiquetas.indexOf("velocidad"));
					atributos.put( "velocidad", valor);
					valor = campos.get(etiquetas.indexOf("orientacion"));
					atributos.put( "orientacion", valor);
					
				    inserter.createRelationship( idNodoVehiculo, idNodoUbicacion, paso_por, atributos );
				    
					// Reiniciamos 
					idNodoVehiculo = -1;
					idNodoCliente = -1;
					idNodoUbicacion = -1;
				}

			} catch (IOException e) {
				e.printStackTrace();
			}
			
		    //////////////////////////////// FINAL DE extract_neo4j_all_header.csv <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
			
		    Label personLabel = DynamicLabel.label( "Person" );
		    inserter.createDeferredSchemaIndex( personLabel ).on( "name" ).create();

		    Map<String, Object> properties = new HashMap<>();

		    properties.put( "name", "Mattias" );
		    long mattiasNode = inserter.createNode( properties, personLabel );

		    properties.put( "name", "Chris" );
		    long chrisNode = inserter.createNode( properties, personLabel );

		    RelationshipType knows = DynamicRelationshipType.withName( "KNOWS" );
		    inserter.createRelationship( mattiasNode, chrisNode, knows, null );
		} catch (Exception e) {
		        inserter.shutdown();
		}
		inserter.shutdown();
	}

}
