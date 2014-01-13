package RallyRobo;

import java.util.Random;

public class Util {
	static final Random generator = new Random();

	static double variance(double[] xs) {
		int n = xs.length;
		double sum1 = 0, sum2 = 0;
		for (double x: xs)
			sum1 += x;
		double mean = sum1/n;
		for (double x: xs)
			sum2 += Math.pow(x - mean, 2);
		return sum2/(n - 1);
	}
}
