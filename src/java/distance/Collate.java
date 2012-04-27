import java.io.*;
import java.lang.reflect.*;
import java.util.*;

/**
 * This file averages across all dataset iterations for a particular align-distance-zstring-estimation method on a particular dataset.
 * 
 *
 * It dumps into a single file the results.
 *
 * Added the additional reporting of dataset, method, and gsfm per result.
 * Although data is repeated, this will make dumping to a single oocalc
 * spreadsheet much easier.
 */

public class Collate {
    public static final String RAWRESULTS_FILENAME_RESULTS_PREFIX = "results";
    public static final String FINAL_FILENAME_FINAL_PREFIX = "final";
    
    public static final String RAWRESULTS_FILENAME_SEPARATOR = "$";

    public static final String FINAL_RESULTS_SEPARATOR = "\t";

    public static final String DIRECTORY_SEPARATOR = "/";

    // parsed from input filename
    private String path;
    private String datasetdir;
    private String alignMethod;
    private String distanceMethod;
    private String zstring;
    private String estimationMethod;

    // just filenames 
    private String inputFilename;
    private String outputFilename;

    private double getAverage (double[] results) {
	// for safety
	if (results.length <= 0) {
	    return (0.0);
	}

        double sum = 0.0;
	for (int i = 0; i < results.length; i++) {
	    sum += results[i];
	}

	// testing
	//System.out.println (sum);

	return (((double) sum) / ((double) results.length));
    }

    // ok - this is fine
    private double getStandardDeviation (double[] results) {
	double average = getAverage (results);
	// lazy
	double squaredaverage = 0.0;
	if (results.length > 0) {
	    double squaredsum = 0.0;
	    for (int i = 0; i < results.length; i++) {
		squaredsum += (results[i] * results[i]);
	    }
	    squaredaverage = (squaredsum / ((double) results.length));
	}

	double sd = Math.sqrt(squaredaverage - (average * average));

	return (sd);
    }

    // filename prefix should have dataset name/method name
    private void outputAverageAndStandardDeviation (Result[] r, Field f, FileWriter fw) {
	try {
	    double[] d = new double[r.length];
	
	    // testing
	    //System.out.println (f.getName());

	    for (int i = 0; i < d.length; i++) {
		// hopefully this works??
		d[i] = f.getDouble(r[i]);

		// testing
		//System.out.println (d[i] = f.getDouble(r[i]));
	    }
	    
	    double da = getAverage(d);
	    double dsd = getStandardDeviation(d);
	    
	    fw.write (datasetdir + FINAL_RESULTS_SEPARATOR + alignMethod + FINAL_RESULTS_SEPARATOR + distanceMethod + FINAL_RESULTS_SEPARATOR + zstring + FINAL_RESULTS_SEPARATOR + estimationMethod + FINAL_RESULTS_SEPARATOR + f.getName() + FINAL_RESULTS_SEPARATOR + da + FINAL_RESULTS_SEPARATOR + dsd + "\n");
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	    System.exit(1);
	}
	catch (IllegalAccessException iae) {
	    System.err.println (iae);
	    System.exit(1);
	}
    }

    // pathname something like 
    // <path>/results!<datasetdir>!<alignMethod>!<distanceMethod>!<zstring>!<estimationMethod>
    private void parseInputFilename (String pathname) {
	this.inputFilename = parseInputFilenameOutOfFullPathname(pathname);
	int pathEndIndex = pathname.lastIndexOf(this.inputFilename);
	this.path = pathname.substring(0, pathEndIndex);
	
	// set output filename
	StringBuffer sb = new StringBuffer(this.inputFilename);
	sb.delete(0, RAWRESULTS_FILENAME_RESULTS_PREFIX.length());
	// no - just have client supply it
	//this.outputFilename = FINAL_FILENAME_FINAL_PREFIX + sb.toString();

	// now parse out pieces of inputFilename
	StringTokenizer st = new StringTokenizer (this.inputFilename.trim(), RAWRESULTS_FILENAME_SEPARATOR);

	st.nextToken(); // result
	this.datasetdir = st.nextToken();
	this.alignMethod = st.nextToken();
	this.distanceMethod = st.nextToken();
	this.zstring = st.nextToken();
	this.estimationMethod = st.nextToken();
    }

    // rips out filename from full pathname
    private String parseInputFilenameOutOfFullPathname (String pathname) {
	StringTokenizer st = new StringTokenizer (pathname, "/");
	String filename = "";
	while (st.hasMoreTokens()) {
	    filename = st.nextToken();
	}

	return (filename);
    }

    private void test () {
	System.out.println ("path: |" + path + "|");
	System.out.println ("inputFilename: |" + inputFilename + "|");
	System.out.println ("outputFilename: |" + outputFilename + "|");
	System.out.println ("datasetdir: " + datasetdir + "|");
	System.out.println ("alignMethod: " + alignMethod + "|");
	System.out.println ("distanceMethod: " + distanceMethod + "|");
	System.out.println ("zstring: " + zstring + "|");
	System.out.println ("estimationMethod: " + estimationMethod + "|");

    }

    public void collate (String pathname, String finalfilename) {
	// small helper function to rip out necessary info from filename passed in
	parseInputFilename (pathname);

	// testing
	//test();

	this.outputFilename = finalfilename;
	
	Result[] results = Parser.parseSymmetricDistanceResultsFile(pathname);
	// must be cleaner way to do this
	Field[] resultFields = Result.class.getFields();
	
	try {
	    // write into 1 file -> not as many files
	    // crazy now
	    // force append
	    FileWriter fw = new FileWriter (this.path + DIRECTORY_SEPARATOR + this.outputFilename, true);
	    
	    for (int i = 0; i < resultFields.length; i++) {
		outputAverageAndStandardDeviation (results, resultFields[i], fw);
	    }
	    
	    fw.flush();
	    fw.close();
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	    System.exit(1);
	}
	
    }

    private void test2() {
	double[] stat = { 0.0, -1.0, 2.5, 3.667, 1.7 };
	System.out.println ("average: " + getAverage(stat));
	System.out.println ("sd: " + getStandardDeviation(stat));
    }

    /*
    public static void main (String[] args) {
	Collate c = new Collate();
	c.test2();
    }
    */

    
    public static void main (String[] args) {
	Collate c = new Collate();
	if (args.length != 2) {
	    System.out.println ("Usage: java Collate <collated symmetric distance input full pathname> <final results filename>");
	    System.exit(1);
	}
	c.collate(args[0], args[1]);
    }
    
}
