/**
 * Simple class to clean newlines in FASTA format files.
 */

import java.util.*;
import java.io.*;

public class Cleaner 
{
    public static final String SEQUENCE_NAME_MARKER = ">";
    public static final String NEWLINE = "";

    private static void run (String infilename, String outfilename) {
	try {
	    BufferedReader br = new BufferedReader(new FileReader(infilename));
	    String line = "";

	    FileWriter fw = new FileWriter (outfilename);

	    while ((line = br.readLine()) != null) {
		if (line.startsWith(SEQUENCE_NAME_MARKER)) {
		    // just output it 
		    fw.write(line + "\n");
		}
		else if (line.trim().equals(NEWLINE)) {
		    fw.write("\n");
		}
		else {
		    // it's part of current sequence
		    // remove newline
		    fw.write(line.trim());
		}
	    }

	    br.close();
	    fw.flush();
	    fw.close();
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	    
	}
    }

    public static void main (String[] args) {
	run (args[0], args[1]);
    }
}
