package RallyRobo;

import java.util.ArrayList;
import java.util.Arrays;

public class DecisionSet {
	public final int[][] xclasses;
	public final int[] xclass_sizes;
	public final int decisionLength;
	public final int size;

	public DecisionSet(int k, int[] hand) {
		this.xclasses = xclasses(hand);
		this.xclass_sizes = new int[xclasses.length];
		for (int i = 0, ni = xclasses.length; i < ni; i++)
			xclass_sizes[i] = xclasses[i].length;

		this.decisionLength = k;
		this.size = computeSize(k, xclass_sizes);
		System.out.println("decisionSetSize: "+size);
	}

	// true iff c and d are *directly* exchangeable; does not respect transitivity
	private static boolean exchangeable(int c, int d) {
		if (Card.translation(c) == 0)
			return Card.rotation(c) == Card.rotation(d);
		else
			return Math.abs(c-d) == 1 && Card.translation(c) == Card.translation(d);
	}
	
	// partition the indices of this.hand into subsets the members of which are
	// mutually exchangeable().  the sets are represented as arrays because
	// we need the ordering information.
	private static int[][] xclasses(int[] hand) {
		ArrayList<ArrayList<Integer>> xclasses = new ArrayList<ArrayList<Integer>>();
		hand: for (int c: hand) {
			// belongs in an existing xclass?
			for (ArrayList<Integer> xclass: xclasses) {
				// exchangeability is transitive, so if the card is
				// exchangeable with at least one of the cards in the
				// xclass, it is exchangeable with all of them.
				for (int d: xclass) {
					if (exchangeable(c, d)) {
						xclass.add(c);
						continue hand;
					}
				}
			}

			// put it in a new xclass
			ArrayList<Integer> xclass = new ArrayList<Integer>();
			xclass.add(c);
			xclasses.add(xclass);
		}
		
		int[][] xclasses2 = new int[xclasses.size()][];
		for (int i = 0, ni = xclasses.size(); i < ni; i++) {
			ArrayList<Integer> xclass = xclasses.get(i);
			xclasses2[i] = new int[xclass.size()];
			for (int j = 0, nj = xclass.size(); j < nj; j++)
				xclasses2[i][j] = xclass.get(j);
		}
		return xclasses2;
	}

	// number of ways of taking a sequence of k items when there are ns[i] of the
	// ith kind of item.
	// there may be a better way to compute this, but it's not time-critical and
	// the quantities involved are small.
	private static int computeSize(int k, int[] ns) {
		if (k == 0)
			return 1;

		int result = 0;
		for (int i = 0; i < ns.length; i++) {
			if (ns[i] > 0) {
				ns[i]--;
				result += computeSize(k-1, ns);
				ns[i]++;
			}
		}
		
		return result;
	}
	
	public int decisionIndex(int[] decision) {
		System.err.println("encoding "+Arrays.toString(decision));
		// a decision is represented by a sequence of indices into this.xclasses,
		// intuitively these are used as digits in radix this.xclasses.size() to
		// compute an index.  however, note that there are then decisionIndexes
		// that correspond to illegal decisions, such as those using the same
		// card multiple times.  in order to avoid this, the radix is nonconstant;
		// we step through the decision, computing the number, decrementing the radix
		// every time one of the xclasses becomes exhausted (all its cards are used).
		// we also need to decrement the indices/digits in decision appropriately;

		// compute the radices and digits
		int[] xclass_sizes = this.xclass_sizes.clone();
		int[] radices = new int[decision.length];
		int[] digits = decision.clone();
		int radix = xclass_sizes.length;
		for (int i = 0, ni = decision.length; i < ni; i++) {
			radices[i] = radix;
			
			xclass_sizes[decision[i]]--;
			if (xclass_sizes[decision[i]] == 0)
				radix--;
			
			// the digits[i]th nonzero element is located at index decision[i]
			for (int j = 0; j < decision[i]; j++) {
				if (xclass_sizes[j] == 0)
					digits[i]--;
			}
		}

		// compute the index in such a way that the least-significant radix is
		// known; this makes decoding straightforward.
		int decisionIndex = 0;
		for (int i = decision.length - 1; i >= 0; i--) {
			System.err.println(digits[i]+"/"+radices[i]);
			decisionIndex *= radices[i];
			decisionIndex += digits[i];
		}
		return decisionIndex;
	}

	public int[] decisionFromIndex(int decisionIndex) {
		System.err.println("decoding "+decisionIndex);
		int[] xclass_sizes = this.xclass_sizes.clone();

		int[] decision = new int[decisionLength];
		int radix = xclass_sizes.length;
		for (int i = 0; i < decisionLength; i++) {
			if (decisionIndex <= 0)
				break;
			
			decision[i]   = decisionIndex % radix;
			decisionIndex = decisionIndex / radix;
			System.err.println(decision[i]+"/"+radix);

			for (int j = 0; j <= decision[i]; j++) {
				if (xclass_sizes[j] == 0)
					decision[i]++;
			}

			xclass_sizes[decision[i]]--;
			if (xclass_sizes[decision[i]] == 0)
				radix--;
			assert(xclass_sizes[decision[i]] >= 0);
		}
		assert(decisionIndex == 0);
		return decision;
	}
	
	public void enumerateDecisionSet() {
		enumerateDecisionSet(decisionLength, new int[decisionLength], xclass_sizes.clone());
	}
	
	public void enumerateDecisionSet(int j, int[] decision, int[] ns) {
		if (j == 0) {
			System.out.println(Arrays.toString(decision));
			return;
		}

		for (int i = 0; i < ns.length; i++) {
			if (ns[i] > 0) {
				ns[i]--;
				decision[j-1] = i;
				enumerateDecisionSet(j-1, decision, ns);
				ns[i]++;
			}
		}
	}

	public int[] cards(int[] decision) {
		int[] cards = new int[decision.length];
		int[] xclass_sizes = this.xclass_sizes.clone();
		for (int i = 0; i < decision.length; i++) {
			int xclass_index = decision[i];
			xclass_sizes[xclass_index]--;
			int j = xclass_sizes[xclass_index];
			cards[i] = xclasses[xclass_index][j];
		}
		return cards;
	}
	
	public int[] cards(int decisionIndex) {
		return cards(decisionFromIndex(decisionIndex));
	}
	
	public int randomIndex() {
		return Util.generator.nextInt(size);
	}
	
	static void test() {
		test_xclasses();
		test_decisionSetSize();
		test_decisionIndex();
		test_decisionIndexDeterministically();
		test_decisionIndexRandomly();
	}

	static void test_xclasses() {
		Test.assert_equal(new int[][]{{11,35,7},{63,64},{78},{67},{50},{54}},
						  xclasses(new int[]{11,63,78,35,64,67,50, 7,54}));
	}

	static void test_decisionSetSize() {
		Test.assert_equal(19, computeSize(3, new int[]{4,2,1}));

		DecisionSet ds = new DecisionSet(3, new int[]{11,13,15,17,12,16,77});
		Test.assert_equal(new int[]{4,2,1}, ds.xclass_sizes);
		Test.assert_equal(19, ds.size);
		int n = 0;
		for (; ; n++) {
			try {
				int[] decision = ds.decisionFromIndex(n);
				System.out.println(Arrays.toString(decision));
			} catch (AssertionError e) {
				break;
			}
		}
		System.out.println(n);
		
		ds.enumerateDecisionSet();
		
		Test.assert_equal(23, computeSize(3, new int[]{4,2,1}));
		Test.assert_equal(1034, computeSize(5, new int[]{3,2,1,1,1,1}));
	}

	static void test_decisionIndex() {
		DecisionSet ds = new DecisionSet(5, new int[]{11,63,78,35,64,67,50, 7,54});
		Test.assert_equal(719, ds.decisionIndex(new int[]{5,4,3,2,1}));
		Test.assert_equal(new int[]{5,4,3,2,1}, ds.decisionFromIndex(719));
		Test.assert_equal(221, ds.decisionIndex(new int[]{5,1,2,1,0}));
		Test.assert_equal(new int[]{5,1,2,1,0}, ds.decisionFromIndex(221));
		for (int d: new int[]{2021, 1604, 1754, 1858, 1910, 1558}) {
			try {
		//		System.err.println(Arrays.toString(ds.decisionFromIndex(d)));
			} catch(AssertionError e) {
				e.printStackTrace(System.err);
			}
		}
	}
	
	static void test_decisionIndexDeterministically() {
		DecisionSet ds = new DecisionSet(5, new int[]{11,63,78,35,64,67,50, 7,54});
		for (int decisionIndex = 0; decisionIndex < ds.size; decisionIndex++) {
			int[] decision = ds.decisionFromIndex(decisionIndex);
			int decisionIndex2 = ds.decisionIndex(decision);
			if (decisionIndex != decisionIndex2)
				throw new AssertionError("test_decisionIndex:"+
										  " expected "+decisionIndex+
										  " but saw "+decisionIndex2+
										  ", intermediate decision "+Arrays.toString(decision));
		}
	}

	static void test_decisionIndexRandomly() {
		DecisionSet ds = new DecisionSet(5, new int[]{11,63,78,35,64,67,50, 7,54});
		for (int i = 0; i < 100; i++) {
			int decisionIndex = ds.randomIndex();
			int[] decision = ds.decisionFromIndex(decisionIndex);
			int decisionIndex2 = ds.decisionIndex(decision);
			if (decisionIndex != decisionIndex2)
				throw new AssertionError("test_decisionIndex:"+
										  " expected "+decisionIndex+
										  " but saw "+decisionIndex2+
										  ", intermediate decision "+Arrays.toString(decision));
		}
	}
}