/**
 * Result.java
 * Simple container class for all results associated with a single
 * dataset instance.
 */

public class Result {
    public double relativeError;
    public double falsePositiveError;
    public double falseNegativeError;
    public double percentColsIgnored;
    public int colsIgnored;
    public int totalCols;
    //"MAX_SIMPLE_DISTANCE_FLAG" 
    public double maxSimpleDistance;
    //"AVERAGE_SIMPLE_DISTANCE_FLAG"
    public double averageSimpleDistance;
    //"MAX_SIMPLE_GAP_DISTANCE_FLAG" 
    public double maxSimpleGapDistance;
    //"AVERAGE_SIMPLE_GAP_DISTANCE_FLAG"
    public double averageSimpleGapDistance;
    //"GAP_SCALING_FACTOR_FLAG" 
    public double gapScalingFactor;
    //"GAP_SCALING_FACTOR_MULTIPLIER_FLAG" 
    public double gapScalingFactorMultiplier;
    //"MAX_DISTANCE_WITH_GAP_METHOD_FLAG"
    public double maxDistanceWithGapMethod;
    //"AVERAGE_DISTANCE_WITH_GAP_METHOD_FLAG"
    public double averageDistanceWithGapMethod;

    //"PERCENT_ALIGNMENT_GAPS_MARKER"
    public double percentAlignmentGaps;
    //"ALIGNMENT_BLANKS_COUNT"
    public double alignmentBlanksCount;
    //"ALIGNMENT_GAP_COUNT"
    public double alignmentGapCount;
    //"ALIGNMENT_ROWS_COUNT"
    public double alignmentRowsCount;
    //"ALIGNMENT_COLUMNS_COUNT"
    public double alignmentColumnsCount;
    //"ALIGNMENT_AVERAGE_GAPS_PER_SEQUENCE"
    public double alignmentAverageGapsPerSequence;
    //"ALIGNMENT_AVERAGE_GAP_LENGTH"
    public double alignmentAverageGapLength;
    //"ALIGNMENT_MNHD"
    public double mnhd;
    //"ALIGNMENT_ANHD"
    public double anhd;

    // omitted at collator level for now due to long runtimes of lobster
    // lobster stuff
    /*
    public double lobsterNumseq;
    public double lobsterAlnwidth;
    public double lobsterNumGaps;
    public double lobsterNumGappedSites;
    public double lobsterGapPct;
    public double lobsterGappedsitePct;
    public double lobsterSP;
    public double lobsterTC;
    public double lobsterCS;
    */

    // timing info
    public double methodTiming;
    public double alignmentTiming;

    // alignment accuracy
    public double sperror;

    public Result () {
	initUndefined();
    }

    // initialize all to undefined value
    private void initUndefined () {
	relativeError = -1.0;
	falsePositiveError = -1.0;
	falseNegativeError = -1.0;
	percentColsIgnored = -1.0;
	colsIgnored = -1;
	totalCols = -1;
	maxSimpleDistance = -1.0;
	averageSimpleDistance = -1.0;
	maxSimpleGapDistance = -1.0;
	averageSimpleGapDistance = -1.0;
	gapScalingFactor = -1.0;
	maxDistanceWithGapMethod = -1.0;
	averageDistanceWithGapMethod = -1.0;
	//"PERCENT_ALIGNMENT_GAPS_MARKER"
	percentAlignmentGaps = -1.0;
	//"ALIGNMENT_BLANKS_COUNT"
	alignmentBlanksCount = -1.0;
	//"ALIGNMENT_GAP_COUNT"
	alignmentGapCount = -1.0;
	//"ALIGNMENT_ROWS_COUNT"
	alignmentRowsCount = -1.0;
	//"ALIGNMENT_COLUMNS_COUNT"
	alignmentColumnsCount = -1.0;
	//"ALIGNMENT_AVERAGE_GAPS_PER_SEQUENCE"
	alignmentAverageGapsPerSequence = -1.0;
	//"ALIGNMENT_AVERAGE_GAP_LENGTH"
	alignmentAverageGapLength = -1.0;
	//"ALIGNMENT_MNHD"
	mnhd = -1.0;
	//"ALIGNMENT_ANHD"
	anhd = -1.0;
	
	/*
	lobsterNumseq = -1.0;
	lobsterAlnwidth = -1.0;
	lobsterNumGaps = -1.0;
	lobsterNumGappedSites = -1.0;
	lobsterGapPct = -1.0;
	lobsterGappedsitePct = -1.0;
	lobsterSP = -1.0;
	lobsterTC = -1.0;
	lobsterCS = -1.0;
	*/

	methodTiming = -1.0;
	alignmentTiming = -1.0;
	sperror = -1.0;
    }

}
