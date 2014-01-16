package RallyRobo;

import java.util.Arrays;

class Test {
	public static void main(String[] args) {
		Util.test();
		Point.test();
		Feature.test();
		Direction.test();
		Card.test();
		Robot.test();
		Game.test();
		DecisionSet.test();
		MonteCarloDecision.test();
	}

	static void assert_pos(Robot robot, int i, int j) {
		int[] expected = Point.make(i, j);
		if (!Point.equals(robot.position, expected))
			throw new AssertionError("robot["+robot.identity+"].position "+
									  "expected "+Arrays.toString(expected)+
									  " but saw "+Arrays.toString(robot.position));
	}

	static void assert_posdir(Robot robot, int i, int j, Direction dir) {
		assert_pos(robot, i, j);
		assert(robot.direction == dir);
	}

	static void assert_equal(int expected, int actual) {
		if (expected != actual)
			throw new AssertionError("assert_equal: expected "+expected+" but saw "+actual);
	}

	public static void assert_equal(int[] expected, int[] actual) {
		if (!Arrays.equals(expected, actual))
			throw new AssertionError("assert_equal: "+
					  "expected "+Arrays.toString(expected)+
					  " but saw "+Arrays.toString(actual));
	}

	public static void assert_equal(int[][] expected, int[][] actual) {
		if (!Arrays.deepEquals(expected, actual))
			throw new AssertionError("assert_equal: "+
					  "expected "+Arrays.deepToString(expected)+
					  " but saw "+Arrays.deepToString(actual));
	}
}
