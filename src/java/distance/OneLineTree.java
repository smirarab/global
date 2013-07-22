import java.io.*;
import java.util.*;

public class OneLineTree 
{
    public static void run (String infilename, String outfilename) {
	try {
	    BufferedReader br = new BufferedReader (new FileReader (infilename));
	    String line = "";
	    FileWriter fw = new FileWriter (outfilename);

	    while ((line = br.readLine()) != null) {
		fw.write(line.trim());
	    }
	    fw.write("\n");

	    fw.flush();
	    fw.close();
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	}
    }

    public static void main (String[] args) {
	run(args[0], args[1]);
    }
}
