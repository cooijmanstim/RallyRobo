package RallyRobo;

public enum Evaluator {
	CheckpointAdvantage(new EvaluationFunction() {
		@Override public double call(Game game, int irobot) {
			Robot us = game.robots.get(irobot);
			int advantage = Integer.MAX_VALUE;
			for (Robot them: game.robots) {
				if (them.identity == irobot)
					continue;
				
				advantage = Math.min(advantage, us.next_checkpoint - them.next_checkpoint);
			}
			return advantage;
		}
	}),
	Heuristic(new EvaluationFunction() {
		@Override public double call(Game game, int irobot) {
			Robot robot = game.robots.get(irobot);
			int distance = Point.manhattanDistance(robot.position, game.board.checkpoints.get(robot.next_checkpoint));
			int active = robot.is_active() ? 1 : 0;
			// TODO: learn weights
			return  3  *active +
					 1  *CheckpointAdvantage.evaluate(game, irobot) +
					-0.3*robot.damage +
					-0.1*distance;
		}
	});

	final EvaluationFunction f;
	Evaluator(EvaluationFunction f) {
		this.f = f;
	}
	
	public double evaluate(Game game, int irobot) {
		return f.call(game, irobot);
	}
}
