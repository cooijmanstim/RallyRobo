package RallyRobo;

class Board {
	static final int InteriorHeight = 12, InteriorWidth = 12;
	static final int Height = InteriorHeight+2, Width = InteriorWidth+2;

	bool features[Height*Width*Feature.cardinality];
	ArrayList<int[Point.dimensionality]> checkpoints;

	Board() {
		// add a border of pits around the board.  this obviates the need to deal with bounds explicitly.
		// the coordinates for the interior of the board are now 1-based.
		for (int i = 0; i < Height; i++) {
			set_feature(i, 0,        Feature.Pit);
			set_feature(i, Height-1, Feature.Pit);
		}
		for (int j = 0; j < Width; j++) {
			set_feature(0,       j, Feature.Pit);
			set_feature(Width-1, j, Feature.Pit);
		}

		// checkpoint labels are 1-based, put a dummy 0th checkpoint in our vector
		// to keep the correspondence
		add_checkpoint(Point.make(-1, -1));
	}

	void add_checkpoint(int[Point.dimensionality] checkpoint) {
		checkpoints.add(checkpoint);
	}

	void set_feature(int i, int j, Feature feature) {
		int k = feature.ordinal();
		features[(i*Width+j)*Height+k] = true;
	}

	void has_feature(int i, int j, Feature feature) {
		int k = feature.ordinal();
		return features[(i*Width+j)*Height+k];
	}

	void set_feature(int[] x, Feature feature) {
		set_feature(x[0], x[1], feature);
	}

	void has_feature(int[] x, Feature feature) {
		return has_feature(x[0], x[1], feature);
	}
}

