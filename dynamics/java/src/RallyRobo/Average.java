package RallyRobo;

public class Average {
	private double average = 0;
	private long n = 0;
	
	public Average() {
	}
	
	public void record(double x) {
		average = average*(n*1.0/(n+1)) + x*1/(n+1);
		n++;
	}
	
	public double value() {
		assert(n != 0);
		return average;
	}
	
	public static void test() {
		Average a = new Average();
		for (int i: new int[]{1,5,6,4,8,2,1,5})
			a.record(i);
		Test.assert_equalish(4, a.value());
	}

	public boolean baseless() {
		return n == 0;
	}

	public long sampleSize() {
		return n;
	}
}
