/**
 * SimplePHYLIPDayhoffDistance.java
 *
 * Calculate distance using Dayhoff substitution matrix as
 * taken from PHYLIP's protdist program.
 *
 * Argh, can't find Dayhoff matrix that works. Later, try going back to the
 * original paper.
 * For now, use workaround per Tandy's advice, just do pairwise 
 * distance calc directly using PHYLIP's protdist program.
 *
 * TOO SLOW DON'T USE THIS
 */

import java.io.*;
import java.util.*;

public class SimplePHYLIPDayhoffDistance extends SimplePHYLIPDistance {
    public static final String DISTANCE_TYPE_STRING = "standard.nei_dayhoff";

    public SimplePHYLIPDayhoffDistance () {
	super();
    }

    /**
     * To prevent name collisions by concurrently running processes
     */
    public SimplePHYLIPDayhoffDistance (String uniqueFilenameSuffix) {
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
	SimplePHYLIPDayhoffDistance d = new SimplePHYLIPDayhoffDistance ();
	System.out.println ("distance is: |" + d.getDistance(xs, ys, null) + "|");
    }

    public static void main (String[] args) {
	test1();
    }
    


}



