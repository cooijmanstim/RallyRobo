package RallyRobo;

class Robot {
	static final int NRegisters = 5;
	static final int MaximumDamage = 9;

	final int identity;

	int[] position, respawn_position;
	Direction direction, respawn_direction;

	int next_checkpoint = 1;
	int damage = 0;
	boolean is_virtual = false;

	enum State { Active, Destroyed, Waiting }
	State state = State.Active;

	int registers[] = new int[NRegisters];
	{
		for (int i = 0; i < NRegisters; i++)
			registers[i] = Card.None;
	}

	Robot(int identity, int[] position, Direction direction) {
		this.identity = identity;
		this.position = position;
		this.direction = direction;

		this.respawn_position = this.position.clone();
		this.respawn_direction = this.direction;
	}

	boolean is_active   () { return state == State.Active;    }
	boolean is_waiting  () { return state == State.Waiting;   }
	boolean is_destroyed() { return state == State.Destroyed; }

	boolean obstructs() {
		return !is_virtual && state != State.Waiting;
	}
	
	boolean can_shoot() {
		return is_active() && !is_virtual;
	}
	
	boolean can_take_damage() {
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
		position = respawn_position.clone();
		direction = respawn_direction;
		damage = 0;
		state = State.Active;
		// always respawn as virtual; the robot will be devirtualized if necessary
		// after all respawns are complete.  this way simultaneous respawns can be
		// handled independently.
		virtualize();
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
