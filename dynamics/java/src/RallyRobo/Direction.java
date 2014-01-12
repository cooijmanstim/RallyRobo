package RallyRobo;

enum Direction {
	East ( 0, 1),
	North( 1, 0),
	West ( 0,-1),
	South(-1, 0);

	final Point vector;
	final static Feature earlyWall, lateWall, conveyor;

	private final static Direction[] values = values();
	final static int cardinality = values().length;

	Direction(int... dx) {
		vector = dx;
		Feature[] walls = {Feature.WallEast, Feature.WallNorth, Feature.WallWest, Feature.WallSouth};
		Feature[] conveyors = {Feature.ConveyorEast, Feature.ConveyorNorth, Feature.ConveyorWest, Feature.ConveyorSouth};
		earlyWall = wallsByDirection[ordinal()];
		lateWall = wallsByDirection[ordinal()];
		conveyor = conveyors[ordinal()];
	}

	Direction rotate(Direction a, int da) {
		return Direction.values[((a + da + cardinality) % cardinality)];
	}

	Direction opposite(Direction a) {
		return rotate(a, 2);
	}


	static void test() {
		assert(rotate(East, -1) == South);
		assert(rotate(South, 2) == North);

		assert(East.earlyWall == Feature.WallWest);
		assert(East. lateWall == Feature.WallEast);
	}
}
