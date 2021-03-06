package RallyRobo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Random;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

final class MonteCarloDecision {
	private final Game game;
	private final int irobot;
	public final DecisionSet decisions;
	private final int maxDepth;
	private Evaluator evaluator = Evaluator.Heuristic;
	private final Average[] expectations;
	private final Average meanDepth = new Average();
	private long sampleCount = 0;

	public MonteCarloDecision(Game game, int irobot, int[] hand, int maxDepth) {
		this.game = game.clone();
		this.irobot = irobot;
		
		this.decisions = new DecisionSet(game.robots.get(irobot).empty_register_count(), hand);
		
		this.maxDepth = maxDepth;

		this.expectations = new Average[decisions.indexUpperBound];
		for (int i = 0; i < expectations.length; i++)
			expectations[i] = new Average();
	}
	
	public void setPlayoutStrategy(Strategy s) {
		for (Robot robot: game.robots)
			robot.set_strategy(s);
	}
	
	public void setEvaluator(Evaluator e) {
		assert(sampleCount == 0);
		evaluator = e;
	}
	
	public long sampleCount() {
		return sampleCount;
	}

	public void sample(long sampleBudget) {
		for (int i = 0; i < sampleBudget; i++)
			sampleOnce();
	}
	
	private class Sampler implements Callable<Void> {
		private Random generator = new Random();
		
		@Override public Void call() {
			try {
				while (!Thread.interrupted())
					sampleOnce(generator);
			} catch(Throwable t) {
				System.out.println("sampler threw: "+t);
				t.printStackTrace();
			}
			return null;
		}
	}
	
	public void sampleTimeLimited(int timeBudget) {
		int nthreads = Runtime.getRuntime().availableProcessors();
		ExecutorService es = Executors.newFixedThreadPool(nthreads);
		List<Sampler> tasks = new ArrayList<Sampler>();
		for (int i = 0; i < nthreads; i++)
			tasks.add(new Sampler());

		long startTime = System.nanoTime();
		try {
			es.invokeAll(tasks, timeBudget, TimeUnit.SECONDS);
		} catch(InterruptedException e) {
			System.out.println("samplers interrupted");
		}
		es.shutdown();
		long endTime = System.nanoTime();
		double duration = (endTime - startTime)*1.0/1e9;
		System.out.println(timeBudget+" seconds took "+duration+" seconds");
	}
	
	public void sampleOnce() {
		sampleOnce(Util.generator);
	}

	public void sampleOnce(Random random) {
		Game game = this.game.clone();

		// make a decision
		int[] decision = decisions.random(random);
		int decisionIndex = decisions.decisionIndex(decision);
		int[] cards = decisions.cards(decision);
		game.robots.get(irobot).fill_registers(cards);

		double value = playout(game);
		expectations[decisionIndex].record(value);
		sampleCount++;
	}
	
	private double playout(Game game) {
		int depth;
		for (depth = 0; depth < maxDepth; depth++) {
			game.fill_registers();
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
			if (expectations[i].baseless())
				continue;
			
			if (expectations[i].value() > expectations[decisionIndex].value())
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
		double minExpectation = Double.MAX_VALUE, maxExpectation = -Double.MAX_VALUE;
		long minSampleCount = Long.MAX_VALUE, maxSampleCount = Long.MIN_VALUE;
		for (int i = 0; i < expectations.length; i++) {
			Average expectation = expectations[i];
			if (expectation.baseless())
				continue;

			minExpectation = Math.min(minExpectation, expectation.value());
			maxExpectation = Math.max(maxExpectation, expectation.value());
			
			minSampleCount = Math.min(minSampleCount, expectation.sampleSize());
			maxSampleCount = Math.max(maxSampleCount, expectation.sampleSize());
		}
		
		Histogram expectationHistogram = new Histogram(10, minExpectation, maxExpectation);
		Histogram sampleCountHistogram = new Histogram(10, minSampleCount, maxSampleCount);

		for (int i = 0; i < expectations.length; i++) {
			Average expectation = expectations[i];
			if (expectation.baseless())
				continue;
			
			expectationHistogram.record(expectation.value());
			sampleCountHistogram.record(expectation.sampleSize());
		}
		return new Statistics(meanDepth, expectationHistogram, sampleCountHistogram);
	}

	static void test() {
	}

	public static void main(String[] args) {
		Game game = Game.example_game();
		//int[] hand = {11,83,57,49,35,21, 3,50, 4};
		int[] hand = {77, 72, 34, 69, 41, 21};
		final MonteCarloDecision mcd = new MonteCarloDecision(game, 0, hand, 10);
		mcd.setEvaluator(Evaluator.Heuristic);
		mcd.setPlayoutStrategy(Strategy.RandomSearchHeuristicFast);
		mcd.sampleTimeLimited(10);
		
		Statistics s = mcd.statistics();
		System.out.println("hand: "+Arrays.toString(hand));
		System.out.println("xclasses: "+Arrays.toString(mcd.decisions.xclass_sizes));
		System.out.println("sample count: "+mcd.sampleCount);
		System.out.println("decision set size: "+mcd.decisions.computeSize());
		System.out.println("mean depth: "+s.meanDepth.value());
		System.out.println("expectations: "+s.expectationHistogram);
		System.out.println("sample counts: "+s.sampleCountHistogram);
	}
}
