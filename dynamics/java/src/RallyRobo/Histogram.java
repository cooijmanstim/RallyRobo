package RallyRobo;

import java.util.Arrays;

public class Histogram {
	public final long[] bins;
	public final double min, max;
	
	public Histogram(int nbins, double min, double max) {
		this.bins = new long[nbins];
		this.min = min;
		this.max = max;
	}

	public void record(double x) {
		int bin = (int)((x - min)/(max - min) * bins.length);
		bin = Math.min(bins.length - 1, Math.max(0, bin));
		bins[bin]++;
	}

	public String toString() {
		return "Histogram("+min+" "+Arrays.toString(bins)+" "+max+")";
	}
	
	static void test() {
		Histogram h = new Histogram(6, -3, 3);
		h.record(-2.5);
		h.record(-2.5);
		h.record(-0.5);
		h.record( 0.5);
		h.record( 0.5);
		h.record( 1.5);
		h.record( 2.5);
		assert(Arrays.equals(h.bins, new long[]{2, 0, 1, 2, 1, 1}));
	}
}
