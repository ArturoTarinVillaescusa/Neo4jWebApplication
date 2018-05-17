package bulkloaders;

import java.awt.Desktop;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.metadata.IIOMetadata;
import javax.imageio.stream.ImageInputStream;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.apache.pdfbox.text.PDFTextStripperByArea;
import org.apache.poi.hdgf.extractor.VisioTextExtractor;
import org.apache.poi.hpsf.PropertySetFactory;
import org.apache.poi.hpsf.SummaryInformation;
import org.apache.poi.hsmf.MAPIMessage;
import org.apache.poi.hsmf.extractor.OutlookTextExtactor;
import org.apache.poi.hslf.extractor.PowerPointExtractor;
import org.apache.poi.hslf.extractor.QuickButCruddyTextExtractor;
import org.apache.poi.hssf.extractor.ExcelExtractor;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hwpf.extractor.WordExtractor;
import org.apache.poi.poifs.eventfilesystem.POIFSReader;
import org.apache.poi.poifs.eventfilesystem.POIFSReaderEvent;
import org.apache.poi.poifs.eventfilesystem.POIFSReaderListener;
import org.neo4j.graphdb.DynamicLabel;
import org.neo4j.graphdb.DynamicRelationshipType;
import org.neo4j.graphdb.Label;
import org.neo4j.graphdb.RelationshipType;
import org.neo4j.io.fs.FileUtils;
import org.neo4j.unsafe.batchinsert.BatchInserter;
import org.neo4j.unsafe.batchinsert.BatchInserters;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;

import bulkloaders.ReadTitle.MyPOIFSReaderListener;

public class BatchInserter_companyx_y_companyy {

	static BatchInserter inserter = null;

    // Etiquetas de nodos y relaciones
    private static final Label etiquetaFolder = DynamicLabel.label( "Folder" );
    private static final Label etiquetaFile = DynamicLabel.label( "File" );
    private static final Label etiquetaNodoGpsMuestra = DynamicLabel.label( "GpsMuestra" );
    private static final Label etiquetaNodoUser = DynamicLabel.label( "User" );
    private static final Label etiquetaNodoGroup = DynamicLabel.label( "Group" );
    
    private static final RelationshipType contiene = DynamicRelationshipType.withName( "CONTIENE" );
    private static final RelationshipType pertenece_al_grupo = DynamicRelationshipType.withName( "PERTENECE_AL_GRUPO" );

    // Lista de elementos creados en Neo4j
    public static Map<String, Long> folders = new HashMap<>();
	public static Map<String, Long> files = new HashMap<>();
	public static Map<String, Long> groups = new HashMap<>();
	public static Map<String, Long> contiene_creados = new HashMap<>();
	public static Map<String, Long> pertenece_al_grupo_creados = new HashMap<>();

	//  Los archivos 05_file_gps_posi y 06_locations_gps guardan informaci�n de los archivos que se encuentran
	// en puntos Gps cercanos. Esta informaci�n me va a permitir a�adir un filtro de proximidad en la pantalla de
	// b�squeda de archivos de la demo.
	// Voy a cargar su informaci�n en nodos de tipo Group, y voy a utilizar ese par de estructuras que vienen a
	// continuaci�n para almacenar temporalmente su contenido en modo de lista de registros o mapa de clases.
	// Utilizaremos el HashMap grupos desde cargaEstructuraDisco, verificando si cada File que insertamos est�
	// relacionado por nombre con alguno de los nodos de Group. De ser as�, el script cargaEstructuraDisco crear�
	// una relaci�n PERTENECE_AL_GRUPO, con origen en el File y con destino en el Group
	public static Map<Integer, FileInGroup> groups_temporal = new HashMap<>();
	
	// http://maxdemarzi.com/2012/02/28/batch-importer-part-1/
	// http://maxdemarzi.com/2012/02/28/batch-importer-part-2/
	// http://maxdemarzi.com/2012/07/02/batch-importer-part-3/
	// https://github.com/jexp/batch-import
	public static void main(String[] args) {
		//if (args.length < 2) {
		//	System.out.println("Mode of use:\njava -jar load_companyx_files_into_neo4j.jar <companyx's_folder_to_load> <neo4j's_folder_to_create>");
		//	System.out.println("\nExample:\njava -jar load_companyx_files_into_neo4j.jar /companyx_FOLDER /companyx_neo4j.db");
		//	System.out.println("\nNote: you must use jre 1.6 or higher");
		//	return;
		//}
		
		// guardar timestamp inicio
		long inicio = System.currentTimeMillis();
		  
		try
		{
			// Creamos una nueva base de datos Neo4j
			File graphDb = new File("C:\\Users\\Arturo\\Documents\\DISCO_CLUSTER\\companyx_y_companyy_v2.graphdb");
			// File graphDb = new File(args[1]);
	        if (graphDb.exists()) {
	            try {
					FileUtils.deleteRecursively(graphDb);
	            	// FileUtils.renameFile(graphDb, new File(graphDb.toString()+"Copia-"+System.currentTimeMillis()));
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

		    cargacompanyy();

			// Cargamos los usuarios de la aplicaci�n. Son inventados, as� que no los leo del archivo, sino que los
			// inserto directamente		    
		    cargaUsuarios();
		    
		    // Generamos grupos de Gps con la informaci�n de los archivos relacionados geograficamente
		    // Cargamos la informaci�n de archivos relacionados geograficamente en un vector que usaremos
			// posteriormente para relacionar nodos File con nodos Group a trav�s de la relacion AGRUPADO_EN
		    groups_temporal = cargaGrupos("C:\\Users\\Arturo\\Documents\\BIG DATA\\CLIENTES\\companyx\\Demo\\05_file_gps_posi",
		    					 "C:\\Users\\Arturo\\Documents\\BIG DATA\\CLIENTES\\companyx\\Demo\\06_locations_gps");
		    
			// Recorremos un arbol de carpetas y generamos una base de datos Neo4j con su contenido
		    File carpeta = new File("C:\\Users\\Arturo\\Documents\\BIG DATA\\CLIENTES\\companyx\\LaCie");
		    // File carpeta = new File(args[0]);
		    
		    cargaEstructuraDisco(carpeta);
		    
		    // �ndices
		    // CREATE INDEX ON :User(user_id);
		    inserter.createDeferredSchemaIndex( etiquetaNodoUser ).on( "user_id" ).create();
		    
			// CREATE INDEX ON :Folder(folder_id);
		    inserter.createDeferredSchemaIndex( etiquetaFolder ).on( "folder_id" ).create();

			// CREATE INDEX ON :File(file_id);
		    inserter.createDeferredSchemaIndex( etiquetaFolder ).on( "file_id" ).create();
		    
		    // CREATE INDEX ON :GpsMuestra(gpsmuestra_id);
		    inserter.createDeferredSchemaIndex( etiquetaNodoGpsMuestra ).on( "gpsmuestra_id" ).create();

		    // CREATE INDEX ON :Group(group_id);
		    inserter.createDeferredSchemaIndex( etiquetaNodoGroup ).on( "group_id" ).create();
		    
		    // cargacompanyy();
		    
		} catch (Exception e) {
		        inserter.shutdown();
		}
		inserter.shutdown();
		
		// calcular tiempo transcurrido
		long fin = System.currentTimeMillis();
		
	    System.out.println("Base de datos Neo4j creada. "+(fin-inicio)/1000 + " segundos");
	    
	    // MATCH (n:Group) WITH n.group_type AS group_type, n.area_id AS area_id, n.location AS location, n.file AS file,
	    // n.group_id AS group_id, n.owner AS owner, n.latitude AS latitude, n.longitude AS longitude, 
	    // n.coordenate_type AS coordenate_type
	    // RETURN group_id, file, location, group_type, latitude, longitude, coordenate_type, owner, area_id ORDER BY group_id
	    
	    // MATCH (f:File)-[]->(n:Group) WHERE n.group_id = 'Seagull Shoals No 1 Edited DT GR ILD.LASSEAGULL_SHOALS_A_1' RETURN f.file_name, n
	    
	    // MATCH (n:Group) WHERE n.file = 'Seagull Shoals No 1 Final Geological Report.pdf' RETURN n
	    
	    // MATCH (n:Group) WHERE n.group_type = 'Area' AND n.area_id = 'Rectangulo_1' RETURN n
	}

	// Cargamos la informaci�n de archivos relacionados geograficamente en un vector que usaremos
	// posteriormente para relacionar nodos File con nodos Group a trav�s de la relacion AGRUPADO_EN
    private static Map<Integer, FileInGroup> cargaGrupos(String file_gps_posi, String locations_gps) {
    	Map<Integer, FileInGroup> groups = new HashMap<>();
    	FileInGroup fileingroup = new FileInGroup();
    	int idNodoGroup = 0;
    	String fila;
	    List<String> campos = new ArrayList<>();
	    List<String> etiquetas = new ArrayList<>();
    	
	    // Recorremos todas las filas del archivo que queremos importar a NEO4J
		try (BufferedReader br = new BufferedReader(new FileReader(file_gps_posi)))
		{
			fila = br.readLine();
		
			// Leemos los identificadores del las columnas
			for (String etiqueta : fila.split("\\t")) {
				etiquetas.add(etiqueta);
			}
			
			// Leemos las filas separando los valores de las columnas
			while ((fila = br.readLine()) != null) {
			
				campos = new ArrayList<>(50);
				
				for (String campo : fila.split("\\t")) {
					// y creamos los nodos y les asignamos los atributos
					campos.add(campo);
				}
				
				if (!fila.trim().equals("")) {
				  if (!campos.get(etiquetas.indexOf("latitude")).equals("¿?")) {
					// Rellenamos los atributos del registro FileInGroup
					fileingroup = new FileInGroup();
					fileingroup.setFile(campos.get(etiquetas.indexOf("Files")));
					fileingroup.setCoordenate_type(campos.get(etiquetas.indexOf("Coordenate_type")));
					fileingroup.setGroup_type(campos.get(etiquetas.indexOf("Type")));
					fileingroup.setArea_id(campos.get(etiquetas.indexOf("Area_ID"))==null?"":campos.get(etiquetas.indexOf("Area_ID")));
					fileingroup.setLatitude(Float.parseFloat(campos.get(etiquetas.indexOf("latitude")).replace(",", ".")));
					fileingroup.setLongitude(Float.parseFloat(campos.get(etiquetas.indexOf("longitude")).replace(",", ".")));
					fileingroup.setLocation(campos.get(etiquetas.indexOf("location")));
					try {
						fileingroup.setOwner(campos.get(etiquetas.indexOf("Owner"))==null?"":campos.get(etiquetas.indexOf("Owner")));
					} catch (IndexOutOfBoundsException e) {
					} catch (Exception e) {
						e.printStackTrace();
					}
					// Guardamos el registro en la lista
					groups.put(idNodoGroup, fileingroup);
				    idNodoGroup++;
				  }
				}
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
    	
		return groups;
	}


	// Cargamos los usuarios de la aplicaci�n. Son inventados, as� que no los leo del archivo, sino que los
	// inserto directamente
	private static void cargaUsuarios() {
		
		Map<String, Object> atributos = new HashMap<>(50);

		atributos.put("user_id", "johns");
		atributos.put("password", "johns01");
		atributos.put("user_name", "John Smith");
		atributos.put("user_company", "Amoco Seychelles");
		atributos.put("role", "Client");
		
		inserter.createNode(atributos, etiquetaNodoUser);
		
		atributos = new HashMap<>(50);

		atributos.put("user_id", "davidw");
		atributos.put("password", "davidw01");
		atributos.put("user_name", "David Williams");
		atributos.put("user_company", "Amoco Seychelles");
		atributos.put("role", "Client");
		
		inserter.createNode(atributos, etiquetaNodoUser);
		
		atributos = new HashMap<>(50);

		atributos.put("user_id", "anaj");
		atributos.put("password", "anaj01");
		atributos.put("user_name", "Ana Johnson");
		atributos.put("user_company", "Schlumberger");
		atributos.put("role", "Client");
		
		inserter.createNode(atributos, etiquetaNodoUser);

		atributos = new HashMap<>(50);

		atributos.put("user_id", "markm");
		atributos.put("password", "markm01");
		atributos.put("user_name", "Marc Miller");
		atributos.put("user_company", "Schlumberger");
		atributos.put("role", "Client");
		
		inserter.createNode(atributos, etiquetaNodoUser);
		
		atributos = new HashMap<>(50);

		atributos.put("user_id", "Arturo");
		atributos.put("password", "arturo01");
		atributos.put("user_name", "Arturo");
		atributos.put("user_company", "DTI Star");
		atributos.put("role", "Consultant");
		
		inserter.createNode(atributos, etiquetaNodoUser);

		atributos = new HashMap<>(50);

		atributos.put("user_id", "duncanw");
		atributos.put("password", "duncanw01");
		atributos.put("user_name", "Duncan W");
		atributos.put("user_company", "companyx");
		atributos.put("role", "Author");
		
		inserter.createNode(atributos, etiquetaNodoUser);

		atributos = new HashMap<>(50);

		atributos.put("user_id", "rheinbockel");
		atributos.put("password", "rheinbockel01");
		atributos.put("user_name", "Rheinbockel");
		atributos.put("user_company", "companyx");
		atributos.put("role", "Author");
		
		inserter.createNode(atributos, etiquetaNodoUser);

		atributos = new HashMap<>(50);

		atributos.put("user_id", "obsgeo");
		atributos.put("password", "obsgeo01");
		atributos.put("user_name", "obsgeo");
		atributos.put("user_company", "companyx");
		atributos.put("role", "Author");
		
		inserter.createNode(atributos, etiquetaNodoUser);		
		atributos = new HashMap<>(50);

		atributos.put("user_id", "wayne");
		atributos.put("password", "waine01");
		atributos.put("user_name", "Waine");
		atributos.put("user_company", "companyx");
		atributos.put("role", "Author");
		
		inserter.createNode(atributos, etiquetaNodoUser);
		
		atributos = new HashMap<>(50);

		atributos.put("user_id", "johnm");
		atributos.put("password", "johnm01");
		atributos.put("user_name", "John M");
		atributos.put("user_company", "companyx");
		atributos.put("role", "Author");
		
		inserter.createNode(atributos, etiquetaNodoUser);
	}

	// Recorremos un arbol de carpetas y generamos una base de datos Neo4j con su contenido
	private static void cargaEstructuraDisco(File carpeta) {
		HashMap<String, Object> atributos = new HashMap<>(50);
		long idNodoHijo = -1;
		long idNodoFolder = -1;
		long idRelacionContiene = -1;
		
		// Limpiamos el contenedor de atributos
		atributos = new HashMap<>(50);
		
	    if (carpeta.exists()){ // Directorio existe }
			// Buscamos el identificador de la Folder actual
			// en los nodos de Folder que ya han sido insertados
			if (!folders.isEmpty() && folders.containsKey(carpeta.toString()))
				idNodoFolder = folders.get(carpeta.toString());
			
			// Si no ha sido insertado ya este nodo Carpeta, lo insertamos
			if (idNodoFolder == -1) {
				// Rellenamos los atributos de la carpeta
				atributos.put("folder_id", carpeta.toString());

				// Creamos el nodo Carpeta
				idNodoFolder = inserter.createNode( atributos, etiquetaFolder );
				
				// Guardamos el identificador para evitar crear duplicados
				folders.put( carpeta.toString(), idNodoFolder);
			}
	    	
	    	File[] ficheros = carpeta.listFiles();

	    	for (int x=0;x<ficheros.length;x++){
	    		System.out.println(ficheros[x].toString());
		  		// Limpiamos el contenedor de atributos
		  		atributos = new HashMap<>(50);	    		

	    		if (ficheros[x].isDirectory()){
	    			// Buscamos el identificador de la Folder actual
	    			// en los nodos de Folder que ya han sido insertados
	    			if (!folders.isEmpty() && folders.containsKey(ficheros[x].toString()))
	    				idNodoHijo = folders.get(ficheros[x].toString());
	    			
	    			// Si no ha sido insertado ya este nodo Carpeta, lo insertamos
	    			if (idNodoHijo == -1) {
	  	  		    	// Rellenamos los atributos de la carpeta hija
	  	  		    	atributos.put("folder_id", ficheros[x].toString());
	  	    		  
	  	  		    	idNodoHijo = inserter.createNode(atributos, etiquetaFolder );
	  	    		  
	  	    			// Guardamos el identificador para evitar crear duplicados
	  	    			folders.put( ficheros[x].toString(), idNodoHijo);
	    			}

	    			cargaEstructuraDisco(ficheros[x]);
	    		} else {
    				// Buscamos el identificador del File actual
    				// en los nodos de File que ya han sido insertados
    				if (!files.isEmpty() && files.containsKey(ficheros[x].toString()))
    					idNodoHijo = files.get(ficheros[x].toString());
    				
    				// Si no ha sido insertado ya este nodo Carpeta, lo insertamos
    				if (idNodoHijo == -1) {
    		  			// Rellenamos los atributos del archivo hijo
    		  			atributos.put("file_id", ficheros[x].toString());
    		  			atributos.put("file_route", ficheros[x].toString());
    		  			atributos.put("file_name", ficheros[x].getName());
    		  			atributos.put("usable_space_on_disk", ficheros[x].getUsableSpace());
    		  			atributos.put("total_space_on_disk", ficheros[x].getTotalSpace());
    		  			atributos.put("free_space_on_disk", ficheros[x].getFreeSpace());
    		  			atributos.put("file_type", ficheros[x].getName().toLowerCase().substring(ficheros[x].getName().lastIndexOf(".")+1));
    		    		
    		  			// Si es un archivo de texto
    		  			if (atributos.get("file_type").toString().toUpperCase().equals("LAS") ||
           		  			atributos.get("file_type").toString().toUpperCase().equals("TXT") ||
           		  			atributos.get("file_type").toString().toUpperCase().equals("LOG") ||
           		  			atributos.get("file_type").toString().toUpperCase().equals("XML") ||
           		  			atributos.get("file_type").toString().toUpperCase().equals("PROPERTIES") ||
    		  				atributos.get("file_type").toString().toUpperCase().equals("SHELLV5") ||
    		  				atributos.get("file_type").toString().toUpperCase().equals("DFX") ||
    		  				atributos.get("file_type").toString().toUpperCase().equals("GFX") ||
    		  				atributos.get("file_type").toString().toUpperCase().equals("XYZ")) {
							try {
								atributos.put("texto", new String(Files.readAllBytes(Paths.get(ficheros[x].toString()))));
							} catch (IOException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
    		  			} else { // Archivo de Microsoft Office
	    		  			// Ponemos en el nodo los atributos del archivo Office
	    		  			leerPropiedadesArchivoOffice(ficheros[x].toString());
	    		  			
	    		  			// Ponemos en el nodo el contenido del archivo Office
	    		  			try {
	    		  				atributos.put("texto", leerContenidoArchivoOffice(ficheros[x].toString()));
	    		  			} catch (NullPointerException e) {
	    		  				// Si es un pdf no legible provoca esta excepci�n
	    		  				atributos.put("texto", "");
	    		  			}
	    		  			
	    		  			atributos.putAll(atrribs);
    		  			}
    		  			
    		  			// Leemos los atributos en caso de que sea un archivo de imagen
    		  			leerPropiedadesArchivoImagen(ficheros[x].toString());
    		  			atributos.putAll(atrribs);

    		  			// Limpiamos el contenedor de atributos del archivo Office
    		  			atrribs = new HashMap<>(50);
    		  			
    		    		idNodoHijo = inserter.createNode(atributos, etiquetaFile );
    		    		
    		    		// Si el File pertenece a un Group:
    		    		// 1) comprobamos si el Group existe, y lo creamos si no es as�
    		    		// 2) enlazamos el File al Group con la relaci�n PERTENECE_AL_GRUPO
    		    		enlazaArchivoConGrupo(idNodoHijo, atributos.get("file_name").toString());
    					
    		    		// Si es un archivo de tipo .LAS, generamos unos puntos GpsMuestra ficticios para poder representar �reas
    		    		if (atributos.get("file_type").toString().toLowerCase().equals("las"))
    		    			generaPuntosGpsMuestra(inserter, idNodoHijo, atributos.get("file_route").toString());
    		    		
    					// Guardamos el identificador para evitar crear duplicados
    					files.put( ficheros[x].toString(), idNodoHijo);
    				}
	    		}

				// Buscamos el si existe creada una relacion CONTIENE entre Folder y el hijo Folder o File de la l�nea actual
				// en la lista de relaciones CONTIENE creadas con anterioridad
				if (!contiene_creados.isEmpty() && contiene_creados.containsKey(idNodoFolder+"_"+idNodoHijo))
					idRelacionContiene = contiene_creados.get(idNodoFolder+"_"+idNodoHijo);
					
				// Si no ha sido insertado ya esta relacion CONTIENE, la insertamos
				if (idRelacionContiene == -1) {
			  		  // Limpiamos el contenedor de atributos
			  		  atributos = new HashMap<>(50);
			    	  
			    	  // Creamos la relaci�n CONTIENE entre la carpeta padre y el hijo
			    	  idRelacionContiene = inserter.createRelationship( idNodoFolder, idNodoHijo, contiene, atributos );
				}
				
				// Guardamos el identificador para evitar crear duplicados
				contiene_creados.put( idNodoFolder+"_"+idNodoHijo, idRelacionContiene);

				// Limpiamos
				idNodoHijo = -1;
				idRelacionContiene = -1;
	    	  
	    	}
	    } else { //Directorio no existe }
	    }
	}

	// Si es un archivo de tipo .LAS, generamos unos puntos GpsMuestra ficticios para poder representar �reas
	// Las columnas GR y ILD, del archivo Seagull Shoals ...las
	// Sus valores eran 53.491501 y 3.472300, que puestos al rev�s apuntaban a un punto en el mar entre Somalia y Seychelles
	// Podr�amos usar esos valores, ILD como latitud, y GR como longitud
	// Cada uno de los archivos que tengo tiene 26.000 l�neas, y casi todos los pares GR-ILD corresponden a un punto que podr�a servir como nodo Gps, para poder pintarlo en el mapa.
	// Y las otras columnas podr�an servir  para generar gr�ficas:
	// DEPT -> Depth
	// RHOB -> bulk density,
	// GR -> Gamma ray
	// and so on
	// Mi intenci�n es lo siguiente:
	// cuando en la pantalla de la demo pulsemos un archivo de este tipo, .las, debe aparecer una ventana de panel de control que permita filtrar por esos datos, y a partir de ese filtro se puedan pintar las chinchetas en un mapa.
	// A ver qu� sale
	
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
	private static void generaPuntosGpsMuestra(BatchInserter inserter, long idNodoFile, String archivo) {

		Map<String, Object> atributos = new HashMap<>();
		List<String> campos = new ArrayList<>(50);
		String fila = "";
		String valor = "";
		List<String> etiquetas = new ArrayList<>();
		
	    long idNodoGpsMuestra = -1;
	    long idNodoGpsMuestraAnterior = -1;

	    // Relaciones
	    RelationshipType tomo_muestras_en = DynamicRelationshipType.withName( "TOMO_MUESTRAS_EN" );
	    long idRelacionTomaMuestrasEn = -1;

	    // RelationshipType en_ruta = DynamicRelationshipType.withName( "EN_RUTA" );
	    // long idRelacionEnRuta = -1;
		
	    Map<String, Long> gpsmuestrass = new HashMap<>();
	    Map<String, Long> tomamuestrasen_creados = new HashMap<>();
	    
	    // Recorremos todas las filas del archivo .LAS que queremos importar a NEO4J
		try (BufferedReader br = new BufferedReader(new FileReader(archivo)))
		{
			fila = br.readLine().replaceAll("\\s+", " ").trim();
			// Saltamos las filas previas hasta que enontramos la l�nea las etiquetas de los puntos GpsMuestra ficticios
			if (!(fila.contains("ILD") && fila.contains("GR")))
				while (!(fila = br.readLine().replaceAll("\\s+", " ").trim().replaceAll("\\s+", " ").trim()).startsWith("~A"));
			
			// Comprobamos si las etiquetas contienen los datos ILD (longitud) y GR (latitud)
			// En caso de que este archivo no los contenga, finalizamos la b�squeda
			if (!(fila.contains("ILD") && fila.contains("GR")))
				return;
		
			// Corregimos las etiquetas, para que encajen con los campos que vamos a leer a continuaci�n
			fila = fila.replace("~A ", "");
			fila = fila.replace("DT O", "DTO");
			
			// Leemos los identificadores del las columnas
			for (String etiqueta : fila.split(" ")) {
				etiqueta = etiqueta.replaceAll("DEPTH", "DEPT").replaceAll("DEPT", "DEPTH");
				etiquetas.add(etiqueta);
			}
			
			// Leemos los puntos GpsMuestra. El primer punto GpsMuestra lo enlazamos al nodo File
			// El resto de GpsMuestra se enlazan en tira. La relacion es TOMO_MUESTRAS_EN
			while (((fila = br.readLine()) != null)) {
				
				// Los campos est�n separados por un solo espacio
				fila = fila.replaceAll("\\s+", " ").trim();
				
				atributos = new HashMap<>(50);
				campos = new ArrayList<>(50);
				
				for (String campo : fila.split(" ")) {
					// y creamos los nodos y les asignamos los atributos
					campos.add(campo.replace(",", "."));
				}
				
				// Rellenamos sus atributos
				for (int i = 0; i < etiquetas.size(); i++) {
					atributos.put(etiquetas.get(i), campos.get(i));
					
					// Su leemos GR insertamos el valor ficticio latitud
					if (etiquetas.get(i).equals("GR"))
						atributos.put("latitude", campos.get(i));
					// Si leemos ILD insertamos el valor ficticio longitud
					if (etiquetas.get(i).equals("ILD"))
						atributos.put("longitude", campos.get(i));
				}
				
				// Descartamos el punto que no tenga latitud (ILD) entre +-90 y longitud (GR) entre 0 y 180
				if (!(campos.get(etiquetas.indexOf("ILD")).equals("###") ||
					  campos.get(etiquetas.indexOf("GR")).equals("###")) &&
					coordenadasCorrectas(Float.parseFloat(campos.get(etiquetas.indexOf("ILD"))), 
										 Float.parseFloat(campos.get(etiquetas.indexOf("GR"))))) {
					
					// Ponemos un atributo que identifica al punto GpsMuestra
					atributos.put("gpsmuestra_id", idNodoFile+"_"+campos.get(etiquetas.indexOf("GR"))+"_"+campos.get(etiquetas.indexOf("ILD")));
					
					// y otro archivo para identificar el archivo al que pertenecen los puntos
					atributos.put("file", archivo);
					
					// Insertamos el nodo GpsMuestra
					idNodoGpsMuestra = inserter.createNode( atributos, etiquetaNodoGpsMuestra );
		
					// Guardamos el identificador para evitar crear duplicados
					gpsmuestrass.put( idNodoFile+"_"+campos.get(etiquetas.indexOf("GR"))+"_"+campos.get(etiquetas.indexOf("ILD")), idNodoGpsMuestra);
					
					// Buscamos el si existe creada una relacion TOMO_MUESTRAS_EN entre el Vehiculo y el primer Poi de la l�nea actual
					// en la lista de relaciones EN_RUTA creadas con anterioridad
					if (!tomamuestrasen_creados.isEmpty() && tomamuestrasen_creados.containsKey(idNodoFile+"_"+idNodoGpsMuestra))					
						idRelacionTomaMuestrasEn = tomamuestrasen_creados.get(idNodoFile+"_"+idNodoGpsMuestra);
		            
					// Si no ha sido insertado ya esta relacion TOMO_MUESTRAS_EN, la insertamos
					if (idRelacionTomaMuestrasEn == -1) {
					    atributos = new HashMap<>(50);
		            
						// La primera relaci�n ser� entre el id del File y el primer GpsMuestra
						if (tomamuestrasen_creados.isEmpty())
							idRelacionTomaMuestrasEn = inserter.createRelationship( idNodoFile, idNodoGpsMuestra, tomo_muestras_en, atributos );
						else
							idRelacionTomaMuestrasEn = inserter.createRelationship( idNodoGpsMuestraAnterior, idNodoGpsMuestra, tomo_muestras_en, atributos );
					}
		            
					// Guardamos el identificador para evitar crear duplicados
					tomamuestrasen_creados.put( idNodoFile+"_"+idNodoGpsMuestra, idRelacionTomaMuestrasEn);
		
					idNodoGpsMuestraAnterior = idNodoGpsMuestra;
					idRelacionTomaMuestrasEn = -1;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	// Descartamos el punto que no tenga latitud (ILD) entre +-90 y longitud (GR) entre 0 y 180
	private static boolean coordenadasCorrectas(float latitud, float longitud) {
		return ((latitud >= -90) && (latitud <= 90) && (longitud >= 0) && (longitud <= 180));
	}

	// Leemos los atributos en caso de que sea un archivo de imagen
	private static void leerPropiedadesArchivoImagen(String rutaArchivo) {
        try {

            File file = new File( rutaArchivo );
            ImageInputStream iis = ImageIO.createImageInputStream(file);
            Iterator<ImageReader> readers = ImageIO.getImageReaders(iis);

            if (readers.hasNext()) {

                // pick the first available ImageReader
                ImageReader reader = readers.next();

                // attach source to the reader
                reader.setInput(iis, true);

                // read metadata of first image
                IIOMetadata metadata = reader.getImageMetadata(0);

                String[] names = metadata.getMetadataFormatNames();
                
                int length = names.length;
                String xml = "";
                
                for (int i = 0; i < length; i++) {
                    System.out.println( "Format name: " + names[ i ] );
                    xml = displayMetadata(metadata.getAsTree(names[i]));
                    atrribs.put("image_metadata", xml);
                }
            }
        }
        catch (Exception e) {

            e.printStackTrace();
        }
	}
	
    static String displayMetadata(Node root) {
        return displayMetadata(root, 0);
    }

    static String indent(int level) {
    	String xml = "";
        for (int i = 0; i < level; i++)
            // System.out.print("    ");
        	xml = xml + "    ";
        return xml;
    }

    static String displayMetadata(Node node, int level) {
        // print open tag of element
        indent(level);
        String xml = "";
        //System.out.print("<" + node.getNodeName());
        xml = "<" + node.getNodeName();
        NamedNodeMap map = node.getAttributes();
        if (map != null) {

            // print attribute values
            int length = map.getLength();
            for (int i = 0; i < length; i++) {
                Node attr = map.item(i);
                //System.out.print(" " + attr.getNodeName() +
                //                  "=\"" + attr.getNodeValue() + "\"");
                xml = xml + " " + attr.getNodeName() +
                "=\"" + attr.getNodeValue() + "\"";
            }
        }

        Node child = node.getFirstChild();
        if (child == null) {
            // no children, so close element and return
            // System.out.println("/>");
        	xml = xml + "/>";
            return xml;
        }

        // children, so close current tag
        // System.out.println(">");
        xml = xml + ">";
        
        while (child != null) {
            // print children recursively
            xml = xml + displayMetadata(child, level + 1);
            child = child.getNextSibling();
        }

        // print close tag of element
        xml = xml + indent(level);
        // System.out.println("</" + node.getNodeName() + ">");
        xml = xml + "</" + node.getNodeName() + ">";
        
        return xml;
    }
	

	// Leemos el contenido del archivo de Microsoft Office
	private static String leerContenidoArchivoOffice(String file) {
        String resultado = "";
        FileInputStream fis = null;
        
        try {
	        QuickButCruddyTextExtractor qe = null;
	        qe = new QuickButCruddyTextExtractor(file);
	        
	        resultado = qe.getTextAsString();
        } catch (Exception e) {
            try {
                // Usamos la clase WordExtractor para obtener el texto del documento Word
                WordExtractor we = null;

                fis = new FileInputStream(file);
                
                we = new WordExtractor(fis);
                fis.close();
                
                resultado = we.getText();
            } catch (Exception e1) {
            	try {
            		// Usamos la clase ExcelExtractor para obtener el texto del documento Excel
    	        	ExcelExtractor ee = null;
    	        	HSSFWorkbook wb = new HSSFWorkbook(fis);
    				ee = new ExcelExtractor(wb);
    	        	fis.close();
    	        	
    	        	resultado = ee.getText();
    	        	
            	} catch (Exception e2) {
            		try {
    	        		// Usamos la clase ExcelExtractor para obtener el texto del documento PowerPoint
    		        	PowerPointExtractor pe = new PowerPointExtractor(file);
    					fis.close();
    					
    					resultado = "Texto: "+pe.getText() + " Notas: "+pe.getNotes();
            		} catch (Exception e3) {
            			try {
	            			MAPIMessage msg = new MAPIMessage(file);
	            			// Usamos la clase OutlookTextExtactor para obtener el texto del documento Outlook
							OutlookTextExtactor oe = new OutlookTextExtactor(msg );
	    					
							resultado = oe.getText();
                		} catch (Exception e4) {
                			// The PDF file from where you would like to extract
                			File input = new File(file);
                			
                			PDDocument pd;
							try {
								pd = PDDocument.load(input);
								
								SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");

	                			atrribs.put("page_count", ""+pd.getNumberOfPages());
	                			atrribs.put("author", ""+pd.getDocumentInformation().getAuthor());
	                			atrribs.put("title", ""+pd.getDocumentInformation().getTitle());
	                			atrribs.put("subject", ""+pd.getDocumentInformation().getSubject());
	                			atrribs.put("producer", ""+pd.getDocumentInformation().getProducer());
	                			atrribs.put("modification_date", ""+sdf.format(pd.getDocumentInformation().getModificationDate().getTime()));
	                			atrribs.put("keywords", ""+pd.getDocumentInformation().getKeywords());
	                			atrribs.put("creator", ""+pd.getDocumentInformation().getCreator());
	                			atrribs.put("creation_date", ""+sdf.format(pd.getDocumentInformation().getCreationDate().getTime()));
	                		    if( !pd.isEncrypted() ){
	                		        PDFTextStripperByArea stripper = new PDFTextStripperByArea();
	                		        stripper.setSortByPosition( true );
	                		        PDFTextStripper Tstripper = new PDFTextStripper();
	                		        String st = Tstripper.getText(pd);
	                		        
	                		        atrribs.put("texto", st);
	                		    }
	                			
							} catch (IOException e5) {
								try {
									// Usamos la clase VisioTextExtractor para obtener el texto del documento Visio
									VisioTextExtractor ve = new VisioTextExtractor(fis);
									
				    	        	fis.close();
				    	        	
				    	        	resultado = ve.getText();
				    	        	
								} catch (IOException e7) {
 
								}
								
							}

                		}
    				}
    	        }
            }
        }
        
        return resultado;
    }

	// Podemos leer las propiedades de los archivos de Microsoft Office
	private static void leerPropiedadesArchivoOffice( String file) {
		
        POIFSReader r = new POIFSReader();
        r.registerListener(new MyPOIFSReaderListener(), "\005SummaryInformation");
        try {
			r.read(new FileInputStream(file));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			// e.printStackTrace();
		}
	}
	
    public static HashMap<String, Object> atrribs = new HashMap<>(50);
    
    static class MyPOIFSReaderListener implements POIFSReaderListener
    {
        public void processPOIFSReaderEvent(final POIFSReaderEvent event)
        {
            SummaryInformation si = null;
            try
            {
                si = (SummaryInformation)
                    PropertySetFactory.create(event.getStream());
            }
            catch (Exception ex)
            {
                throw new RuntimeException
                    ("Property set stream \"" +
                     event.getPath() + event.getName() + "\": " + ex);
            }

	         DateFormat df = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");

            if (!si.getApplicationName().equals(null))
            	atrribs.put("application_name", si.getApplicationName());
            atrribs.put("num_char", si.getCharCount());
            if (!si.getComments().equals(null))
            	atrribs.put("comments", si.getComments());
            try {
            	atrribs.put("creation_date", df.format(si.getCreateDateTime()));
            } catch (Exception e) {
            	atrribs.put("creation_date", "");
            }
            atrribs.put("edition_date", df.format(si.getEditTime()));
            // atrribs.put("first_selection", si.getFirstSection());
            atrribs.put("keywords", si.getKeywords());
            atrribs.put("last_author", si.getLastAuthor());
            try {
            	atrribs.put("last_printed", df.format(si.getLastPrinted()));
	        } catch (Exception e) {
	        	atrribs.put("last_printed", "");
	        }
            try {
            	atrribs.put("last_saved_date", df.format(si.getLastSaveDateTime()));
		    } catch (Exception e) {
		    	atrribs.put("last_saved_date", "");
		    }
            atrribs.put("page_count", si.getPageCount());
            // atrribs.put("properties", si.getProperties());
            if (!si.getRevNumber().equals(null))
            	atrribs.put("rev_number", si.getRevNumber());
            if (!si.getSubject().equals(null))
            	atrribs.put("subject", si.getSubject());
            if (!si.getTemplate().equals(null))
                atrribs.put("template", si.getTemplate());
            atrribs.put("word_count",si.getWordCount());
            atrribs.put("author", si.getAuthor());
            atrribs.put("title", si.getTitle());
        }
    }

	// Si el File pertenece a un Group:
	// 1) comprobamos si el Group existe, y lo creamos si no es as�
	// 2) enlazamos el File al Group con la relaci�n PERTENECE_AL_GRUPO
	private static void enlazaArchivoConGrupo(long idNodoFile, String file_name) {
		String fichero;
		String valor;
		Map<String, Object> atributos = new HashMap<>();
	    long idNodoGroup = -1;
	    long idRelacionPerteneceAlGrupo = -1;

		// Recorrer los grupos, crearlos si no existen y enlazarlos
		for (int i = 0; i < groups_temporal.size(); i++) {
			fichero = groups_temporal.get(i).getFile();

			// Si el nombre del File del Group temporal que estamos tratando coincide con el nombre del File
			// que acabamos de insertar, creamos el Group en caso de que no exista y enlazamos File y Group
			// con la relaci�n PERTENECE_AL_GRUPO
			if (fichero.equals(file_name)) {
				// El identificador Group se compone del campo File + el campo localizador
				valor =  groups_temporal.get(i).getFile()+ groups_temporal.get(i).getLocation();
				
				// Buscamos el identificador del Group del registro actual
				// en los nodos de Group que ya han sido insertados
				if (!groups.isEmpty() && groups.containsKey(valor))
					idNodoGroup = groups.get(valor);

				// Si no ha sido insertado ya este nodo Grupo, lo insertamos
				if (idNodoGroup == -1) {
					// Rellenamos los atributos del nodo Vehiculo
					atributos.put( "group_id", valor);
					atributos.put( "area_id", groups_temporal.get(i).getArea_id());
					atributos.put( "coordenate_type", groups_temporal.get(i).getCoordenate_type()==null?"":groups_temporal.get(i).getCoordenate_type());
					atributos.put( "file", groups_temporal.get(i).getFile()==null?"":groups_temporal.get(i).getFile());
					atributos.put( "group_type", groups_temporal.get(i).getGroup_type()==null?"":groups_temporal.get(i).getGroup_type());
					atributos.put( "latitude", groups_temporal.get(i).getLatitude());
					atributos.put( "longitude", groups_temporal.get(i).getLongitude());
					atributos.put( "location", groups_temporal.get(i).getLocation()==null?"":groups_temporal.get(i).getLocation());
					atributos.put( "owner", groups_temporal.get(i).getOwner()==null?"":groups_temporal.get(i).getOwner());
									
					// Insertamos el nodo Group
					idNodoGroup = inserter.createNode( atributos, etiquetaNodoGroup );

					// Guardamos el identificador para evitar crear duplicados
					groups.put( "group_id", idNodoGroup);
					
				}
				
				// Buscamos el si existe creada una relacion PERTENECE_AL_GRUPO entre File que viene como par�metro
				// y el Group de la l�nea actual en la lista de relaciones PERTENECE_AL_GRUPO creadas con anterioridad
				if (!pertenece_al_grupo_creados.isEmpty() && pertenece_al_grupo_creados.containsKey(idNodoFile+"_"+idNodoGroup))
					idRelacionPerteneceAlGrupo = pertenece_al_grupo_creados.get(idNodoFile+"_"+idNodoGroup);
					
				// Si no ha sido insertado ya esta relacion TIENE, la insertamos
				if (idRelacionPerteneceAlGrupo == -1) {
					// Insertamos la relacion TIENE
					idRelacionPerteneceAlGrupo = inserter.createRelationship( idNodoFile, idNodoGroup, pertenece_al_grupo, null );

					// Guardamos el identificador para evitar crear duplicados
					pertenece_al_grupo_creados.put( idNodoFile+"_"+idNodoGroup, idRelacionPerteneceAlGrupo);
				}
			    
				// Reiniciamos 
				idNodoGroup = -1;
				idRelacionPerteneceAlGrupo = -1;
				
				System.out.println("ENLAZAMOS "+idNodoFile+" "+file_name);
			}
		}
	}
	
	
    private static void cargacompanyy() {
    	
	    List<String> campos = new ArrayList<>();
	    List<String> etiquetas = new ArrayList<>();
	    Map<String, Object> atributos = new HashMap<>();
	    
	    // Guardamos los identificadores de los nodos para evitar crear duplicados de una misma clave
	    Map<String, Long> usuarios = new HashMap<>();
	    Map<String, Long> clientes = new HashMap<>();
	    Map<String, Long> vehiculos = new HashMap<>();
	    Map<String, Long> puede_ver_creados = new HashMap<>();
	    Map<String, Long> tiene_creados = new HashMap<>();
	    
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
			
			// Si el vehiculo se encuentra en la lista de POIs del archivo
			if (fila != null) {
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
			
			// Enlazamos el vehiculo con el primero de sus GPS:
			// 1) Buscamos la primera fila del archivo que contiene el vehiculo actual
			while (((fila = br.readLine()) != null) && !fila.contains(vehicle_id)) {}
			
			// Si el veh�culo se encuentra en el archivo de GPSs
			if (fila != null) {
				// 2) Extraemos los campos columna de la primera fila de GPSs del vehiculo
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
				
				// Buscamos el si existe creada una relacion HA_ESTADO_EN entre el Vehiculo y el primer Gps de la l�nea actual
				// en la lista de relaciones HA_ESTADO_EN creadas con anterioridad
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
				
				// A continuaci�n leemos el resto de puntos de inter�s del vehiculo, y los enlazamos al punto Gps inicial
				// HA_ESTADO_EN
				while (((fila = br.readLine()) != null) && fila.contains(vehicle_id)) {
					 					
					atributos = new HashMap<>(50);
					campos = new ArrayList<>(50);
					
					// Extraemos los campos columna de la fila actual de POIs del vehiculo
					for (String campo : fila.split("\\t")) {
						// y creamos los nodos y les asignamos los atributos
						campos.add(campo);
					}
					
					// Rellenamos los atributos del Gps actual
					for (int i = 0; i < etiquetas.size(); i++) {
						atributos.put(etiquetas.get(i), campos.get(i));
					}
					
					atributos.put("gps_id", campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud")));
					
					// Insertamos el nodo Gps actual
					idNodoGps = inserter.createNode( atributos, etiquetaNodoGps );
	
					// Guardamos el identificador para evitar crear duplicados
					gpss.put( campos.get(etiquetas.indexOf("latitud"))+"_"+campos.get(etiquetas.indexOf("longitud")), idNodoGps);
					
					// Buscamos el si existe creada una relacion HA_ESTADO_EN entre el Gps anterior y el Gps de la l�nea actual
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
