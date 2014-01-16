package RallyRobo;

import java.util.ArrayList;
import java.util.Arrays;

class MonteCarloDecision {
	private final Game game;
	private final int irobot;
	private final DecisionSet decisions;
	private final long[] successCounts, sampleCounts;
	private long sampleCount = 0;

	private double[] winRates;
	
	public MonteCarloDecision(Game game, int irobot, int[] hand) {
		this.game = game.clone();
		this.irobot = irobot;
		
		this.decisions = new DecisionSet(decisionLength(game.robots.get(irobot)), hand);

		this.successCounts = new long[decisions.size];
		this.sampleCounts = new long[decisions.size];
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
		int decisionIndex = decisions.randomIndex(); 
		int[] cards = decisions.cards(decisionIndex);
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
		while (!game.over) {
			Card.fill_empty_registers_randomly(game);
			game.perform_turn();
		}
		return game.winner.identity == game.robots.get(irobot).identity;
	}

	private void computeWinRates() {
		winRates = new double[decisions.size];
		for (int i = 0; i < decisions.size; i++)
			winRates[i] = successCounts[i] * 1.0 / sampleCounts[i];
	}

	public int[] decide() {
		if (winRates == null)
			computeWinRates();

		int decisionIndex = 0;
		for (int i = 0; i < decisions.size; i++) {
			if (winRates[i] > winRates[decisionIndex])
				decisionIndex = i;
		}

		return decisions.cards(decisionIndex);
	}

	static class Statistics {
		final double min, max;
		final long[] histogram;
		Statistics(double min, double max, long[] histogram) {
			this.min = min; this.max = max;
			this.histogram = histogram;
		}
	}
	
	public Statistics statistics() {
		if (winRates == null)
			computeWinRates();
		
		double min = 1, max = 0;
		for (int i = 0, ni = winRates.length; i < ni; i++) {
			min = Math.min(min, winRates[i]);
			max = Math.max(max, winRates[i]);
		}

		int nbuckets = 10;
		long[] histogram = new long[nbuckets];
		for (int i = 0, ni = winRates.length; i < ni; i++) {
			int bucket = (int)((winRates[i] - min)/(max - min) * nbuckets);
			if (bucket == nbuckets)
				bucket--;
			histogram[bucket]++;
		}
		return new Statistics(min, max, histogram);
	}

	static void test() {
	}

	public static void main(String[] args) {
		Game game = Game.example_game();
		int[] hand = {11,83,57,49,35,21, 3,50, 4};
		MonteCarloDecision mcd = new MonteCarloDecision(game, 0, hand);
		mcd.sample(1000);
		Statistics s = mcd.statistics();
		System.out.println("statistics: "+s.min+" "+Arrays.toString(s.histogram)+" "+s.max);
	}
}
