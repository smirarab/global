/**
 * Abstract superclass for all simple distances - that is, distances
 * calculated on a pairwise basis that need the columnsToIgnore flag
 * array to be passed in separately. e.g. model, Hamming, JTT, Dayhoff, etc.
 * dists.
 *
 * Doesn't worry about linear combos of dists, factoring in gap contribution,
 * etc.
 */

public abstract class SimpleDistance {
    // moved to Utility.java
    //public static final char BLANK_CHAR = '-';
    
    // columnsToIgnore used for Nei global gap column omission
    // WARNING - columnsToIgnore may or may not be used by the 
    // SimpleDistance subclass!!
    //
    // it's up to the individual SimpleDistance subclass and its associated
    // DistanceWithGapMethod subclass to manually coordinate
    // columnsToIgnore usage/nonusage!!!!
    public abstract double getDistance (Sequence xs, Sequence ys, boolean[] columnsToIgnore);


    // convenience function - if you don't care about sequence names
    // which shouldn't matter for simple distances anyway
    public double getDistance (String x, String y, boolean[] columnsToIgnore) {
	Sequence xs = new Sequence();
	Sequence ys = new Sequence();
	xs.sequence = x;
	ys.sequence = y;
	return (getDistance(xs, ys, columnsToIgnore));
    }
}
