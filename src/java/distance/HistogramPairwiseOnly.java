/**
 *
 * Histogram.java
 * Need to compute histogram of gap distributions on pairwise basis
 *
 * STANDALONE
 * For use ONLY with real world datasets, where we examine some reference
 * alignment but don't have a true tree/true tree internal nodes, true
 * tree edge lengths, etc.
 **/

import java.io.*;
import java.util.*;

public class HistogramPairwiseOnly
{
    public static final String HISTOGRAM_FIELD_DATA_SEPARATOR = "\t";

    public static final String PAIRWISE_TAXA_SUFFIX = "_PAIRWISE_TAXA";
    public static final String EDGEWISE_SUFFIX = "_EDGEWISE_SUFFIX";

    private void compute (String infilename, String outfilename) {
	// accumulator of gap lengths count
	// pairwise taxa on true alignment
	Vector<Integer> gapLengthsPairwiseTaxaCount = new Vector<Integer>();

	accumulateGapLengthsPairwiseTaxaCount (infilename, gapLengthsPairwiseTaxaCount);

	   

	int[] pairwiseTaxaResult = Utility.convert(gapLengthsPairwiseTaxaCount);

	dump(pairwiseTaxaResult, outfilename + PAIRWISE_TAXA_SUFFIX);

    }

    private void accumulateGapLengthsPairwiseTaxaCount (String singleAlignmentFilename, Vector<Integer> gapLengthsPairwiseTaxaCount) {
	Sequence[] seqs = Parser.parseMSA (singleAlignmentFilename);
		    
	if ((seqs == null) || (seqs[0] == null)) {
	    System.err.println ("ERROR: cannot compute stats if alignment empty!!");
	    // strict
	    System.exit(1);
	}
	
	Utility.getGapLengths(seqs, gapLengthsPairwiseTaxaCount);

    }

    private void dump (int[] gapLengthsPairwiseTaxaCount, String outfilename) {
	FileWriter fw;

	try {
	    fw = new FileWriter (outfilename);
	    for (int i = 0; i < gapLengthsPairwiseTaxaCount.length; i++) {
		fw.write (i + HISTOGRAM_FIELD_DATA_SEPARATOR + gapLengthsPairwiseTaxaCount[i] + "\n");
	    }
	    fw.flush();
	    fw.close();
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	}
    }

    // append to single file
    // hrm... going to have to kludge this
    // here's what we're going to do
    // instead of trying to make persistant store of histogram to update
    // as we make running gap length counts across multiple alignments,
    // let's just take in a list of input alignment filenames
    public static void main (String[] args) 
    {
	if (args.length != 2) {
	    System.err.println ("Usage: java HistogramPairwiseOnly <alignment input filename> <output results filename>");
	    System.exit(1);
	}

	HistogramPairwiseOnly histogram = new HistogramPairwiseOnly();
	histogram.compute (args[0], args[1]);
    }
}
