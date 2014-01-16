package RallyRobo;

import java.util.ArrayList;
import java.util.Arrays;

class MonteCarloDecision {
	private final Game game;
	private final int irobot;
	private final DecisionSet decisions;
	private final long[] successCounts, sampleCounts;
	private final Average meanDepth = new Average();
	private long sampleCount = 0;

	private double[] winRates;
	
	public MonteCarloDecision(Game game, int irobot, int[] hand) {
		this.game = game.clone();
		this.irobot = irobot;
		
		this.decisions = new DecisionSet(decisionLength(game.robots.get(irobot)), hand);

		this.successCounts = new long[decisions.indexUpperBound];
		this.sampleCounts = new long[decisions.indexUpperBound];
	}

	private static int decisionLength(Robot robot) {
		// NRegisters minus number of already filled (i.e. locked) registers
		int decisionLength = 0;
		for (int card: robot.registers) {
			if (card == Card.None)
				decisionLength++;
			else
				break;
		}
		return decisionLength;
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
		int[] registers = game.robots.get(irobot).registers;
		for (int i = 0; i < cards.length; i++)
			registers[i] = cards[i];

		boolean won = playout(game);
		sampleCount++;
		sampleCounts[decisionIndex]++;
		if (won)
			successCounts[decisionIndex]++;
	}

	private boolean playout(Game game) {
		// XXX: maybe limit depth. games can take arbitrarily long.
		int depth = 0;
		while (!game.over) {
			// TODO: use DecisionSet
			Card.fill_empty_registers_randomly(game);
			game.perform_turn();
			depth++;
		}
		meanDepth.record(depth);
		return game.winner.identity == game.robots.get(irobot).identity;
	}

	private void computeWinRates() {
		winRates = new double[decisions.indexUpperBound];
		for (int i = 0; i < decisions.indexUpperBound; i++) {
			if (sampleCounts[i] == 0)
				continue;
		
			winRates[i] = successCounts[i] * 1.0 / sampleCounts[i];
		}
	}

	public int[] decide() {
		if (winRates == null)
			computeWinRates();

		int decisionIndex = 0;
		for (int i = 0; i < decisions.indexUpperBound; i++) {
			if (sampleCounts[i] == 0)
				continue;
			
			if (winRates[i] > winRates[decisionIndex])
				decisionIndex = i;
		}

		return decisions.cards(decisionIndex);
	}

	static class Statistics {
		public final Average meanDepth;
		public final Histogram winRatesHistogram, sampleCountsHistogram;
		Statistics(Average meanDepth, Histogram winRatesHistogram, Histogram sampleCountsHistogram) {
			this.meanDepth = meanDepth;
			this.winRatesHistogram = winRatesHistogram;
			this.sampleCountsHistogram = sampleCountsHistogram;
		}
	}
	
	public Statistics statistics() {
		if (winRates == null)
			computeWinRates();

		double minWinRate = Double.MAX_VALUE, maxWinRate = Double.MIN_VALUE;
		long minSampleCount = Long.MAX_VALUE, maxSampleCount = Long.MIN_VALUE;
		for (int i = 0, ni = winRates.length; i < ni; i++) {
			if (sampleCounts[i] == 0)
				continue;
			
			minWinRate = Math.min(minWinRate, winRates[i]);
			maxWinRate = Math.max(maxWinRate, winRates[i]);
			
			minSampleCount = Math.min(minSampleCount, sampleCounts[i]);
			maxSampleCount = Math.max(maxSampleCount, sampleCounts[i]);
		}
		
		Histogram winRatesHistogram    = new Histogram(10, minWinRate, maxWinRate);
		Histogram sampleCountsHistogram = new Histogram(10, minSampleCount, maxSampleCount);

		for (int i = 0, ni = sampleCounts.length; i < ni; i++) {
			if (sampleCounts[i] == 0)
				continue;
			
			winRatesHistogram.record(winRates[i]);
			sampleCountsHistogram.record(sampleCounts[i]);
		}
		return new Statistics(meanDepth, winRatesHistogram, sampleCountsHistogram);
	}

	static void test() {
	}

	public static void main(String[] args) {
		Game game = Game.example_game();
		int[] hand = {11,83,57,49,35,21, 3,50, 4};
		MonteCarloDecision mcd = new MonteCarloDecision(game, 0, hand);
		mcd.sample(10000);
		Statistics s = mcd.statistics();
		System.out.println("decision set size: "+mcd.decisions.computeSize());
		System.out.println("mean depth: "+s.meanDepth.value());
		System.out.println("win rates: "+s.winRatesHistogram);
		System.out.println("sample counts: "+s.sampleCountsHistogram);
	}
}
