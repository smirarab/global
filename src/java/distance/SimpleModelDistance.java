/**
 *
 * SimpleModelDistance.java
 * Implement simple model distance between two strings.
 * Get frequency of interchange matrix between two strings and then
 * apply get logdet of that matrix as estimate of true additive distance
 * between the two strings.
 *
 * Uses columnsToIgnore parameter to choose which sites to factor into the computation.
 *
 * WARNING - THIS IS A CASE WHERE THE SIMPLEDISTANCE subclass ACTUALLY
 * USES THE COLUMNSTOIGNORE PARAMETER - UNLIKE MOST OTHER SIMPLEDISTANCES!!!
 *
 * ???ModelDistance DistanceWithGapMethod subclasses will need to take this
 * into account!!!
 *
 * For linear combination with other distance measures.
 *
 * Use fix factor 1 correction for undefined logdet distances!!
 * Just replace undefined distances with the largest well-defined distance in the distance matrix.
 * Need to do this as a separate step after the calculation of individual distances.
 * 
 */

public class SimpleModelDistance extends SimpleDistance {

    // output to user that undefined logdet distance occurred
    // -> make user rerun sim in this case
    // since this code is used by simulation scripts
    public static final String UNDEFINED_LOGDET_DISTANCE_FLAG = "UNDEFINED_LOGDET_DISTANCE_FLAG";

    //public static final char BLANK_CHAR = '-';
    
    /**
     * distance x->y
     */
    public SimpleModelDistance () {
    }
    
    /**
     * Two sequences x and y MUST be of the same length, 
     * otherwise this function returns -1
     *
     * columnsToIgnore parameter is used.
     */
    public double getDistance(Sequence xs, Sequence ys, boolean[] columnsToIgnore) {
	String x = xs.sequence;
	String y = ys.sequence;

	if (x.length() != y.length()) {
	    return (-1);
	}

	if (columnsToIgnore == null) {
	    return (-1);
	}

	DNASubstitutionProbabilityMatrix m = new DNASubstitutionProbabilityMatrix();
	int numCols = 0;

	for (int i = 0; i < x.length(); i++) {
	    if (columnsToIgnore[i]) {
		continue;
	    }

	    char xc = x.charAt(i);
	    char yc = y.charAt(i);
	    
	    // need to do hamming distance? 
	    // this means count positions that have different 
	    // characters (blanks/gaps included?? is this so???)
	    //if ((xc != Utility.BLANK_CHAR) && (yc != Utility.BLANK_CHAR) && (xc != yc)) {
	    //subsCost += 1.0;
	    //}

	    if ((xc != Utility.BLANK_CHAR) && (yc != Utility.BLANK_CHAR)) {
		m.insert(xc, yc);
		numCols++;
	    }
	}

	m.setNumCols(numCols);

	// testing
	//System.out.println ("numcols: " + numcols);
	//m.print();
	
	
	// testing 
	//m.print();

	// only makes sense when you're dealing with a distance matrix anyhow
	// apply fix factor 1 correction in matrix class
	double distance = m.computeLogDetDistance();

	//System.out.println ("distance: " + distance);

	/*
	if (distance == Double.POSITIVE_INFINITY) {
	    System.err.println ("we have infinity!!");

	    m.print();

	    System.out.println ("x: |" + xs.name + "| y: |" + ys.name + "|");

	    System.exit(1);
	}
	*/


	return (distance);
    }

    // um ok - seems to work
    public static void test1 () {
	String x = "ACTGCTGAT-GCTTTCGG-GGGTTTT----AATT----C";
	String y = "CCTGC-GAT-GCTGTCGGGGGTTTTGGGGGTTTT----G";
	boolean[] b = new boolean[x.length()];
	b[2] = true;

	Sequence xs = new Sequence(); xs.sequence = x;
	Sequence ys = new Sequence(); ys.sequence = y;
	SimpleModelDistance d = new SimpleModelDistance ();
	System.out.println ("distance is: |" + d.getDistance(xs, ys, b) + "|");
    }

    public static void main (String[] args) {
	test1();
    }
}
