/**
 *
 * SimpleHammingDistance.java
 * Implement simple hamming distance between two strings.
 * Treats blanks in gaps as separate character -> linear gap penalty.
 *
 * For linear combination with other distance measures.
 *
 */

public class SimpleHammingDistance extends SimpleDistance {

    //public static final char BLANK_CHAR = '-';
    
    /**
     * distance x->y
     */
    public SimpleHammingDistance () {
    }
    
    /**
     * Two sequences x and y MUST be of the same length, 
     * otherwise this function returns -1
     *
     * columnsToIgnore parameter is USED - set it appropriately
     * depending on the gap method you want!!
     */
    public double getDistance(Sequence xs, Sequence ys, boolean[] columnsToIgnore) {
	String x = xs.sequence;
	String y = ys.sequence;

	double subsCost = 0.0;

	if (x.length() != y.length()) {
	    return (-1);
	}

	for (int i = 0; i < x.length(); i++) {
	    if (columnsToIgnore[i] == true) {
		// ignore this column for pairwise distance calculation
		// if flags say so
		continue;
	    }
	    else {
		char xc = x.charAt(i);
		char yc = y.charAt(i);
		
		// need to do hamming distance? 
		// this means count positions that have different 
		// characters (blanks/gaps included?? is this so???)
		if ((xc != Utility.BLANK_CHAR) && (yc != Utility.BLANK_CHAR) && (xc != yc)) {
		    subsCost += 1.0;
		}
	    }
	}
	
	return (subsCost);
    }

    // um ok
    public static void test1 () {
	String x = "ARDND--NDRYVVY-------VY---V-V-V-V-";
	String y = "DRVYVVY--Y-Y-Y-Y-Y--ARND-Y-Y------";
	Sequence xs = new Sequence(); xs.sequence = x;
	Sequence ys = new Sequence(); ys.sequence = y;
	SimpleHammingDistance d = new SimpleHammingDistance ();
	boolean[] ci = new boolean[x.length()];
	System.out.println ("distance is: |" + d.getDistance(xs, ys, ci) + "|");
    }

    public static void main (String[] args) {
	test1();
    }
}
