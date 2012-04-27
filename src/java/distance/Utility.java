import java.io.*;
import java.util.*;

/**
 * Utility.java
 *
 * contains utility functions used by various classes.
 */

public class Utility {
    public static final String PARSE_SEPARATOR = " | ";
    public static final String PARSE_SEPARATOR_TOKEN = "|";
    public static final char BLANK_CHAR = '-';

    // maybe these gap ops should go into utility class??
    public static int getNumGaps (String x, boolean[] bothGappedFlags) {
	int numGaps = 0;
	//int totalGapLength = 0;
	boolean gapOpen = false;

	for (int i = 0; i < x.length(); i++) {
	    // don't even worry about this index if both strings gapped here
	    if (bothGappedFlags[i]) {
		continue;
	    }

	    char c = x.charAt(i);
	    if (c == BLANK_CHAR) {
		if (!gapOpen) {
		    gapOpen = true;
		    numGaps++;
		}
		//totalGapLength++;
	    }
	    else { // c != BLANK_CHAR
		if (gapOpen) {
		    gapOpen = false;
		}
	    }
	}


	return (numGaps);
    }

    public static boolean[] getBothGapped (String x, String y) {
	boolean[] bothGappedFlags = new boolean[x.length()];

	for (int i = 0; i < x.length(); i++) {
	    char xc = x.charAt(i);
	    char yc = y.charAt(i);
	    if ((xc == BLANK_CHAR) && (yc == BLANK_CHAR)) {
		bothGappedFlags[i] = true;
	    }
	    else {
		// paranoid
		bothGappedFlags[i] = false;
	    }
	}

	return (bothGappedFlags);
    }

    /**
     * Get all gaps for a pair of strings. No need to worry about pairwise
     * gap considerations.
     */
    public static int getNumGaps (String x, String y) {
	// ignore all positions with both characters blanks
	boolean[] bothGappedFlags = getBothGapped (x, y);

	// first contribution to cost is inserting gaps into first sequence
	// only count gaps as locations where one string has blanks but not
	// the other
	int xNumGaps = getNumGaps(x, bothGappedFlags);
	int yNumGaps = getNumGaps(y, bothGappedFlags);

	return (xNumGaps + yNumGaps);
    }

    public static int getNumBlanksPairwiseOmitBothBlanks (String x, String y) {
	// ignore all positions with both characters blanks
	boolean[] bothGappedFlags = getBothGapped (x, y);

	int numBlanks = getNumBlanks(x, bothGappedFlags) + getNumBlanks(y, bothGappedFlags);

	return (numBlanks);
    }

    // accumulate counts into gapLengthsCount
    public static void getGapLengths (Sequence[] s, Vector<Integer> gapLengthsCount) {
	if (gapLengthsCount == null) {
	    gapLengthsCount = new Vector<Integer>();
	}

	for (int i = 0; i < s.length; i++) {
	    for (int j = i + 1; j < s.length; j++) {

		getGapLengths (s[i].sequence, s[j].sequence, gapLengthsCount);
	    }

	    // kliu testing
	    //System.out.println ("Utility.getGapLengths i just finished: " + i + "|");

	}

    }
    

    // helper function to convert vector of integers to int array
    public static int[] convert (Vector<Integer> gapLengthsCount) {
	int[] result = new int[gapLengthsCount.size()];
	for (int i = 0; i < gapLengthsCount.size(); i++) {
	    if (gapLengthsCount.get(i) != null) {
		result[i] = gapLengthsCount.get(i).intValue();
	    }
	    else {
		result[i] = 0; // no gaps of this length encountered
	    }
	}

	return (result);

    }

    // for pairwise use! not setwise!
    /** 
     * Get lengths of all pairwise gaps (omitting both blank columns) and accumulate into a histogram array
     * e.g. array[1] = count of gaps with length 1, etc.
     * For examining statistics about gap length distribution
     * Use passed in gapLengthsCount and add to it as histogram array
     */
    public static void getGapLengths (String x, String y, Vector<Integer> gapLengthsCount) {
	if (gapLengthsCount == null) {
	    return;
	}

	boolean[] bothGappedFlags = getBothGapped (x, y);

	getGapLengths (x, gapLengthsCount, false, bothGappedFlags);
	getGapLengths (y, gapLengthsCount, false, bothGappedFlags);

    }

    // another flag to disable the bothGappedFlags action
    private static void getGapLengths (String x, Vector<Integer> gapLengthsCount, boolean disableBothGappedFlagsCheck, boolean[] bothGappedFlags) {
	//int numGaps = 0;
	boolean gapOpen = false;
	int gapLength = 0;

	for (int i = 0; i < x.length(); i++) {
	    // don't even worry about this index if both strings gapped here
	    if (!disableBothGappedFlagsCheck && bothGappedFlags[i]) {
		continue;
	    }

	    char c = x.charAt(i);
	    if (c == BLANK_CHAR) {
		if (!gapOpen) {
		    gapOpen = true;
		    //numGaps++;
		    gapLength++;
		}
		else {
		    // extending current gap
		    gapLength++;
		}
	    }
	    else { // c != BLANK_CHAR
		if (gapOpen) {
		    gapOpen = false;

		    // current gap finished with gapLength
		    // increment 
		    incrementSingleGapLength (gapLengthsCount, gapLength);

		    // reset gapLength
		    gapLength = 0;
		}
	    }
	}

	// if string ends in a gap, consider it closed and increment count
	if (gapOpen && (gapLength > 0)) {
	    // no need but oh well
	    gapOpen = false;

	    // last gap finished with gapLength
	    // increment 
	    incrementSingleGapLength (gapLengthsCount, gapLength);

	    gapLength = 0;
	}

	
    }

    private static void incrementSingleGapLength (Vector<Integer> gapLengthsCount, int gapLength) {
	if (gapLengthsCount == null) {
	    return;
	}

	if (gapLengthsCount.size() < gapLength + 1) {
	    gapLengthsCount.setSize(gapLength + 1);
	}

	if (gapLengthsCount.get(gapLength) == null) {
	    gapLengthsCount.set(gapLength, new Integer(0));
	}

	// increment it - should exist now
	gapLengthsCount.set(gapLength, gapLengthsCount.get(gapLength) + 1);
    }
    
    // for stats program
    public static int getNumBlanks (String x) {
	int numBlanks = 0;
	for (int i = 0; i < x.length(); i++) {
	    if (x.charAt(i) == BLANK_CHAR) {
		numBlanks++;
	    }
	}
	return (numBlanks);
    }

    // ignore positions at particular positions - helper function for above
    public static int getNumBlanks (String x, boolean[] bothGappedFlags) {
	int numBlanks = 0;
	for (int i = 0; i < x.length(); i++) {
	    if ((x.charAt(i) == BLANK_CHAR) && (!bothGappedFlags[i])) {
		numBlanks++;
	    }
	}
	return (numBlanks);
    }
    
    // pass by reference - use reference types for integer primitive type

    // simple utility function to check and see number of columns at which
    // site differs for two sequences
    // both sequences must have the SAME LENGTH, otherwise returns -1
    //
    public NumSiteResult getNumDifferingSites (String x, String y) {
	int diff = 0;
	int cols = 0;

	if (x.length() != y.length()) {
	    return (null);
	}

	for (int i = 0; i < x.length(); i++) {
	    char xc = x.charAt(i);
	    char yc = y.charAt(i);
	    
	    // need to do hamming distance? 
	    // this means count positions that have different 
	    // characters (blanks/gaps included?? is this so???)
	    if ((xc != Utility.BLANK_CHAR) && (yc != Utility.BLANK_CHAR)) {
		cols++;

		if (xc != yc) {
		    diff++;
		}
	    }
	}

	// return 2 results via pass by reference result parameters 
	NumSiteResult result = new NumSiteResult(diff, cols);
	
	return (result);
    }
    
    // above functions seem to be pairwise biased
    // have a separate setwise gap length histogram counter
    public static int[] getSetwiseGapLengthHistogram (Sequence[] seqs) {
	Vector<Integer> counts = new Vector<Integer>();

	// foreach good
	for (Sequence seq : seqs) {
	    getGapLengths(seq.sequence, counts, true, null);
	}

	// now just convert over to ints
	Integer[] intarray = new Integer[counts.size()];
	intarray = counts.toArray(intarray);

	int [] results = new int[counts.size()];

	for (int i = 0; i < intarray.length; i++) {
	    if (intarray[i] != null) {
		results[i] = intarray[i].intValue();
	    }
	    else {
		results[i] = 0;
	    }
	}

	return (results);
    }

    // calculates the average of an array of observations
    public static int calculateHistogramNumObservations (int[] histogram) {
	int numObservations = 0;
	for (int i = 0; i < histogram.length; i++) {
	    numObservations += histogram[i];
	}
	return (numObservations);
    }

    // calculates the average of an array of observations
    public static double calculateHistogramAverage (int[] histogram) {
	double result = 0.0;
	int numObservations = 0;
	for (int i = 0; i < histogram.length; i++) {
	    result += ((double) i * histogram[i]);
	    numObservations += histogram[i];
	}
	return (result / ((double) numObservations));
    }

    // E[X^2]
    private static double calculateHistogramAverageObservationSquared (int[] histogram) {
	double result = 0.0;
	int numObservations = 0;
	for (int i = 0; i < histogram.length; i++) {
	    result += ((double) i * i * histogram[i]);
	    numObservations += histogram[i];
	}
	return (result / ((double) numObservations));
    }

    public static double calculateHistogramStddev (int[] histogram) {
	double mean = calculateHistogramAverage(histogram);
	return (Math.sqrt(calculateHistogramAverageObservationSquared(histogram) - mean * mean));
    }

    public static double calculateHistogramMedian (int[] histogram) {
	int numObservations = calculateHistogramNumObservations(histogram);
	int middle = numObservations / 2;
	if (numObservations % 2 == 1) {
	    return (getHistogramObservation(histogram, middle));
	}
	else {
	    return ((getHistogramObservation(histogram, middle) + getHistogramObservation(histogram, middle - 1)) / 2.0);
	}
    }

    // get ith observation value
    protected static int getHistogramObservation (int[] histogram, int obs) {
	int count = 0;
	for (int i = 0; i < histogram.length; i++) {
	    count += histogram[i];
	    if (count >= (obs + 1)) {
		return (i);
	    }
	}
	System.err.println ("ERROR: could not find observation " + obs + "!");
	// safe value
	return (0);
    }

    // ok - histogram helper functions seem to work ok
    private static void test () {
	Sequence[] s = new Sequence[3];
	
	for (int i = 0; i < s.length; i++) {
	    s[i] = new Sequence();
	}

	s[0].sequence = "SJH----ASD----WWEWE----WEWQREWR----"; s[0].name = "one";
	s[1].sequence = "ERWER----WERWE--ER--ERERE----ERERER"; s[0].name = "two";
	s[2].sequence = "WEREWRWERWER----------EWREWR--E-E-E"; s[0].name = "three";

	Vector<Integer> gapLengthsCount = new Vector<Integer>();
	getGapLengths (s, gapLengthsCount);
	int[] histogram = convert(gapLengthsCount);

	for (int i = 0; i < histogram.length; i++) {
	    System.out.println (i + ": " + histogram[i]);
	}
    }

    public static void main (String[] args) {
	test();
    }

    public class NumSiteResult {
	public int numDifferingSites;
	public int numSitesNotGapped;
	
	public NumSiteResult (int numDifferingSites, int numSitesNotGapped) {
	    this.numDifferingSites = numDifferingSites;
	    this.numSitesNotGapped = numSitesNotGapped;
	}
    }
}
