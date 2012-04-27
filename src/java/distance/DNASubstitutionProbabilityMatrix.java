/**
 *
 * DNASubstitutionProbabilityMatrix.java
 *
 * Counts number of substitutions, changes to a probability matrix,
 * and applies logdet transform. For model distance calculation given an
 * MSA, used on a pairwise distance calculation basis.
 *
 *   A  C  T  G
 * A
 * C
 * T
 * G
 *
 * Need to make row stochastic
 */

import Jama.*;

public class DNASubstitutionProbabilityMatrix {
    public static final double UNDEFINED_LOGDET_DISTANCE_INDICATOR = -1.0;
    // just in case no fix factor 1 substitute distance exists
    // then use this 
    public static final double LAST_RESORT_FIX_FACTOR_ONE_DISTANCE = 1.0;

    private static final int DNANUM = 4;
    // substitution count matrix, becomes the substitution probability matrix
    // later
    private double[][] m;
    // character frequency count (later probability) in sequence x
    private double[] fx;
    // maintain total original count of all chars in sequence x - for later calcs
    private double fxTotalCount;
    // character frequency count (later probability) in sequence x
    private double[] fy;
    private double fyTotalCount;
    
    private double numCols;

    // testing
    private int numEntries;
    
    //private double MAX_LOG_DET_DISTANCE = 999999.0;

    public DNASubstitutionProbabilityMatrix () {
	// should all be zeroed
	m = new double[DNANUM][DNANUM];
	fx = new double[DNANUM];
	fy = new double[DNANUM];
	//paranoid
	reset();
    }

    private int ind (char c) {
	switch (c) {
	case 'A': return 0;
	case 'C': return 1;
	case 'T': return 2;
	case 'G': return 3;
	default: return -1;
	}
    }

    /*
     * Reset subs prob matrix.
     *
     */
    public void reset () {
	for (int i = 0; i < DNANUM; i++) {
	    for (int j = 0; j < DNANUM; j++) {
		m[i][j] = 0.0;
	    }
	}

	for (int i = 0; i < DNANUM; i++) {
	    fx[i] = 0.0;
	    fy[i] = 0.0;
	}
    }

    /*
     * Count one time the substitution event of char x->char y for the 
     * strings pair
     * being compared by this matrix.
     *
     */
    public void insert (char x, char y) {
	if ((ind(x) < 0) || (ind(y) < 0)) {
	    System.err.println ("ERROR: trying to compute model distance with non DNA character: x: " + x + ", y: " + y);
	    System.exit(1);
	}

	m[ind(x)][ind(y)] += 1.0;

	// need to also count the frequencies for each sequence - really
	// like working with the joint - keep count directly
	fx[ind(x)] += 1.0;
	fy[ind(y)] += 1.0;

	// testing
	numEntries++;
    }

    /**
     * Scale all entries of matrix by k.
     * Useful for changing counts in matrix into probabilities.
     *
     * WARNING - if you want to divide by number of cols, 
     * use scale(1/numcols)!!!
     */
    private void scale (double k) {
	for (int i = 0; i < DNANUM; i++) {
	    for (int j = 0; j < DNANUM; j++) {
		m[i][j] *= k;
	    }
	}
    }
    
    /**
     * Scale rows to make row stochastic
     *
     * changes count matrix/vectors into probability matrix/vectors
     */
    private void makeRowStochastic () {
	double rowWeight = 0.0;
	for (int i = 0; i < DNANUM; i++) {
	    rowWeight = 0.0;
	    for (int j = 0; j < DNANUM; j++) {
		rowWeight += m[i][j];
	    }
	    for (int j = 0; j < DNANUM; j++) {
		m[i][j] = m[i][j] / rowWeight;
	    }
	}

    }
    
    private void makeFrequencies () {
	double rowWeight = 0.0;
	for (int i = 0; i < DNANUM; i++) {
	    rowWeight += fx[i];
	}
	fxTotalCount = rowWeight;
	for (int i = 0; i < DNANUM; i++) {
	    fx[i] = fx[i] / rowWeight;
	}

	rowWeight = 0.0;
	for (int i = 0; i < DNANUM; i++) {
	    rowWeight += fy[i];
	}
	fyTotalCount = rowWeight;
	for (int i = 0; i < DNANUM; i++) {
	    fy[i] = fy[i] / rowWeight;
	}
    }


    public void print (double[][] mat) {
	for (int i = 0; i < DNANUM; i++) {
	    for (int j = 0; j < DNANUM; j++) {
		Driver.print (mat[i][j] + " ");
	    }
	    Driver.println();
	}

    }

    public void print () {
	print (m);
    }

    /**
     * testing
     */
    private String printCollapsedString () {
	String result = "";

	for (int i = 0; i < DNANUM; i++) {
	    for (int j = 0; j < DNANUM; j++) {
		result += m[i][j] + " ";
	    }
	    result += "| ";
	}

	return (result);
    }
    
    /**
     * Hopefully JAMA works and doesn't return funky values??
     */
    public double computeLogDetDistance () {
	// testing
	//print();

	// changeover count matrices/vectors into probability matrices/vectors
	// no?? steel says you want the joint probability, not conditional?
	// incorrect - need to make count matrix m row stochastic prob matrix
	double scaleFactor = 1.0 / ((double) numCols);
	scale (scaleFactor);
	// makeRowStochastic();
	makeFrequencies();

	/*
	Matrix mat = new Matrix(m);
	double det = mat.det();

	// testing
	//Driver.println ("det: " + det);

	double logdet = Math.log(Math.abs(det));
	return (-1.0 * logdet);
	*/
	
	// SHOOT!!! can sometimes get singular frequency matrices!!
	// -> determinant is zero and so logdet is infinity!!!
	// just happens that way??
	return (computeLogDetDistanceOriginalLake());
    }

    // warning - if have ln (1) -> distance is zero
    // if determinant of matrix is one -> zero answer!
    //
    // see Thollesson 2004
    // Vol. 20 no. 3 2004, pages 
    // DOI: 10.1093/bioinformatics/btg422
    /**
     * First of 2 methods for calculating logdet distance
     * ASSUMES EQUAL PROBABILITY OF SUBSTITUTION ACROSS THE 4 DNA CHARACTERS!!!
     */
    // dxy = -1/r ln ( det fxy / sqrt( set (Pi_x Pi_y)))
    //
    // returns negative value indicating undefined logdet distance
    private double computeLogDetDistanceOriginalLake () {
	Matrix mat = new Matrix(m);
	double det = mat.det();

	// need absval
	det = Math.abs(det);

	if (det <= 0.0) {
	    //Driver.println ("CORRECTING");
	    // do as the LDDist people do - since det SHOULD be in (0, 1), 
	    // this is as if it has no info???

	    // ARGH - sometimes it will just turn out that the 
	    // frequency matrix is singular
	    // in this case make the distance ~ infinite
	    // by returning really big value
	    
	    // no longer will check for this, but go ahead and output warning anyhow.
	    //
	    // NO this is NOT right according to Tandy
	    // just let re-run simmed dataset if this occurs
	    //return (MAX_LOG_DET_DISTANCE);
	    //Driver.println (SimpleModelDistance.UNDEFINED_LOGDET_DISTANCE_FLAG + ": ERROR: undefined logdet distance occurred. Please rerun simulation. det: |" + det + " | num cols: |" + numCols + "| numEntries: |" + numEntries + "| mcollapsed: |" + printCollapsedString() + "|");
	    // just print notification
	    System.out.println (SimpleModelDistance.UNDEFINED_LOGDET_DISTANCE_FLAG + ": WARNING: undefined logdet distance occurred. Will use fix factor 1 correction. det: |" + det + " | num cols: |" + numCols + "| numEntries: |" + numEntries + "|");

	    // testing
	    //System.out.println ("TESTING: UNDEFINED LOGDET DISTANCE OCCURRED.");
	    
	    // just let it continue - eventually the output
	    // distance matrix will have an infinity symbol for this distance

	    // too slow to throw an exception
	    // just return negative value to signal undefined logdet distance
	    return (UNDEFINED_LOGDET_DISTANCE_INDICATOR);
	}

	// testing
	//Driver.println ("det: " + det);

	// this is NOT right - need to set Pi_x as the frequencies of
	// each character in sequence x
	// need to scale determinant
	// since we divide by sqrt(det(Pi_x Pi_y))
	// and Pi_x == 1/4 * Identity_matrix == Pi_y due to uniform 
	// substitution probability assumption above

	// compute denominator factor based on char frequency matrices
	double frequencyFactor = computeFrequencyFactor();
	if (frequencyFactor > 0.0) {
	    det = det / frequencyFactor;

	    //Driver.println ("freq factor: " + computeFrequencyFactor());
	    //Driver.println ("det after divide by freq: " + det);
	    
	    double logdet = Math.log(det);
	    // since we divide by -r also, r = 4 for DNA
	    return (-0.25 * logdet);
	}
	else {
	    // if all frequencies are the same, then return indicator
	    // instead of undefined
	    
	    // will be corrected using fix factor 1

	    // note this
	    System.out.println ("WARNING: frequency factor denominator in logdet calculation is zero! Will use fix factor 1 to correct this.");

	    return (UNDEFINED_LOGDET_DISTANCE_INDICATOR);
	}
    }  

    private double computeFrequencyFactor () {
	double mfx[][] = new double[DNANUM][DNANUM];
	double mfy[][] = new double[DNANUM][DNANUM];
	// eh, no need to be so paranoid...
	for (int i = 0; i < DNANUM; i++) {
	    mfx[i][i] = fx[i];
	    mfy[i][i] = fy[i];
	}

	// testing - ok - probs seem to sum to 1
	//print (mfx); print(mfy);
	
	Matrix Mfx = new Matrix(mfx);
	Matrix Mfy = new Matrix(mfy);

	Matrix product = Mfx.times(Mfy);

	// testing - ok - seems to be getting smaller
	//Driver.println ("product: ");
	//print (product.getArray());
	
	double proddet = product.det();
	
	//Driver.println ("proddet: " + proddet);

	return (Math.sqrt(proddet));
    }

    /**
     * second of 2 methods for calculating logdet distance
     * ASSUMES EQUAL PROBABILITY OF SUBSTITUTION ACROSS THE 4 DNA CHARACTERS!!!
     * 
     * hmm, for the equal subsitution prob assumption above this calc
     * should be the same as the first above lake original???
     */
    private double computeLogDetDistanceLDDistModification () {
	Matrix mat = new Matrix(m);
	double det = mat.det();

	// need absval
	det = Math.abs(det);

	// testing
	//Driver.println ("det: " + det);

	// need to scale determinant
	// since we divide by sqrt(det(Pi_x Pi_y))
	// and Pi_x == 1/4 * Identity_matrix == Pi_y due to uniform 
	// substitution probability assumption above
	double frequencyFactor = computeFrequencyFactor();
	if (frequencyFactor > 0.0) {
	    det = det / frequencyFactor;
	    
	    double logdet = Math.log(det);
	    
	    // correction factor 
	    double factor = (1.0 - getSumSquaresTotalFrequencies()) / (4.0 - 1.0);
	    
	    // since we divide by -r also, r = 4 for DNA
	    return (-factor * logdet);
	}
	else {
	    // see lake comments - return undefined indicator
	    // -> later corrected with fix factor 1

	    // note this
	    System.err.println ("WARNING: frequency factor denominator in logdet calculation is zero! Will use fix factor 1 to correct this.");

	    return (UNDEFINED_LOGDET_DISTANCE_INDICATOR);
	}

    }  
    
    // return sum_i pi_i^2
    private double getSumSquaresTotalFrequencies () {
	double ss = 0.0;
	for (int i = 0; i < DNANUM; i++) {
	    ss += Math.pow((fx[i]*fxTotalCount + fy[i]*fyTotalCount) / (fxTotalCount + fyTotalCount), 2.0);
	}
	return (ss);
    }

    public void setNumCols (int numCols) {
	this.numCols = numCols;
    }
  
}
