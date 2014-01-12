package RallyRobo;

enum Direction {
	East ( 0, 1),
	North( 1, 0),
	West ( 0,-1),
	South(-1, 0);

	final int[] vector;
	final Feature earlyWall, lateWall, conveyor;

	private final static Direction[] values = values();
	final static int cardinality = values().length;

	Direction(int... dx) {
		vector = dx;
		Feature[] walls = {Feature.WallEast, Feature.WallNorth, Feature.WallWest, Feature.WallSouth};
		Feature[] conveyors = {Feature.ConveyorEast, Feature.ConveyorNorth, Feature.ConveyorWest, Feature.ConveyorSouth};
		earlyWall = walls[ordinal()];
		lateWall = walls[ordinal()];
		conveyor = conveyors[ordinal()];
	}

	Direction rotate(int d) {
		return Direction.values[((ordinal() + d + cardinality) % cardinality)];
	}

	Direction opposite() {
		return rotate(2);
	}


	static void test() {
		assert(East.rotate(-1) == South);
		assert(South.rotate(2) == North);

		assert(East.earlyWall == Feature.WallWest);
		assert(East. lateWall == Feature.WallEast);
	}
}
