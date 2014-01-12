package RallyRobo;

import java.util.Arrays;

class Point {
	static final int dimensionality = 2;

	static int[] make(int... x) {
		return x;
	}

	static boolean equals(int[] a, int[] b) {
		return Arrays.equals(a, b);
	}

	static void addTo(int[] x, int[] dx) {
		for (int i = 0; i < dimensionality; i++)
			x[i] += dx[i];
	}

	static int[] add(int[] x, int[] y) {
		int[] z = x.clone();
		addTo(z, y);
		return z;
	}

	// true iff one or more steps in direction dir from a lead to b
	static boolean sees(int[] a, int[] b, Direction dir) {
		int[] dx = dir.vector;
		for (int i = 0; i < dimensionality; i++)
			if (a[i] == b[i] && dx[i] == 0 && (b[1-i] - a[1-i])/dx[1-i] > 0)
				return true;
		return false;
	}


	static void test() {
		assert( sees(make(0, 0), make( 0, 3), Direction.East));
		assert( sees(make(0, 0), make(-3, 0), Direction.South));
		assert(!sees(make(0, 0), make(-3, 0), Direction.East));
		assert(!sees(make(0, 0), make( 0,-3), Direction.South));
	}
}
