package RallyRobo;

class Robot {
	static final int NRegisters = 5;
	static final int MaximumDamage = 9;

	public final int identity;

	public int[] position, respawn_position;
	public Direction direction, respawn_direction;

	public int next_checkpoint = 1;
	public int damage = 0;
	public boolean is_virtual = false;

	static enum State { Active, Destroyed, Waiting }
	public State state = State.Active;

	// this would be in State except that Matlab can't traverse inner classes
	private static final State[] states = State.values();
	public static State stateFromOrdinal(int i) {
		return states[i];
	}

	
	public int registers[] = new int[NRegisters];
	{
		for (int i = 0; i < NRegisters; i++)
			registers[i] = Card.None;
	}

	Robot(int identity, int[] position, Direction direction) {
		this.identity = identity;
		this.position = position;
		this.direction = direction;

		save_respawn();
	}

	public boolean is_active   () { return state == State.Active;    }
	public boolean is_waiting  () { return state == State.Waiting;   }
	public boolean is_destroyed() { return state == State.Destroyed; }
	
	public boolean is_visible() { return !is_virtual && state != State.Waiting; }

	public boolean obstructs() {
		return !is_virtual && state != State.Waiting;
	}
	
	public boolean can_be_pushed() {
		return obstructs();
	}
	
	public boolean can_shoot() {
		return is_active() && !is_virtual;
	}
	
	public boolean can_take_damage() {
		return is_active() && !is_virtual;
	}

	// ease my pain
	void set_posdir(int i, int j, Direction dir) {
		position = Point.make(i, j);
		direction = dir;
	}

	void rotate(int d) {
		direction = direction.rotate(d);
	}

	void take_damage() {
		damage++;
		if (damage > MaximumDamage)
			destroy();
	}
	
	void repair() {
		damage = Math.max(0, damage - 1);
	}
	
	void destroy() {
		state = State.Destroyed;
	}
	
	void skip() {
		state = State.Waiting;
	}
	
	void respawn() {
		load_respawn();
		damage = 0;
		state = State.Active;
		// always respawn as virtual; the robot will be devirtualized if necessary
		// after all respawns are complete.  this way simultaneous respawns can be
		// handled independently.
		virtualize();
	}

	public void save_respawn() {
		respawn_position = position.clone();
		respawn_direction = direction;
	}

	public void load_respawn() {
		position = respawn_position.clone();
		direction = respawn_direction;
	}
	
	void virtualize() {
		is_virtual = true;
	}
	
	void devirtualize() {
		is_virtual = false;
	}
	
	void vacate_registers() {
		int ni = Math.min(NRegisters, MaximumDamage - damage);
		for (int i = 0; i < ni; i++)
			registers[i] = Card.None;
	}


	static void test() {
		Robot robot = new Robot(0, Point.make(0, 0), Direction.East);
		robot.rotate(-1);
		assert(robot.direction == Direction.South);
		robot.rotate(2);
		assert(robot.direction == Direction.North);
	}
}
