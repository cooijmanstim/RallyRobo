package RallyRobo;

public enum Evaluator {
	CheckpointAdvantage(new EvaluationFunction() {
		@Override public double call(Game game, int irobot) {
			return Knowledge.checkpointAdvantage(game, irobot);
		}
	}),
	Heuristic(new EvaluationFunction() {
		@Override public double call(Game game, int irobot) {
			Robot robot = game.robots.get(irobot);
			int distance = Math.min(game.board.width*game.board.height,
									Knowledge.distanceToCheckpoint(game, irobot));
			int active = robot.is_active() && !Knowledge.conveyorOfDeath(game, irobot) ? 1 : -1;
			int winloss = game.is_over() ? (game.winner() == irobot ? 1 : -1) : 0;
			// TODO: learn weights
			return 100  *winloss +
					  3  *active +
					  5  *Knowledge.checkpointAdvantage(game, irobot) +
					  1  *robot.next_checkpoint +
					 -0.3*robot.damage +
					 -0.1*distance;
		}
	}),
	WinLoss(new EvaluationFunction () {
		@Override public double call(Game game, int irobot) {
			int winloss = game.is_over() && game.winner() == irobot ? 1 : 0;
			return winloss;
		}
	}),
	Constant(new EvaluationFunction () {
		@Override public double call(Game game, int irobot) {
			return 0;
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
