package RallyRobo;

class Test {
	public static void main(String[] args) {
		Point.test();
		Feature.test();
		Direction.test();
		Card.test();
		Robot.test();
		Game.test();
	}

	static void assert_pos(Robot robot, int i, int j) {
		assert(Point.equals(robot.position, Point.make(i, j)));
	}

	static void assert_posdir(Robot robot, int i, int j, Direction dir) {
		assert_pos(robot, i, j);
		assert(robot.direction == dir);
	}
}
