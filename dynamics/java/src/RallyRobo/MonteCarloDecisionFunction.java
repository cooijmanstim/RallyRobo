package RallyRobo;

import java.util.Arrays;

import RallyRobo.MonteCarloDecision.Statistics;

public class MonteCarloDecisionFunction implements DecisionFunction {
	final int duration;
	final int maxDepth;
	final Evaluator evaluator;
	final Strategy playoutStrategy;
	
	public MonteCarloDecisionFunction(int duration, int maxDepth, Evaluator evaluator, Strategy playoutStrategy) {
		this.duration = duration;
		this.maxDepth = maxDepth;
		this.evaluator = evaluator;
		this.playoutStrategy = playoutStrategy;
	}
	
	@Override public int[] call(Game game, int irobot, int[] hand) {
		MonteCarloDecision mcd = new MonteCarloDecision(game, irobot, hand, maxDepth);
		mcd.setEvaluator(evaluator);
		mcd.setPlayoutStrategy(playoutStrategy);
		mcd.sampleTimeLimited(duration);
		Statistics s = mcd.statistics();
		System.out.println("hand: "+Arrays.toString(hand));
		System.out.println("decision set size: "+mcd.decisions.computeSize());
		System.out.println("sample count: "+mcd.sampleCount());
		System.out.println("mean depth: "+s.meanDepth.value());
		System.out.println("expectations: "+s.expectationHistogram);
		System.out.println("sample counts: "+s.sampleCountHistogram);
		return mcd.decide();
	}
}
