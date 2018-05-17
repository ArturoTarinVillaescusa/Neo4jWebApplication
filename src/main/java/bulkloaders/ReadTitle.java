/* ====================================================================
   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
==================================================================== */

package bulkloaders;

import java.io.FileInputStream;
import java.io.IOException;

import org.apache.poi.POIOLE2TextExtractor;
import org.apache.poi.POITextExtractor;
import org.apache.poi.extractor.ExtractorFactory;
import org.apache.poi.hdgf.extractor.VisioTextExtractor;
import org.apache.poi.hpsf.PropertySetFactory;
import org.apache.poi.hpsf.SummaryInformation;
import org.apache.poi.hslf.extractor.PowerPointExtractor;
import org.apache.poi.hssf.extractor.ExcelExtractor;
import org.apache.poi.hwpf.extractor.WordExtractor;
import org.apache.poi.poifs.eventfilesystem.POIFSReader;
import org.apache.poi.poifs.eventfilesystem.POIFSReaderEvent;
import org.apache.poi.poifs.eventfilesystem.POIFSReaderListener;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;

/**
 * <p>Sample application showing how to read a OLE 2 document's
 * title. Call it with the document's file name as command line
 * parameter.</p>
 *
 * <p>Explanations can be found in the HPSF HOW-TO.</p>
 *
 * @author Rainer Klute <a
 * href="mailto:klute@rainer-klute.de">&lt;klute@rainer-klute.de&gt;</a>
 */
public class ReadTitle
{
    /**
     * <p>Runs the example program.</p>
     *
     * @param args Command-line arguments. The first command-line argument must
     * be the name of a POI filesystem to read.
     * @throws IOException if any I/O exception occurs.
     */
    public static void main(final String[] args) throws IOException
    {
        final String filename = "C:\\Users\\Arturo\\Documents\\BIG DATA\\CLIENTES\\companyx\\Proposal_companyx_V01.doc";
        POIFSReader r = new POIFSReader();
        r.registerListener(new MyPOIFSReaderListener(),
                           "\005SummaryInformation");
        r.read(new FileInputStream(filename));
        System.out.println(a);
        
        FileInputStream fis = new FileInputStream(filename);
        POIFSFileSystem fileSystem = new POIFSFileSystem(fis);
        
        // Firstly, get an extractor for the Workbook
        try {
	        POIOLE2TextExtractor oleTextExtractor = 
	           ExtractorFactory.createExtractor(fileSystem);
	        // Then a List of extractors for any embedded Excel, Word, PowerPoint
	        // or Visio objects embedded into it.
	        POITextExtractor[] embeddedExtractors =
	           ExtractorFactory.getEmbededDocsTextExtractors(oleTextExtractor);
	        
	        for (POITextExtractor textExtractor : embeddedExtractors) {
	            // If the embedded object was an Excel spreadsheet.
	            if (textExtractor instanceof ExcelExtractor) {
	               ExcelExtractor excelExtractor = (ExcelExtractor) textExtractor;
	               System.out.println(excelExtractor.getText());
	            }
	            // A Word Document
	            else if (textExtractor instanceof WordExtractor) {
	               WordExtractor wordExtractor = (WordExtractor) textExtractor;
	               String[] paragraphText = wordExtractor.getParagraphText();
	               for (String paragraph : paragraphText) {
	                  System.out.println(paragraph);
	               }
	               // Display the document's header and footer text
	               System.out.println("Footer text: " + wordExtractor.getFooterText());
	               System.out.println("Header text: " + wordExtractor.getHeaderText());
	            }
	            // PowerPoint Presentation.
	            else if (textExtractor instanceof PowerPointExtractor) {
	               PowerPointExtractor powerPointExtractor =
	                  (PowerPointExtractor) textExtractor;
	               System.out.println("Text: " + powerPointExtractor.getText());
	               System.out.println("Notes: " + powerPointExtractor.getNotes());
	            }
	            // Visio Drawing
	            else if (textExtractor instanceof VisioTextExtractor) {
	               VisioTextExtractor visioTextExtractor = 
	                  (VisioTextExtractor) textExtractor;
	               System.out.println("Text: " + visioTextExtractor.getText());
	            }
	         }
	        
    	} catch (Exception e) {
        	e.printStackTrace();
        }
        
    }

    public static String a;
    
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
            final String title = si.getTitle();
            System.out.println(si.getApplicationName());
            System.out.println(si.getAuthor());
            System.out.println(si.getCharCount());
            System.out.println(si.getComments());
            System.out.println(si.getCreateDateTime());
            System.out.println(si.getEditTime());
            System.out.println(si.getFirstSection());
            System.out.println(si.getKeywords());
            System.out.println(si.getLastAuthor());
            System.out.println(si.getLastPrinted());
            System.out.println(si.getLastSaveDateTime());
            System.out.println(si.getPageCount());
            System.out.println(si.getProperties());
            System.out.println(si.getRevNumber());
            System.out.println(si.getSubject());
            System.out.println(si.getTemplate());
            System.out.println(si.getTitle());
            System.out.println(si.getWordCount());
            a= "Author "+si.getAuthor()+", Title: \"" + title + "\"";
            if (title != null)
                System.out.println("Title: \"" + title + "\"");
            else
                System.out.println("Document has no title.");
        }
    }

}
