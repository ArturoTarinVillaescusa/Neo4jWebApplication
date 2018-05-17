package bulkloaders;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
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

public class BatchInserter_companyz_Heuristic_Neo4j {

	public static void main(String[] args) {
		BatchInserter inserter = null;
		
		// guardar timestamp inicio
		long inicio = System.currentTimeMillis();
		  
		try
		{
		    List<String> campos = new ArrayList<>();
		    List<String> etiquetas = new ArrayList<>();
		    Map<String, Object> atributos = new HashMap<>();
		    
		    // Guardamos los identificadores de los nodos para evitar crear duplicados de una misma clave
		    Map<String, Long> usuarios = new HashMap<>();
		    Map<String, Long> clientes = new HashMap<>();
		    Map<String, Long> vehiculos = new HashMap<>();
		    Map<String, Long> puede_ver_creados = new HashMap<>();
		    Map<String, Long> tiene_creados = new HashMap<>();

			// Creamos una nueva base de datos Neo4j
	        File graphDb = new File("C:\\Users\\Arturo\\Documents\\DISCO_CLUSTER\\companyzv7.graphdb");
	        if (graphDb.exists()) {
	            try {
					FileUtils.deleteRecursively(graphDb);
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

		    // Nodos e �ndices
		    Label etiquetaNodoUsuario = DynamicLabel.label( "Usuario" );
		    long idNodoUsuario = -1;

		    Label etiquetaNodoCliente = DynamicLabel.label( "Cliente" );
		    long idNodoCliente = -1;
			// CREATE INDEX ON :Cliente(client_id);
		    inserter.createDeferredSchemaIndex( etiquetaNodoCliente ).on( "client_id" ).create();

		    Label etiquetaNodoVehiculo = DynamicLabel.label( "Vehiculo" );
		    long idNodoVehiculo = -1;
			// CREATE INDEX ON :Vehiculo(vehicle_id);
		    inserter.createDeferredSchemaIndex( etiquetaNodoCliente ).on( "vehicle_id" ).create();

		    Label etiquetaNodoGps = DynamicLabel.label( "Gps" );

			// CREATE INDEX ON :Gps(latitud);
		    inserter.createDeferredSchemaIndex( etiquetaNodoGps ).on( "latitud" ).create();
			// CREATE INDEX ON :Gps(longitud);
		    inserter.createDeferredSchemaIndex( etiquetaNodoGps ).on( "longitud" ).create();

		    Label etiquetaNodoPOI = DynamicLabel.label( "Poi" );

			// CREATE INDEX ON :Poi(latitud);
		    inserter.createDeferredSchemaIndex( etiquetaNodoPOI ).on( "latitud" ).create();
			// CREATE INDEX ON :Poi(longitud);
		    inserter.createDeferredSchemaIndex( etiquetaNodoPOI ).on( "longitud" ).create();
		    
		    // Relaciones
		    RelationshipType tiene = DynamicRelationshipType.withName( "TIENE" );
		    long idRelacionTiene = -1;
		    
		    RelationshipType puede_ver = DynamicRelationshipType.withName( "PUEDE_VER" );
		    long idRelacionPuedeVer = -1;
		    
			String fila;
			String valor;
		    
		    // Recorremos todas las filas del archivo que queremos importar a NEO4J
			try (BufferedReader br = 
				new BufferedReader(new FileReader("C:\\Users\\Arturo\\Documents\\BIG DATA\\PRODUCTOS\\companyz\\05_Client_Vehicle_List.csv")))
			{


				fila = br.readLine();
			
				// Leemos los identificadores del las columnas
				for (String etiqueta : fila.split("\\t")) {
					etiquetas.add(etiqueta);
				}
				
				// Leemos las filas separando los valores de las columnas
				while ((fila = br.readLine()) != null) {

				    ////////////////////////////////	05_Client_Vehicle_List.csv     /////////////////////////////////////////////
					
					// USING PERIODIC COMMIT 1000
					// LOAD CSV WITH HEADERS FROM "file:///mnt/hgfs/Downloads/05_Client_Vehicle_List.csv" AS row
					// FIELDTERMINATOR '\t'
					// WITH row
					// MERGE (c:Cliente {client_id:row.client_id})
					// MERGE (v:Vehiculo {vehicle_id:row.vehicle_id})
					// MERGE (c)-[t:TIENE]->(v);
					 					
					atributos = new HashMap<>(50);
					campos = new ArrayList<>(50);
					
					for (String campo : fila.split("\\t")) {
						// y creamos los nodos y les asignamos los atributos
						campos.add(campo);
					}
					
					// Rellenamos los atributos del nodo Cliente
					valor = campos.get(etiquetas.indexOf("client_id"));
					
					// Buscamos el identificador del Cliente de la l�nea actual
					// en los nodos de Cliente que ya han sido insertados
					if (!clientes.isEmpty() && clientes.containsKey(valor))
						idNodoCliente = clientes.get(valor);
					
					// Si no ha sido insertado ya este nodo Cliente, lo insertamos
					if (idNodoCliente == -1) {
						atributos.put( "client_id", valor );

						// Rellenamos el resto de atributos del nodo vehiculo
						atributos.putAll(mapeaStats(valor, "C:\\Users\\Arturo\\Documents\\BIG DATA\\PRODUCTOS\\companyz\\10_extract_clients_stats.txt"));
						atributos.putAll(mapeaStats(valor, "C:\\Users\\Arturo\\Documents\\BIG DATA\\PRODUCTOS\\companyz\\06_Clients_stats.csv"));
						
						// Insertamos el nodo Cliente
						idNodoCliente = inserter.createNode( atributos, etiquetaNodoCliente );

						// Guardamos el identificador para evitar crear duplicados
						clientes.put( campos.get(etiquetas.indexOf("client_id")), idNodoCliente);
						
						// Insertamos el nodo Usuario correspondiente al Cliente insertado, y los relacionamos con la relacion PUEDE_VER
						// Leemos los identificadores del las columnas
						try (BufferedReader br1 = 
							new BufferedReader(new FileReader("C:\\Users\\Arturo\\Documents\\BIG DATA\\PRODUCTOS\\companyz\\03_Users_Clients_List.csv")))
						{
							List<String> etiquetas1 = new ArrayList<>();
							List<String> campos1 = new ArrayList<>();
	
							String fila1 = br1.readLine();
								
							// Extraemos las etiquetas del archivo que relaciona usuarios y clientes
							for (String etiqueta1 : fila1.split("\\t")) {
								etiquetas1.add(etiqueta1);
							}
								
							// 1) Buscamos la fila del archivo que contiene el cliente actual
							while (((fila1 = br1.readLine()) != null) && !fila1.contains(valor)) {}
								
							// 2) Extraemos los campos columna de la fila
							for (String campo1 : fila1.split("\\t")) {
								// y creamos los nodos y les asignamos los atributos
								campos1.add(campo1);
							}
								
							// Obtenemos el identificador del Usuario que vamos a insertar
							Map<String, Object> atributos_usuario = new HashMap<>(50);
							atributos_usuario.put( "usuario_id", campos1.get(etiquetas1.indexOf("user_id")));
							atributos_usuario.put( "clave", campos1.get(etiquetas1.indexOf("user_id"))+"_01");
								
							if (!usuarios.containsKey(campos1.get(etiquetas1.indexOf("user_id")))) {
								// Insertamos el nodo Usuario
								idNodoUsuario = inserter.createNode( atributos_usuario, etiquetaNodoUsuario );
	
								// Guardamos el identificador para evitar crear duplicados
								usuarios.put( campos1.get(etiquetas1.indexOf("user_id")), idNodoUsuario);
							}
								
							// Buscamos el si existe creada una relacion PUEDE_VER entre el Usuario de la l�nea actual y el Cliente
							// en la lista de relaciones PUEDE_VER creadas con anterioridad
							if (!puede_ver_creados.isEmpty() && puede_ver_creados.containsKey(idNodoUsuario))					
								idRelacionPuedeVer = puede_ver_creados.get(idNodoUsuario);
					            
							// Si no ha sido insertado ya esta relacion PUEDE_VER, la insertamos
							if (idRelacionPuedeVer == -1) {
								Map<String, Object> atributos_puede_ver = new HashMap<>(50);
					            								
								idRelacionPuedeVer = inserter.createRelationship( idNodoUsuario, idNodoCliente, puede_ver, atributos_puede_ver );					
							
							}
					            
							// Guardamos el identificador para evitar crear duplicados
							puede_ver_creados.put( idNodoUsuario+"_"+idNodoCliente, idRelacionPuedeVer);
							
							// Reiniciamos
							idRelacionPuedeVer = -1;
						} catch (Exception e) {
							e.printStackTrace();
						}
						
					}
					
					atributos = new HashMap<>(50);
					
					// Rellenamos los atributos del nodo Vehiculo.
					// ���IMPORTANTE!!! El identificador del vehiculo se forma uniendo client_id+"_"+vehicle_id
					valor = campos.get(etiquetas.indexOf("client_id"))+"_"+
							campos.get(etiquetas.indexOf("vehicle_id"));
					
					// Buscamos el identificador del Vehiculo de la l�nea actual
					// en los nodos de Vehiculo que ya han sido insertados
					if (!vehiculos.isEmpty() && vehiculos.containsKey(valor))
						idNodoVehiculo = vehiculos.get(valor);
					
					// Si no ha sido insertado ya este nodo Cliente, lo insertamos
					if (idNodoVehiculo == -1) {
						// Rellenamos los atributos del nodo Vehiculo
						atributos.put( "vehicle_id", valor);
						
						// Rellenamos el resto de atributos del nodo vehiculo
						atributos.putAll(mapeaStats(valor, "C:\\Users\\Arturo\\Documents\\BIG DATA\\PRODUCTOS\\companyz\\11_extract_vehicles_stats.txt"));
						atributos.putAll(mapeaStats(valor, "C:\\Users\\Arturo\\Documents\\BIG DATA\\PRODUCTOS\\companyz\\07_Vehicles_stats.csv"));
						
						// Buscamos el identificador del Vehiculo de la l�nea actual
						// en los nodos de Vehiculo que ya han sido insertados
						if (!vehiculos.isEmpty() && vehiculos.containsKey(valor))
							idNodoVehiculo = vehiculos.get(valor);
						// Insertamos el nodo Vehiculo
						idNodoVehiculo = inserter.createNode( atributos, etiquetaNodoVehiculo );

						// Guardamos el identificador para evitar crear duplicados
						vehiculos.put( campos.get(etiquetas.indexOf("vehicle_id")), idNodoVehiculo);
						
						// Creamos el arbol de puntos de interes de este vehiculo
						creaPOIs(inserter, idNodoVehiculo, valor, "C:\\Users\\Arturo\\Documents\\BIG DATA\\PRODUCTOS\\companyz\\09_extract_pois_trace.txt");
						
						// Creamos el arbol de puntos de GPS de este vehiculo
						creaGpss(inserter, idNodoVehiculo, valor, "C:\\Users\\Arturo\\Documents\\BIG DATA\\PRODUCTOS\\companyz\\03_gps_positions.txt");
						
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
			
		} catch (Exception e) {
		        inserter.shutdown();
		}
		inserter.shutdown();
		
		// calcular tiempo transcurrido
		long fin = System.currentTimeMillis();
		
	    System.out.println("Segundos: "+(fin-inicio)/1000);		
	}

    // Recorremos todas las filas del archivo de pois, y creamos una tira de nodos relacionados con sus poi
	// Esta tira est� conectada al veh�culo por una relacion
	private static void creaPOIs(BatchInserter inserter, long idNodoVehiculo, String vehicle_id, String fichero_pois) {

		Map<String, Object> atributos = new HashMap<>();
		List<String> campos = new ArrayList<>(50);
		String fila = "";
		String valor = "";
		List<String> etiquetas = new ArrayList<>();
		
	    Label etiquetaNodoPOI = DynamicLabel.label( "Poi" );
	    long idNodoPoi = -1;
	    long idNodoPoiAnterior = -1;

	    // Relaciones
	    RelationshipType ha_estado_en_poi = DynamicRelationshipType.withName( "HA_ESTADO_EN_POI" );
	    long idRelacionHaEstadoEnPoi = -1;
	    
	    RelationshipType en_ruta = DynamicRelationshipType.withName( "EN_RUTA" );
	    long idRelacionEnRuta = -1;
		
	    Map<String, Long> pois = new HashMap<>();
	    Map<String, Long> haestadoenpoi_creados = new HashMap<>();
	    Map<String, Long> en_ruta_creados = new HashMap<>();
	    
		try (BufferedReader br = new BufferedReader(new FileReader(fichero_pois)))
		{
			fila = br.readLine();
		
			// Leemos los identificadores del las columnas
			for (String etiqueta : fila.split("\\t")) {
				etiquetas.add(etiqueta);
			}
			
			// Enlazamos el vehiculo con el primero de sus POI:
			// 1) Buscamos la primera fila del archivo que contiene el vehiculo actual
			while (((fila = br.readLine()) != null) && !fila.contains(vehicle_id)) {}
			
			// 2) Extraemos los campos columna de la primera fila de POIs del vehiculo
			for (String campo : fila.split("\\t")) {
				// y creamos los nodos y les asignamos los atributos
				campos.add(campo);
			}
			
			// 3) Rellenamos sus atributos
			for (int i = 0; i < etiquetas.size(); i++) {
				atributos.put(etiquetas.get(i), campos.get(i));
			}
			atributos.put("poi_id", campos.get(etiquetas.indexOf("latitude"))+"_"+campos.get(etiquetas.indexOf("longitude")));
			
			// Insertamos el nodo POI
			idNodoPoi = inserter.createNode( atributos, etiquetaNodoPOI );

			// Guardamos el identificador para evitar crear duplicados
			pois.put( campos.get(etiquetas.indexOf("latitude"))+"_"+campos.get(etiquetas.indexOf("longitude")), idNodoPoi);
			
			// Buscamos el si existe creada una relacion HA_ESTADO_EN_POI entre el Vehiculo y el primer Poi de la l�nea actual
			// en la lista de relaciones EN_RUTA creadas con anterioridad
			if (!haestadoenpoi_creados.isEmpty() && haestadoenpoi_creados.containsKey(idNodoVehiculo+"_"+idNodoPoi))					
				idRelacionHaEstadoEnPoi = haestadoenpoi_creados.get(idNodoVehiculo+"_"+idNodoPoi);
            
			// Si no ha sido insertado ya esta relacion HA_ESTADO_EN_POI, la insertamos
			if (idRelacionHaEstadoEnPoi == -1) {
			    atributos = new HashMap<>(50);
            
				valor = campos.get(etiquetas.indexOf("date"));
				atributos.put( "fecha", valor);
				
				idRelacionHaEstadoEnPoi = inserter.createRelationship( idNodoVehiculo, idNodoPoi, ha_estado_en_poi, atributos );					
			
			}
            
			// Guardamos el identificador para evitar crear duplicados
			haestadoenpoi_creados.put( idNodoVehiculo+"_"+idNodoPoi, idRelacionHaEstadoEnPoi);

			idNodoPoiAnterior = idNodoPoi;				
			
			// A continuaci�n leemos el resto de puntos de inter�s del vehiculo, y los enlazamos al punto de interes inicial
			// EN_RUTA
			while (((fila = br.readLine()) != null) && fila.contains(vehicle_id)) {
				 					
				atributos = new HashMap<>(50);
				campos = new ArrayList<>(50);
				
				// Extraemos los campos columna de la fila actual de POIs del vehiculo
				for (String campo : fila.split("\\t")) {
					// y creamos los nodos y les asignamos los atributos
					campos.add(campo);
				}
				
				// Rellenamos los atributos del Poi actual
				for (int i = 0; i < etiquetas.size(); i++) {
					atributos.put(etiquetas.get(i), campos.get(i));
				}
				
				atributos.put("poi_id", campos.get(etiquetas.indexOf("latitude"))+"_"+campos.get(etiquetas.indexOf("longitude")));
				
				// Insertamos el nodo POI actual
				idNodoPoi = inserter.createNode( atributos, etiquetaNodoPOI );

				// Guardamos el identificador para evitar crear duplicados
				pois.put( campos.get(etiquetas.indexOf("latitude"))+"_"+campos.get(etiquetas.indexOf("longitude")), idNodoPoi);
				
				// Buscamos el si existe creada una relacion EN_RUTA entre el Poi anterior y el Poi de la l�nea actual
				// en la lista de relaciones EN_RUTA creadas con anterioridad
				if (!en_ruta_creados.isEmpty() && en_ruta_creados.containsKey(idNodoPoi))					
					idRelacionEnRuta = en_ruta_creados.get(idNodoVehiculo+"_"+idNodoPoi);
	            
				// Si no ha sido insertado ya esta relacion EN_RUTA, la insertamos
				if (idRelacionEnRuta == -1) {
				    atributos = new HashMap<>(50);
	            
					valor = campos.get(etiquetas.indexOf("date"));
					atributos.put( "fecha", valor);
					
					idRelacionEnRuta = inserter.createRelationship( idNodoPoiAnterior, idNodoPoi, en_ruta, atributos );					
				
				}
	            
				// Guardamos el identificador para evitar crear duplicados
				en_ruta_creados.put( idNodoPoiAnterior+"_"+idNodoPoi, idRelacionEnRuta);
				
				// Reiniciamos
				idNodoPoiAnterior = idNodoPoi;
				idNodoPoi = -1;
				idRelacionEnRuta = -1;
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
    // Recorremos todas las filas del archivo de gpss, y creamos una tira de nodos Gps relacionados con este vehiculo
	// Esta tira est� conectada al veh�culo por una relacion
	private static void creaGpss(BatchInserter inserter, long idNodoVehiculo, String vehicle_id, String fichero_gpss) {

		Map<String, Object> atributos = new HashMap<>();
		List<String> campos = new ArrayList<>(50);
		String fila = "";
		String valor = "";
		List<String> etiquetas = new ArrayList<>();
		
	    Label etiquetaNodoGps = DynamicLabel.label( "Gps" );
	    long idNodoGps = -1;
	    long idNodoGpsAnterior = -1;

	    // Relaciones
	    RelationshipType ha_estado_en = DynamicRelationshipType.withName( "HA_ESTADO_EN" );
	    long idRelacionHaEstadoEn = -1;
	    
	    // RelationshipType en_ruta = DynamicRelationshipType.withName( "EN_RUTA" );
	    // long idRelacionEnRuta = -1;
		
	    Map<String, Long> gpss = new HashMap<>();
	    Map<String, Long> haestadoen_creados = new HashMap<>();
	    
		try (BufferedReader br = new BufferedReader(new FileReader(fichero_gpss)))
		{
			fila = br.readLine();
		
			// Leemos los identificadores del las columnas
			for (String etiqueta : fila.split("\\t")) {
				etiquetas.add(etiqueta);
			}
			
			// Enlazamos el vehiculo con el primero de sus POI:
			// 1) Buscamos la primera fila del archivo que contiene el vehiculo actual
			while (((fila = br.readLine()) != null) && !fila.contains(vehicle_id)) {}
			
			// 2) Extraemos los campos columna de la primera fila de POIs del vehiculo
			for (String campo : fila.split("\\t")) {
				// y creamos los nodos y les asignamos los atributos
				campos.add(campo);
			}
			
			// 3) Rellenamos sus atributos
			for (int i = 0; i < etiquetas.size(); i++) {
				atributos.put(etiquetas.get(i), campos.get(i));
			}
			atributos.put("gps_id", campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud")));
			
			// Insertamos el nodo Gps
			idNodoGps = inserter.createNode( atributos, etiquetaNodoGps );

			// Guardamos el identificador para evitar crear duplicados
			gpss.put( campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud")), idNodoGps);
			
			// Buscamos el si existe creada una relacion HA_ESTADO_EN entre el Vehiculo y el primer Poi de la l�nea actual
			// en la lista de relaciones EN_RUTA creadas con anterioridad
			if (!haestadoen_creados.isEmpty() && haestadoen_creados.containsKey(idNodoVehiculo+"_"+idNodoGps))					
				idRelacionHaEstadoEn = haestadoen_creados.get(idNodoVehiculo+"_"+idNodoGps);
            
			// Si no ha sido insertado ya esta relacion HA_ESTADO_EN_POI, la insertamos
			if (idRelacionHaEstadoEn == -1) {
			    atributos = new HashMap<>(50);
            
				valor = campos.get(etiquetas.indexOf("fecha"));
				atributos.put( "fecha", valor);
				
				idRelacionHaEstadoEn = inserter.createRelationship( idNodoVehiculo, idNodoGps, ha_estado_en, atributos );					
			
			}
            
			// Guardamos el identificador para evitar crear duplicados
			haestadoen_creados.put( idNodoVehiculo+"_"+idNodoGps, idRelacionHaEstadoEn);

			idNodoGpsAnterior = idNodoGps;				
			
			// A continuaci�n leemos el resto de puntos de inter�s del vehiculo, y los enlazamos al punto de interes inicial
			// HA_ESTADO_EN
			while (((fila = br.readLine()) != null) && fila.contains(vehicle_id)) {
				 					
				atributos = new HashMap<>(50);
				campos = new ArrayList<>(50);
				
				// Extraemos los campos columna de la fila actual de POIs del vehiculo
				for (String campo : fila.split("\\t")) {
					// y creamos los nodos y les asignamos los atributos
					campos.add(campo);
				}
				
				// Rellenamos los atributos del Poi actual
				for (int i = 0; i < etiquetas.size(); i++) {
					atributos.put(etiquetas.get(i), campos.get(i));
				}
				
				atributos.put("gps_id", campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud")));
				
				// Insertamos el nodo POI actual
				idNodoGps = inserter.createNode( atributos, etiquetaNodoGps );

				// Guardamos el identificador para evitar crear duplicados
				gpss.put( campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud")), idNodoGps);
				
				// Buscamos el si existe creada una relacion HA_ESTADO_EN entre el Poi anterior y el Poi de la l�nea actual
				// en la lista de relaciones EN_RUTA creadas con anterioridad
				if (!haestadoen_creados.isEmpty() && haestadoen_creados.containsKey(idNodoGps))					
					idRelacionHaEstadoEn = haestadoen_creados.get(idNodoVehiculo+"_"+idNodoGps);
	            
				// Si no ha sido insertado ya esta relacion HA_ESTADO_EN, la insertamos
				if (idRelacionHaEstadoEn == -1) {
				    atributos = new HashMap<>(50);
	            
					valor = campos.get(etiquetas.indexOf("fecha"));
					atributos.put( "fecha", valor);
					
					idRelacionHaEstadoEn = inserter.createRelationship( idNodoGpsAnterior, idNodoGps, ha_estado_en, atributos );					
				
				}
	            
				// Guardamos el identificador para evitar crear duplicados
				haestadoen_creados.put( idNodoGpsAnterior+"_"+idNodoGps, idRelacionHaEstadoEn);
				
				// Reiniciamos
				idNodoGpsAnterior = idNodoGps;
				idNodoGps = -1;
				idRelacionHaEstadoEn = -1;
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	// Cargamos los atributos estad�sticos de cualquier tipo de nodo desde el archivo de estadisticas
	private static Map<String, Object> mapeaStats(String id, String archivo) {
		Map<String, Object> atributos = new HashMap<>();
		List<String> campos = new ArrayList<>(50);
		String fila = "";
		List<String> etiquetas = new ArrayList<>();
		
	    // Recorremos los archivos de estad�sticas para rellenar el resto de atributos del nodo
		try (BufferedReader br = new BufferedReader(new FileReader(archivo)))
		{
			
			fila = br.readLine();
			
			// Leemos los identificadores del las columnas
			for (String etiqueta : fila.split("\\t")) {
				etiquetas.add(etiqueta);
			}
			
			// Buscamos el identificador del nodo en el archivo de estad�sticas de este tipo de nodos
			while ((fila = br.readLine()) != null) {
				// Cuando encontramos la fila en la que se encuentra, extraemos sus atributos y salimos
				if (fila.contains(id)) {

					// Leemos los valores de las columnas
					for (String campo : fila.split("\\t")) {
						campos.add(campo);
					}
					
					// y rellenamos los atributos
					for (int i = 0; i < etiquetas.size(); i++) {
						atributos.put(etiquetas.get(i), campos.get(i));
					}
					
					// Si hemos encontrado los atributos, los retornamos
					return atributos;
				}
			}
			
		} catch (Exception e) {
			
		}
		
		return atributos;
	}

}
