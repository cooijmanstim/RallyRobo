package RallyRobo;

public enum Strategy {
	Random(new DecisionFunction() {
		@Override public int[] call(Game game, int irobot, int[] hand) {
			DecisionSet ds = new DecisionSet(game.robots.get(irobot).empty_register_count(), hand);
			return ds.cards(ds.random());
		}
	}),
	RandomSearchHeuristicFast(new RandomSearchDecisionFunction(100, Evaluator.Heuristic)),
	RandomSearchHeuristicSlow(new RandomSearchDecisionFunction(1000, Evaluator.Heuristic)),
	MonteCarloCheckpoint(new MonteCarloDecisionFunction(30, 1, Evaluator.CheckpointAdvantage, Strategy.Random)),
	MonteCarloHeuristic(new MonteCarloDecisionFunction(30, 1, Evaluator.Heuristic, Strategy.Random)),
	MonteCarloHeuristicSmart(new MonteCarloDecisionFunction(30, 1, Evaluator.Heuristic, Strategy.RandomSearchHeuristicFast));
	
	final DecisionFunction f;
	Strategy(DecisionFunction f) {
		this.f = f;
	}

	public int[] decide(Game game, int irobot, int[] hand) {
		return f.call(game, irobot, hand);
	}
}
