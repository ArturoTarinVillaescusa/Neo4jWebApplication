package org.neo4j.servlet;

import java.io.IOException;
import java.util.Properties;

import org.neo4j.rest.graphdb.RestAPI;
import org.neo4j.rest.graphdb.RestAPIFacade;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

public class Neo4JContextListener implements ServletContextListener {

	// Url and credentials to use the Neo4j database through REST web services
	private static String URL_NEO4J = "http://localhost:7474/db/data";
	private static String USUARIO = "neo4j";
	private static String CLAVE = "arturo";
	
	// Servlet constructor
    public void contextInitialized(final ServletContextEvent sce) {
        final ServletContext servletContext = sce.getServletContext();

        initRestObjectInstance(servletContext);
    }

    // Servlet disposer
    public void contextDestroyed(final ServletContextEvent sce) {
        final ServletContext servletContext = sce.getServletContext();

        disposeRestObjectInstance(servletContext);
    }

    // Init the REST object instance
    void initRestObjectInstance(final ServletContext servletContext) {

    	Properties properties = new Properties();
        
        try {
			properties.load(this.getClass().getClassLoader().getResourceAsStream("neo4j.properties"));
			
			URL_NEO4J = (String) properties.get("url");
			USUARIO = (String) properties.get("usuario");
			CLAVE = (String) properties.get("clave");
			
	        final RestAPI restPointerToGraphDb = new RestAPIFacade(URL_NEO4J, USUARIO, CLAVE);    
	        
	        servletContext.setAttribute(Util.REST_CONTEXT_KEY, restPointerToGraphDb);
		} catch (IOException e) {
			System.out.println("ServiceProperties::initProperties ---> " +e.toString());
		}
        
    }

    // Dispose the REST object instance
    void disposeRestObjectInstance(final ServletContext servletContext) {
        try {
            RestAPI restInstance = Util.restInstance(servletContext);
            restInstance.close();
        } catch (Exception e) {
            System.out.println("Neo4jContentListener::disposeRestObjectInstance ==> "+e.getMessage());
        }
    }
    
}
