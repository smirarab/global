/**
 * Implements distance interface for normalized simple Hamming distance. Kind of a hack.
 *
 * Need to just get pairwise normalized hamming distance average for each dataset.
 * This is a quick way of getting at that.
 *
 */

public class NormalizedSimpleHammingDistance extends PairwiseGapOmitDistance {
    // hmm - simple Hamming distance by itself should already pairwise ignore any gapped cols?
    // similarly for LiSan distance, etc.?
    // hmm - but still need PairwiseGapOmitDistance to output stats about omitted columns
    //
    // hmm - wish had multiple inheritance in Java
    //private Distance simpleHammingDistance;

    // override parent superclass's getDistanceMatrix(seqs) function!!
    // need to add normalization factor for each pairwise dist
    // = H_ij / k_ij, where k_ij is the total number of columns considered between seqs i and j

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
	    System.out.println (i + ": " + gappedColumnFlags[i]);
	}
	*/

	for (int i = 0; i < seqs.length; i++) {
	    for (int j = 0; j < seqs.length; j++) {
		if (i == j) {
		    d[i][j] = 0.0;
		}
		else {
		    // all sequences in MSA should be same length
		    gr = getPairwiseGappedColumnFlags(seqs[i], seqs[j]);
		    gappedColumnFlags = gr.gappedColumnFlags;
		    totalNumGaps += gr.numGaps;

		    d[i][j] = simpleDistance.getDistance(seqs[i], seqs[j], gappedColumnFlags);

		    // now normalize 
		    // gr.numGaps is actually the number of gapped columns for this pair
		    int numNonGappedColumns = seqs[i].sequence.length() - gr.numGaps;
		    if (numNonGappedColumns > 0) {
			d[i][j] = d[i][j] / numNonGappedColumns;
		    }
		    // else all gapped -> distance is zero since no cols -> hamming dist, -> 
		    // leave it as it is
		}
	    }
	}

	// testing
	outputPercentColumnsIgnored(totalNumGaps, seqs[0].sequence.length() * seqs.length * (seqs.length - 1));

	// now need to output total cells in MSA matrix ignored based on 
	// pairwise gap omit
	// instead of column omit percentage for Nei correction
	// still works out to gaps ignored percentage in both cases

	// more reporting
	// NOTE!!!!
	// this will become pairwise normalized hamming distance stats for dataset
	Driver.println (MAX_DISTANCE_WITH_GAP_METHOD_FLAG + " | " + getMax(d));
	Driver.println (AVERAGE_DISTANCE_WITH_GAP_METHOD_FLAG + " | " + getAverage(d));


	return (d);
    }


    protected void initializeSimpleDistance () {
	simpleDistance = new SimpleHammingDistance();
    }

    // um ok
    public static void test1 () {
	String x = "ACTG---TACGCTAGA--AGACGAT--ACAGATC--A--AC";
	String y = "AAAAAGCTAATCTAGA--AGAGGAT--AGAGTTC-----AC";
	Sequence xs = new Sequence(); xs.sequence = x; xs.name="blah1";
	Sequence ys = new Sequence(); ys.sequence = y; ys.name="blah2";
	PairwiseGapOmitHammingDistance d = new PairwiseGapOmitHammingDistance ();
	Sequence[] seqs = new Sequence[2];
	seqs[0] = xs;
	seqs[1] = ys;
	double[][] result = d.getDistanceMatrix(seqs);
	System.out.println ("distance is: |" + result[0][1] + "|");
    }

    public static void main (String[] args) {
	test1();
    }



}

