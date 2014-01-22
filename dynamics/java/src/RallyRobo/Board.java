package RallyRobo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;

final class Board {
	public final int interiorHeight, interiorWidth, height, width;

	final boolean features[];
	final public ArrayList<int[]> checkpoints = new ArrayList<int[]>();

	Board(int m, int n) {
		interiorHeight = m; interiorWidth = n;
		height = m+2; width = m+2;
		features = new boolean[height*width*Feature.cardinality];
		
		// add a border of pits around the board.  this obviates the need to deal with bounds explicitly.
		// the coordinates for the interior of the board are now 1-based.
		for (int i = 0; i < height; i++) {
			set_feature(i, 0,        Feature.Pit);
			set_feature(i, height-1, Feature.Pit);
		}
		for (int j = 0; j < width; j++) {
			set_feature(0,       j, Feature.Pit);
			set_feature(width-1, j, Feature.Pit);
		}

		// checkpoint labels are 1-based, put a dummy 0th checkpoint in our vector
		// to keep the correspondence
		add_checkpoint(Point.make(-1, -1));
	}

	Board(Board that) {
		this.interiorHeight = that.interiorHeight;
		this.interiorWidth  = that.interiorWidth;
		this.height = that.height;
		this.width  = that.width;
		this.features = that.features.clone();
		for (int[] checkpoint: that.checkpoints)
			this.checkpoints.add(checkpoint.clone());
	}

	@Override public Board clone() {
		return new Board(this);
	}
	
	@Override public boolean equals(Object o) {
		if (!(o instanceof Board))
			return false;
		Board that = (Board)o;
		Iterator<int[]> it1 = this.checkpoints.iterator(),
						it2 = that.checkpoints.iterator();
		while (it1.hasNext() && it2.hasNext())
			if (!Point.equals(it1.next(), it2.next()))
				return false;
		if (it1.hasNext() || it2.hasNext())
			return false;
		return this.height == that.height &&
				this.width == that.width &&
				this.interiorHeight == that.interiorHeight &&
				this.interiorWidth == that.interiorWidth &&
				Arrays.equals(this.features, that.features);
	}

	public void add_checkpoint(int... checkpoint) {
		checkpoints.add(checkpoint);
	}

	boolean within_bounds(int[] x) {
		return 0 <= x[0] && x[0] < height &&
				0 <= x[1] && x[1] < width;
	}

	public void set_feature(int i, int j, int k) {
		features[(i*width+j)*Feature.cardinality+k] = true;
	}

	public void unset_feature(int i, int j, int k) {
		features[(i*width+j)*Feature.cardinality+k] = false;
	}

	public boolean has_feature(int i, int j, int k) {
		return features[(i*width+j)*Feature.cardinality+k];
	}

	public void set_feature(int i, int j, Feature feature) {
		set_feature(i, j, feature.ordinal());
	}
	
	public void unset_feature(int i, int j, Feature feature) {
		unset_feature(i, j, feature.ordinal());
	}
	
	public boolean has_feature(int i, int j, Feature feature) {
		return has_feature(i, j, feature.ordinal());
	}
	
	public boolean[] has_feature(int i, int j, boolean[] features) {
		int n = 0;
		for (int k = 0; k < features.length; k++) {
			if (features[k])
				n++;
		}

		boolean[] result = new boolean[n];
		int l = 0;
		for (int k = 0; k < features.length; k++) {
			if (features[k] && has_feature(i, j, k)) {
				result[l] = true;
				l++;
			}
		}
		return result;
	}

	public void set_feature(int[] x, Feature feature) {
		set_feature(x[0], x[1], feature);
	}
	
	public boolean has_feature(int[] x, Feature feature) {
		return has_feature(x[0], x[1], feature);
	}
	
	public void set_feature(int i,int j, boolean[] features){
		for(int k=0; k < features.length; k++){
			if(features[k]){
				set_feature(i,j,k);
			}
		}
	}
	
}
