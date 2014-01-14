package RallyRobo;

import java.util.Arrays;

class MonteCarloDecision {
	private final Game game;
	private final int irobot;
	private final int[] hand;
	private final int decisionLength;

	private final long[] successCounts, sampleCounts;
	private long sampleCount = 0;

	private double[] winRates;
	
	public MonteCarloDecision(Game game, int irobot, int[] hand) {
		this.game = game.clone();
		this.irobot = irobot;
		this.hand = hand;

		// NRegisters minus number of already filled (i.e. locked) registers
		int decisionLength = 0;
		for (int card: game.robots.get(irobot).registers) {
			if (card == Card.None)
				decisionLength++;
			else
				break;
		}
		this.decisionLength = decisionLength;

		this.successCounts = new long[decisionIndexCount()];
		this.sampleCounts = new long[decisionIndexCount()];
	}

	private int decisionIndex(int[] decision) {
		// a decision is represented by a sequence of indices into this.hand,
		// these are used as digits in radix this.hand.length to compute an
		// index.  note that there are decisionIndexes that correspond to
		// illegal decisions, such as those using the same card multiple times.
		// the sampling procedure will ensure that these decisions are not
		// used.
		return Util.digitsToNumber(decision, hand.length);
	}

	private int[] decisionFromIndex(int decisionIndex) {
		return Util.numberToDigits(decisionIndex, hand.length, decisionLength);
	}
	
	private boolean interchangeable(int c, int d) {
		if (Card.translation(c) == 0)
			return Card.rotation(c) == Card.rotation(d);
		else
			return Math.abs(c-d) == 1 && Card.translation(c) == Card.translation(d);
	}
	
	// XXX: modifies decision
	private int[] canonicalize(int[] decision) {
		// some classes of decisions are equivalent, in that they necessarily lead
		// to the same outcome.  if k > 1 cards have the same translation properties
		// and consecutive priorities, then the order in which they are played
		// (with respect to each other) makes no difference.  for cards with the
		// same rotation properties the priorities do not even need to be consecutive.
		// it is complicated to devise a sampling procedure and a numbering scheme
		// so that this degeneracy disappears.  it is easier to ensure the statistics
		// collected are equal among members of the same equivalence class.
		// to do this, put the interchangeable cards into a canonical order (ascending
		// priority).  this way, every decision in an equivalence class maps to the
		// same canonical decision.  the statistics will be tallied in that decision's
		// bucket.
		// sort decision by priority, but never swap
		//  * translation cards with different effect and non-consecutive priorities
		//  * rotation cards with different effect
		int n = decision.length;
		for (int i = 0; i < n; i++) {
			int min = i, c = hand[decision[min]];
			for (int j = i+1; j < n; j++) {
				int d = hand[decision[j]];
				if (interchangeable(c, d) && d < c) {
					min = j;
					c = d;
				}
			}

			if (min != i) {
				int temp = decision[i];
				decision[i] = decision[min];
				decision[min] = temp;
			}
		}
		return decision;
	}

	private int decisionIndexCount() {
		return (int)Math.pow(hand.length, decisionLength);
	}

	public void sample(long sampleBudget) {
		for (int i = 0; i < sampleBudget; i++)
			sampleOnce();
	}
	
	public int[] randomDecision() {
		// a decision is a sequence of indices into this.hand.
		boolean[] indexset = new boolean[hand.length];
		Arrays.fill(indexset, true);
		// use the reservoir sampling procedure
		int[] decision = Util.take(decisionLength, indexset);
		return canonicalize(decision);
	}

	public void sampleOnce() {
		Game game = this.game.clone();

		// make a decision
		int[] decision = randomDecision();
		int[] registers = game.robots.get(irobot).registers;
		for (int i = 0; i < decisionLength; i++)
			registers[i] = hand[decision[i]];

		boolean won = playout(game);
		int decisionIndex = decisionIndex(decision);
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

	public int[] decide() {
		if (winRates == null)
			winRates = new double[sampleCounts.length];
		
		int decisionIndex = 0;
		for (int i = 0, ni = decisionIndexCount(); i < ni; i++) {
			// don't bother with the unused buckets
			if (sampleCounts[i] == 0)
				continue;
			
			winRates[i] = successCounts[i] * 1.0 / sampleCounts[i];
			if (winRates[i] > winRates[decisionIndex])
				decisionIndex = i;
		}
		return decisionFromIndex(decisionIndex);
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
			decide();
		
		double min = 1, max = 0;
		for (int i = 0, ni = winRates.length; i < ni; i++) {
			if (sampleCounts[i] == 0)
				continue;

			min = Math.min(min, winRates[i]);
			max = Math.max(max, winRates[i]);
		}

		int nbuckets = 10;
		long[] histogram = new long[nbuckets];
		for (int i = 0, ni = winRates.length; i < ni; i++) {
			if (sampleCounts[i] == 0)
				continue;

			int bucket = (int)((winRates[i] - min)/(max - min) * nbuckets);
			if (bucket == nbuckets)
				bucket--;
			histogram[bucket]++;
		}
		return new Statistics(min, max, histogram);
	}

	static void test() {
		test_decisionIndex();
		test_canonicalize();
	}

	static void test_decisionIndex() {
		Game game = Game.example_game();
		MonteCarloDecision mcd = new MonteCarloDecision(game, 0, new int[]{11,63,78,35,64,67,50, 7,54});
		for (int i = 0; i < 100; i++) {
			int[] decision = mcd.randomDecision();
			int decisionIndex = mcd.decisionIndex(decision);
			int[] decision2 = mcd.decisionFromIndex(decisionIndex);
			if (!Arrays.equals(decision, decision2))
				throw new AssertionError("test_decisionIndex:"+
										  " expected "+Arrays.toString(decision)+
										  " but saw "+Arrays.toString(decision2)+
										  ", intermediate decisionIndex "+decisionIndex);
		}
	}

	static void test_canonicalize() {
		Game game = Game.example_game();
		int[] hand = {11,83,57,49,35,21, 3,50, 4};
		MonteCarloDecision mcd = new MonteCarloDecision(game, 0, hand);

		mcd.test_canonicalize_case(new int[]{0,1,2,3,4}, new int[]{0,1,2,3,4});
		mcd.test_canonicalize_case(new int[]{5,7,4,3,6}, new int[]{5,3,4,7,6});
		mcd.test_canonicalize_case(new int[]{4,8,0,6,5}, new int[]{0,6,5,8,4});
	}
	
	void test_canonicalize_case(int[] a, int[] b) {
		int[] c = canonicalize(a.clone());
		if (!Arrays.equals(c, b)) {
			throw new AssertionError("test_canonicalize: from "+Arrays.toString(a)+
									  " expected "+Arrays.toString(b)+
									  " but saw "+Arrays.toString(c));
		}
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
