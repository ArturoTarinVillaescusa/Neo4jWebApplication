package bulkloaders;

import java.awt.Desktop;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.metadata.IIOMetadata;
import javax.imageio.stream.ImageInputStream;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.apache.pdfbox.text.PDFTextStripperByArea;
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

public class BatchInserter_companyx_copy_4 {

    // Etiquetas de nodos y relaciones
    private static final Label etiquetaFolder = DynamicLabel.label( "Folder" );
    private static final Label etiquetaFile = DynamicLabel.label( "File" );
    private static final RelationshipType contiene = DynamicRelationshipType.withName( "CONTIENE" );
	public static Map<String, Long> folders = new HashMap<>();
	public static Map<String, Long> files = new HashMap<>();
	public static Map<String, Long> contiene_creados = new HashMap<>();
	
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
			// Creamos una nueva base de datos Neo4j
	        File graphDb = new File("C:\\Users\\Arturo\\Documents\\DISCO_CLUSTER_NEO4J\\companyxv1.graphdb");
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

		    // �ndices
			// CREATE INDEX ON :Folder(folder_id);
		    inserter.createDeferredSchemaIndex( etiquetaFolder ).on( "folder_id" ).create();

			// CREATE INDEX ON :File(file_id);
		    inserter.createDeferredSchemaIndex( etiquetaFolder ).on( "file_id" ).create();

			// Recorremos un arbol de carpetas y generamos una base de datos Neo4j con su contenido
		    File carpeta = new File("C:\\Users\\Arturo\\Documents\\BIG DATA\\CLIENTES\\companyx\\DATA");
		    cargaEstructuraDisco(inserter, carpeta);		    
		    
		} catch (Exception e) {
		        inserter.shutdown();
		}
		inserter.shutdown();
		
		// calcular tiempo transcurrido
		long fin = System.currentTimeMillis();
		
	    System.out.println("Segundos: "+(fin-inicio)/1000);		
	}

	// Recorremos un arbol de carpetas y generamos una base de datos Neo4j con su contenido
	private static void cargaEstructuraDisco(BatchInserter inserter, File carpeta) {
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

	    			cargaEstructuraDisco(inserter, ficheros[x]);
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
    		  			atributos.put("file_type", ficheros[x].getName().substring(ficheros[x].getName().lastIndexOf(".")+1));
    		    		
    		  			// Si es un archivo de texto
    		  			if (atributos.get("file_type").toString().toUpperCase().equals("LAS") ||
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
	    		  			atributos.put("texto", leerContenidoArchivoOffice(ficheros[x].toString()));
	
	    		  			atributos.putAll(atrribs);
    		  			}
    		  			
    		  			// Leemos los atributos en caso de que sea un archivo de imagen
    		  			leerPropiedadesArchivoImagen(ficheros[x].toString());
    		  			atributos.putAll(atrribs);

    		  			// Limpiamos el contenedor de atributos del archivo Office
    		  			atrribs = new HashMap<>(50);
    		  			
    		    		idNodoHijo = inserter.createNode(atributos, etiquetaFile );
    					
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

	                			atrribs.put("num_paginas", ""+pd.getNumberOfPages());
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
			e.printStackTrace();
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

            atrribs.put("application_name", si.getApplicationName());
            atrribs.put("num_char", si.getCharCount());
            atrribs.put("comments", si.getComments());
            atrribs.put("creation_date", df.format(si.getCreateDateTime()));
            atrribs.put("edition_date", df.format(si.getEditTime()));
            // atrribs.put("first_selection", si.getFirstSection());
            atrribs.put("keywords", si.getKeywords());
            atrribs.put("last_author", si.getLastAuthor());
            atrribs.put("last_printed", df.format(si.getLastPrinted()));
            atrribs.put("last_saved_date", df.format(si.getLastSaveDateTime()));
            atrribs.put("page_count", si.getPageCount());
            // atrribs.put("properties", si.getProperties());
            atrribs.put("rev_number", si.getRevNumber());
            atrribs.put("subject", si.getSubject());
            atrribs.put("template", si.getTemplate());
            atrribs.put("word_count",si.getWordCount());
            atrribs.put("author", si.getAuthor());
            atrribs.put("title", si.getTitle());
        }
    }

}
