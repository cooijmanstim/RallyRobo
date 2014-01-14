package RallyRobo;

import java.util.Arrays;

class Test {
	public static void main(String[] args) {
		Point.test();
		Feature.test();
		Direction.test();
		Card.test();
		Robot.test();
		Game.test();
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
}
