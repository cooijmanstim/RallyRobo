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
		if (bin == bins.length)
			bin--;
		bins[bin]++;
	}

	public String toString() {
		return "Histogram("+min+" "+Arrays.toString(bins)+" "+max+")";
	}
}
