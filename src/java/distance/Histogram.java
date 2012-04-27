/**
 *
 * Histogram.java
 * Need to compute histogram of gap distributions on pairwise basis
 *
 **/

import java.io.*;
import java.util.*;

public class Histogram 
{
    public static final String HISTOGRAM_FIELD_DATA_SEPARATOR = "\t";

    public static final String PAIRWISE_TAXA_SUFFIX = "_PAIRWISE_TAXA";
    public static final String EDGEWISE_SUFFIX = "_EDGEWISE_SUFFIX";

    private void compute (String infilename, String outfilename) {
	// accumulator of gap lengths count
	// pairwise taxa on true alignment
	Vector<Integer> gapLengthsPairwiseTaxaCount = new Vector<Integer>();
	// edgewise on true tree 
	Vector<Integer> gapLengthsEdgewiseCount = new Vector<Integer>();

	try {
	    // format is 1 input alignment filename per line
	    BufferedReader br = new BufferedReader(new FileReader(infilename));
	    String line = "";
	    
	    while ((line = br.readLine()) != null) {
		if (line != "") {

		    // kliu testing
		    //System.out.println ("Currently processing histogram manifest file line: |" + line + "|");

		    // tokenize on whitespace
		    StringTokenizer tok = new StringTokenizer (line.trim());
		    // first token is true alignment without internal sequences
		    String alignmentWithoutInternalSequencesFile = tok.nextToken();

		    // kliu testing
		    //System.out.println ("Accumulating pairwise counts...");

		    accumulateGapLengthsPairwiseTaxaCount (alignmentWithoutInternalSequencesFile, gapLengthsPairwiseTaxaCount);

		    // second token is true tree with internal sequences
		    String trueTreeWithInternalSequencesFile = tok.nextToken();
		    // third token is true alignment with internal sequences
		    String trueAlignmentWithInternalSequencesFile = tok.nextToken();

		    System.out.println ("Accumulating edgewise counts...");

		    accumulateGapLengthsEdgewiseCount (trueTreeWithInternalSequencesFile, trueAlignmentWithInternalSequencesFile, gapLengthsEdgewiseCount);
		}
	    }	    
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	    // strict
	    System.exit(1);
	}

	int[] pairwiseTaxaResult = Utility.convert(gapLengthsPairwiseTaxaCount);
	int[] edgewiseResult = Utility.convert(gapLengthsEdgewiseCount);

	// kliu testing
	//System.out.println ("Dumping results...");

	dump(pairwiseTaxaResult, outfilename + PAIRWISE_TAXA_SUFFIX);
	dump(edgewiseResult, outfilename + EDGEWISE_SUFFIX);

	System.out.println ("done.");

    }

    private void accumulateGapLengthsEdgewiseCount (String trueTreeWithInternalSequencesFile, String trueAlignmentWithInternalSequencesFile, Vector<Integer> gapLengthsEdgewiseCount) {
	// hmmm - need to check for null reference error here?
	// perhaps edges don't line up??

	// both contain internal sequences!!!
	TreeNode trueTree = Parser.parseNewickTreeFile(trueTreeWithInternalSequencesFile);
	Sequence[] trueAlign = Parser.parseMSA (trueAlignmentWithInternalSequencesFile);
	Parser.populateTreeWithSequences(trueTree, trueAlign);

	// ok, now for each of the O(n) edges in the true tree, check
	// each edge's induced pairwise alignment and count gap lengths
	// on that pairwise alignment, accumulate that count
	// into the histogram vector gapLengthsEdgewiseCount
	//
	// walk the tree
	accumulateGapLengthsEdgewiseCountHelper (trueTree, null, gapLengthsEdgewiseCount);
    }

    // walk the tree - if parent is null, then called with the root - 
    // no accumulate for root
    //
    // ok, now for each of the O(n) edges in the true tree, check
    // each edge's induced pairwise alignment and count gap lengths
    // on that pairwise alignment, accumulate that count
    // into the histogram vector gapLengthsEdgewiseCount
    private void accumulateGapLengthsEdgewiseCountHelper (TreeNode tn, TreeNode parent, Vector<Integer> gapLengthsEdgewiseCount) {

	// for safety, but should never call with tn null
	if (tn == null) {
	    return;
	}
	
	if (parent == null) {
	    // this is the root - no incoming parent edge for the root
	    // thus no accumulate for the root
	    for (int i = 0; i < tn.getChildren().size(); i++) {
		TreeNode child = tn.getChildren().get(i);
		accumulateGapLengthsEdgewiseCountHelper (child, tn, gapLengthsEdgewiseCount);
	    }
	}
	else {
	    // this is not the root - leaf BC, o/w recurse
	    // in both cases accumulate
	    // first accumulate
	    Utility.getGapLengths(tn.getSequence(), parent.getSequence(), gapLengthsEdgewiseCount);

	    // then recurse if not a leaf
	    for (int i = 0; i < tn.getChildren().size(); i++) {
		TreeNode child = tn.getChildren().get(i);
		accumulateGapLengthsEdgewiseCountHelper (child, tn, gapLengthsEdgewiseCount);
	    }
	}
    }

    private void accumulateGapLengthsPairwiseTaxaCount (String singleAlignmentFilename, Vector<Integer> gapLengthsPairwiseTaxaCount) {
	
	// kliu testing
	//System.out.println ("Pairwise parsing MSA...");

	Sequence[] seqs = Parser.parseMSA (singleAlignmentFilename);
		    
	if ((seqs == null) || (seqs[0] == null)) {
	    System.err.println ("ERROR: cannot compute stats if alignment empty!!");
	    // strict
	    System.exit(1);
	}
	
	System.out.println ("Getting gap lengths...");

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
	    System.err.println ("Usage: java Histogram <input filename with list of all filenames of all true alignments/true tree with internal seqs/true alignments with internal seqs to examine, 1 line per like <true alignment> <true tree with internal seqs> <true alignment with internal seqs>> <output results filename>");
	    System.exit(1);
	}

	Histogram histogram = new Histogram();
	histogram.compute (args[0], args[1]);
    }
}
