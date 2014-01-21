package RallyRobo;

enum Feature {
	Pit, Repair,
	WallEast, WallNorth, WallWest, WallSouth,
	ConveyorEast, ConveyorNorth, ConveyorWest, ConveyorSouth,
	ConveyorTurningCw, ConveyorTurningCcw;
	
	static final int cardinality = values().length;
	
	static void test() {
	}
}

