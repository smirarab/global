/**
 * SimplePHYLIPJTTDistance.java
 *
 * Calculate distance using Jones Taylor Thornton substitution matrix as
 * taken from PHYLIP's protdist program.
 *
 * Argh, can't find JTT matrix that works. Later, try going back to the
 * original paper.
 * For now, use workaround per Tandy's advice, just do pairwise 
 * distance calc directly using PHYLIP's protdist program.
 *
 * Too slow! Don't use this anymore. Use lapd implementation instead.
 */

import java.io.*;
import java.util.*;

public class SimplePHYLIPJTTDistance extends SimplePHYLIPDistance {
    public static final String DISTANCE_TYPE_STRING = "standard.nei_jtt";

    public SimplePHYLIPJTTDistance () {
	super();
    }

    /**
     * to prevent name collisions by concurrently running processes
     */
    public SimplePHYLIPJTTDistance (String uniqueFilenameSuffix) {
	super (uniqueFilenameSuffix);
    }

    /**
     * let superclass know which distance type to use
     */
    public String getDistanceTypeString () {
	return (DISTANCE_TYPE_STRING);
    }

    // um ok
    
    public static void test1 () {
	String x = "ARNDND--NDRYVVY-------VY---V-V-V-V-";
	String y = "DRYVYVVY--Y-Y-Y-Y-Y--ARND-Y-Y------";
	Sequence xs = new Sequence(); xs.sequence = x; xs.name = "BLAH";
	Sequence ys = new Sequence(); ys.sequence = y; ys.name = "BLAHBLAHBL";
	SimplePHYLIPJTTDistance d = new SimplePHYLIPJTTDistance ();
	System.out.println ("distance is: |" + d.getDistance(xs, ys, null) + "|");
    }

    public static void main (String[] args) {
	test1();
    }
    

}



