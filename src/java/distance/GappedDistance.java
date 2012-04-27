/**
 * GappedDistance.java
 *
 * Implements a gap count distance method. It will make a linear combo
 * of the gap distance simple distance with another simple distance
 * and set the gap scaling factor by averages
 *
    // best way to do it is to set k s.t. (avg pairwise model dist) = k (avg pairwise gap dist)
    // thus k = (avg pairwise model dist) / ( avg pairwise gap dist)
    *
    *
    * ARGH - try to figure out how to improve on distance reporting mechanism
    * it's REALLY annoying to collect statistics on dataset runs
    * do this later - for now it's really hard to parse out
    * different GSFM runs
 */

public abstract class GappedDistance extends DistanceWithGapMethod {
    // for reporting
    public static final String MAX_SIMPLE_DISTANCE_FLAG = "MAX_SIMPLE_DISTANCE_FLAG";
    public static final String AVERAGE_SIMPLE_DISTANCE_FLAG = "AVERAGE_SIMPLE_DISTANCE_FLAG";
    public static final String MAX_SIMPLE_GAP_DISTANCE_FLAG = "MAX_SIMPLE_GAP_DISTANCE_FLAG";
    public static final String AVERAGE_SIMPLE_GAP_DISTANCE_FLAG = "AVERAGE_SIMPLE_GAP_DISTANCE_FLAG";
    public static final String GAP_SCALING_FACTOR_FLAG = "GAP_SCALING_FACTOR_FLAG";
    public static final String GAP_SCALING_FACTOR_MULTIPLIER_FLAG = "GAP_SCALING_FACTOR_MULTIPLIER_FLAG";



    // gap count part of this distance
    private SimpleDistance simpleGapDistance;
    // other part of this distance
    protected SimpleDistance simpleDistance;

    private double[][] cachedSimpleDistanceMatrix;
    private double[][] cachedSimpleGapMatrix;

    // formula for this distance is simpleDistance + k simpleGapDistance
    // where k = (avg pairwise model dist) / ( avg pairwise gap dist)

    public GappedDistance () {
	initializeSimpleGapDistance();
	initializeSimpleDistance();

	cachedSimpleDistanceMatrix = null;
	cachedSimpleGapMatrix = null;
    }

    private void initializeSimpleGapDistance () {
	simpleGapDistance = new SimpleGapDistance();
    }

    // subclasses need to override this!!!
    protected abstract void initializeSimpleDistance ();

    /**
     * return gap scaling factor
     * k = (avg pairwise model dist) / ( avg pairwise gap dist)
     *
     * this doesn't work well enough - change to max
     */
    private double getGapScalingFactor (double[][] d, double[][] g, double gapScalingFactorMultiplier) {
	double averageD = getAverage (d);
	double averageG = getAverage (g);

	double maxD = getMax (d);
	double maxG = getMax (g);

	// eh - why not just output it here - doesn't matter
	// very soon will output average distances properly
	Driver.println (AVERAGE_SIMPLE_DISTANCE_FLAG + " | " + averageD);
	Driver.println (AVERAGE_SIMPLE_GAP_DISTANCE_FLAG + " |" + averageG);
	// also output max
	Driver.println (MAX_SIMPLE_DISTANCE_FLAG + " | " + getMax(d));
	Driver.println (MAX_SIMPLE_GAP_DISTANCE_FLAG + " | " + getMax(g));


	// hmm - need actually a matrix of k values - one for each pair
	// then do cellwise scalar mult k * gap dist
	// to scale gap dist
	// does this make sense???
	// many gaps - scale down less if blanks take up most of columns??
	//           - scale down lots if blanks take few cols????
	// 
	// is this what we want??
	// my manual experiments -> 1 k / dataset can work ok
	// just need to set it low enough
	// pairwise basis set k to scale down gap simpledist - what does this mean?
	// need to capture number of "events"........

	// hm... it's fine... k then becomes a function on pairwise
	// basis, don't worry about it
	// hmm... since we are figuring out how to set k - 
	// break this off into its own one off code dir

	double k = 0.0;

	// this doesn't work well
	// try other things see if that helps
	//
	// try multiplying by percent gapped for entire alignment
	//
	// WARNING - do NOT divide by 0.0!!!
	if (maxG > 0.0) {
	    // in fact - this may not be the proper gap scaling factor
	    //double k = averageD / averageG;
	    k = maxD / maxG;
	}
	// otherwise don't have any gap contribution if gap part of distance is zero
	
	k *= gapScalingFactorMultiplier;

	// report k too
	Driver.println (GAP_SCALING_FACTOR_FLAG + " | " + k);
	// for recordkeeping
	Driver.println (GAP_SCALING_FACTOR_MULTIPLIER_FLAG + " | " + gapScalingFactorMultiplier);
	
	return (k);

    }

    // formula for this distance is simpleDistance + k simpleGapDistance
    // where k = (avg pairwise model dist) / ( avg pairwise gap dist)

    // actually, it is - for simple pairwise testing functions
    // NOT USED
    // signal an exception instead
    // bad class design
    // fix this later
    //
    // fine
    // hmm - let's make object hierarchy better
    // have abstract GappedDistance have gapDistance
    // subclasses like GappedModelDistance will just initialize second distance
    // and call superclass's getDistanceMatrix which will do linear combo with k set by averages above
    // appropriately
    public double[][] getDistanceMatrix(Sequence[] seqs) {
	System.err.println ("ERROR: GappedDistance.getDistanceMatrix NOT SUPPORTED! Use cache/get methods instead.");

	// NEED TO REINSTATE THIS!!! JTT/DAYHOFF METHODS USE THIS!!!
	System.exit(1);

	return (null);

	/*
	double[][] d = getDistanceMatrix (simpleDistance, seqs);
	double[][] g = getDistanceMatrix (simpleGapDistance, seqs);

	double k = getGapScalingFactor(d, g, 1.0);

	scalarMultiply (g, k);
	
	double[][] result = add(d, g);

	// more reporting
	Driver.println (MAX_DISTANCE_WITH_GAP_METHOD_FLAG + " | " + getMax(result));
	Driver.println (AVERAGE_DISTANCE_WITH_GAP_METHOD_FLAG + " | " + getAverage(result));


	    
	return (result);
	*/
    }

    // need to kind of hack this
    // s, g set from pairwise alignments
    // then do gsfm/affine scaling appropriately
    /**
     * Must call this prior to cacheGetDistanceMatrix() calls below.
     */
    public void cacheSetSimpleDistanceMatrices (Sequence[] seqs) {
	cachedSimpleDistanceMatrix = getDistanceMatrix (simpleDistance, seqs);
	cachedSimpleGapMatrix = getDistanceMatrix (simpleGapDistance, seqs);	
    }

    // need special version for pairwise
    // pass in raw sequences
    // do pairwise alignment manually
    // set simple distance matrices appropriately
    public void cacheSetSimpleDistanceMatricesPairwise (Sequence[] seqs) {
	// change this later
	Substitution sub = new EDNAFull();

	cachedSimpleDistanceMatrix = new double[seqs.length][seqs.length];
	cachedSimpleGapMatrix = new double[seqs.length][seqs.length];
	for (int i = 0; i < seqs.length; i++) {
	    for (int j = i + 1; j < seqs.length; j++) {
		// testing
		System.out.println ("Processing pair " + i + " and " + j + ".");
		NWAffine nwaffine = new NWAffine(sub, 
						 PairwiseAlignmentDriver.PAIRWISE_ALIGNMENT_GAP_OPEN_COST, 
						 PairwiseAlignmentDriver.PAIRWISE_ALIGNMENT_GAP_EXTEND_COST, 
						 seqs[i].sequence, 
						 seqs[j].sequence);
		String[] match = nwaffine.getMatch();
		
		boolean[] dummy = new boolean[match[0].length()];
		cachedSimpleDistanceMatrix[i][j] = simpleDistance.getDistance(match[0], match[1], dummy);
		cachedSimpleGapMatrix[i][j] = simpleGapDistance.getDistance(match[0], match[1], dummy);

		// testing
		// ok - seems to work
		//System.out.println ("Sequences " + i + " and " + j + " have simpledist " + cachedSimpleDistanceMatrix[i][j] + " and simplegapdist " + cachedSimpleGapMatrix[i][j]);
	    }
	}

	// apply fix factor 1 correction
	applyFixFactorOneCorrection(cachedSimpleDistanceMatrix);
	applyFixFactorOneCorrection(cachedSimpleGapMatrix);


	reflect (cachedSimpleDistanceMatrix);
	reflect (cachedSimpleGapMatrix);
	
    }


    /**
     * Repeat distance matrix calculation using cached simple distance and
     * gapped distance matrices and GSFM parameter.
     *
     * If cached simple/gap distance matrices don't exist then this returns 
     * null.
     */
    public double[][] cacheGetDistanceMatrix(double gapScalingFactorMultiplier) {
	if ((cachedSimpleDistanceMatrix == null) || (cachedSimpleGapMatrix == null)) {
	    return (null);
	}

	double[][] s = copy(cachedSimpleDistanceMatrix);
	double[][] g = copy(cachedSimpleGapMatrix);

	double k = getGapScalingFactor(s, g, gapScalingFactorMultiplier);

	scalarMultiply (g, k);
	
	// too slow - turn this off
	// plus scaling gap factor now set automatically
        // testing
	/*
        Driver.println ("s:");
        print(s);
        Driver.println ("g:");
        print(g);
	*/

	double[][] result = add(s, g);

	// more reporting
	Driver.println (MAX_DISTANCE_WITH_GAP_METHOD_FLAG + " | " + getMax(result));
	Driver.println (AVERAGE_DISTANCE_WITH_GAP_METHOD_FLAG + " | " + getAverage(result));


	    
	return (result);
	
    }

}

