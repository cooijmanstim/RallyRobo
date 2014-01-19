package RallyRobo;

public enum Strategy {
	Random(new DecisionFunction() {
		@Override public int[] call(Game game, int irobot, int[] hand) {
			DecisionSet ds = new DecisionSet(game.robots.get(irobot).empty_register_count(), hand);
			return ds.cards(ds.random());
		}
	}),
	RandomSearchHeuristic(new RandomSearchDecisionFunction(30, Evaluator.Heuristic)),
	MonteCarloCheckpoint(new MonteCarloDecisionFunction(30, 10, Evaluator.CheckpointAdvantage, Strategy.Random)),
	MonteCarloHeuristic(new MonteCarloDecisionFunction(30, 10, Evaluator.Heuristic, Strategy.Random)),
	MonteCarloHeuristicSmart(new MonteCarloDecisionFunction(30, 10, Evaluator.Heuristic, Strategy.RandomSearchHeuristic));
	
	final DecisionFunction f;
	Strategy(DecisionFunction f) {
		this.f = f;
	}

	public int[] decide(Game game, int irobot, int[] hand) {
		return f.call(game, irobot, hand);
	}
}
