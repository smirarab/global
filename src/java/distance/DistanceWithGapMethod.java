/**
 *
 * DistanceWithGapMethod.java
 * Implement a new distance measure between two sequences that incorporates
 * some method of dealing with gaps
 *
 * Gap count method subclasses will try to do a linear combo of 2 simple
 * distance classes, nei will call 1 simple distance class with a nontrivial
 * columnsToIgnore parameter, etc.
 *
 * Just an abstract class - move implementation to concrete classes
 *
 * Change to abstract class so common distance subcalculations can be
 * moved here
 */


public abstract class DistanceWithGapMethod {
    // for reporting purposes
    public static final String MAX_DISTANCE_WITH_GAP_METHOD_FLAG = "MAX_DISTANCE_WITH_GAP_METHOD_FLAG";
    public static final String AVERAGE_DISTANCE_WITH_GAP_METHOD_FLAG = "AVERAGE_DISTANCE_WITH_GAP_METHOD_FLAG";


    // hrm - actually this is the most important public method since Driver uses it??
    // make this one required?? 
    //
    // force subclasses to do their thing
    // don't do default thing - probably not right
    public abstract double[][] getDistanceMatrix(Sequence[] seqs);

    // not used - return (getDistanceMatrix(this, seqs));

    // distance matrix ops
    /**
     * Find max entry in matrix with all nonnegative entries.
     */
    protected double getMax (double[][] d) {
	double max = -1.0;
	for (int i = 0; i < d.length; i++) {
	    for (int j = 0; j < d[i].length; j++) {
		if (d[i][j] > max) {
		    max = d[i][j];
		}
	    }
	}
	return (max);
    }

    protected double getAverage (double[][] d) {
	double averageD = 0.0;
	int numD = 0;
	// hmm - well, don't assume that d symmetric
	for (int i = 0; i < d.length; i++) {
	    for (int j = 0; j < d[i].length; j++) {
		if (i != j) {
		    // ignore the diagonals
		    averageD += d[i][j];
		    numD++;
		}
	    }
	}

	averageD = averageD / ((double) numD);

	return (averageD);
    }

    /**
     * Returns k * d, where k scalar and d nxn matrix.
     */
    protected void scalarMultiply (double[][] d, double k) {
	for (int i = 0; i < d.length; i++) {
	    for (int j = 0; j < d[i].length; j++) {
		d[i][j] *= k;
	    }
	}
    }

    /**
     * Returns d + e, where d nxn matrix and e nxn matrix.
     * d and e must be of same square dimensions, otherwise returns null 
     * for an error.
     */
    protected double[][] add (double[][] d, double[][]e) {
	if (d.length != e.length) {
	    return null;
	}
	for (int i = 0; i < d.length; i++) {
	    if ((d[i].length != e[i].length) || (d[i].length != d[0].length)) {
		return null;
	    }
	}
	double[][] result = new double[d.length][d[0].length];
	for (int i = 0; i < d.length; i++) {
	    for (int j = 0; j < d[i].length; j++) {
		result[i][j] = d[i][j] + e[i][j];
	    }
	}
	return (result);
    }

    /**
     * Returns d - e, where d nxn matrix and e nxn matrix.
     * d and e must be of same square dimensions, otherwise returns null 
     * for an error.
     */
    protected double[][] subtract (double[][] d, double[][] e) {
	if (d.length != e.length) {
	    return null;
	}
	for (int i = 0; i < d.length; i++) {
	    if ((d[i].length != e[i].length) || (d[i].length != d[0].length)) {
		return null;
	    }
	}
	double[][] result = new double[d.length][d[0].length];
	for (int i = 0; i < d.length; i++) {
	    for (int j = 0; j < d[i].length; j++) {
		result[i][j] = d[i][j] - e[i][j];
	    }
	}
	return (result);
    }

    

    protected double[][] copy (double[][] d) {
	if ((d == null) || (d[0] == null)) {
	    return (null);
	}
	
	double[][] e = new double[d.length][d[0].length];
	for (int i = 0; i < d.length; i++) {
	    for (int j = 0; j < d[i].length; j++) {
		e[i][j] = d[i][j];
	    }
	}
	return (e);
    }

    /**
     * reflect an upper triangular matrix across the diagonal
     * d must be square
     * destructive
     **/
    protected void reflect (double[][] d) {
	if ((d == null) || (d[0] == null)) {
	    return;
	}

	for (int i = 0; i < d[0].length; i++) {
	    for (int j = 0; j < i; j++) {
		d[i][j] = d[j][i];
	    }
	}
    }

    protected void init (boolean[] b) {
	for (int i = 0; i < b.length; i++) {
	    b[i] = false;
	}
    }

    

    /**
     * Calculate distance matrix for a particular distance against
     * alignment seqs.
     *
     * Helper method - use any distance.
     * 
     * really only used for Gapped distanceWithGapMethods
     * 
     * defaults to use all columns - only use this if that's what you want!!
     *
     * Implements fix factor 1 correction by replacing all negative matrix 
     * entries with maximum matrix entry.
     *
     * To speed calculation, assume matrix is symmetric (distances 
     * are reflexibly equal).
     */
    protected double[][] getDistanceMatrix (SimpleDistance simpleDistance, Sequence[] seqs) {
	double[][] d = new double[seqs.length][seqs.length];

	for (int i = 0; i < seqs.length; i++) {
	    for (int j = i; j < seqs.length; j++) {
		// explicitly set diagonal to 0
		if (i == j) {
		    d[i][j] = 0.0;
		}
		else {
		    // since model distance requires it - others can ignore
		    // or default to false
		    // use all columns
		    boolean[] columnsToIgnore = new boolean[seqs[i].sequence.length()];
		    // default to use all columns
		    // paranoid 
		    init(columnsToIgnore);

		    d[i][j] = simpleDistance.getDistance(seqs[i], seqs[j], columnsToIgnore);
		}
	    }
	}

	// apply fix factor 1 correction
	applyFixFactorOneCorrection(d);

	// now reflect upper triangular matrix
	reflect(d);

	return (d);
    }

    // testing
    protected void print (double[][] d) {
	for (int i = 0; i < d.length; i++) {
	    for (int j = 0; j < d[i].length; j++) {
		Driver.println (d[i][j]);
	    }
	    Driver.println ("---");
	}
    }
    
    /**
     * Apply fix factor 1 correction to distance matrix d.
     * Replace negative entries with maximum entry in d.
     */
    protected void applyFixFactorOneCorrection(double[][] d) {
	double max = getMax(d);

	if (max < 0.0) {
	    max = DNASubstitutionProbabilityMatrix.LAST_RESORT_FIX_FACTOR_ONE_DISTANCE;
	}

	// now just replace negative entries in d with max
	for (int i = 0; i < d.length; i++) {
	    for (int j = 0; j < d[i].length; j++) {
		if (d[i][j] < 0.0) {
		    d[i][j] = max;
		}
	    }
	}

	
    }

}

