/**
 * Implements distance interface for 
 * gapped model distance.
 *
 */

public class AffineDayhoffDistance extends AffineDistance {


    public void initializeSimpleDistance () {
	// initialize with gapped Dayhoff distance
	simpleDistance = new SimpleDayhoffDistance();
    }


    // um ok
    public static void test1 () {
	String x = "ACTG---TACGCTAGA--AGACGAT--ACAGATC--A--AC";
	String y = "AAAAAGCTAATCTAGA--AGAGGAT--AGAGTTC-----AC";
	Sequence xs = new Sequence(); xs.sequence = x; xs.name="blah1";
	Sequence ys = new Sequence(); ys.sequence = y; ys.name="blah2";
	AffineDayhoffDistance d = new AffineDayhoffDistance ();
	Sequence[] seqs = new Sequence[2];
	seqs[0] = xs;
	seqs[1] = ys;
	// DON'T USE THIS METHOD - USE CACHE/GET!!!!
	double[][] result = d.getDistanceMatrix(seqs);
	System.out.println ("distance is: |" + result[0][1] + "|");
    }

    public static void main (String[] args) {
	test1();
    }


}
