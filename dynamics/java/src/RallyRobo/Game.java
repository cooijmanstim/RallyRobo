package RallyRobo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;

class Game {
	final public Board board;
	public ArrayList<Robot> robots = new ArrayList<Robot>();
	boolean over = false;
	Robot winner = null;
	
	public Game(int height, int width) {
		board = new Board(height, width);
	}

	public Game(Game that) {
		this.board = that.board.clone();
		for (Robot robot: that.robots)
			this.robots.add(robot.clone());
		this.over = that.over;
		if (that.winner != null)
			this.winner = this.robots.get(that.winner.identity);
	}

	@Override public Game clone() {
		return new Game(this);
	}
	
	@Override public boolean equals(Object o) {
		if (!(o instanceof Game))
			return false;
		Game that = (Game)o;
		return this.board.equals(that.board) &&
				this.robots.equals(that.robots) &&
				this.over == that.over &&
				this.winner == that.winner;
	}
	
	public boolean is_over() {
		return over;
	}
	
	public Robot add_robot(int[] position, Direction direction) {
		int identity = robots.size();
		Robot robot = new Robot(identity, position, direction);
		robots.add(robot);
		return robot;
	}
	
	public Robot add_robot(int i, int j, Direction dir) {
		return add_robot(Point.make(i, j), dir);
	}
	
	private void add_features(Feature feature, int points[][]) {
		for (int[] x: points)
			board.set_feature(x[0], x[1], feature);
	}
	
	public static Game example_game() {
		Game game = new Game(12, 12);
		game.board.add_checkpoint(12, 1);
		game.board.add_checkpoint( 8, 9);
		game.board.add_checkpoint( 2, 8);
		game.board.add_checkpoint( 9, 5);
		
		game.add_robot( 3,  1, Direction.East);
		game.add_robot( 4, 11, Direction.North);
		game.add_robot( 8,  1, Direction.North);
		game.add_robot(11,  9, Direction.South);
		
		game.add_features(Feature.Pit,                new int[][]{{5,8}, {5,9}, {7,3}, {10,6}});
		game.add_features(Feature.Repair,             new int[][]{{1,2}, {5,2}, {3,5}, {3,9}, {8,5}, {10,1}});
		game.add_features(Feature.ConveyorNorth,      new int[][]{{1,3}, {2,3}, {3,3}, {4,7}, {5,7}});
		game.add_features(Feature.ConveyorEast,       new int[][]{{4,3}, {4,4}, {4,5}, {4,6}, {6,7}, {6,8}, {6,9}, {6,10}, {6,11}, {6,12}});
		game.add_features(Feature.ConveyorWest,       new int[][]{{6,1}, {6,2}, {6,3}, {6,4}, {7,5}, {7,6}, {7,7}, {7,8}, {7,9}, {7,10}, {7,11}, {7,12}});
		game.add_features(Feature.ConveyorSouth,      new int[][]{{7,4}});
		game.add_features(Feature.ConveyorTurningCcw, new int[][]{{4,7}, {7,4}});
		game.add_features(Feature.ConveyorTurningCw,  new int[][]{{6,7}, {4,3}, {6,4}});
		game.add_features(Feature.WallEast,           new int[][]{{5,4}});
		game.add_features(Feature.WallNorth,          new int[][]{{2,10}, {5,4}, {7,7}, {10,3}});
		game.add_features(Feature.WallWest,           new int[][]{{1,4}, {2,10}, {3,7}, {5,1}, {9,11}, {12,5}});
		game.add_features(Feature.WallSouth,          new int[][]{{1,6}});
		
		return game;
	}
	
	boolean robot_can_move(Robot robot, Direction dir) {
		int[] a = robot.position, b = Point.add(a, dir.vector);
		return  !board.has_feature(a, Feature.Pit)  &&
			!board.has_feature(a, dir.lateWall) &&
			!board.has_feature(b, dir.earlyWall);
	}
	
	/* Move the indicated robot in the direction 'dx', pushing other robots
	 * if they are in the way.  Does not move if the move is obstructed or
	 * would involve pushing a robot through an obstruction.
	 * returns true if anything was moved.
	 */
	boolean robot_move_maybe(Robot robot, Direction dir) {
		if (!robot_can_move(robot, dir))
			return false;
		
		int[] xnew = Point.add(robot.position, dir.vector);
		
		// it is assumed that pits are bottomless; occupied pits don't obstruct
		if (!board.has_feature(xnew, Feature.Pit)) {
			// if there is a robot at the destination, try to push it
			for (Robot pushee: robots) {
				if (pushee.can_be_pushed() && Point.equals(pushee.position, xnew)) {
					if (!robot_move_maybe(pushee, dir))
						return false;
					break;
				}
			}
		}
		
		// permission to land
		translate_robot(robot, dir.vector);
		return true;
	}
	
	void translate_robot(Robot robot, int... dx) {
		Point.addTo(robot.position, dx);
		if (board.has_feature(robot.position, Feature.Pit))
			robot.destroy();
	}
	
	void advance_conveyors() {
		// the project documentation guarantees that conveyor belt movement is never
		// obstructed. so we can move each robot in parallel without worrying about
		// what's on the tile it is moving to.
		for (Robot robot: robots) {
			if (robot.is_virtual || robot.is_waiting())
				continue;
			
			int[] dx = {0, 0};
			for (Direction dir: Direction.values) {
				if (board.has_feature(robot.position, dir.conveyor)) {
					dx = dir.vector;
					break;
				}
			}
			translate_robot(robot, dx);
			
			// this should only happen if the robot was actually moved, but we
			// don't need to explicitly check for it.  if the robot did not move,
			// then its position did not have a Conveyor* feature and should also
			// not have a ConveyorTurning* feature.
			if (board.has_feature(robot.position, Feature.ConveyorTurningCcw)) {
				robot.rotate(1);
			} else if (board.has_feature(robot.position, Feature.ConveyorTurningCw)) {
				robot.rotate(-1);
			}
		}
	}
	
	boolean in_view(Robot shootee, Robot shooter) {
		if (board.has_feature(shooter.position, shooter.direction.lateWall))
			return false;
		
		if (board.has_feature(shootee.position, shooter.direction.earlyWall))
			return false;
		
		if (!Point.sees(shooter.position, shootee.position, shooter.direction))
			return false;
		
		for (Robot obstructor: robots) {
			if (obstructor.obstructs()
			    && Point.sees(shooter.position, obstructor.position, shooter.direction)
			    && Point.sees(obstructor.position, shootee.position, shooter.direction))
				return false;
		}
		
		// trace line of sight to check for obstructing walls
		int[] x = shooter.position.clone();
		Point.addTo(x, shooter.direction.vector);
		while (!Point.equals(x, shootee.position)) {
			assert(board.within_bounds(x));
			if (board.has_feature(x, shooter.direction.earlyWall)) return false;
			if (board.has_feature(x, shooter.direction. lateWall)) return false;
			Point.addTo(x, shooter.direction.vector);
		}
		
		return true;
	}

	void fire_robot_lasers() {
		for (int i = 0, ni = robots.size(); i < ni; i++) {
			Robot shooter = robots.get(i);
			if (shooter.can_shoot()) {
				for (int j = 0, nj = ni; j < nj; j++) {
					if (i == j)
						continue;
					
					Robot shootee = robots.get(j);
					if (shootee.can_take_damage() && in_view(shootee, shooter)) {
						shootee.take_damage();
						break;
					}
				}
			}
		}
	}

	void remove_destroyed_robots() {
		for (Robot robot: robots) {
			if (robot.is_destroyed())
				robot.skip();
		}
	}

	boolean any_robot_obstructing(int[] x, Robot exception) {
		for (Robot obstructor: robots)
			if (obstructor != exception && obstructor.obstructs() && Point.equals(obstructor.position, x))
				return true;
		return false;
	}

	void respawn_waiting_robots() {
		for (Robot robot: robots) {
			if (robot.is_waiting())
				robot.respawn();
		}
	}

	void devirtualize_robots() {
		for (Robot robot: robots) {
			if (robot.is_virtual && !any_robot_obstructing(robot.position, robot))
				robot.devirtualize();
		}
	}

	void promote_robots() {
		for (Robot robot: robots) {
			if (!robot.is_virtual && robot.is_active() &&
					Point.equals(board.checkpoints.get(robot.next_checkpoint),
								 robot.position)) {
				robot.save_respawn();
				robot.next_checkpoint++;
				if (robot.next_checkpoint >= board.checkpoints.size()) {
					over = true;
					winner = robot;
				}
			}
		}
	}

	void repair_robots() {
		for (Robot robot: robots) {
			if (!robot.is_virtual && robot.is_active() && board.has_feature(robot.position, Feature.Repair))
				robot.repair();
		}
	}

	// before calling this, make sure the registers are filled
	public void perform_turn() {
		// grab a working copy that we can sort according to card priority
		ArrayList<Robot> robots = new ArrayList<Robot>(this.robots);

		for (int i = 0; i < Robot.NRegisters; i++) {
			process_register(i, robots);
			if (over)
				return;
		}
		
		finalize_turn();
	}

	// computes the contents of the deck based on what's in locked registers
	public boolean[] deck() {
		boolean[] deck = Card.deck();
		for (Robot robot: robots) {
			for (int i = 0; i < Robot.NRegisters; i++) {
				if (robot.registers[i] != Card.None)
					deck[robot.registers[i]-1] = false;
			}
		}
		return deck;
	}
	
	// doesn't modify state; just returns hands that would be dealt
	public int[][] deal() {
		int ncards = 0;
		int[] hand_sizes = new int[robots.size()];
		for (int i = 0; i < hand_sizes.length; i++) {
			Robot robot = robots.get(i);
			if (!robot.is_active())
				continue;
			
			hand_sizes[i] = robot.hand_size();
			ncards += hand_sizes[i];
		}
		
		boolean[] deck = deck();
		int[] card_indices = Util.take(ncards, deck);
		int k = 0;
		int[][] hands = new int[hand_sizes.length][];
		for (int i = 0; i < hand_sizes.length; i++) {
			hands[i] = new int[hand_sizes[i]];
			for (int j = 0; j < hands[i].length; j++) {
				hands[i][j] = 1+card_indices[k];
				k++;
			}
		}
		return hands;
	}
	
	public void fill_registers() {
		int[][] hands = deal();
		for (int i = 0; i < robots.size(); i++) {
			Robot robot = robots.get(i);
			if (robot.is_active()) {
				assert(hands[i].length > 0);
				robot.decide(this, hands[i]);
			}
		}
	}

	public void vacate_registers() {
		for (Robot robot: robots)
			robot.vacate_registers();
	}
	
	public void finalize_turn() {
		respawn_waiting_robots();
		remove_destroyed_robots();
		devirtualize_robots();
		vacate_registers();
	}

	// for convenience
	public void process_register(int i) {
		process_register(i, new ArrayList<Robot>(robots));
	}

	// for speed
	private void process_register(final int i, ArrayList<Robot> robots) {
		assert(!over);
		
		Collections.sort(robots, new Comparator<Robot>() {
			@Override
			public int compare(Robot a, Robot b) {
				if (!a.is_active() || !b.is_active())
					return 0;
				else
					return Card.priority(b.registers[i]) -
							Card.priority(a.registers[i]);
			}
		});

		for (Robot robot: robots) {
			if (robot.is_active())
				Card.apply(this, robot, robot.registers[i]);
		}
		
		devirtualize_robots();
		advance_conveyors();
		fire_robot_lasers();
		promote_robots();
		repair_robots();
	}
	
	public double evaluate_naive_outcome(int[] decision, int irobot, Evaluator evaluator) {
		// this is gross; make temporary copies of state data and do some
		// half-assed simulation to get an idea of where the decision leads.
		ArrayList<Robot> oldrobots = robots;
		boolean oldover = over;
		Robot oldwinner = winner;
		robots = new ArrayList<Robot>();
		for (Robot robot: oldrobots)
			robots.add(robot.clone());
		
		Robot robot = robots.get(irobot);
		for (int j = 0; j < decision.length; j++) {
			Card.apply(this, robot, decision[j]);
			advance_conveyors();
			devirtualize_robots();
		}
		double evaluation = evaluator.evaluate(this, irobot);
		
		robots = oldrobots;
		over = oldover;
		winner = oldwinner;
		
		return evaluation;
	}
	
	static void test() {
		test_example_game();
		test_robot_can_move();
		test_robot_move_maybe();
		test_advance_conveyors();
		test_fire_robot_lasers();
		test_push_many();
		test_push_many_into_pit();
		test_perform_turn();
		test_evaluate_naive_outcome();
	}

	static void test_example_game() {
		Game game = Game.example_game();
		int[] x = {8, 1};

		assert(!game.board.has_feature(x, Feature.Pit));
		assert(!game.board.has_feature(x, Feature.WallEast));
		assert(!game.board.has_feature(x, Feature.WallNorth));
		assert(!game.board.has_feature(x, Feature.WallWest));
		assert(!game.board.has_feature(x, Feature.WallSouth));

		x = Point.make(5, 4);
		assert(game.board.has_feature(x, Feature.WallNorth));
		assert(game.board.has_feature(x, Feature.WallEast));
	}

	static void test_robot_can_move() {
		Game game = Game.example_game();
		Robot robot = game.robots.get(2);

		for (Direction dir: Direction.values())
			assert(game.robot_can_move(robot, dir));

		robot.position = Point.make(5, 4);
		assert(!game.robot_can_move(robot, Direction.East));
		assert(!game.robot_can_move(robot, Direction.North));
		assert( game.robot_can_move(robot, Direction.West));
		assert( game.robot_can_move(robot, Direction.South));
	}

	static void test_robot_move_maybe() {
		Game game = Game.example_game();
		Robot robot = game.robots.get(2);
		robot.position = Point.make(5, 4);

		assert(!game.robot_move_maybe(robot, Direction.North)); // wall inside
		assert(!game.robot_move_maybe(robot, Direction.East )); // wall inside
		assert( game.robot_move_maybe(robot, Direction.South));
		assert( game.robot_move_maybe(robot, Direction.East ));
		assert( game.robot_move_maybe(robot, Direction.North));
		assert(!game.robot_move_maybe(robot, Direction.West )); // wall outside
		assert( game.robot_move_maybe(robot, Direction.North));
		assert( game.robot_move_maybe(robot, Direction.West ));
		assert(!game.robot_move_maybe(robot, Direction.South)); // wall outside
		assert( game.robot_move_maybe(robot, Direction.North));
		assert( game.robot_move_maybe(robot, Direction.West ));  // into pit
		assert(!game.robot_move_maybe(robot, Direction.East ));
		assert(!game.robot_move_maybe(robot, Direction.North));
		assert(!game.robot_move_maybe(robot, Direction.West ));
		assert(!game.robot_move_maybe(robot, Direction.South));
	}

	static void test_advance_conveyors() {
		Game game = Game.example_game();
		Robot robot = game.robots.get(0);

		// get on the conveyor belt
		Card.apply(game, robot, Card.TwoForward);

		game.advance_conveyors(); Test.assert_posdir(robot, 4, 3, Direction.South);
		game.advance_conveyors(); Test.assert_posdir(robot, 4, 4, Direction.South);
		game.advance_conveyors(); Test.assert_posdir(robot, 4, 5, Direction.South);
		game.advance_conveyors(); Test.assert_posdir(robot, 4, 6, Direction.South);
		
		// this went wrong at some point
		assert(game.board.has_feature(robot.position, Feature.ConveyorEast));
		
		game.advance_conveyors(); Test.assert_posdir(robot, 4, 7, Direction.East);
		game.advance_conveyors();
		game.advance_conveyors(); Test.assert_posdir(robot, 6, 7, Direction.South);
		game.advance_conveyors();
		game.advance_conveyors();
		game.advance_conveyors();
		game.advance_conveyors();
		game.advance_conveyors(); Test.assert_posdir(robot, 6, 12, Direction.South);
		
		// move off the board (effectively into pit)
		game.advance_conveyors(); Test.assert_posdir(robot, 6, 13, Direction.South);
		game.advance_conveyors(); Test.assert_posdir(robot, 6, 13, Direction.South);
	}

	static void test_fire_robot_lasers() {
		Game game = Game.example_game();
		Robot[] robots = game.robots.toArray(new Robot[]{});

		robots[0].set_posdir( 9, 9, Direction.North);
		robots[1].set_posdir(10, 6, Direction.East);
		robots[2].set_posdir(10, 9, Direction.West);
		robots[3].set_posdir(11, 9, Direction.South);

		robots[1].destroy();

		game.fire_robot_lasers();

		assert(robots[0].damage == 0);
		assert(robots[1].damage == 0);
		assert(robots[2].damage == 2);
		assert(robots[3].damage == 0);
	}

	static void test_push_many() {
		Game game = Game.example_game();
		Robot[] robots = game.robots.toArray(new Robot[]{});

		robots[0].set_posdir( 9, 9, Direction.North);
		robots[2].set_posdir(10, 9, Direction.West);
		robots[3].set_posdir(11, 9, Direction.South);

		robots[2].destroy();

		Card.apply(game, robots[3], Card.OneForward);

		Test.assert_pos(robots[0], 8, 9);
		Test.assert_pos(robots[2], 9, 9);
		Test.assert_pos(robots[3],10, 9);
	}
	
	static void test_push_many_into_pit() {
		Game game = Game.example_game();
		Robot[] robots = game.robots.toArray(new Robot[]{});

		robots[0].set_posdir(10, 8, Direction.West);
		robots[1].set_posdir(10, 7, Direction.East);
		robots[2].set_posdir(10, 6, Direction.North);

		robots[2].destroy();

		Card.apply(game, robots[0], Card.ThreeForward);

		Test.assert_pos(robots[0], 10, 6);
		Test.assert_pos(robots[1], 10, 6);
		Test.assert_pos(robots[2], 10, 6);
		
		assert(robots[0].is_destroyed());
		assert(robots[1].is_destroyed());
		assert(robots[2].is_destroyed());
	}

	static void test_advance_conveyors_regression() {
		Game game = Game.example_game();
		Robot robot = game.robots.get(1);
		robot.position = Point.make(7, 4);
		robot.direction = Direction.East;
		Card.apply(game, robot, Card.OneForward);
		game.advance_conveyors();
		Test.assert_posdir(robot, 7, 4, Direction.North);
	}
	
	static void test_perform_turn_regression1() {
		test_advance_conveyors_regression();
		
		Game game = Game.example_game();
		Robot[] robots = game.robots.toArray(new Robot[]{});

		robots[0].registers = new int[]{11,63,78,35,64};
		robots[1].registers = new int[]{81,10,43,45,12};
		robots[2].registers = new int[]{70,49,44,67,46};
		robots[3].registers = new int[]{ 8,68,83,46,47};

		game.perform_turn();
		
		robots[0].registers = new int[]{11,63,77,35,64};
		robots[1].registers = new int[]{49,80,78, 7,43};
		robots[2].registers = new int[]{10,84,68,12,83};
		robots[3].registers = new int[]{67,50, 1,46,47};

		Test.assert_posdir(robots[1],  7, 4, Direction.East);
		
		game.process_register(0);

		Test.assert_posdir(robots[1],  7, 4, Direction.North);
		Test.assert_posdir(robots[2], 11, 1, Direction.East);
		Test.assert_posdir(robots[3], 11, 4, Direction.West);
		
		assert(robots[2].damage == 3);
		assert(robots[3].damage == 2);
		
		game.process_register(1);
		
		Test.assert_posdir(robots[1], 10, 4, Direction.North);
		Test.assert_posdir(robots[2], 11, 3, Direction.East);
		Test.assert_posdir(robots[3], 11, 4, Direction.West);
		
		assert(robots[2].damage == 4);
		assert(robots[3].damage == 4);
		
		game.process_register(2);
		
		Test.assert_posdir(robots[1], 12, 4, Direction.North);
		Test.assert_posdir(robots[2], 11, 5, Direction.East);
		
		assert(robots[3].is_destroyed());
	}
	
	static void test_perform_turn_regression2() {
		Game game = Game.example_game();
		Robot[] robots = game.robots.toArray(new Robot[]{});

		robots[0].registers = new int[]{11,63,78,35,64};
		robots[1].registers = new int[]{81,10,43,45,12};
		robots[2].registers = new int[]{70,49,44,67,46};
		robots[3].registers = new int[]{ 8,68,83,46,47};

		game.perform_turn();
		
		robots[0].registers = new int[]{11,63,77,35,64};
		robots[1].registers = new int[]{49,80,78, 7,43};
		robots[2].registers = new int[]{10,84,68,12,83};
		robots[3].registers = new int[]{67,50, 1,46,47};

		game.perform_turn();
		
		robots[0].registers = new int[]{67, 7,79,17,19};
		robots[1].registers = new int[]{82, 9,68,11,49};
		robots[2].registers = new int[]{71,13,72,15,73};
		robots[3].registers = new int[]{67,50, 1,46,47};
		
		game.perform_turn();
		
		robots[0].registers = new int[]{ 9,68,59,44, 9};
		robots[1].registers = new int[]{55,56,57,58,84};
		robots[2].registers = new int[]{67,50, 7,53,54};
		robots[3].registers = new int[]{49,43,51,52, 8};
		
		Test.assert_posdir(robots[0],  6,  8, Direction.North);
		Test.assert_posdir(robots[1], 10,  2, Direction.East);
		Test.assert_posdir(robots[2],  8,  9, Direction.North);
		Test.assert_posdir(robots[3], 11,  9, Direction.South);

		game.process_register(0);

		Test.assert_posdir(robots[0],  6,  9, Direction.West);
		Test.assert_posdir(robots[1], 10,  3, Direction.East);
		Test.assert_posdir(robots[2],  9,  9, Direction.North);
		Test.assert_posdir(robots[3], 10,  9, Direction.South);
		
		assert(robots[2].damage == 5);

		game.process_register(1);

		Test.assert_posdir(robots[0],  6,  8, Direction.West);
		Test.assert_posdir(robots[1], 10,  4, Direction.East);
		Test.assert_posdir(robots[2], 10,  9, Direction.North);
		Test.assert_posdir(robots[3], 12,  9, Direction.South);
		
		assert(robots[2].damage == 7);

		game.process_register(2);

		Test.assert_posdir(robots[0],  6,  8, Direction.West);
		Test.assert_posdir(robots[1], 10,  5, Direction.East);
		Test.assert_posdir(robots[2], 10,  9, Direction.West);
		Test.assert_posdir(robots[3], 11,  9, Direction.South);
		
		assert(robots[1].damage == 1);
		assert(robots[2].damage == 9);
		
		game.process_register(3);
		
		Test.assert_posdir(robots[0],  6, 10, Direction.West);
		Test.assert_posdir(robots[2], 10,  8, Direction.West);
		Test.assert_posdir(robots[3], 10,  9, Direction.South);
		
		assert(robots[1].is_destroyed());
		assert(robots[2].damage == 9);
		
		game.process_register(4);
		
		Test.assert_posdir(robots[0],  6, 11, Direction.South);
		Test.assert_posdir(robots[3], 10,  9, Direction.West);
		
		assert(robots[2].is_destroyed());
	}
	
	static void test_perform_turn() {
		test_perform_turn_regression1();
		test_perform_turn_regression2();
		
		Game game = Game.example_game();
		Robot[] robots = game.robots.toArray(new Robot[]{});

		robots[0].registers = new int[]{11,63,78,35,64};
		robots[1].registers = new int[]{81,10,43,45,12};
		robots[2].registers = new int[]{70,49,44,67,46};
		robots[3].registers = new int[]{ 8,68,83,46,47};

		game.perform_turn();
		
		Test.assert_posdir(robots[1],  7,  4, Direction.East);
		Test.assert_posdir(robots[2], 11,  1, Direction.North);
		Test.assert_posdir(robots[3], 11,  6, Direction.West);

		assert(robots[0].is_waiting());
		assert(robots[2].damage == 2);
		
		assert(robots[2].next_checkpoint == 2);

		robots[0].registers = new int[]{11,63,77,35,64};
		robots[1].registers = new int[]{49,80,78, 7,43};
		robots[2].registers = new int[]{10,84,68,12,83};
		robots[3].registers = new int[]{67,50, 1,46,47};
		
		game.perform_turn();
		
		Test.assert_posdir(robots[0],  3,  1, Direction.East);
		Test.assert_posdir(robots[1], 12,  4, Direction.West);
		Test.assert_posdir(robots[2],  8,  5, Direction.South);
		
		assert(robots[0].is_active());
		assert(robots[2].damage == 3);
		assert(robots[3].is_waiting());		
		
		robots[0].registers = new int[]{67, 7,79,17,19};
		robots[1].registers = new int[]{82, 9,68,11,49};
		robots[2].registers = new int[]{71,13,72,15,73};
		robots[3].registers = new int[]{67,50, 1,46,47};
		
		game.perform_turn();
		
		Test.assert_posdir(robots[0],  6,  8, Direction.North);
		Test.assert_posdir(robots[1], 10,  2, Direction.East);
		Test.assert_posdir(robots[2],  8,  9, Direction.North);
		Test.assert_posdir(robots[3], 11,  9, Direction.South);

		assert(robots[3].is_active());
		
		assert(robots[1].next_checkpoint == 2);
		assert(Point.equals(robots[1].respawn_position, Point.make(12, 1)));
		assert(robots[2].next_checkpoint == 3);
		
		robots[0].registers = new int[]{ 9,68,59,44, 9};
		robots[1].registers = new int[]{55,56,57,58,84};
		robots[2].registers = new int[]{67,50, 7,53,54};
		robots[3].registers = new int[]{49,43,51,52, 8};
		
		game.perform_turn();
		
		assert(robots[1].is_waiting());
		assert(robots[2].is_waiting());
		
		Test.assert_posdir(robots[0],  6, 11, Direction.South);
		Test.assert_posdir(robots[3], 10,  9, Direction.West);
		
		assert(robots[0].next_checkpoint == 1);
		assert(robots[3].next_checkpoint == 1);
		
		robots[0].registers = new int[]{ 8,49,10,79,12};
		robots[1].registers = new int[]{55,56,57,58,84};
		robots[2].registers = new int[]{67,50, 7,53,54};
		robots[3].registers = new int[]{50,44,68,45,46};
		
		assert(robots[2].is_waiting());
		
		game.perform_turn();
		
		assert(robots[0].is_waiting());
		assert(robots[1].is_active());
		assert(robots[2].is_active());
		
		Test.assert_posdir(robots[1], 12,  1, Direction.West);
		Test.assert_posdir(robots[2],  8,  9, Direction.North);
		Test.assert_posdir(robots[3], 10,  9, Direction.West);
		
		assert(robots[1].next_checkpoint == 2);
		assert(robots[2].next_checkpoint == 3);
	}
	
	static void test_evaluate_naive_outcome() {
		Game game = Game.example_game();
		Game game2 = Game.example_game();
		int[] hand = {11,83,57,49,35,21, 3,50, 4};
		DecisionSet ds = new DecisionSet(5, hand);
		for (int i = 0; i < 100; i++) {
			game2.evaluate_naive_outcome(ds.cards(ds.random()), i % game.robots.size(), Evaluator.Heuristic);
			assert(game.equals(game2));
		}
	}
}
