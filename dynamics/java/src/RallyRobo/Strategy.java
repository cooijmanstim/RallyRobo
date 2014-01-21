package RallyRobo;

public enum Strategy {
	Random(new DecisionFunction() {
		@Override public int[] call(Game game, int irobot, int[] hand) {
			DecisionSet ds = new DecisionSet(game.robots.get(irobot).empty_register_count(), hand);
			return ds.cards(ds.random());
		}
	}),
	RandomSearchHeuristicFast(new RandomSearchDecisionFunction(100, Evaluator.Heuristic)),
	RandomSearchHeuristicSlow(new RandomSearchDecisionFunction(10000, Evaluator.Heuristic)),
	MonteCarloTerminal(new MonteCarloDecisionFunction(10, 10000, Evaluator.WinLoss, Strategy.RandomSearchHeuristicFast)),
	MonteCarloCheckpointSmart(new MonteCarloDecisionFunction(10, 4, Evaluator.CheckpointAdvantage, Strategy.RandomSearchHeuristicFast)),
	MonteCarloHeuristic(new MonteCarloDecisionFunction(10, 4, Evaluator.Heuristic, Strategy.Random)),
	MonteCarloHeuristicSmart(new MonteCarloDecisionFunction(10, 4, Evaluator.Heuristic, Strategy.RandomSearchHeuristicFast));
	
	final DecisionFunction f;
	Strategy(DecisionFunction f) {
		this.f = f;
	}

	public int[] decide(Game game, int irobot, int[] hand) {
		return f.call(game, irobot, hand);
	}
}
