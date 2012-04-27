/**
 * RandomInteger.java
 * Create a random number between [0, 2^31)
 */

public class RandomInteger {
    // hmm - I'm going to assume ROSE can't handle 4 byte integers
    // use 1 byte integers
    //
    // err - can't do this... 2^8 = 256 max number of seeds ->
    // 256 max number of rose runs??????
    // NO
    //public static final int MAX_VALUE = ((int) Math.pow(2.0,8.0)) - 1;
    public static final int MAX_VALUE = Integer.MAX_VALUE;

    public static void main (String[] args) {
	int randomInteger = (int) (RandomInteger.MAX_VALUE * Math.random());
	System.out.println (randomInteger);
    }
}
