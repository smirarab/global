public class Test {
    public static void main (String[] args) {
	int[] arr = { 0, 1, 2, 1, 1, 1, 1, 1 };
	double median = Utility.calculateHistogramMedian(arr);
	System.out.println ("median is |" + median + "|");
	for (int i = 0; i < arr.length; i++) {
	    System.out.print (arr[i] + " ");
	    System.out.println();
	}
    }
}
