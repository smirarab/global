/**
 *
 * Parser.java
 *
 * Parser for various things.
 * - parse phylip MSA alignment file -> set of strings (which are aligned)
 * - parse collated symmetric distance results file - should have only one 
 *   tree accuracy per entry
 */

import java.io.*;
import java.util.*;

public class Parser {

    // uh, not the best marker... oh well
    // results parsing is not that great :(
    public static final String END_OF_RESULT = "---";

    public static final String TREE_PAIR_MARKER = "Tree pair 1";
    public static final String FPFNCOUNT_MARKER = "FPFNCOUNT";
    //public static final String LOBSTER_STATS_MARKER = "LOBSTER_STATS";
    public static final String SPERROR_MARKER = "SPERROR";
    public static final String METHOD_TIMING_MARKER = "METHODTIMING";
    public static final String ALIGNMENT_TIMING_MARKER = "ALIGNMENTTIMING";
    public static final String GAPPED_COLUMNS_IGNORED_OUTPUT_FLAG = "GAPPED_COLUMNS_IGNORED_OUTPUT_FLAG";
    public static final String MAX_SIMPLE_DISTANCE_FLAG = GappedDistance.MAX_SIMPLE_DISTANCE_FLAG;
    //public double maxSimpleDistance;
    public static final String AVERAGE_SIMPLE_DISTANCE_FLAG = GappedDistance.AVERAGE_SIMPLE_DISTANCE_FLAG;
    //public double averageSimpleDistance;
    public static final String MAX_SIMPLE_GAP_DISTANCE_FLAG = GappedDistance.MAX_SIMPLE_GAP_DISTANCE_FLAG;
    //public double maxSimpleGapDistance;
    public static final String AVERAGE_SIMPLE_GAP_DISTANCE_FLAG = GappedDistance.AVERAGE_SIMPLE_GAP_DISTANCE_FLAG;
    //public double averageSimpleGapDistance;
    public static final String GAP_SCALING_FACTOR_FLAG = GappedDistance.GAP_SCALING_FACTOR_FLAG;
    //public double gapScalingFactor;
    public static final String GAP_SCALING_FACTOR_MULTIPLIER_FLAG = GappedDistance.GAP_SCALING_FACTOR_MULTIPLIER_FLAG;
    //public double gapScalingFactor;
    public static final String MAX_DISTANCE_WITH_GAP_METHOD_FLAG = DistanceWithGapMethod.MAX_DISTANCE_WITH_GAP_METHOD_FLAG;
    //public double maxDistanceWithGapMethod;
    public static final String AVERAGE_DISTANCE_WITH_GAP_METHOD_FLAG = DistanceWithGapMethod.AVERAGE_DISTANCE_WITH_GAP_METHOD_FLAG;
    //public double averageDistanceWithGapMethod;

    public static final String ALIGNMENT_PERCENT_BLANKS_MARKER = AlignmentStatistics.ALIGNMENT_PERCENT_BLANKS_MARKER;
    public static final String ALIGNMENT_BLANKS_COUNT = AlignmentStatistics.ALIGNMENT_BLANKS_COUNT;
    public static final String ALIGNMENT_GAPS_COUNT = AlignmentStatistics.ALIGNMENT_GAPS_COUNT;
    public static final String ALIGNMENT_ROWS_COUNT = AlignmentStatistics.ALIGNMENT_ROWS_COUNT;
    public static final String ALIGNMENT_COLUMNS_COUNT = AlignmentStatistics.ALIGNMENT_COLUMNS_COUNT;
    public static final String ALIGNMENT_AVERAGE_GAPS_PER_SEQUENCE = AlignmentStatistics.ALIGNMENT_AVERAGE_GAPS_PER_SEQUENCE;
    public static final String ALIGNMENT_AVERAGE_GAP_LENGTH = AlignmentStatistics.ALIGNMENT_AVERAGE_GAP_LENGTH;
    public static final String ALIGNMENT_MNHD = AlignmentStatistics.ALIGNMENT_MNHD;
    public static final String ALIGNMENT_ANHD = AlignmentStatistics.ALIGNMENT_ANHD;


    // for tokenizing Newick tree format
    public static final String NEWICK_START_NODE_DELIMITER = "(";
    public static final String NEWICK_END_NODE_DELIMITER = ")";
    public static final String NEWICK_ADD_SIBLING_DELIMITER = ","; 
    public static final String NEWICK_END_TREE_DELIMITER = ";";
    public static final String NEWICK_DELIMITERS = 
	NEWICK_START_NODE_DELIMITER +
	NEWICK_END_NODE_DELIMITER + 
	NEWICK_ADD_SIBLING_DELIMITER + 
	NEWICK_END_TREE_DELIMITER;


    public static final String NEWICK_NODE_INFO_DELIMITER = ":";

    public static final String FASTA_SEQUENCE_NAME_DELIMITER = ">";

    // ok
    public static Sequence[] parseMSA (String filename) {
	try {
	    BufferedReader br = new BufferedReader(new FileReader (filename));
	    String line = br.readLine(); // first line should be rows by column entry
	    StringTokenizer tok = new StringTokenizer (line);
	    int numrows = Integer.parseInt(tok.nextToken());
	    int numcols = Integer.parseInt(tok.nextToken());

	    StringBuffer[] seqs = new StringBuffer[numrows];
	    for (int i = 0; i < seqs.length; i++) {
		seqs[i] = new StringBuffer(numcols);
	    }
	    String[] names = new String[numrows];
	    
	    int currRow = 0;
	    boolean firstSet = true;
	    while ((line = br.readLine()) != null) {
		line = line.trim();
		//System.out.println (line);

		if (line.equals("")) {
		    currRow = 0;
		    firstSet = false;
		}
		else {
		    tok = new StringTokenizer(line);
		    if (firstSet) {
			names[currRow] = tok.nextToken();
		    }
		    while (tok.hasMoreTokens()) {
			seqs[currRow].append(tok.nextToken());
		    }
		    currRow++;
		}
	    }
	    
	    Sequence[] sequences = new Sequence[numrows];
	    for (int i = 0; i < sequences.length; i++) {
		sequences[i] = new Sequence();
		// need to canonically capitalize sequences
		// oops - strings are NON-MUTABLE objects... forgot about that
		sequences[i].sequence = seqs[i].toString().toUpperCase();
		sequences[i].name = names[i];
	    }

	    br.close();

	    return (sequences);
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	    System.exit(1);
	}

	return (null);
    }

    // parse a fasta file 
    // usually used for fasta raw sequences file format
    public static Sequence[] parseFASTA (String filename) {
	try {
	    BufferedReader br = new BufferedReader (new FileReader (filename));
	    String line = "";
	    Vector<Sequence> v = new Vector<Sequence>();
	    String name = "";
	    StringBuffer sb = null;
	    // warning - at end br.readLine() returns null
	    while ((line = br.readLine()) != null) {
		line = line.trim();
		// >??? is sequence name
		// followed by sequence data
		if (line.startsWith(FASTA_SEQUENCE_NAME_DELIMITER)) {
		    if (sb != null) {
			// next sequence -> finish current sequence
			Sequence s = new Sequence();
			s.name = name;
			s.sequence = sb.toString();
			v.add(s);
		    }

		    // now do the new sequence
		    name = line.substring(FASTA_SEQUENCE_NAME_DELIMITER.length());
		    sb = new StringBuffer();
		}
		else {
		    // then it's part of the current sequence
		    sb.append(line);
		}
	    }
	    // need to finish last
	    if (sb != null) {
		// next sequence -> finish current sequence
		Sequence s = new Sequence();
		s.name = name;
		s.sequence = sb.toString();
		v.add(s);
	    }

	    Sequence[] seqs = new Sequence[v.size()];
	    seqs = v.toArray(seqs);

	    return (seqs);
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	    return (null);
	}
    }


    // simple helper function that makes child node a child of the node
    // at the top of stack s
    private static void setTreeNodeParentEdge (Stack<TreeNode> s, TreeNode child) {
	if (!s.empty()) {
	    s.peek().addChild (child);
	}
    }

    private static TreeNode parseNewickTree (String line) {
	// to keep track of construction
	Stack<TreeNode> s = new Stack<TreeNode>();

	// cheap parser - use kludgey StringTokenizer
	StringTokenizer st = new StringTokenizer(line, NEWICK_DELIMITERS, true);

	// argh - due to newick format, need to keep track of previous token
	String tok = "";
	String prevToken = "";

	// root is always first node on stack
	boolean createdRootFlag = false;
	TreeNode rootNode = null;

	while (st.hasMoreTokens()) {
	    prevToken = tok;
	    tok = st.nextToken().trim();

	    if (tok.equals(NEWICK_START_NODE_DELIMITER)) {
		TreeNode newNode = new TreeNode();
		// set link
		setTreeNodeParentEdge (s, newNode);

		// check root
		if (!createdRootFlag) {
		    rootNode = newNode;
		    createdRootFlag = true;
		}
		
		// make a new node and pop it on the stack
		s.push (newNode);
	    }
	    else if (tok.equals(NEWICK_END_NODE_DELIMITER)) {
		// only pop once get name appended to ending parenthesis
		// noop
	    }
	    else if (tok.equals(NEWICK_ADD_SIBLING_DELIMITER)) {
		// keep working with current node DFS step
		// noop
	    }
	    else if (tok.equals(NEWICK_END_TREE_DELIMITER)) {
		// prev token could be anything
		// nodeinfo or it could be end node character
		// just let it slide
	    }
	    else {
		// it's an identifier - in the form of <?name?>:<distance>
		// identifier signals either the end of a node currently being processed ...)something:9.0
		// or the start and end of a leaf node (something:9.0...
		if (prevToken.equals(NEWICK_END_NODE_DELIMITER )) {
		    // identifier attached to the end of a node
		    TreeNode tn = s.pop();
		    parseAndSetNodeData(tn, tok);

		    // that's it - it's done, no more processing for this node
		}
		else {
		    // then, it's a node by itself - just a leaf
		    // just create it and set up links appropriately
		    TreeNode newNode = new TreeNode();
		    parseAndSetNodeData(newNode, tok);
		    // set link
		    setTreeNodeParentEdge (s, newNode);

		    // that's it - it's done, no more processing for leaf
		}
	    }
	}

	// verify that there's only one node left on stack - that should be the root
	if (!(s.size() == 0)) {
	    System.err.println ("ERROR: parse error for tree - " + s.size() + " unfinished nodes left.");
	    return (null);
	}
	else {
	    TreeNode root = rootNode;
	    return (root);
	}
    }

    // very simple parser
    // info string is in form of <?name?>:<distance>
    private static void parseAndSetNodeData (TreeNode tn, String infoString) {
	// hmm... one of three possibilities
	// <tree node name>:<tree node length>
	// <tree node name>
	// :<tree node length>
	StringTokenizer st = new StringTokenizer(infoString, NEWICK_NODE_INFO_DELIMITER, true);

	if (st.countTokens() > 2) {
	    tn.setName (st.nextToken().trim());
	    // get rid of :
	    st.nextToken();
	    tn.setLength (Double.parseDouble(st.nextToken().trim()));
	}
	else if (st.countTokens() == 2) {
	    // get rid of :
	    st.nextToken();
	    // just distance
	    double length = Double.parseDouble(st.nextToken().trim());
	    tn.setLength (length);
	}
	else if (st.countTokens() == 1) {
	    tn.setName (st.nextToken().trim());
	}
	// else noop - no info???
    }

    // WARNING - this parser is really brittle
    // doesn't allow newlines in newick file
    // also doesn't allow malformed newick tree files -> blows up and returns null
    //
    // assume only 1 tree per file
    // later can extend to do multiple trees per file as needed (1 tree per
    // line)
    /**
     * Parse Newick tree file into object.
     */
    public static TreeNode parseNewickTreeFile (String filename) {
	try {
	    BufferedReader br = new BufferedReader (new FileReader (filename));
	    String line = "";

	    // extend this later as needed
	    line = br.readLine();
	    
	    return (parseNewickTree (line));
	    
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	    return (null);
	}
    }

    /**
     * Helper function to populate a TreeNode tree with associated sequences
     */
    public static void populateTreeWithSequences (TreeNode tn, Sequence[] sequences) {
	// sequence name -> Sequence object
	Hashtable<String,Sequence> ht = new Hashtable<String,Sequence>();

	for (int i = 0; i < sequences.length; i++) {
	    ht.put(sequences[i].name, sequences[i]);
	}

	// walk the tree and set appropriately at each node
	populateTreeWithSequencesHelper (tn, ht);
    }

    // walk the tree
    private static void populateTreeWithSequencesHelper (TreeNode tn, Hashtable<String,Sequence> ht) {
	if (tn != null) {
	    Sequence sequence = ht.get(tn.getName());
	    if (sequence != null) {
		tn.setSequence(sequence.sequence);
	    }
	} 

	for (int i = 0; i < tn.getChildren().size(); i++) {
	    TreeNode child = tn.getChildren().get(i);
	    populateTreeWithSequencesHelper (child, ht);
	}
    }

    // no - this parser is dumb - change to 
    // work with each line until single result delimiter reached
    // then start another result
    // try to fill in as much of result as possible 
    /**
     * Result is array of ints - improvement in symmetric distance to 
     * true tree
     * 
     */
    public static Result[] parseSymmetricDistanceResultsFile (String filename) {
	try {
	    BufferedReader br = new BufferedReader(new FileReader(filename));
	    String line = "";
	    Vector<Result> resultsVec = new Vector<Result>();

	    Result r = new Result();

	    // keep stripping off lines until get to EOResult marker ---
	    // then make new result
	    //
	    // process each line based on starting marker
	    while ((line = br.readLine()) != null) {
		line = line.trim();
		if (line.startsWith(END_OF_RESULT)) {		    
		    resultsVec.add (r);
		    r = new Result();
		}
		else if (!line.equals("")) {
		    // process one line for a single result
		    // testing - errors can occur during parsing - note which run/filename caused it
		    try {
			parseSymmetricDistanceResultsLine (line, r, br);
		    }
		    catch (Exception e) {
			System.err.println (e);
			System.err.println ("ERROR: parsing error occurred for raw file: |" + filename + "| for line: |" + line + "|");
		    }
		}
		// else NOOP - ignore blank lines
	    }

	    Result[] results = new Result[resultsVec.size()];
	    for (int i = 0; i < resultsVec.size(); i++) {
		results[i] = resultsVec.get(i);
	    }

	    br.close();

	    return (results);
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	    System.exit(1);
	}

	return (null);
    }


    // HACK - br passed in here - fix later
    private static void parseSymmetricDistanceResultsLine_TREE_PAIR_MARKER (String line, Result r, BufferedReader br) {
	StringTokenizer tok = new StringTokenizer (line, ":");
	tok.nextToken();
	int accuracy = Integer.parseInt(tok.nextToken().trim());
	// re-tokenize last token based on whitespace delimiters
	
	// HACKCKCK
	try {
	line = br.readLine();
	tok = new StringTokenizer (line);
	int numSequences = Integer.parseInt(tok.nextToken().trim());
	int numCols = Integer.parseInt(tok.nextToken().trim());
	// want accuracy relative to maximum symmetric 
	// difference between two trees, which is
	// 2 (n - 3), where n is the number of taxa/sequences
	// at leaf edges
	double relativeAccuracy = ((double) accuracy) / (2.0 * (((double) numSequences) - 3.0)); 
	
	r.relativeError = relativeAccuracy;
	}
	catch (Exception e) {
	    System.err.println (e);
	    System.exit(1);
	}
    }

    private static void parseSymmetricDistanceResultsLine_GAPPED_COLUMNS_IGNORED_OUTPUT_FLAG (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, "|");
	// ignore flag GAPPED_COLUMNS_IGNORED_OUTPUT_FLAG
	tok.nextToken();
	r.percentColsIgnored = Double.parseDouble (tok.nextToken());
	r.colsIgnored = Integer.parseInt (tok.nextToken().trim());
	r.totalCols = Integer.parseInt (tok.nextToken().trim());
    }

    private static void parseSymmetricDistanceResultsLine_MAX_SIMPLE_DISTANCE_FLAG (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, "|");
	tok.nextToken();
	r.maxSimpleDistance = Double.parseDouble(tok.nextToken().trim());
    }

    private static void parseSymmetricDistanceResultsLine_AVERAGE_SIMPLE_DISTANCE_FLAG (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, "|");
	tok.nextToken();
	r.averageSimpleDistance = Double.parseDouble(tok.nextToken().trim());
    }

    private static void parseSymmetricDistanceResultsLine_MAX_SIMPLE_GAP_DISTANCE_FLAG (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, "|");
	tok.nextToken();
	r.maxSimpleGapDistance = Double.parseDouble(tok.nextToken().trim());
    }

    private static void parseSymmetricDistanceResultsLine_AVERAGE_SIMPLE_GAP_DISTANCE_FLAG (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, "|");
	tok.nextToken();
	r.averageSimpleGapDistance = Double.parseDouble(tok.nextToken().trim());
    }

    private static void parseSymmetricDistanceResultsLine_GAP_SCALING_FACTOR_FLAG (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, "|");
	tok.nextToken();
	r.gapScalingFactor = Double.parseDouble(tok.nextToken().trim());
    }

    private static void parseSymmetricDistanceResultsLine_GAP_SCALING_FACTOR_MULTIPLIER_FLAG (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, "|");
	tok.nextToken();
	r.gapScalingFactor = Double.parseDouble(tok.nextToken().trim());
    }


    private static void parseSymmetricDistanceResultsLine_MAX_DISTANCE_WITH_GAP_METHOD_FLAG (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, "|");
	tok.nextToken();
	r.maxDistanceWithGapMethod = Double.parseDouble(tok.nextToken().trim());
    }

    private static void parseSymmetricDistanceResultsLine_AVERAGE_DISTANCE_WITH_GAP_METHOD_FLAG (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, "|");
	tok.nextToken();
	r.averageDistanceWithGapMethod = Double.parseDouble(tok.nextToken().trim());

    }

    private static void parseSymmetricDistanceResultsLine_ALIGNMENT_PERCENT_BLANKS_MARKER (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, Utility.PARSE_SEPARATOR_TOKEN);
	tok.nextToken();
	r.percentAlignmentGaps = Double.parseDouble(tok.nextToken().trim());

    }

    private static void parseSymmetricDistanceResultsLine_ALIGNMENT_BLANKS_COUNT (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, Utility.PARSE_SEPARATOR_TOKEN);
	tok.nextToken();
	r.alignmentBlanksCount = Double.parseDouble(tok.nextToken().trim());

    }

    private static void parseSymmetricDistanceResultsLine_ALIGNMENT_GAPS_COUNT (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, Utility.PARSE_SEPARATOR_TOKEN);
	tok.nextToken();
	r.alignmentGapCount = Double.parseDouble(tok.nextToken().trim());

    }

    private static void parseSymmetricDistanceResultsLine_ALIGNMENT_ROWS_COUNT (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, Utility.PARSE_SEPARATOR_TOKEN);
	tok.nextToken();
	r.alignmentRowsCount = Double.parseDouble(tok.nextToken().trim());

    }

    private static void parseSymmetricDistanceResultsLine_ALIGNMENT_COLUMNS_COUNT (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, Utility.PARSE_SEPARATOR_TOKEN);
	tok.nextToken();
	r.alignmentColumnsCount = Double.parseDouble(tok.nextToken().trim());

    }

    private static void parseSymmetricDistanceResultsLine_ALIGNMENT_AVERAGE_GAPS_PER_SEQUENCE (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, Utility.PARSE_SEPARATOR_TOKEN);
	tok.nextToken();
	r.alignmentAverageGapsPerSequence = Double.parseDouble(tok.nextToken().trim());

    }

    private static void parseSymmetricDistanceResultsLine_ALIGNMENT_AVERAGE_GAP_LENGTH (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, Utility.PARSE_SEPARATOR_TOKEN);
	tok.nextToken();
	r.alignmentAverageGapLength = Double.parseDouble(tok.nextToken().trim());

    }

    private static void parseSymmetricDistanceResultsLine_ALIGNMENT_MNHD (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, Utility.PARSE_SEPARATOR_TOKEN);
	tok.nextToken();
	r.mnhd = Double.parseDouble(tok.nextToken().trim());

    }

    private static void parseSymmetricDistanceResultsLine_ALIGNMENT_ANHD(String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line, Utility.PARSE_SEPARATOR_TOKEN);
	tok.nextToken();
	r.anhd = Double.parseDouble(tok.nextToken().trim());
    }

 	/*
0: numseq
1: alnwidth
2: num_gaps
3: num_gappedsites
4: gap_pct
5: gappedsite_pct
6: 1-lobsterscore_sp
7: 1-lobsterscore_tc
8: 1-lobsterscore_cs
	*/
   
    /*
    private static void parseSymmetricDistanceResultsLine_LOBSTER_STATS_MARKER (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line);

	// strip off first token LOBSTER_STATS
	tok.nextToken();

	r.lobsterNumseq = Double.parseDouble(tok.nextToken().trim());
	r.lobsterAlnwidth = Double.parseDouble(tok.nextToken().trim());
	r.lobsterNumGaps = Double.parseDouble(tok.nextToken().trim());
	r.lobsterNumGappedSites = Double.parseDouble(tok.nextToken().trim());
	r.lobsterGapPct = Double.parseDouble(tok.nextToken().trim());
	r.lobsterGappedsitePct = Double.parseDouble(tok.nextToken().trim());
	r.lobsterSP = Double.parseDouble(tok.nextToken().trim());
	r.lobsterTC = Double.parseDouble(tok.nextToken().trim());
	r.lobsterCS = Double.parseDouble(tok.nextToken().trim());
    }
    */

    private static void parseSymmetricDistanceResultsLine_METHOD_TIMING_MARKER  (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line);

	// strip off first marker token 
	tok.nextToken();

	r.methodTiming = Double.parseDouble(tok.nextToken().trim());
    }

    private static void parseSymmetricDistanceResultsLine_ALIGNMENT_TIMING_MARKER  (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line);

	// strip off first marker token 
	tok.nextToken();

	r.alignmentTiming = Double.parseDouble(tok.nextToken().trim());
    }

    private static void parseSymmetricDistanceResultsLine_SPERROR_MARKER  (String line, Result r) {
	StringTokenizer tok = new StringTokenizer (line);

	// strip off first marker token 
	tok.nextToken();

	r.sperror = Double.parseDouble(tok.nextToken().trim());
    }

    private static void parseSymmetricDistanceResultsLine_FPFNCOUNT_MARKER (String line, Result r) {

	// line format is FPFNCOUNT <fp> <fn> <rows=numtaxa> <cols=numsites>
	StringTokenizer tok = new StringTokenizer (line);
	
	// skip marker FPFNCOUNT
	tok.nextToken();
	
	int fpCount = Integer.parseInt (tok.nextToken());
	int fnCount = Integer.parseInt (tok.nextToken());
	int numSequences = Integer.parseInt (tok.nextToken());
	int numSites = Integer.parseInt (tok.nextToken());

	// want fp error relative to maximum fp count 
	// , which is
	// (n - 3), where n is the number of taxa/sequences
	// at leaf edges
	// similarly for fn error
	double fpError = ((double) fpCount) / (((double) numSequences) - 3.0);
	double fnError = ((double) fnCount) / (((double) numSequences) - 3.0);
	
	r.falsePositiveError = fpError;
	r.falseNegativeError = fnError;
    }


    // HACK - br passed in here - fix later
    private static void parseSymmetricDistanceResultsLine (String line, Result r, BufferedReader br) {
	if (line.startsWith(TREE_PAIR_MARKER)) {
	    parseSymmetricDistanceResultsLine_TREE_PAIR_MARKER (line, r, br);
	}
	else if (line.startsWith(FPFNCOUNT_MARKER)) {
	    parseSymmetricDistanceResultsLine_FPFNCOUNT_MARKER (line, r);
	}
	/*
	else if (line.startsWith(LOBSTER_STATS_MARKER)) {
	    parseSymmetricDistanceResultsLine_LOBSTER_STATS_MARKER (line, r);
	}
	*/
	else if (line.startsWith(SPERROR_MARKER)) {
	    parseSymmetricDistanceResultsLine_SPERROR_MARKER (line, r);
	}
	else if (line.startsWith(METHOD_TIMING_MARKER)) {
	    parseSymmetricDistanceResultsLine_METHOD_TIMING_MARKER (line, r);
	}
	else if (line.startsWith(ALIGNMENT_TIMING_MARKER)) {
	    parseSymmetricDistanceResultsLine_ALIGNMENT_TIMING_MARKER (line, r);
	}
	else if (line.startsWith (GAPPED_COLUMNS_IGNORED_OUTPUT_FLAG)) {
	    parseSymmetricDistanceResultsLine_GAPPED_COLUMNS_IGNORED_OUTPUT_FLAG (line, r);
	}
	//public double maxSimpleDistance;
	else if (line.startsWith(MAX_SIMPLE_DISTANCE_FLAG)) {
	    parseSymmetricDistanceResultsLine_MAX_SIMPLE_DISTANCE_FLAG (line, r);
	}
	//public double averageSimpleDistance;
	else if (line.startsWith(AVERAGE_SIMPLE_DISTANCE_FLAG)) {
	    parseSymmetricDistanceResultsLine_AVERAGE_SIMPLE_DISTANCE_FLAG (line, r);
	}
	//public double maxSimpleGapDistance;
	else if (line.startsWith(MAX_SIMPLE_GAP_DISTANCE_FLAG)) {
	    parseSymmetricDistanceResultsLine_MAX_SIMPLE_GAP_DISTANCE_FLAG (line, r);
	}
	//public double averageSimpleGapDistance;
	else if (line.startsWith(AVERAGE_SIMPLE_GAP_DISTANCE_FLAG)) {
	    parseSymmetricDistanceResultsLine_AVERAGE_SIMPLE_GAP_DISTANCE_FLAG  (line, r);
	}
	//public double gapScalingFactor;
	else if (line.startsWith(GAP_SCALING_FACTOR_FLAG )) {
	    parseSymmetricDistanceResultsLine_GAP_SCALING_FACTOR_FLAG (line, r);
	}
	//public double gapScalingFactorMultiplier;
	else if (line.startsWith(GAP_SCALING_FACTOR_MULTIPLIER_FLAG )) {
	    parseSymmetricDistanceResultsLine_GAP_SCALING_FACTOR_MULTIPLIER_FLAG (line, r);
	}
	//public double maxDistanceWithGapMethod;
	else if (line.startsWith(MAX_DISTANCE_WITH_GAP_METHOD_FLAG)) {
	    parseSymmetricDistanceResultsLine_MAX_DISTANCE_WITH_GAP_METHOD_FLAG  (line, r);
	}
	//public double averageDistanceWithGapMethod;
	else if (line.startsWith(AVERAGE_DISTANCE_WITH_GAP_METHOD_FLAG)) {
	    parseSymmetricDistanceResultsLine_AVERAGE_DISTANCE_WITH_GAP_METHOD_FLAG (line, r);
	}
	else if (line.startsWith(ALIGNMENT_PERCENT_BLANKS_MARKER)) {
	    parseSymmetricDistanceResultsLine_ALIGNMENT_PERCENT_BLANKS_MARKER (line, r);
	}

	else if (line.startsWith(ALIGNMENT_GAPS_COUNT)) {
	    parseSymmetricDistanceResultsLine_ALIGNMENT_GAPS_COUNT (line, r);
	}
	else if (line.startsWith(ALIGNMENT_BLANKS_COUNT)) {
	    parseSymmetricDistanceResultsLine_ALIGNMENT_BLANKS_COUNT (line, r);
	}
	else if (line.startsWith(ALIGNMENT_ROWS_COUNT)) {
	    parseSymmetricDistanceResultsLine_ALIGNMENT_ROWS_COUNT (line, r);
	}
	else if (line.startsWith(ALIGNMENT_COLUMNS_COUNT)) {
	    parseSymmetricDistanceResultsLine_ALIGNMENT_COLUMNS_COUNT (line, r);
	}
	else if (line.startsWith(ALIGNMENT_AVERAGE_GAPS_PER_SEQUENCE)) {
	    parseSymmetricDistanceResultsLine_ALIGNMENT_AVERAGE_GAPS_PER_SEQUENCE (line, r);
	}
	else if (line.startsWith(ALIGNMENT_AVERAGE_GAP_LENGTH)) {
	    parseSymmetricDistanceResultsLine_ALIGNMENT_AVERAGE_GAP_LENGTH (line, r);
	}
	else if (line.startsWith(ALIGNMENT_MNHD)) {
	    parseSymmetricDistanceResultsLine_ALIGNMENT_MNHD (line, r);
	}
	else if (line.startsWith(ALIGNMENT_ANHD)) {
	    parseSymmetricDistanceResultsLine_ALIGNMENT_ANHD (line, r);
	}






	// else noop
	
    }

    /**
     * Only works for PHYLIP protdist results file over 2 sequences only.
     * For pairwise comparisons only!!!
     *
     * Strips out the one and only single PHYLIP substitution distance between
     * the two sequences in the results file and returns it.
     *
     * Returns -1.0 signalling error - nonsymmetric PHYLIP distance???? Shouldn't
     * happen.
     */
    public static double parsePairPHYLIPDistanceResultFile (String filename) {
	try {
	    BufferedReader br = new BufferedReader(new FileReader(filename));
	    // don't care about first line
	    String line = br.readLine();
	    line = br.readLine();
	    StringTokenizer tok = new StringTokenizer(line);
	    tok.nextToken();
	    tok.nextToken();
	    double distance = Double.parseDouble (tok.nextToken());

	    // paranoid - verify that the matrix is symmetric
	    line = br.readLine();
	    tok = new StringTokenizer(line);
	    tok.nextToken();
	    double distance2 = Double.parseDouble (tok.nextToken());
	    
	    if (distance != distance2) {
		return (-1.0);
	    }

	    return (distance);
	}
	catch (IOException ioe) {
	    System.err.println (ioe);
	    System.exit(1);
	}

	return (-1.0);
    }

    public static Sequence[] test1 () {
	Sequence[] seqs = Parser.parseMSA("/u/kliu/research/align/testdist/test.phylip");
	/*
	for (int i = 0; i < seqs.length; i++) {
	    System.out.println (i + "|" + seqs[i].name + "|" + seqs[i].sequence);
	    }*/
	return seqs;
    }

    private static void test2 () {
	Result[] result = Parser.parseSymmetricDistanceResultsFile("/u/kliu/research/align/script/results");

	for (int i = 0; i < result.length; i++) {
	    System.out.println (i + ": " + result[i].relativeError + "|" + result[i].percentColsIgnored + "|" + result[i].colsIgnored + "|" + result[i].totalCols);
	}
    }

    private static void test3 () {
	double dist = Parser.parsePairPHYLIPDistanceResultFile("/tmp/test");
	System.out.println ("dist: " + dist);
    }

    // test
    // inorder traversal
    // hrm - looks good - try compactifying whitespace out of tree file??
    private static void print (TreeNode tn) {
	if (tn.getSequence() == null) {
	    System.err.println ("ERROR: null sequence for tree node");
	}

	System.out.println (tn.getName() + ":" + tn.getLength() + "<");
	for (int i = 0; i < tn.getChildren().size(); i++) {
	    TreeNode child = tn.getChildren().get(i);
	    print(child);
	}
	System.out.println (">");
    }
    
    // testing
    private static void test4 () {
	TreeNode tn = parseNewickTreeFile ("/u/kliu/research/align/test/rose.tt.2");
	Sequence[] aln = parseMSA ("/u/kliu/research/align/test/rose.aln.2.phylip");
	populateTreeWithSequences(tn, aln);
	print (tn);
    }

    private static void test5 (String filename) {
	Sequence[] s = parseFASTA (filename);
	for (int i = 0; i < s.length; i++) {
	    System.out.println (s[i].name + ": |" + s[i].sequence + "|");
	}
    }

    public static void main (String[] args) {
	test5(args[0]);
    }

    
}
