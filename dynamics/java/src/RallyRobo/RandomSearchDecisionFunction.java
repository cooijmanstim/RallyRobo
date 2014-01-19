package RallyRobo;

public class RandomSearchDecisionFunction implements DecisionFunction {
	final long sampleBudget;
	final Evaluator evaluator;
	
	public RandomSearchDecisionFunction(int sampleBudget, Evaluator evaluator) {
		this.sampleBudget = sampleBudget;
		this.evaluator = evaluator;
	}
	
	@Override public int[] call(Game game, int irobot, int[] hand) {
		Robot robot = game.robots.get(irobot);
		DecisionSet ds = new DecisionSet(robot.empty_register_count(), hand);
		int[] decision, bestDecision = null;
		double bestScore = Double.MIN_VALUE;
		for (int i = 0; i < sampleBudget; i++) {
			decision = ds.cards(ds.random());
			double score = game.evaluate_naive_outcome(decision, irobot, evaluator);
			if (score > bestScore || bestDecision == null) {
				bestScore = score;
				bestDecision = decision;
			}
		}
		return bestDecision;
	}
}
