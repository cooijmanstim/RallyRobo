package RallyRobo;

import java.util.ArrayList;
import java.util.Arrays;

class MonteCarloDecision {
	private final Game game;
	private final int irobot;
	private final DecisionSet decisions;
	private final int maxDepth;
	private final Evaluator evaluator;
	private final double[] expectations;
	private final long[] sampleCounts;
	private final Average meanDepth = new Average();
	private long sampleCount = 0;

	public MonteCarloDecision(Game game, int irobot, int[] hand, int maxDepth, Evaluator evaluator) {
		this.game = game.clone();
		this.irobot = irobot;
		
		this.decisions = new DecisionSet(game.robots.get(irobot).empty_register_count(), hand);
		
		this.maxDepth = maxDepth;
		this.evaluator = evaluator;

		this.expectations = new double[decisions.indexUpperBound];
		this.sampleCounts = new long[decisions.indexUpperBound];
	}

	public void sample(long sampleBudget) {
		for (int i = 0; i < sampleBudget; i++)
			sampleOnce();
	}

	public void sampleOnce() {
		Game game = this.game.clone();

		// make a decision
		int[] decision = decisions.random();
		int decisionIndex = decisions.decisionIndex(decision);
		int[] cards = decisions.cards(decision);
		game.robots.get(irobot).fill_registers(cards);

		double value = playout(game);
		recordValue(decisionIndex, value);
	}
	
	private void recordValue(int i, double x) {
		long n = sampleCounts[i];
		expectations[i] = (n*1.0/(n+1))*expectations[i] + (1.0/(n+1))*x;
		sampleCount++;
		sampleCounts[i]++;
	}

	private final boolean use_decisionset_internally = true;

	private double playout(Game game) {
		int depth;
		for (depth = 0; depth < maxDepth; depth++) {
			if (use_decisionset_internally) {
				int[][] hands = game.deal();
				for (int i = 0; i < hands.length; i++) {
					Robot robot = game.robots.get(i);
					if (!robot.is_active())
						continue;
				
					int k = robot.empty_register_count();
					if (k > 0) {
						DecisionSet ds = new DecisionSet(k, hands[i]);
						int[] cards = ds.cards(ds.random());
						robot.fill_registers(cards);
					}
				}
			} else {
				boolean[] deck = game.deck();
				for (Robot robot: game.robots)
					robot.fill_registers(Util.take(robot.empty_register_count(), deck));
			}
			game.perform_turn();
			
			if (game.over)
				break;
		}
		meanDepth.record(depth);
		return evaluator.evaluate(game, irobot);
	}

	public int[] decide() {
		int decisionIndex = 0;
		for (int i = 0; i < decisions.indexUpperBound; i++) {
			if (sampleCounts[i] == 0)
				continue;
			
			if (expectations[i] > expectations[decisionIndex])
				decisionIndex = i;
		}

		return decisions.cards(decisionIndex);
	}

	static class Statistics {
		public final Average meanDepth;
		public final Histogram expectationHistogram, sampleCountHistogram;
		Statistics(Average meanDepth, Histogram expectationHistogram, Histogram sampleCountHistogram) {
			this.meanDepth = meanDepth;
			this.expectationHistogram = expectationHistogram;
			this.sampleCountHistogram = sampleCountHistogram;
		}
	}
	
	public Statistics statistics() {
		double minExpectation = Double.MAX_VALUE, maxExpectation = Double.MIN_VALUE;
		long minSampleCount = Long.MAX_VALUE, maxSampleCount = Long.MIN_VALUE;
		for (int i = 0, ni = sampleCounts.length; i < ni; i++) {
			if (sampleCounts[i] == 0)
				continue;
			
			minExpectation = Math.min(minExpectation, expectations[i]);
			maxExpectation = Math.max(maxExpectation, expectations[i]);
			
			minSampleCount = Math.min(minSampleCount, sampleCounts[i]);
			maxSampleCount = Math.max(maxSampleCount, sampleCounts[i]);
		}
		
		Histogram expectationHistogram = new Histogram(10, minExpectation, maxExpectation);
		Histogram sampleCountHistogram = new Histogram(10, minSampleCount, maxSampleCount);

		for (int i = 0, ni = sampleCounts.length; i < ni; i++) {
			if (sampleCounts[i] == 0)
				continue;
			
			expectationHistogram.record(expectations[i]);
			sampleCountHistogram.record(sampleCounts[i]);
		}
		return new Statistics(meanDepth, expectationHistogram, sampleCountHistogram);
	}

	static void test() {
	}

	public static void main(String[] args) {
		Game game = Game.example_game();
		int[] hand = {11,83,57,49,35,21, 3,50, 4};
		MonteCarloDecision mcd = new MonteCarloDecision(game, 0, hand, 10, new CheckpointAdvantageEvaluator());
		mcd.sample(10000);
		Statistics s = mcd.statistics();
		System.out.println("sample count: "+mcd.sampleCount);
		System.out.println("decision set size: "+mcd.decisions.computeSize());
		System.out.println("mean depth: "+s.meanDepth.value());
		System.out.println("expectations: "+s.expectationHistogram);
		System.out.println("sample counts: "+s.sampleCountHistogram);
	}
}
