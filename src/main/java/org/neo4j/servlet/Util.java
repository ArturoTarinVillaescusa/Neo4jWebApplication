package org.neo4j.servlet;

import org.neo4j.rest.graphdb.RestAPI;

import javax.servlet.ServletContext;

public class Util {

	public static final String REST_CONTEXT_KEY = "neo4j-rest-instance";
	
	// Get the REST object instance
    public static RestAPI restInstance(final ServletContext servletContext) {
        final Object restService = servletContext.getAttribute(REST_CONTEXT_KEY);

        if (restService instanceof RestAPI) {
            return (RestAPI) restService;
        }
        throw new RuntimeException("no GraphDatabaseService found in servletContext[" + REST_CONTEXT_KEY + "]," +
                " is the ContextListener configured?");
    }
    
}
