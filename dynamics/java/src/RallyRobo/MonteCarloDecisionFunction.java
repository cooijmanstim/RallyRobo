package RallyRobo;

import RallyRobo.MonteCarloDecision.Statistics;

public class MonteCarloDecisionFunction implements DecisionFunction {
	final int duration;
	final int maxDepth;
	final Evaluator evaluator;
	
	public MonteCarloDecisionFunction(int duration, int maxDepth, Evaluator evaluator) {
		this.duration = duration;
		this.maxDepth = maxDepth;
		this.evaluator = evaluator;
	}
	
	@Override public int[] call(Game game, int irobot, int[] hand) {
		MonteCarloDecision mcd = new MonteCarloDecision(game, irobot, hand, maxDepth, evaluator);
		mcd.sampleTimeLimited(duration);
		Statistics s = mcd.statistics();
		System.out.println("sample count: "+mcd.sampleCount());
		System.out.println("decision set size: "+mcd.decisions.computeSize());
		System.out.println("mean depth: "+s.meanDepth.value());
		System.out.println("expectations: "+s.expectationHistogram);
		System.out.println("sample counts: "+s.sampleCountHistogram);
		return mcd.decide();
	}
}
