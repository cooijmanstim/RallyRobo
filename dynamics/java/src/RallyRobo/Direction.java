package RallyRobo;

enum Direction {
	East ( 0, 1),
	North( 1, 0),
	West ( 0,-1),
	South(-1, 0);

	public final int[] vector;
	public final Feature earlyWall, lateWall, conveyor;

	public final static Direction[] values = values();
	public final static int cardinality = values().length;
	public final static int[] ordinals = new int[cardinality];
	static {
		int i = 0;
		for (Direction value: values) {
			ordinals[i] = value.ordinal();
			i++;
		}
	}

	Direction(int... dx) {
		vector = dx;
		Feature[] walls = {Feature.WallEast, Feature.WallNorth, Feature.WallWest, Feature.WallSouth};
		Feature[] conveyors = {Feature.ConveyorEast, Feature.ConveyorNorth, Feature.ConveyorWest, Feature.ConveyorSouth};
		earlyWall = walls[(ordinal()+2)%walls.length]; // can't use opposite() yet
		lateWall = walls[ordinal()];
		conveyor = conveyors[ordinal()];
	}

	Direction rotate(int d) {
		return Direction.values[((ordinal() + d + cardinality) % cardinality)];
	}

	Direction opposite() {
		return rotate(2);
	}

	public static Direction fromOrdinal(int i) {
		return values[i];
	}

	static void test() {
		assert(East.rotate(-1) == South);
		assert(South.rotate(2) == North);

		assert(East.earlyWall == Feature.WallWest);
		assert(East. lateWall == Feature.WallEast);
	}
}
