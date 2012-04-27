/**
 * Contains common functionality for Nei correction based distances.
 */

public abstract class NeiDistance extends DistanceWithGapMethod
{
    // let subclasses initialize this!!
    protected SimpleDistance simpleDistance;

    public NeiDistance () {
	initializeSimpleDistance();
    }
    
    protected abstract void initializeSimpleDistance ();
	// need to initialize simple distance used

    private boolean[] getGappedColumnFlags (Sequence[] seqs) {
	String[] s = new String[seqs.length];
	for (int i = 0; i < seqs.length; i++) {
	    s[i] = seqs[i].sequence;
	}
	return (getGappedColumnFlags (s));
    }

    // global across entire MSA - just need to report once per dataset instance
    private boolean[] getGappedColumnFlags (String[] seqs) {
	// should be fine
	if (seqs.length <= 0) {
	    System.err.println ("ERROR: number of sequences in MSA must be at least one!");
	    System.exit(1);
	}

	// all sequences in MSA should be same length
	boolean[] gappedColumnFlags = new boolean[seqs[0].length()];

	// paranoid
	for (int i = 0; i < gappedColumnFlags.length; i++) {
	    gappedColumnFlags[i] = false;
	}
	
	// process entire MSA - all indices with gaps set on global flag
	for (int i = 0; i < seqs.length; i++) {
	    for (int j = 0; j < seqs[i].length(); j++) {
		if (seqs[i].charAt(j) == Utility.BLANK_CHAR) {
		    gappedColumnFlags[j] = true;
		}
	    }
	}

	return (gappedColumnFlags);
    }

    // helper method - process MSA into distance matrix
    //
    // need special global treatment for gaps - find all MSA columns
    // with gaps and flag them - ignore these columns (indices) for pairwise
    // distance calculation purposes
    public double[][] getDistanceMatrix(Sequence[] seqs) {
	double[][] d = new double[seqs.length][seqs.length];

	// all sequences in MSA should be same length
	boolean[] gappedColumnFlags = getGappedColumnFlags(seqs);

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
		    d[i][j] = simpleDistance.getDistance(seqs[i], seqs[j], gappedColumnFlags);
		}
	    }
	}

	// apply fix factor 1 correction
	applyFixFactorOneCorrection(d);

	// now reflect upper triangular matrix
	reflect(d);


	// testing
	outputPercentColumnsIgnored(gappedColumnFlags);

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

	for (int i = 0; i < seqs.length; i++) {
	    for (int j = i; j < seqs.length; j++) {
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
		    boolean[] gappedColumnFlags = getGappedColumnFlags(match);
		    
		    d[i][j] = simpleDistance.getDistance(match[0], match[1], gappedColumnFlags);
		}
	    }
	}

	// apply fix factor 1 correction
	applyFixFactorOneCorrection(d);

	// now reflect upper triangular matrix
	reflect(d);


	// fix this later
	// testing
	//outputPercentColumnsIgnored(gappedColumnFlags);

	// more reporting
	Driver.println (MAX_DISTANCE_WITH_GAP_METHOD_FLAG + " | " + getMax(d));
	Driver.println (AVERAGE_DISTANCE_WITH_GAP_METHOD_FLAG + " | " + getAverage(d));

	return (d);
    }


    private void outputPercentColumnsIgnored (boolean[] gappedColumnFlags) {
	// testing
	int numColumnsIgnored = 0;

	for (int i = 0; i < gappedColumnFlags.length; i++) {
	    if (gappedColumnFlags[i]) {
		numColumnsIgnored++;
	    }
	}

	double percentColumnsIgnored = ((double) numColumnsIgnored) / ((double) gappedColumnFlags.length);

	// testing
	Driver.println (Parser.GAPPED_COLUMNS_IGNORED_OUTPUT_FLAG + " | " + percentColumnsIgnored + " | " + numColumnsIgnored + " | " + gappedColumnFlags.length);

    }

}




