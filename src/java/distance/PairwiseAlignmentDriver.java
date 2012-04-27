import java.text.*;
import java.io.*;
import java.util.*;

/**
 * Usage: java PairwiseAlignmentDriver 
 * Forces a symmetric matrix by only considering matrix entries [i,j] for i < j
 *
 * added GSFM (gap scaling factor multiplier) z parameter, separated by commas
 *
 * Uses pairwise alignments created from input raw sequences.
 *
 * Alter this later for dna/aa pairalign option.
 */

// may want to alter class hierarchy later
// make an abstract superclass or something like that
// we're going to override run here
public class PairwiseAlignmentDriver extends Driver {

    // hmm.. might need to change this later?
    public static final int PAIRWISE_ALIGNMENT_GAP_OPEN_COST = 10;
    public static final int PAIRWISE_ALIGNMENT_GAP_EXTEND_COST = 1;
    
    // override superclass's version of this method
    // need to replace this in PairwiseAlignmentDriver
    public static void run (String infile, String outfile, String statsOutFile, String distanceMeasureString, String gapScalingFactorMultipliersString) {

	// testing
	//System.out.println ("zallstring that I heard in Driver.java: |" + gapScalingFactorMultipliersString + "|");

	double[] gapScalingFactorMultipliers = parseGapScalingFactorMultipliersString (gapScalingFactorMultipliersString);
	//Sequence[] seqs = Parser.parseMSA(infile);

	// raw seqs from FASTA file
	Sequence[] seqs = Parser.parseFASTA(infile);

	// arg - to satisfy compiler
	double[][] distances = new double[0][0];

	DistanceWithGapMethod distance = getDistanceWithGapMethod (distanceMeasureString);

	if (distance instanceof GappedDistance) {
	    GappedDistance gappedDistance = (GappedDistance) distance;
	    // do this cache set only once per all GSFM settings
	    gappedDistance.cacheSetSimpleDistanceMatricesPairwise(seqs);
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
	else if (distance instanceof PairwiseGapOmitDistance) { // no caching of simple distances for non-gapped distance methods
	    if ((gapScalingFactorMultipliers.length != 1) || (gapScalingFactorMultipliers[0] != 0.0)) {
		printUsage();
		System.exit(1);
	    }

	    PairwiseGapOmitDistance pgoDistance = (PairwiseGapOmitDistance) distance;

	    String gsfmFilenameSuffix = GSFM_FILENAME_DELIMITER + gapScalingFactorMultipliers[0];

	    // change printwriter to filename
	    changePrintWriter (statsOutFile + gsfmFilenameSuffix);

	    distances = pgoDistance.getDistanceMatrixPairwise (seqs);
	    Writer.writePhylipDistanceMatrix(seqs, distances, outfile + gsfmFilenameSuffix);

	    flushAndClosePrintWriter();

	}
	else {
	    System.err.println ("ERROR: distance measure " + distanceMeasureString + " not supported!");
	}

    }



    
    public static void printUsage () {
	System.out.println ("Usage: java PairwiseAlignmentDriver <raw input sequences in FASTA format> <output distance matrix filename> <stats output filename> <distance measure to use: nei_hamming | gapped_hamming | pgo_hamming | gapped_jtt | pgo_jtt | nei_jtt | gapped_dayhoff | pgo_dayhoff | nei_dayhoff | nei_model | gapped_model | pgo_model | norm_hamming | affine_<model|jtt|dayhoff>,<gapOpenPenalty>,<gapExtendPenalty>> <gap scaling factor multiplier z values, separated by commas, e.g. 0.1,1.0,10.0 nongapped distances need 0.0!!!>");
    }

    public static void main (String[] args) {
	
	if (args.length != 5) {
	    printUsage();
	    System.exit(1);
	}

	PairwiseAlignmentDriver.run(args[0], args[1], args[2], args[3], args[4]);
	
    }
}





