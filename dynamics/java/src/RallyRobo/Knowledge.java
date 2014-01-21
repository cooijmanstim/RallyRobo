package RallyRobo;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Comparator;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.PriorityQueue;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;

public class Knowledge {
	static int checkpointAdvantage(Game game, int irobot) {
		Robot us = game.robots.get(irobot);
		int advantage = Integer.MAX_VALUE;
		for (Robot them: game.robots) {
			if (them.identity == irobot)
				continue;
		
			advantage = Math.min(advantage, us.next_checkpoint - them.next_checkpoint);
		}
		return advantage;
	}
	
	static int distanceToCheckpoint(Game game, int irobot) {
		Robot robot = game.robots.get(irobot);
		int[] a = robot.position.clone(),
			  b = game.board.checkpoints.get(robot.next_checkpoint).clone();
		return Point.manhattanDistance(a, b);
	}

	private static int lindex(Board board, int[] x) {
		return board.width*x[0]+x[1];
	}
	
	// A* distance, moving around walls, pits
	static int distance(final Board board, final int[] start, final int[] goal) {
		if (board.has_feature(start, Feature.Pit))
			return Integer.MAX_VALUE;

		int npoints = board.height * board.width;
		final int[] f = new int[npoints];
		final int[] g = new int[npoints];
		Arrays.fill(f, Integer.MAX_VALUE);
		Arrays.fill(g, Integer.MAX_VALUE);
		final boolean[] seen = new boolean[npoints];

		PriorityQueue<int[]> fringe = new PriorityQueue<int[]>(100, new Comparator<int[]>() {
			@Override public int compare(int[] a, int[] b) {
				return f[lindex(board, a)] - f[lindex(board, b)];
			}
		});

		fringe.add(start);
		g[lindex(board, start)] = 0;
		f[lindex(board, start)] = Point.manhattanDistance(start, goal);
		
		while (!fringe.isEmpty()) {
			int[] current = fringe.remove();
			if (Point.equals(current, goal))
				return g[lindex(board, current)];

			seen[lindex(board, current)] = true;
			
			for (Direction dir: Direction.values) {
				if (board.has_feature(current, dir.lateWall))
					continue;
				int[] next = Point.add(current, dir.vector);
				if (board.has_feature(next, dir.earlyWall) ||
					board.has_feature(next, Feature.Pit))
					continue;

				if (seen[lindex(board, next)])
					continue;

				int tentative_g = g[lindex(board, current)] + 1;
				if (tentative_g < g[lindex(board, next)]) {
					g[lindex(board, next)] = tentative_g;
					f[lindex(board, next)] = tentative_g + Point.manhattanDistance(next, goal);

					// (re)insert next into the fringe
					Iterator<int[]> it = fringe.iterator();
					while (it.hasNext()) {
						int[] x = it.next();
						if (Point.equals(x, next)) {
							it.remove();
							break;
						}
					}
					fringe.add(next);
				}
			}
		}
		
		return Integer.MAX_VALUE;
	}

	static boolean conveyorOfDeath(Game game, int irobot) {
		Robot robot = game.robots.get(irobot);
		return game.board.has_feature(robot.position, robot.direction.conveyor) &&
				game.board.has_feature(Point.add(robot.position, robot.direction.vector),
								       Feature.Pit);
	}
	
	static void test() {
		Game game = Game.example_game();
		Test.assert_equal( 6, Knowledge.distance(game.board, new int[]{12,5}, new int[]{12,1}));
		Test.assert_equal(21, Knowledge.distance(game.board, new int[]{2,10}, new int[]{12,1}));
	}
}
