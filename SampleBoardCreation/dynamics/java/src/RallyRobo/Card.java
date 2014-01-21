package RallyRobo;

import java.util.Arrays;

class Card {
	static final int None = 0; // used to specify absence of card in registers

	static final int cardinality = 84;
	static final int[] priorities   = new int[cardinality];
	static final int[] translations = new int[cardinality];
	static final int[] rotations    = new int[cardinality];

	static void specifyCards(int a, int da, int b, int translation, int rotation) {
		for (; a <= b; a += da) {
			priorities[a-1]   = a*10;
			translations[a-1] = translation;
			rotations[a-1]    = rotation;
		}
	}

	static {
		specifyCards( 1, 1,  6,  0,  2); // u-turn
		specifyCards( 7, 2, 41,  0,  1); // ccw rotation
		specifyCards( 8, 2, 42,  0, -1); // cw rotation
		specifyCards(43, 1, 48, -1,  0); // back up
		specifyCards(49, 1, 66,  1,  0); // one forward
		specifyCards(67, 1, 78,  2,  0); // two forward
		specifyCards(79, 1, 84,  3,  0); // three forward
	}

	static int priority    (int card) { return priorities  [card-1]; }
	static int translation (int card) { return translations[card-1]; }
	static int rotation    (int card) { return rotations   [card-1]; }

	static void apply(Game game, Robot robot, int card) {
		int translation = translation(card), rotation = rotation(card);
		if (translation == 0) {
			// rotation only
			robot.rotate(rotation);
		} else {
			// translation only, tile by tile
			Direction di = translation >= 0 ? robot.direction : robot.direction.opposite();
			for (int k = Math.abs(translation); k >= 1; k--) {
				boolean moved = game.robot_move_maybe(robot, di);
				if (!moved)
					break;
			}
		}
	}


	// reservoir sampling on a set represented by a bit vector
	// http://en.wikipedia.org/wiki/Reservoir_sampling
	static int[] take(int k, boolean deck[]) {
		int[] cards = new int[k];
		int m = deck.length;

		int j = 0;
		for (int i = 0; ; i++) {
			// fast forward to the next element of the set
			for (; j < m && !deck[j]; j++) {}

			if (j >= m) {
				// there should have been at least k cards in the deck
				assert(i >= k);
				break;
			}
			
			if (i < k) {
				// initial phase: fill the reservoir
				deck[j] = false;
				cards[i] = j+1;
			} else {
				// replace reservoir items
				// XXX: not sure why the +1 is needed. the wikipedia example stresses
				// that the range should be inclusive, but since we are dealing with
				// 0-based indices, leaving out the +1 should be equivalent. however,
				// tests show a bias toward replacement when it is left out.
				int h = Util.generator.nextInt(i+1);
				if (h < k) {
					deck[cards[h]-1] = true;
					deck[j] = false;
					cards[h] = j+1;
				}
			}
			
			j++;
		}
		
		return cards;
	}

	// this is gross
	public static void fill_empty_registers_randomly(Game game) {
		boolean deck[] = new boolean[cardinality];
		Arrays.fill(deck, true);

		int ncards = 0;
		for (Robot robot: game.robots) {
			for (int i = 0; i < Robot.NRegisters; i++) {
				if (robot.registers[i] == Card.None) {
					ncards++;
				} else {
					deck[robot.registers[i]-1] = false;
				}
			}
		}

		int cards[] = take(ncards, deck);
		int j = 0;
		for (Robot robot: game.robots) {
			for (int i = 0; i < Robot.NRegisters; i++) {
				if (robot.registers[i] == Card.None) {
					robot.registers[i] = cards[j];
					j++;
				}
			}
		}
	}

	// for ease of specifying a card when you don't care about its priority (i.e., in tests)
	static final int UTurn = 1, CounterClockwise = 7, Clockwise = 8, OneBackward = 43,
		         OneForward = 49, TwoForward = 67, ThreeForward = 79;

	static void test() {
		test_apply();
		test_take();
	}
	
	static void test_apply() {
		final Game game = Game.example_game();
		final Robot robot = game.robots.get(0), pushed_robot = game.robots.get(1);
		
		assert(Point.equals(robot.position, Point.make(3, 1)));
		assert(robot.direction == Direction.East);
		
		assert(Point.equals(pushed_robot.position, Point.make(4, 11)));
		
		apply(game, robot, TwoForward	   ); Test.assert_posdir(robot, 3,  3, Direction.East);
		apply(game, robot, TwoForward	   ); Test.assert_posdir(robot, 3,  5, Direction.East);
		apply(game, robot, TwoForward	   ); Test.assert_posdir(robot, 3,  6, Direction.East); // ran into a wall
		apply(game, robot, CounterClockwise); Test.assert_posdir(robot, 3,  6, Direction.North);
		apply(game, robot, TwoForward	   ); Test.assert_posdir(robot, 5,  6, Direction.North);
		apply(game, robot, OneBackward	   ); Test.assert_posdir(robot, 4,  6, Direction.North);
		apply(game, robot, Clockwise	   ); Test.assert_posdir(robot, 4,  6, Direction.East);
		apply(game, robot, ThreeForward	   ); Test.assert_posdir(robot, 4,  9, Direction.East);
		apply(game, robot, ThreeForward	   ); Test.assert_posdir(robot, 4, 12, Direction.East); // push other robot off the board
		assert(Point.equals(pushed_robot.position, Point.make(4, 13)));
		apply(game, robot, UTurn           ); Test.assert_posdir(robot, 4, 12, Direction.West);
		apply(game, robot, ThreeForward    ); Test.assert_posdir(robot, 4,  9, Direction.West);
		apply(game, robot, Clockwise       ); Test.assert_posdir(robot, 4,  9, Direction.North);
		apply(game, robot, ThreeForward    ); Test.assert_posdir(robot, 5,  9, Direction.North); // fell into a pit
		
		// can't leave pit in any direction
		for (int i = 0; i < Direction.cardinality; i++) {
			apply(game, robot, CounterClockwise);
			apply(game, robot, OneForward);
			assert(Point.equals(robot.position, Point.make(5, 9)));
		}
	}
	
	static void test_take() {
		int k = 5, n = 20;
		boolean[] deck = new boolean[n];
		Arrays.fill(deck, true);
		
		int sample_size = 10000;
		int[] counts = new int[n];
		for (int i = 0; i < sample_size; i++) {
			for (int card: take(k, deck.clone()))
				counts[card-1]++;
		}

		double[] ps = new double[n]; 
		for (int i = 0; i < n; i++) {
			ps[i] = counts[i] * 1.0 / sample_size;
		}
		
		// might fail every once in a while due to randomness
		assert(ps[0] - k*1.0/n < 1e-2);
		assert(Util.variance(ps) < 1e-2);
	}
}
