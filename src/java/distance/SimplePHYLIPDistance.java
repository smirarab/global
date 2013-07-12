/**
 * SimplePHYLIPDistance.java
 *
 * Calculate distance using some substitution matrix as
 * taken from PHYLIP's protdist program.
 *
 * Argh, can't find JTT matrix that works. Later, try going back to the
 * original paper.
 * For now, use workaround per Tandy's advice, just do pairwise 
 * distance calc directly using PHYLIP's protdist program.
 *
 * subclasses need to pass additional distance type string to protdist.sh
 * wrapper.
 *
 * Don't even bother with this. Way too slow.
 */

import java.io.*;
import java.util.*;

public abstract class SimplePHYLIPDistance extends SimpleDistance {
    public static final String WORK_MSA_FILE = "/tmp/SimplePHYLIPDistance_WORK_MSA_FILE";
    public static final String WORK_DISTANCE_FILE = "/tmp/SimplePHYLIPDistance_WORK_DISTANCE_FILE";
    public static final String TEMP_PHYLIP_PROTDIST_OUTPUT_FILE = "/tmp/TEMP_PHYLIP_PROTDIST_OUTPUT_FILE";

    public static final String UNIQUE_STRING_FILENAME_SEPARATOR = "_";

    private String workMSAFileString;
    private String workDistanceFileString;
    private String tempPhylipProtdistOutputFileString;

    /**
     * distance x->y
     */
    public SimplePHYLIPDistance () {
	workMSAFileString = WORK_MSA_FILE;
	workDistanceFileString = WORK_DISTANCE_FILE;
	tempPhylipProtdistOutputFileString = TEMP_PHYLIP_PROTDIST_OUTPUT_FILE;
    }

    /**
     * distance x->y
     * adds a unique ID to temporary work filenames to prevent collisions
     * by simultaneously running files
     */
    public SimplePHYLIPDistance (String uniqueFilenameSuffix) {
	workMSAFileString = WORK_MSA_FILE + uniqueFilenameSuffix;
	workDistanceFileString = WORK_DISTANCE_FILE + uniqueFilenameSuffix;
	tempPhylipProtdistOutputFileString = TEMP_PHYLIP_PROTDIST_OUTPUT_FILE + uniqueFilenameSuffix;

    }


    /**
     * override this method to choose distance type for PHYLIP to use
     */
    // could let it default to JTT - but let subclasses decide
    public abstract String getDistanceTypeString ();
    
    /**
     * Two sequences x and y MUST be of the same length, 
     * otherwise this function returns -1
     *
     * columnsToIgnore parameter is NOT USED
     * it just on a pgo basis for pair finds phylip distance
     *
     * this is fine ONLY BECAUSE there is no Nei??? DistanceWithGapMethod
     * class that uses JTT, Dayhoff (or any other SimplePhylipDistance)!!!!
     *
     * need to directly use PHYLIP protdist program as a workaround
     *
     * Also returns -1 if there's some problem with runtime calls, etc.
     */
    public double getDistance(Sequence xs, Sequence ys, boolean[] columnsToIgnore) {
	if (xs.sequence.length() != ys.sequence.length()) {
	    return (-1);
	}
	
	// make writer, process phylip, and parser calls to get back distance
	Writer.writeMSA (xs, ys, workMSAFileString);

	// hopefully this works?
	String currDir = new File(".").getAbsolutePath();

	try {	    
	    // work with wrapper - so much simpler
	    Process proc = Runtime.getRuntime().exec(currDir + "/protdist_wrapper.sh " + workMSAFileString + " " + workDistanceFileString + " " + tempPhylipProtdistOutputFileString + " " + getDistanceTypeString());	 

	    int exitStatus = proc.waitFor();

	    if (exitStatus != 0) {
		System.err.println ("ERROR: PHYLIP wrapper program did not exit normally.");
		System.exit(1);
	    }

	    double distance = Parser.parsePairPHYLIPDistanceResultFile (workDistanceFileString);

	    // clean temporary work files
	    cleanTemporaryWorkFiles();
	    
	    return (distance);
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	    return (-1.0);
	}
	catch (InterruptedException ie) {
	    System.err.println (ie);
	    return (-1.0);
	}
    }

    private void cleanTemporaryWorkFiles () {
	try {
	    // hopefully this works?
	    String currDir = new File(".").getAbsolutePath();
	    
	    Process proc = Runtime.getRuntime().exec("rm " + workMSAFileString);	 
	    
	    int exitStatus = proc.waitFor();
	    
	    if (exitStatus != 0) {
		System.err.println ("ERROR: removing workMSAFile failed.");
		System.exit(1);
	    }

	    proc = Runtime.getRuntime().exec("rm " + workDistanceFileString);	 
	    
	    exitStatus = proc.waitFor();
	    
	    if (exitStatus != 0) {
		System.err.println ("ERROR: removing workDistanceFile failed.");
		System.exit(1);
	    }
	    
	    proc = Runtime.getRuntime().exec("rm " + tempPhylipProtdistOutputFileString);	 
	    
	    exitStatus = proc.waitFor();
	    
	    if (exitStatus != 0) {
		System.err.println ("ERROR: removing tempPhylipProtdistOutputFile failed.");
		System.exit(1);
	    }
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	}
	catch (InterruptedException ie) {
	    System.err.println (ie);
	}

	
    }


    // um ok
    /*
    public static void test1 () {
	String x = "ARNDND--NDRYVVY-------VY---V-V-V-V-";
	String y = "DRYVYVVY--Y-Y-Y-Y-Y--ARND-Y-Y------";
	Sequence xs = new Sequence(); xs.sequence = x; xs.name = "BLAH";
	Sequence ys = new Sequence(); ys.sequence = y; ys.name = "BLAHBLAHBL";
	SimplePHYLIPJTTDistance d = new SimplePHYLIPJTTDistance ();
	System.out.println ("distance is: |" + d.getDistance(xs, ys, null) + "|");
    }

    public static void main (String[] args) {
	test1();
    }
    */
}



