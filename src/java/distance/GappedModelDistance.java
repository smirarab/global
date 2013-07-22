/**
 * Implements distance interface for 
 * gapped model distance.
 *
 */

public class GappedModelDistance extends GappedDistance {
    // can't set gap scaling factor manually per dataset!!
    // best way to do it is to set k s.t. (avg pairwise model dist) = k (avg pairwise gap dist)
    // thus k = (avg pairwise model dist) / ( avg pairwise gap dist)
    //public static final double GAP_OPEN_COST = 0.2;


    public void initializeSimpleDistance () {
	// initialize with gapped Model distance
	simpleDistance = new SimpleModelDistance();
    }


    // um ok
    public static void test1 () {
	String x = "ACTG---TACGCTAGA--AGACGAT--ACAGATC--A--AC";
	String y = "AAAAAGCTAATCTAGA--AGAGGAT--AGAGTTC-----AC";
	Sequence xs = new Sequence(); xs.sequence = x; xs.name="blah1";
	Sequence ys = new Sequence(); ys.sequence = y; ys.name="blah2";
	GappedModelDistance d = new GappedModelDistance ();
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
