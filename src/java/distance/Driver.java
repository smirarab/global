import java.text.*;
import java.io.*;
import java.util.*;

/**
 * Usage: java Driver 
 * Forces a symmetric matrix by only considering matrix entries [i,j] for i < j
 *
 * added GSFM (gap scaling factor multiplier) z parameter, separated by commas
 */

public class Driver {
    public static PrintWriter pw = new PrintWriter(System.out);

    // distances parameterized by two different things - 
    // 1. gap treatment type - Nei, Tandy's gap use, PGO, and WNG (not used)
    // 2. amino acid subsitution cost type - Hamming, LiSan, LiSanSpecialized, JTT

    public static final String NEI_HAMMING_DISTANCE_MEASURE = "nei_hamming";
    public static final String GAPPED_HAMMING_DISTANCE_MEASURE = "gapped_hamming";
    // PGO stands for pairwise gap omit - the third type of gap treatment
    // first type of gap treatment is Nei's - globally delete all gapped columns
    // second type of gap treatment is Tandy's - include count
    // third type is PGO - pairwise delete gapped columns and work on rest of columns substitution cost only
    public static final String PGO_HAMMING_DISTANCE_MEASURE = "pgo_hamming";

    /**
     * AA distances
     */
    public static final String NEI_JTT_DISTANCE_MEASURE = "nei_jtt";
    public static final String PGO_JTT_DISTANCE_MEASURE = "pgo_jtt";
    public static final String GAPPED_JTT_DISTANCE_MEASURE = "gapped_jtt";
    public static final String AFFINE_JTT_DISTANCE_MEASURE = "affine_jtt";

    
    public static final String NEI_DAYHOFF_DISTANCE_MEASURE = "nei_dayhoff";
    public static final String PGO_DAYHOFF_DISTANCE_MEASURE = "pgo_dayhoff";
    public static final String GAPPED_DAYHOFF_DISTANCE_MEASURE = "gapped_dayhoff";
    public static final String AFFINE_DAYHOFF_DISTANCE_MEASURE = "affine_dayhoff";



    /**
     * WARNING - Driver doesn't do anything to check that the dataset you're
     * working with is of the same DNA || AA type as the distance
     * measure you're using
     *
     * need to manually make sure they match!!!!
     */
    public static final String NEI_MODEL_DISTANCE_MEASURE = "nei_model";
    public static final String GAPPED_MODEL_DISTANCE_MEASURE = "gapped_model";
    public static final String PGO_MODEL_DISTANCE_MEASURE = "pgo_model";

    // add in affine distances
    public static final String AFFINE_MODEL_DISTANCE_MEASURE = "affine_model";

    // kind of a hack - 
    // add this just to get at dataset's normalized hamming distance 
    // average and max
    public static final String NORMALIZED_SIMPLE_HAMMING_DISTANCE_MEASURE = "norm_hamming";

    /**
     * for parsing of GSFM z parameter string
     */
    public static final String GSFM_PARAMETER_DELIMITER = ",";

    /**
     * for output filenames with gsfm
     */
    public static final String GSFM_FILENAME_DELIMITER = ".";

    /**
     * for parsing of extra parameters attached to distance measure strings
     **/
    public static final String DISTANCE_MEASURE_STRING_PARAMETER_DELIMITER = ",";
    
    protected static double[] parseGapScalingFactorMultipliersString (String gapScalingFactorMultipliersString) {
	StringTokenizer tok = new StringTokenizer (gapScalingFactorMultipliersString, GSFM_PARAMETER_DELIMITER);
	Vector<Double> vec = new Vector<Double>();
	while (tok.hasMoreTokens()) {
	    Double gsfm = new Double(Double.parseDouble(tok.nextToken()));
	    vec.add(gsfm);
	}

	double[] result = new double[vec.size()];
	for (int i = 0; i < result.length; i++) {
	    result[i] = ((Double) (vec.get(i))).doubleValue();
	}
	
	return (result);
    }

    // only for use in this class
    // parse out other parameters in affine distance measure string
    // no - only 1 pair of gap penalties per affine distance measure instance!!!
    // too complicated to match up output files otherwise
    protected static GapPenalties parseAffineDistanceMeasureStringParameters (String affineDistanceMeasureString) {
	GapPenalties gp = new GapPenalties();
	StringTokenizer tok = new StringTokenizer (affineDistanceMeasureString, DISTANCE_MEASURE_STRING_PARAMETER_DELIMITER);
	try {
	    // first should be distance measure name
	    tok.nextToken();
	    // second token should be gap open penalty
	    gp.gapOpenPenalty = Double.parseDouble(tok.nextToken());
	    // third token should be gap extend penalty
	    gp.gapExtendPenalty = Double.parseDouble(tok.nextToken());
	}
	catch (Exception e) {
	    System.err.println (e);
	    System.err.println ("ERROR: improperly formatted affine distance measure string! Recheck parameter list for affine distance measure!");
		
	}

	return (gp);
    }

    protected static DistanceWithGapMethod getDistanceWithGapMethod (String distanceMeasureString) {
	// initialize with default to satisfy compiler warning variable may not have been initialized
	// sigh
	DistanceWithGapMethod distance = new NormalizedSimpleHammingDistance();
	// change this later
	// chain extra parameters along distance measure name
	if (distanceMeasureString.trim().startsWith(GAPPED_HAMMING_DISTANCE_MEASURE)) {
	    distance = new GappedHammingDistance();
	}
	else if (distanceMeasureString.trim().startsWith(NEI_HAMMING_DISTANCE_MEASURE)) {
	    distance = new NeiHammingDistance();
	}
	else if (distanceMeasureString.trim().startsWith(PGO_HAMMING_DISTANCE_MEASURE)) {
	    distance = new PairwiseGapOmitHammingDistance();
	}
	else if (distanceMeasureString.trim().startsWith(AFFINE_JTT_DISTANCE_MEASURE)) {
	    distance = new AffineJTTDistance();
	}
	else if (distanceMeasureString.trim().startsWith(GAPPED_JTT_DISTANCE_MEASURE)) {
	    distance = new GappedJTTDistance();
	}
	else if (distanceMeasureString.trim().startsWith(PGO_JTT_DISTANCE_MEASURE)) {
	    distance = new PairwiseGapOmitJTTDistance();
	}
	else if (distanceMeasureString.trim().startsWith(NEI_JTT_DISTANCE_MEASURE)) {
	    distance = new NeiJTTDistance();
	}
	else if (distanceMeasureString.trim().startsWith(AFFINE_DAYHOFF_DISTANCE_MEASURE)) {
	    distance = new AffineDayhoffDistance();
	}
	else if (distanceMeasureString.trim().startsWith(GAPPED_DAYHOFF_DISTANCE_MEASURE)) {
	    distance = new GappedDayhoffDistance();
	}
	else if (distanceMeasureString.trim().startsWith(PGO_DAYHOFF_DISTANCE_MEASURE)) {
	    distance = new PairwiseGapOmitDayhoffDistance();
	}
	else if (distanceMeasureString.trim().startsWith(NEI_DAYHOFF_DISTANCE_MEASURE)) {
	    distance = new NeiDayhoffDistance();
	}
	else if (distanceMeasureString.trim().startsWith(GAPPED_MODEL_DISTANCE_MEASURE)) {
	    distance = new GappedModelDistance();
	}
	else if (distanceMeasureString.trim().startsWith(NEI_MODEL_DISTANCE_MEASURE)) {
	    distance = new NeiModelDistance();
	} 
	else if (distanceMeasureString.trim().startsWith(PGO_MODEL_DISTANCE_MEASURE)) {
	    distance = new PairwiseGapOmitModelDistance();
	}
	else if (distanceMeasureString.trim().startsWith(AFFINE_MODEL_DISTANCE_MEASURE)) {
	    distance = new AffineModelDistance();
	}
	else if (distanceMeasureString.trim().startsWith(NORMALIZED_SIMPLE_HAMMING_DISTANCE_MEASURE)) {
	    distance = new NormalizedSimpleHammingDistance();
	}
	else {
	    printUsage();
	    System.exit(1);
	}

	return (distance);

    }

    public static void run (String infile, String outfile, String statsOutFile, String distanceMeasureString, String gapScalingFactorMultipliersString) {

	// testing
	//System.out.println ("zallstring that I heard in Driver.java: |" + gapScalingFactorMultipliersString + "|");

	double[] gapScalingFactorMultipliers = parseGapScalingFactorMultipliersString (gapScalingFactorMultipliersString);
	Sequence[] seqs = Parser.parseMSA(infile);

	// arg - to satisfy compiler
	double[][] distances = new double[0][0];

	DistanceWithGapMethod distance = getDistanceWithGapMethod(distanceMeasureString);

	// unfortunately, for cache get/set - no easy way of outputting
	// to stats file if logdet distance error occurred??
	// so just output to STDOUT
	if (distance instanceof GappedDistance) {
	    GappedDistance gappedDistance = (GappedDistance) distance;
	    // do this cache set only once per all GSFM settings
	    gappedDistance.cacheSetSimpleDistanceMatrices(seqs);
	    // rerun for all gsfm settings as necessary
	    for (int i = 0; i < gapScalingFactorMultipliers.length; i++) {
		double gsfm = gapScalingFactorMultipliers[i];

		// testing
		//System.out.println (gsfm);

		String gsfmOutfile = outfile + GSFM_FILENAME_DELIMITER + (new Double(gsfm)).toString();
		String gsfmStatsOutfile = statsOutFile + GSFM_FILENAME_DELIMITER + (new Double(gsfm)).toString();
		
		// change printwriter to new filename
		changePrintWriter (gsfmStatsOutfile);

		distances = gappedDistance.cacheGetDistanceMatrix (gsfm);
		Writer.writePhylipDistanceMatrix(seqs, distances, gsfmOutfile);

		flushAndClosePrintWriter();
	    }
	}
	// LATER ADD IN PARAMETERIZING PASS IN MULTIPLE GAP OPEN/EXTEND
	// PARAMETER COSTS FOR AFFINE DISTANCES
	else if (distance instanceof AffineDistance) {
	    // parse out rest of parameters from distanceMeasureString
	    GapPenalties gapPenalties = parseAffineDistanceMeasureStringParameters(distanceMeasureString);

	    AffineDistance affineDistance = (AffineDistance) distance;
	    // do this cache set only once per all GSFM settings
	    affineDistance.cacheSetSimpleDistanceMatrices(seqs);
	    // rerun for all gsfm settings as necessary
	    // affine distance params
	    // concatenated onto affine distance name
	    for (int i = 0; i < gapScalingFactorMultipliers.length; i++) {
		double gsfm = gapScalingFactorMultipliers[i];
		    
		    String gsfmOutfile = outfile + GSFM_FILENAME_DELIMITER + (new Double(gsfm)).toString();
		    String gsfmStatsOutfile = statsOutFile + GSFM_FILENAME_DELIMITER + (new Double(gsfm)).toString();
		    
		    // WARNING - MUST MUST MUST have this set 
		    // appropriately for both gsfm AND affine penalties!!!
		    // change printwriter to new filename
		    changePrintWriter (gsfmStatsOutfile);
		    
		    distances = affineDistance.cacheGetDistanceMatrix (gsfm, gapPenalties.gapOpenPenalty, gapPenalties.gapExtendPenalty);
		    Writer.writePhylipDistanceMatrix(seqs, distances, gsfmOutfile);
		    
		    flushAndClosePrintWriter();
	    }
	}
	else { // no caching of simple distances for non-gapped distance methods
	    if ((gapScalingFactorMultipliers.length != 1) || (gapScalingFactorMultipliers[0] != 0.0)) {
		printUsage();
		System.exit(1);
	    }

	    String gsfmFilenameSuffix = GSFM_FILENAME_DELIMITER + gapScalingFactorMultipliers[0];

	    // change printwriter to filename
	    changePrintWriter (statsOutFile + gsfmFilenameSuffix);

	    distances = distance.getDistanceMatrix (seqs);
	    Writer.writePhylipDistanceMatrix(seqs, distances, outfile + gsfmFilenameSuffix);

	    flushAndClosePrintWriter();

	}

    }

    /**
     * for stat reporting
     */
    public static void changePrintWriter (String filename) {
	try {
	    pw = new PrintWriter (filename);
	}
	catch (FileNotFoundException fnfe) {
	    System.err.println (fnfe);
	    pw = new PrintWriter (System.out);
	}
    }

    public static void println (String s) {
	pw.println (s);
    }

    public static void println (double d) {
	pw.println (d);
    }

    public static void println () {
	pw.println ();
    }


    public static void print (String s) {
	pw.print (s);
    }

    public static void flushAndClosePrintWriter () {
	pw.flush();
	pw.close();
    }
    
    public static void test1 () {
	Sequence[] seqs = Parser.test1();
	double[][] distances = (new GappedHammingDistance()).getDistanceMatrix(seqs);
	DecimalFormat f = new DecimalFormat ("0000.000");

	System.out.println ("   " + seqs.length);

	
	for (int i = 0; i < seqs.length; i++) {
	    System.out.print (seqs[i].name);
	    for (int k = 0; k < 10 - seqs[i].name.length(); k++) {
		System.out.print (" ");
	    }
	    System.out.print ("  ");
	    int cols = 1;
	    for (int j = 0; j < seqs.length; j++) {
		if (i != j) {
		    int di = i;
		    int dj = j;
		    // force symmetric matrix - arg - what the???
		    // testing!!!
		    if (j > i) { di = j; dj = i; }
		    double d = distances[di][dj];
		    // testing
		    if (d > 2000) {
			System.err.println ("ARGH");
		    }
		    System.out.print (f.format(d));
		}
		else {
		    System.out.print (f.format(0));
		}
		System.out.print ("  ");
		cols++;
		if (cols >= 7) {
		    System.out.println ();
		    System.out.print ("  ");
		    cols = 0;
		}
	    }
	    if (cols != 7) {
		System.out.println();
	    }
	}
	
    }
    
    public static void printUsage () {
	// not used anymore
	// nei_lisan | nei_lisan_special
	// gapped_lisan | gapped_lisan_special
	// pgo_lisan | pgo_lisan_special
	// not used anymore
	// wng_hamming | wng_lisan | wng_lisan_special
	System.out.println ("Usage: java Driver <input MSA alignment file in PHYLIP format> <output distance matrix filename> <stats output filename> <distance measure to use: nei_hamming | gapped_hamming | pgo_hamming | gapped_jtt | pgo_jtt | nei_jtt | gapped_dayhoff | pgo_dayhoff | nei_dayhoff | nei_model | gapped_model | pgo_model | norm_hamming | affine_<model|jtt|dayhoff>,<gapOpenPenalty>,<gapExtendPenalty>> <gap scaling factor multiplier z values, separated by commas, e.g. 0.1,1.0,10.0 nongapped distances need 0.0!!!>");
    }

    public static void main (String[] args) {
	//test1();

	
	if (args.length != 5) {
	    printUsage();
	    System.exit(1);
	}

	run(args[0], args[1], args[2], args[3], args[4]);
	
    }
}





