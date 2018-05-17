package org.neo4j.servlet.rest;

import org.neo4j.graphdb.Transaction;
import org.neo4j.rest.graphdb.RestAPI;
import org.neo4j.rest.graphdb.query.QueryEngine;
import org.neo4j.rest.graphdb.query.RestCypherQueryEngine;
import org.neo4j.rest.graphdb.util.QueryResult;
import org.neo4j.servlet.Util;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Collections;
import java.util.Iterator;
import java.util.Map;

public class CypherServlet extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doGet(final HttpServletRequest request, final HttpServletResponse response) throws IOException, ServletException {
        doPost(request, response);
    }

    protected void doPost(final HttpServletRequest request, final HttpServletResponse response) throws javax.servlet.ServletException, IOException {
   		consultaCyper(request, response);
    }

    // Launch a Cypher query to the Neo4j database using REST Web Services
    @SuppressWarnings("deprecation")
	public void consultaCyper(HttpServletRequest request, HttpServletResponse response) throws ServletException {
    	// Obtain the JSP parameter into a String variable
        String texto_consulta = request.getParameter("consultaCypher");
        final String pantalla = request.getParameter("pantalla");
        final String fichero = request.getParameter("fichero");
        
        // Obtain the REST object instance
        final RestAPI restPointerToGraphDb = Util.restInstance(getServletContext());
        
        // Neo4j accomplishes ACID transactions. Let's make our query Atomic, Consistent, Isolated, Durable
        Transaction tx = restPointerToGraphDb.beginTx();
        
		QueryEngine engine=new RestCypherQueryEngine(restPointerToGraphDb);  
        
    	QueryResult<Map<String,Object>> result;
    	
		// Mark the isolated transaction block
		tx = restPointerToGraphDb.beginTx();
        try {
        	// Cypher query execution
        	result=engine.query(texto_consulta, Collections.EMPTY_MAP);
        	
            // Push the result into a variable to feed the result display jsp page
            request.setAttribute("listaNodosResult", result);
            
            // Push also the selected speed limit, to put it in the queries generated in the next form
            request.setAttribute("fichero", fichero);

            // Submit to same _<pantalla>.jsp: remove the "_" character
            if (pantalla.startsWith("_"))
            	getServletConfig().getServletContext().getRequestDispatcher("/indice.jsp#/"+pantalla.substring(1)).forward(request,response);
            else
	            // Forward to the corresponding resultado<pantalla>.jsp to display the result of the query
	            getServletConfig().getServletContext().getRequestDispatcher("/resultado"+pantalla+".jsp").forward(request,response);            
            
        } catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
            tx.finish();
        }
    }

    // For more methods see the CreateSimpleGraph.java sample
}
