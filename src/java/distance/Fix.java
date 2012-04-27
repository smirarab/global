/**
 * Utility script to fix names on trees to be of limited length.
 * Name collisions resolved also.
 */

import java.io.*;
import java.util.*;

public class Fix {
    public static final int MAX_NAME_LENGTH = 10;
    // first half preserve
    // second half discard
    public static final String TOK_DELIM = " \t\n\r\f(),:";

    // keep digits!!
    /*
      case '0': return true;
      case '1': return true;
      case '2': return true;
      case '3': return true;
      case '4': return true;
      case '5': return true;
      case '6': return true;
      case '7': return true;
      case '8': return true;
      case '9': return true;
    */
    // chars in entire string to blow away
    private static boolean checkDiscard (char c) {
	switch (c) {
	    // NO - DO NOT DELETE periods!!! these used in distances!!
	    //	case '.': return true;
	case '_': return true;
	default: return false;
	}
    }

    private static boolean checkInclude (char c) {
	switch (c) {
	case '(': return true;
	case ')': return true;
	case ',': return true;
	case ' ': return true;
	case '\t': return true;
	case '\n': return true;
	case '\r': return true;
	case '\f': return true;
	default: return false;
	}
    }

    public static void fix (String filename) {
	try {
	    StringBuffer all = new StringBuffer();
	    BufferedReader br = new BufferedReader(new FileReader(filename));
	    String line = "";
	    // upper case it
	    while ((line = br.readLine()) != null) {
		line = line.toUpperCase();
		all.append(line);
	    }

	    if (!all.toString().matches(".*;.*")) {
		all.append(";");
	    }

	    // first pass - remove unwanted chars
	    // LEAVE NUMBERS
	    // just do number -> char replacement at next step
	    // mmm - need to be a little smarter - leave in distances
	    // 
	    for (int i = 0; i < all.length(); i++) {
		if (checkDiscard(all.charAt(i))) {
		    all.delete(i, i+1);
		    i--;
		}
	    }

	    StringBuffer trunc = new StringBuffer();
	    // second pass - truncate all names to be max number of chars allowed
	    // while also resolving name collisions
	    HashSet<String> hs = new HashSet<String> ();
	    StringTokenizer tok = new StringTokenizer (all.toString(), TOK_DELIM, true);
	    while (tok.hasMoreTokens()) {
		String t = tok.nextToken();
		if (t.length() == 1) {
		    if (checkInclude(t.charAt(0))) {
		        trunc.append(t);
		    }
		    else {
			// hmm - well append in any case - don't bother with collision resolution here
			trunc.append(t);
		    }
		}
		// not a delimiter - SHOULDN'T be single char names
		else {
		    // testing
		    //System.out.println ("t nametest: |" + t + "|" + isNameToken(t) + "|");
		    if (isNameToken(t)) {
			// testing
			//System.out.println ("t orig: " + t);
			
			t = substituteCharsForDigits(t);
			t = removeUnwantedNameChars(t);

			//System.out.println ("t subs: " + t);

			// not a delimiter - check for length
			if (t.length() > MAX_NAME_LENGTH) {
			    t = t.substring(0, MAX_NAME_LENGTH);
			}
			
			if (hs.contains(t)) {
			    String newt = resolveCollision (t, hs);
			    hs.add(newt);
			    trunc.append(newt);
			    
			    // testing
			    //System.out.println ("collision occurred: " + t + "|" + newt);
			}
			else { //  no collision
			    hs.add(t);
			    trunc.append(t);
			}
		    }
		    // it's a distance
		    else {
			// straight append
			trunc.append(t);			    
		    }
		}
	    }
	    
	    System.out.println (trunc);

	    br.close();
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	    System.exit(1);
	}
    }

    private static boolean isUnwantedNameChar (char c) {
	switch (c) {
	case '.': return true;
	case '-': return true;
	default: return false;
	}
    }

    /**
     * s is a name token - remove all unwawnted chars in name
     */
    private static String removeUnwantedNameChars (String s) {
	StringBuffer sb = new StringBuffer (s);
	for (int i = 0; i < sb.length(); i++) {
	    if (isUnwantedNameChar(sb.charAt(i))) {
		sb.delete(i, i+1);
		i--;
	    }
	}
	
	return (sb.toString());
    }

    /**
     * Simple test - if first character isn't a digit, then it's a name token
     */
    private static boolean isNameToken (String s) {
	if (s == null) {
	    return (false);
	}

	if (s.length() <= 0) {
	    return false;
	}

	if (!Character.isDigit(s.charAt(0))) {
	    return (true);
	}
	else {
	    return (false);
	}
    }

    /**
     * Remap digits to corresponding chars in t
     */
    private static String substituteCharsForDigits (String t) {
	StringBuffer sb = new StringBuffer (t);
	for (int i = 0; i < sb.length(); i++) {
	    char c = sb.charAt(i);
	    if (Character.isDigit(c)) {
		sb.replace (i, i+1, mapDigitToChar(c));
	    }
	}

	return (sb.toString());
    }

    private static String mapDigitToChar (char dc) {
	switch (dc) {
	case '0': return "A";
	case '1': return "B";
	case '2': return "C";
	case '3': return "D";
	case '4': return "E";
	case '5': return "F";
	case '6': return "G";
	case '7': return "H";
	case '8': return "I";
	case '9': return "J";
	default: return "";
	}
    }


    /**
     * find a new name by flipping one character at a time brute force
     * doesn't even try all possible names... oh well
     */
    private static String resolveCollision (String t, HashSet hs) {
	StringBuffer sbt = new StringBuffer(t);
	// doesn't try all possible strings - oh well - no need for all
	for (int i = 0; i < sbt.length(); i++) {
	    // does this work??
	    for (char c = 'A'; c <= 'Z'; c++) {
		sbt.setCharAt(i, c);
		if (!hs.contains(sbt.toString())) {
		    return (sbt.toString());
		}
	    }
	}
	// shouldn't happen - if so just try |[A, ..., Z]|^|t| exponentially many possible charstrings instead of limited number of new charstrings above
	System.err.println ("ERROR: name collision could not be resolved by this really naive single char flip.");
	System.exit(1);
	return ("ERROR");
    }

    public static void main (String[] args) {
	if (args.length != 1) {
	    System.out.println ("Usage: java Fix <tree file to fix for names>");
	    System.exit(1);
	}

	fix(args[0]);
    }
}
