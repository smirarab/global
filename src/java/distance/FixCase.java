/**
 * FixCase.java
 * really simple class to make all characters in a file upper case
 */

import java.io.*;
import java.util.*;

public class FixCase 
{
    private static void fixCase (String infilename, String outfilename) {
	try {
	    FileWriter fw = new FileWriter(outfilename);
	    BufferedReader br = new BufferedReader (new FileReader (infilename));
	    String line = "";
	    while ((line = br.readLine()) != null) {
		fw.write (line.toUpperCase()); fw.write ("\n");
	    }
	    fw.flush();
	    fw.close();
	    
	    br.close();
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	    return;
	}
    }

    public static void main (String[] args) {
	if (args.length != 2) {
	    System.err.println ("Usage: java FixCase <input file> <output file with all contents in upper case>");
	}

	fixCase (args[0], args[1]);
    }
}
