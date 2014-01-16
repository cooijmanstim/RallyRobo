package RallyRobo;

public class Average {
	private double average = 0;
	private long n = 0;
	
	public Average() {
	}
	
	public void record(double x) {
		average = average*n/(n+1) + x*1/(n+1);
		n++;
	}
	
	public double value() {
		assert(n != 0);
		return average/n;
	}
}
