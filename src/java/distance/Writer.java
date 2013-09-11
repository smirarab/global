/**
 * Writer.java
 *
 * Writes in various file formats.
 */

import java.io.*;
import java.util.*;
import java.text.*;

public class Writer {
    // arg - PHYLIP wants output 10 char by 10 char
    public static final int PHYLIP_OUTPUT_CHUNK_SIZE = 10;
    public static final int PHYLIP_OUTPUT_MAX_CHUNKS_PER_PHYLIP_LINE = 6;
    public static final String PHYLIP_BLANK_NAME = "          ";
    public static final String PHYLIP_NAME_TAB = "   ";

    /**
     * Writes out a pair of sequences into PHYLIP format.
     * x and y MUST be of the same length
     */
    public static void writeMSA (Sequence x, Sequence y, String filename) {
	Sequence[] seqs = new Sequence[2];
	seqs[0] = x;
	seqs[1] = y;

	writeMSA (seqs, filename);
    }

    /**
     * Writes out an alignment into PHYLIP format.
     * All sequences in seqs MUST be of the same length
     */
    public static void writeMSA (Sequence[] seqs, String filename) {
	if (!verifyLength (seqs)) {
	    System.err.println ("ERROR: MSA for output to PHYLIP temporary file has sequences with differing lengths.");
	    System.exit(1);
	}

	try {
	    FileWriter fw = new FileWriter (filename);
	    
	    // index into pairwise alignment - advanced "line" by "line"
	    // through PHYLIP output
	    int ind = 0;
	    // keep track of new index into alignment after PHYLIP line output
	    int newind = -1;

	    // write out header
	    // hmm - it seems to be flexible with spaces
	    fw.write (" " + seqs.length + " " + seqs[0].sequence.length() + "\n");
	    
	    // first sequence must exist by verify check above
	    while (ind < seqs[0].sequence.length()) {
		// output a PHYLIP line
		for (int i = 0; i < seqs.length; i++) {
		    // now process an individual line
		    // output "line" of PHYLIP output
		    // where it's output the pairwise 
		    // alignment out to PHYLIP line limits
		    newind = outputPhylipLine(seqs[i], fw, ind);
		}
		// need extra newline after PHYLIP line output
		fw.write ("\n");

		ind = newind;
	    }

	    fw.flush();
	    fw.close();
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	    System.exit(1);
	}
    } 

    /**
     * Output a PHYLIP "line" where it's a max 7 chunk (of 10 chars each) 
     * line for each sequence in the pair. Try to exhaust
     * the pair as well.
     *
     * Returns new index
     */
    private static int outputPhylipLine (Sequence x, FileWriter fw, int ind) throws IOException {
	int origind = ind;

	if (ind == 0) {
	    // output names for first PHYLIP line only
	    outputPhylipLineName (x, fw);
	}
	else {
	    // 10 chars for name, 3 chars for blank
	    fw.write (PHYLIP_BLANK_NAME + PHYLIP_NAME_TAB);
	}

	// don't want to run off of sequence string ends
	// also need to output max 6 chunks with 10 chars per chunk for a
	// PHYLIP line
	while ((ind < x.sequence.length()) && (ind - origind < PHYLIP_OUTPUT_CHUNK_SIZE * PHYLIP_OUTPUT_MAX_CHUNKS_PER_PHYLIP_LINE)) {
	    fw.write (x.sequence.charAt(ind));
	    if (ind % PHYLIP_OUTPUT_CHUNK_SIZE == PHYLIP_OUTPUT_CHUNK_SIZE - 1) {
		fw.write (" ");
	    }
	    ind++;
	}
	fw.write ("\n");

	return (ind);
    }

    private static void outputPhylipLineName (Sequence x, FileWriter fw) throws IOException { 
	fw.write (x.name);
	for (int i = 0; i < 10 - x.name.length(); i++) {
	    fw.write (" ");
	}
	fw.write (PHYLIP_NAME_TAB);
    }

    /**
     * Make sure MSA all sequences have same length (and are valid).
     */
    private static boolean verifyLength (Sequence[] seqs) {
	if ((seqs == null) || (seqs[0] == null)) {
	    return (false);
	} 

	for (int i = 0; i < seqs.length; i++) {
	    if (seqs[i].sequence.length() != seqs[0].sequence.length()) {
		return (false);
	    }
	}

	return (true);
    }

    /**
     * Find largest significant digit place for all pairwise distances
     * between sequences
     *
     * if returns x, then all pairwise distances are strictly less than 10^x
     */
    private static int getMaxSignificantDigit (double[][] distances) {
	double maxD = -1;
	for (int i = 0; i < distances.length; i++) {
	    for (int j = i+1; j < distances[i].length; j++) {
		double d = distances[i][j];
		if (d > maxD) {
		    maxD = d;
		}
	    }
	}

	return (getMaxSignificantDigit(maxD));

    }

    private static int getMaxSignificantDigit (double dist) {
	// testing
	//System.out.println ("Maximum pairwise distance is: |" + dist + "|");

	int exp = (int) Math.ceil(Math.log10(dist));

	if (exp - ((int) Math.floor(Math.log10(dist))) == 0) {
	    // exact power of 10 - go to next power
	    return (exp + 1);
	}
	else {
	    return (exp);
	}
    }


    private static String getNumberFormatString (double[][] distances) {
	int msd = getMaxSignificantDigit (distances);

	return (getNumberFormatString(msd));
    }

    private static String getNumberFormatString (double distance) {
	int msd = getMaxSignificantDigit (distance);

	return (getNumberFormatString(msd));
    }

    private static String getNumberFormatString (int msd) {
	StringBuffer sb = new StringBuffer ("0000000");
	
	// frustrating how the distances are input in the PHYLIP format
	if ((7 > msd) && (msd > 0)) {
	    sb.insert(msd, ".");
	}
	else if (msd >= 7) {
	    sb.insert (6, ".");
	}
	else { // msd > 0
	    sb.insert(1, ".");
	}

	return (sb.toString());
    }


    /**
     * Writes out a distance matrix for an MSA represented
     * by seqs in PHYLIP format.
     */
    public static void writePhylipDistanceMatrix (Sequence[] seqs, double[][] distances, String filename) {
	try {
	    FileWriter fw = new FileWriter(filename);

	    // NO - do distance number formatting on a per distance basis
	    //String nfs = getNumberFormatString (distances);
	    //DecimalFormat f = new DecimalFormat (nfs);

	    fw.write ("   " + seqs.length); fw.write("\n");
	    
	    for (int i = 0; i < distances.length; i++) {
		// this is fine since indices in two arrays correspond
		fw.write (seqs[i].name); 
		for (int k = 0; k < 10 - seqs[i].name.length(); k++) {
		    fw.write (" ");
		}
		fw.write ("  ");
		// since we've already output name in 0th column
		int cols = 1;
		for (int j = 0; j < distances[i].length; j++) {
		    if ((cols == 0) && (j > 0)) {
			// we've wrapped around to a new line after
			// this first line - indent
			fw.write ("  ");
		    }

		    if (i != j) {
			int di = i;
			int dj = j;
			// force symmetric matrix - arg - what the???
			// testing!!!
			if (j > i) { di = j; dj = i; }
			double d = distances[di][dj];

			String nfs = getNumberFormatString (d);
			DecimalFormat f = new DecimalFormat (nfs);

			// testing
			//if (d > 2000) {
			//	System.err.println ("ARGH");
			//}
			fw.write (f.format(d));
		    }
		    else {
			fw.write ("0.000000");
		    }
		    fw.write ("  ");
		    cols++;
		    if (cols >= 7) {
			fw.write("\n");
			cols = 0;
		    }
		}
		// this needs to be 0 - since reset to 0 after
		// column exhausted cols >= 7 above
		if (cols != 0) {
		    // testing
		    //System.out.println ("cols after row exhausted: |" + cols + "|");

		    fw.write("\n");
		}
	    }
	    
	    fw.flush();
	    fw.close();
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	    System.exit(1);
	}

    }

    public static void test1 () {
	Sequence[] seqs = new Sequence[4];
	for (int i = 0; i < seqs.length; i++) {
	    seqs[i] = new Sequence();
	}
	seqs[0].name = "BLAH";
	seqs[0].sequence = "KJHKAJSHDLKJHEWKHLKJHEWFKLJHWJEHFKWE234234398798719879387287kjhjwhefkjhwekhkjhwkejfheeeef23KJHKAJSHDLKJHEWKHLKJHEWFKLJHWJEHFKWE234234398798719879387287kjhjwhefkjhwekhkjhwkejfheeeef23JLKJWLKJDQLWKJLKQJWLKDLKLK#R#L@KRJ#RLKJ#LRK43lijlu698968798987989687968985998394593454939()";
	seqs[1].name = "BLAHBLAHAH";
	seqs[1].sequence = "WEFLKJWELFJELWJFLKWJELFKJWLEJFLKWJELKJLWJLFkljlktyjkjykhjtkyhkjkjk6jhj6kjh6kjhk6jkjyk6jkyy6WEFLKJWELFJELWJFLKWJELFKJWLEJFLKWJELKJLWJLFkljlktyjkjykhjtkyhkjkjk6jhj6kjh6kjhk6jkjyk6jkyy6JLKJWLKJDQLWKJLKQJWLKDLKLK#R#L@KRJ#RLKJ#LRK43lijlu698968798987989687968985998394593454()984";
	seqs[2].name = "BLEEBLEEBL";
	seqs[2].sequence = "JLKJWLKJDQLWKJLKQJWLKDLKLK#R#L@KRJ#RLKJ#LRK43lijlu69896879898798968796898599839459345493984JLKJWLKJDQLWKJLKQJWLKDLKLK#R#L@KRJ#RLKJ#LRK43lijlu69896879898798968796898599839459345493984JLKJWLKJDQLWKJLKQJWLKDLKLK#R#L@KRJ#RLKJ#LRK43lijlu69896879898798968796898599839459()5493984";
	seqs[3].name = "E";
	seqs[3].sequence = "klhh23rjkh2kjhrk3jhrkjh2kjh3krhk2j3hrkjh3jh435hkjhrekgjhekrhgkjhjhrjghk3jh4kjh4jhgj4hjthj4hJLKJWLKJDQLWKJLKQJWLKDLKLK#R#L@KRJ#RLKJ#LRK43lijlu69896879898798968796898599839459345493984JLKJWLKJDQLWKJLKQJWLKDLKLK#R#L@KRJ#RLKJ#LRK43lijlu698968798987()968796898599839459345493())";

	writeMSA (seqs, "/tmp/test");
    }

    public static void test2 () {
	Sequence x = new Sequence();
	Sequence y = new Sequence();
	x.name = "BLAH";
	x.sequence = "KJHKAJSHDLKJHEWKHLKJHEWFKLJHWJEHFKWE234234398798719879387287kjhjwhefkjhwekhkjhwkejfheeeef23KJHKAJSHDLKJHEWKHLKJHEWFKLJHWJEHFKWE234234398798719879387287kjhjwhefkjhwekhkjhwkejfheeeef23JLKJWLKJDQLWKJLKQJWLKDLKLK#R#L@KRJ#RLKJ#LRK43lijlu698968798987989687968985998394593454939()";
	y.name = "BLAHBLAHAH";
	y.sequence = "WEFLKJWELFJELWJFLKWJELFKJWLEJFLKWJELKJLWJLFkljlktyjkjykhjtkyhkjkjk6jhj6kjh6kjhk6jkjyk6jkyy6WEFLKJWELFJELWJFLKWJELFKJWLEJFLKWJELKJLWJLFkljlktyjkjykhjtkyhkjkjk6jhj6kjh6kjhk6jkjyk6jkyy6JLKJWLKJDQLWKJLKQJWLKDLKLK#R#L@KRJ#RLKJ#LRK43lijlu698968798987989687968985998394593454()984";
	
	writeMSA (x, y, "/tmp/test");
    }

    public static void main (String[] args) {
	test2();
    }
}
