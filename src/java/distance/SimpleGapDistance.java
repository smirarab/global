/**
 *
 * SimpleGapDistance.java
 * Just count the difference in the number of gaps between two strings.
 * For linear combination with other distance measures.
 */


public class SimpleGapDistance extends SimpleDistance {

    
    /**
     * distance x->y
     */
    public SimpleGapDistance () {
    }

    /**
     * Two sequences x and y MUST be of the same length, 
     * otherwise this function returns -1
     *
     * columnsToIgnore parameter is NOT USED
     */
    public double getDistance(Sequence xs, Sequence ys, boolean[] columnsToIgnore) {
	String x = xs.sequence;
	String y = ys.sequence;

	if (x.length() != y.length()) {
	    return (-1);
	}

	// just care about the number of gaps between the two strings?
	// == number of evolutionary events?
	double gapCost = (double) Utility.getNumGaps(x, y);
	
	return (gapCost);
    }

    // um ok
    public static void test1 () {
	String x = "ARNDND--NDRYVVY-------VY---V-V-V-V-";
	String y = "DRYVYVVY--Y-Y-Y-Y-Y--ARND-Y-Y------";
	Sequence xs = new Sequence(); xs.sequence = x;
	Sequence ys = new Sequence(); ys.sequence = y;
	SimpleGapDistance d = new SimpleGapDistance ();
	System.out.println ("distance is: |" + d.getDistance(xs, ys, null) + "|");
    }

    public static void main (String[] args) {
	test1();
    }
}
