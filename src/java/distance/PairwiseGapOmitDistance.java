/**
 * Contains common functionality for pairwise gap omit correction 
 * based distances.
 *
 * Oops - really care about blanks, not really gaps - for this correction.
 */


public abstract class PairwiseGapOmitDistance extends DistanceWithGapMethod
{
    protected SimpleDistance simpleDistance;

    public PairwiseGapOmitDistance () {
	initializeSimpleDistance();
    }

    // concrete subclasses must override this to specify this simple
    // distance type
    protected abstract void initializeSimpleDistance ();

    protected GapResult getPairwiseGappedColumnFlags (Sequence xs, Sequence ys) {
	return (getPairwiseGappedColumnFlags(xs.sequence, ys.sequence));
    }

    // Get gapped columns for this pair of sequences only!!
    // returns null signalling error
    //
    // make this protected since maybe subclasses want to use this
    protected GapResult getPairwiseGappedColumnFlags (String xs, String ys) {

	if ((xs.length() != ys.length()) || (xs.length() == 0)) {
	    return (null);
	}

	// all sequences in MSA should be same length
	boolean[] gappedColumnFlags = new boolean[xs.length()];
	int numGaps = 0;

	// paranoid
	for (int i = 0; i < gappedColumnFlags.length; i++) {
	    gappedColumnFlags[i] = false;
	}
	
	// process pair - all indices with gaps set on flag
	for (int i = 0; i < xs.length(); i++) {
	    if (xs.charAt(i) == Utility.BLANK_CHAR) {
		gappedColumnFlags[i] = true;
	    }
	}

	for (int i = 0; i < ys.length(); i++) {
	    if (ys.charAt(i) == Utility.BLANK_CHAR) {
		gappedColumnFlags[i] = true;
	    }
	}

	// count total number of gaps for this pair
	for (int i = 0; i < gappedColumnFlags.length; i++) {
	    if (gappedColumnFlags[i]) {
		numGaps++;
	    }
	}

	GapResult gr = new GapResult();
	gr.gappedColumnFlags = gappedColumnFlags;
	gr.numGaps = numGaps;

	return (gr);
    }

    // helper method - process MSA into distance matrix
    //
    // need special global treatment for gaps - find all MSA columns
    // with gaps and flag them - ignore these columns (indices) for pairwise
    // distance calculation purposes
    public double[][] getDistanceMatrix(Sequence[] seqs) {
	double[][] d = new double[seqs.length][seqs.length];
	boolean[] gappedColumnFlags;
	GapResult gr;
	int totalNumGaps = 0;

	// testing
	/*
	for (int i = 0; i < gappedColumnFlags.length; i++) {
	    Driver.println (i + ": " + gappedColumnFlags[i]);
	}
	*/

	for (int i = 0; i < seqs.length; i++) {
	    for (int j = i; j < seqs.length; j++) {
		if (i == j) {
		    d[i][j] = 0.0;
		}
		else {
		    // all sequences in MSA should be same length
		    gr = getPairwiseGappedColumnFlags(seqs[i], seqs[j]);
		    gappedColumnFlags = gr.gappedColumnFlags;
		    totalNumGaps += gr.numGaps;

		    d[i][j] = simpleDistance.getDistance(seqs[i], seqs[j], gappedColumnFlags);

		}
	    }
	}

	// apply fix factor 1 correction
	applyFixFactorOneCorrection(d);

	// now reflect upper triangular matrix
	reflect(d);


	// testing
	outputPercentColumnsIgnored(totalNumGaps, seqs[0].sequence.length() * seqs.length * (seqs.length - 1));

	// now need to output total cells in MSA matrix ignored based on 
	// pairwise gap omit
	// instead of column omit percentage for Nei correction
	// still works out to gaps ignored percentage in both cases

	// more reporting
	Driver.println (MAX_DISTANCE_WITH_GAP_METHOD_FLAG + " | " + getMax(d));
	Driver.println (AVERAGE_DISTANCE_WITH_GAP_METHOD_FLAG + " | " + getAverage(d));


	return (d);
    }

    // this doesn't even make sense for pairwise alignments
    // but leave it in for symmetry
    //
    // special version to work with pairwise alignments
    //
    // helper method - process MSA into distance matrix
    //
    // need special global treatment for gaps - find all MSA columns
    // with gaps and flag them - ignore these columns (indices) for pairwise
    // distance calculation purposes
    public double[][] getDistanceMatrixPairwise (Sequence[] seqs) {
	// change this later
	Substitution sub = new EDNAFull();

	double[][] d = new double[seqs.length][seqs.length];

	// testing
	/*
	for (int i = 0; i < gappedColumnFlags.length; i++) {
	    Driver.println (i + ": " + gappedColumnFlags[i]);
	}
	*/

	// too slow - assume symmetric and reflect
	for (int i = 0; i < seqs.length; i++) {
	    for (int j = i; j < seqs.length; j++) {
		// explicitly - probably not needed though
		if (i == j) {
		    d[i][j] = 0.0;
		}
		else {
		    NWAffine nwaffine = new NWAffine(sub, 
						     PairwiseAlignmentDriver.PAIRWISE_ALIGNMENT_GAP_OPEN_COST, 
						     PairwiseAlignmentDriver.PAIRWISE_ALIGNMENT_GAP_EXTEND_COST, 
						     seqs[i].sequence, 
						     seqs[j].sequence);
		    String[] match = nwaffine.getMatch();
		    boolean[] gappedColumnFlags = (getPairwiseGappedColumnFlags(match[0], match[1])).gappedColumnFlags;
		    
		    d[i][j] = simpleDistance.getDistance(match[0], match[1], gappedColumnFlags);
		}
	    }
	}

	// apply fix factor 1 correction
	applyFixFactorOneCorrection(d);

	// now reflect upper triangular matrix
	reflect(d);


	// testing
	// omit this for now
	//outputPercentColumnsIgnored(gappedColumnFlags);

	// more reporting
	Driver.println (MAX_DISTANCE_WITH_GAP_METHOD_FLAG + " | " + getMax(d));
	Driver.println (AVERAGE_DISTANCE_WITH_GAP_METHOD_FLAG + " | " + getAverage(d));

	return (d);
    }


    // make available to subclasses just in case they need it....
    // e.g. for overridden methods above
    protected void outputPercentColumnsIgnored (int totalNumGaps, int totalNumSequencesExaminedChars) {
	// not counted correctly
	// counting number of blanks for all pairs of sequences
	// need to divide by the total number of characters for all pairs of sequences examined
	// should be seqs[0].sequence.length() * (n permute 2), where n is seqs.length
	// since we go through all ordered pairs (ordered sub lists) above
	// and (n permute k) k-ordered subsets out of n already doesn't
	// allow two of the same into a pair due to subsetting
	double percentColumnsIgnored = ((double) totalNumGaps) / ((double) totalNumSequencesExaminedChars);

	// testing
	Driver.println (Parser.GAPPED_COLUMNS_IGNORED_OUTPUT_FLAG + " | " + percentColumnsIgnored + " | " + totalNumGaps + " | " + totalNumSequencesExaminedChars + " | ... uses cells not cols ...");

    }

}




