/**
 *
 * SimpleBlankDistance.java
 * Just count the difference in the number of blanks between two strings.
 * For linear combination with other distance measures.
 */


public class SimpleBlankDistance extends SimpleDistance {

    
    /**
     * distance x->y
     */
    public SimpleBlankDistance () {
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

	int numBlanks = Utility.getNumBlanksPairwiseOmitBothBlanks (x, y);
	
	return ((double) numBlanks);
    }

    // test this!
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
