/**
 * Implements distance interface for pairwise gap omit Hamming distance.
 *
 */

public class PairwiseGapOmitHammingDistance extends PairwiseGapOmitDistance {
    // hmm - simple Hamming distance by itself should already pairwise ignore any gapped cols?
    // similarly for LiSan distance, etc.?
    // hmm - but still need PairwiseGapOmitDistance to output stats about omitted columns
    //
    // hmm - wish had multiple inheritance in Java
    //private Distance simpleHammingDistance;

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

