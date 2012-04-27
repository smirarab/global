/**
 * SimpleJTTDistance.java
 *
 * Calculate distance using Jones Taylor Thornton substitution matrix using
 * PAL library.
 *
 * Woohoo! PAL!
 */

import java.io.*;
import java.util.*;
import pal.distance.*;
import pal.alignment.*;
import pal.datatype.*;
import pal.substmodel.*;
import pal.misc.*;

public class SimpleJTTDistance extends SimpleDistance {

    public SimpleJTTDistance () {
	super();
    }

    // get nongapped pairwise alignment, also ignoring columns to ignore in flag array
    protected String[] getNonGappedPairwiseAlignmentWithFlags (String x, String y, boolean[] columnsToIgnore) {
	// alignment must be of same length
	if (x.length() != y.length()) {
	    return (null);
	}

	StringBuffer xsb = new StringBuffer();
	StringBuffer ysb = new StringBuffer();

	for (int i = 0; i < x.length(); i++) {
	    if ((!columnsToIgnore[i]) && (x.charAt(i) != Utility.BLANK_CHAR) && (y.charAt(i) != Utility.BLANK_CHAR)) {
		xsb.append(x.charAt(i));
		ysb.append(y.charAt(i));
	    }
	}

	String[] result = new String[2];
	result[0] = xsb.toString();
	result[1] = ysb.toString();

	return (result);
    }

    public double getDistance (Sequence xs, Sequence ys, boolean[] columnsToIgnore) {
	// ignore columnsToIgnore sites, also ignore any pairwise gapped columns 
	// since they're not used in pairwise substitution distance calculations anyway
	
	// construct new non-gapped strings and pass into PAL -> use their implementation
	String[] pairAlignNonGapped = getNonGappedPairwiseAlignmentWithFlags (xs.sequence, ys.sequence, columnsToIgnore);	

	//System.out.println ("left strings: " + pairAlignNonGapped[0] + "|" + pairAlignNonGapped[1]);

	// now use PAL libraries
	// don't really care about identifiers
	Identifier[] ids = new Identifier[2];
	ids[0] = new Identifier("x");
	ids[1] = new Identifier("y");
	// I hope this works - this constructor has no documentation at all
	SimpleAlignment sa = new SimpleAlignment (ids, pairAlignNonGapped, new AminoAcids());
	// no idea what this does - PAL needs better documentation
	SitePattern sp = new SitePattern (sa);
	// hmm - I hope the static relative frequencies function works like this - no doc provided

	// WARNING - MIGHT WANT TO ADJUST THIS LATER - doesn't work well for 
	// highly divergent short sequences whose frequencies highly differ from input
	JTT jtt = new JTT(JTT.getOriginalFrequencies());

	// testing - this is fine - we don't want to
	// model gamma rates across sites here - not clear how to choose this
	// besides, PHYLIP uses uniform rates across sites
	// we can change later as needed
	UniformRate ur = new UniformRate();

	// kind of annoying - need to use utility generator class to get instance
	// of JTT into SubstitutionModel
	SubstitutionModel smjtt = SubstitutionModel.Utils.createSubstitutionModel(jtt, ur);
	// with smjtt doesn't work??? - nah, 1.0 indicates too highly diverged
	// according to input frequencies
	PairwiseDistance pd = new PairwiseDistance (sp, smjtt);
	// weird - below does something
	//PairwiseDistance pd = new PairwiseDistance (sp);


	// kind of convoluted - but I shouldn't complain, since I get Golden Section approx method
	// jtt stuff for free

	// only two sequences - get distance between the first and second strings
	double distance = pd.getDistance(0, 1);
	//System.out.println ("distance: " + distance);
	return (distance);
    }

    
    public static void test1 () {
	// nice - it works now!?!?!?!
	// WARNING - if sequences too far apart -> 1.0 distance!!
	String x = "ARYDND--NDRYVVY-------VY---V-V-V-V-";
	String y = "RNYDNVVY--R-Y-Y-Y-Y--AVYD-Y-Y------";
	Sequence xs = new Sequence(); xs.sequence = x; xs.name = "BLAH";
	Sequence ys = new Sequence(); ys.sequence = y; ys.name = "BLAHBLAHBL";
	SimpleJTTDistance d = new SimpleJTTDistance ();
	System.out.println ("distance is: |" + d.getDistance(xs, ys, new boolean[x.length()]) + "|");
    }

    // yes this works
    public static void test2() {
	double[] f = JTT.getOriginalFrequencies();
	for (int i = 0; i < f.length; i++) {
	    System.out.println ("jtt f: " + f[i]);
	}
    }

    public static void main (String[] args) {
	test1();
    }


}



