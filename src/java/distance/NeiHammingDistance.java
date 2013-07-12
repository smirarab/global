/**
 *
 * NeiHammingDistance.java
 * 
 * Uses Nei's ignore all columns with gaps on a global basis.
 * Uses Hamming pairwise distance (number of columns with differing 
 * characters) given Nei's global gap (omission) treatment.
 */



public class NeiHammingDistance extends NeiDistance {
    
    protected void initializeSimpleDistance () {
	simpleDistance = new SimpleHammingDistance();
    }


    // um ok
    public static void test1 () {
	String x = "ARNDND--NDRYVVY-------VY---V-V-V-V-";
	String y = "DRYVYVVY--Y-Y-Y-Y-Y--ARND-Y-Y------";
	Sequence xs = new Sequence(); xs.sequence = x;
	Sequence ys = new Sequence(); ys.sequence = y;
	boolean[] columnsToIgnore = new boolean[x.length()];
	NeiHammingDistance d = new NeiHammingDistance ();
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
