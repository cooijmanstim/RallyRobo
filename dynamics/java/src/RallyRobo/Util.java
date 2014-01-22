package RallyRobo;

import java.util.Arrays;
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

	// reservoir sampling on a set represented by a bit vector
	// http://en.wikipedia.org/wiki/Reservoir_sampling
	static int[] take(int k, boolean set[]) {
		int[] sample = new int[k];
		int m = set.length;

		int j = 0;
		for (int i = 0; ; i++) {
			// fast forward to the next element of the set
			for (; j < m && !set[j]; j++) {}

			if (j >= m) {
				// there should have been at least k elements in the set
				assert(i >= k);
				break;
			}
			
			if (i < k) {
				// initial phase: fill the reservoir
				set[j] = false;
				sample[i] = j;
			} else {
				// replace reservoir items
				// XXX: not sure why the +1 is needed. the wikipedia example stresses
				// that the range should be inclusive, but since we are dealing with
				// 0-based indices, leaving out the +1 should be equivalent. however,
				// tests show a bias toward replacement when it is left out.
				int h = Util.generator.nextInt(i+1);
				if (h < k) {
					set[sample[h]] = true;
					set[j] = false;
					sample[h] = j;
				}
			}
			
			j++;
		}
		
		return sample;
	}
	
	public static int[] take(int k, int[] xs) {
		boolean[] set = new boolean[xs.length];
		Arrays.fill(set, true);
		int[] sample = take(k, set);
		for (int i = 0; i < sample.length; i++)
			sample[i] = xs[sample[i]];
		return sample;
	}

	public static int digitsToNumber(int[] digits, int radix) {
		int number = 0;
		for (int i = 0, ni = digits.length; i < ni; i++) {
			number *= radix;
			number += digits[i];
		}
		return number;
	}
	
	public static int[] numberToDigits(int number, int radix, int ndigits) {
		int[] digits = new int[ndigits];
		for (int i = ndigits-1; i >= 0; i--) {
			if (number <= 0)
				break;
			digits[i] = number % radix;
			number = number / radix;
		}
		assert(number == 0);
		return digits;
	}

	// in our domain, n will be at most 5, so no need to worry about overflow
	public static int multinomial_coefficient(int n, int[] ks) {
		int sum = 0;
		for (int i = 0; i < ks.length; i++) {
			sum += ks[i];

			for (int k = ks[i]-1; k > 1; k--)
				ks[i] *= k;
		}

		// if ks don't sum to n, add an (n-sum)! in the denominator
		int k0 = n - sum;

		int c = 1;
		for (int d = n; d > k0; d--)
			c *= d;
		for (int i = 0; i < ks.length; i++)
			c /= ks[i];
		return c;
	}

	public static void test() {
		test_multinomial_coefficient();
	}

	private static void test_multinomial_coefficient() {
		Test.assert_equal(6, multinomial_coefficient(3, new int[]{1, 1, 1}));
		Test.assert_equal(3, multinomial_coefficient(3, new int[]{2, 1}));
		Test.assert_equal(6, multinomial_coefficient(3, new int[]{1, 1}));
		Test.assert_equal(6, multinomial_coefficient(4, new int[]{2, 2}));
	}

}
