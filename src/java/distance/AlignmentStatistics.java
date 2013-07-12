/**
 * AlignmentStatistics.java
 *
 * compute and output statistics about alignment before any distance
 * computations are ever done
 *
 */

import java.io.*;
import java.util.*;
import java.math.*;

public class AlignmentStatistics {
    public static final String ALIGNMENT_PERCENT_BLANKS_MARKER = "ALIGNMENT_PERCENT_BLANKS_MARKER";
    public static final String ALIGNMENT_BLANKS_COUNT = "ALIGNMENT_BLANKS_COUNT";
    public static final String ALIGNMENT_GAPS_COUNT = "ALIGNMENT_GAPS_COUNT";
    public static final String ALIGNMENT_ROWS_COUNT = "ALIGNMENT_ROWS_COUNT";
    public static final String ALIGNMENT_COLUMNS_COUNT = "ALIGNMENT_COLUMNS_COUNT";
    public static final String ALIGNMENT_AVERAGE_GAPS_PER_SEQUENCE = "ALIGNMENT_AVERAGE_GAPS_PER_SEQUENCE";
    // add average gap length
    // average across all sequences, then take that average ->
    // across entire dataset
    public static final String ALIGNMENT_AVERAGE_GAP_LENGTH = "ALIGNMENT_AVERAGE_GAP_LENGTH";
    public static final String ALIGNMENT_STDDEV_GAP_LENGTH = "ALIGNMENT_STDDEV_GAP_LENGTH";
    public static final String ALIGNMENT_MEDIAN_GAP_LENGTH = "ALIGNMENT_MEDIAN_GAP_LENGTH";
    public static final String ALIGNMENT_MNHD = "ALIGNMENT_MNHD";
    public static final String ALIGNMENT_ANHD = "ALIGNMENT_ANHD";

    private static final int ANHD_DECIMAL_PRECISION = 10;

    // nhd == normalized hamming distance (a == average, m == max)
    private NHDResult calculateNHDStatistics (Sequence[] seqs) {
	// maintain counts of columns
	BigDecimal differingColumns = new BigDecimal(0.0);
	BigDecimal totalColumns = new BigDecimal(0.0);
	// mnhd calculation easy - just keep track of max nhd seen so far
	double mnhd = 0.0;

	int numDifferingSites;
	int numSitesNotGapped;
	double nhd;

	for (int i = 0; i < seqs.length; i++) {
	    for (int j = i + 1; j < seqs.length; j++) {
		// too slow - can't do two passes - doubles time
		Utility.NumSiteResult numSiteResult = (new Utility()).getNumDifferingSites(seqs[i].sequence, seqs[j].sequence);
		numDifferingSites = numSiteResult.numDifferingSites;
		numSitesNotGapped = numSiteResult.numSitesNotGapped;

		//numDifferingSites = Utility.getNumDifferingSites(seqs[i].sequence, seqs[j].sequence);
		//numSitesNotGapped = Utility.getNumSitesNotGapped(seqs[i].sequence, seqs[j].sequence);
		differingColumns = differingColumns.add(new BigDecimal(numDifferingSites));
		totalColumns = totalColumns.add(new BigDecimal(numSitesNotGapped));

		nhd = ((double) numDifferingSites) / ((double) numSitesNotGapped);

		// kliu 
		// if numSitesNotGapped == 0
		// -> nhd is NaN
		// and NaN always fails below test!
		// I guess this is fine - just skip over NaNs
		// ANHD is done as (sum of all pairs diff cols) / (sum of all pairs not gapped cols) anyways to cope with this

		if (nhd > mnhd) {
		    mnhd = nhd;
		}
	    }
	}
	
	// anhd is just differingColumns running count divided by total columns running count
	BigDecimal anhdBigDecimal = differingColumns.divide(totalColumns, new MathContext(ANHD_DECIMAL_PRECISION));
	double anhd = anhdBigDecimal.doubleValue();

	NHDResult result = new NHDResult (mnhd, anhd);

	return (result);
    }

    // add mnhd and anhd calculations here
    // calculated on pairwise basis
    private void compute (String inFilename, String outFilename) {
	// switch for FASTA!
	//	Sequence[] seqs = Parser.parseMSA (inFilename);
	Sequence[] seqs = Parser.parseFASTA (inFilename);

	
	if ((seqs == null) || (seqs[0] == null)) {
	    System.err.println ("ERROR: cannot compute stats if alignment empty!!");
	    System.exit(1);
	}
	
	// look at all cols in alignment
	// probably a more efficient way to do this but oh well
	boolean[] colsToIgnore = new boolean[seqs[0].sequence.length()];

	double rows = seqs.length;
	// assume alignment has all rows have same number of columns
	// should be of course
	double cols = seqs[0].sequence.length();
	double numGaps = 0.0;
	for (int i = 0; i < seqs.length; i++) {
	    numGaps += ((double) (Utility.getNumGaps (seqs[i].sequence, colsToIgnore)));
	}
	double averageNumGaps = numGaps / rows;
	double numBlanks = 0.0;
	for (int i = 0; i < seqs.length; i++) {
	    numBlanks += ((double) (Utility.getNumBlanks (seqs[i].sequence)));
	}
	double alignPercentBlanks = numBlanks / (rows * cols);

	// kliu - meh, do this separately
	// from series of gap observations since we need stddev also
	int[] gapLengthHistogram = Utility.getSetwiseGapLengthHistogram(seqs);
	double averageGapLength = 0.0;
	double stddevGapLength = 0.0;
	double medianGapLength = 0.0;
	if (gapLengthHistogram.length > 0) {
	    averageGapLength = Utility.calculateHistogramAverage(gapLengthHistogram);
	    stddevGapLength = Utility.calculateHistogramStddev(gapLengthHistogram);
	    medianGapLength = Utility.calculateHistogramMedian(gapLengthHistogram);
	}

	/*
	// testing
	for (int i = 0; i < gapLengthHistogram.length; i++) {
	    System.out.println (i + " | " + gapLengthHistogram[i]);
	}
	*/

	/*
	// also compute average gap length = 
	// (total blank num) / (total num gaps)
	//
	// if numGaps is zero, just say gap length contrib of zero
	// shouldn't be the case with decent datasets, but just in case
	double averageGapLength = 0.0;
	if (numGaps > 0.0) {
	    averageGapLength = numBlanks / numGaps;
	}
	*/

	NHDResult nhdResult = calculateNHDStatistics(seqs);


	try {
	    FileWriter fw = new FileWriter (outFilename);
	    fw.write(ALIGNMENT_PERCENT_BLANKS_MARKER + Utility.PARSE_SEPARATOR + alignPercentBlanks + "\n");
	    fw.write(ALIGNMENT_BLANKS_COUNT + Utility.PARSE_SEPARATOR + numBlanks + "\n");
	    fw.write(ALIGNMENT_GAPS_COUNT + Utility.PARSE_SEPARATOR + numGaps + "\n");
	    fw.write(ALIGNMENT_ROWS_COUNT + Utility.PARSE_SEPARATOR + rows + "\n");
	    fw.write(ALIGNMENT_COLUMNS_COUNT + Utility.PARSE_SEPARATOR + cols + "\n");
	    fw.write(ALIGNMENT_AVERAGE_GAPS_PER_SEQUENCE + Utility.PARSE_SEPARATOR + averageNumGaps + "\n");
	    fw.write(ALIGNMENT_AVERAGE_GAP_LENGTH + Utility.PARSE_SEPARATOR + averageGapLength + "\n");
	    fw.write(ALIGNMENT_STDDEV_GAP_LENGTH + Utility.PARSE_SEPARATOR + stddevGapLength + "\n");
	    fw.write(ALIGNMENT_MEDIAN_GAP_LENGTH + Utility.PARSE_SEPARATOR + medianGapLength + "\n");
	    fw.write(ALIGNMENT_MNHD + Utility.PARSE_SEPARATOR + nhdResult.mnhd + "\n");
	    fw.write(ALIGNMENT_ANHD + Utility.PARSE_SEPARATOR + nhdResult.anhd + "\n");
	    fw.flush();
	    fw.close();
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	    System.exit(1);
	}

    }

    private static void printUsage() {
	System.err.println ("Usage: java AlignmentStatistics <FASTA alignment file to analyze> <output filename>");
    }

    public static void main (String[] args) {
	if (args.length != 2) {
	    printUsage();
	    System.exit(1);
	}

	AlignmentStatistics as = new AlignmentStatistics();
	as.compute(args[0], args[1]);
    }

    private class NHDResult {
	private double mnhd;
	private double anhd;

	private NHDResult (double mnhd, double anhd) {
	    this.mnhd = mnhd;
	    this.anhd = anhd;
	}
    }
}
