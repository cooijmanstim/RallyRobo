package RallyRobo;

public class CheckpointAdvantageEvaluator implements Evaluator {
	@Override
	public double evaluate(Game game, int irobot) {
		Robot us = game.robots.get(irobot);
		int advantage = Integer.MAX_VALUE;
		for (Robot them: game.robots) {
			if (them.identity == irobot)
				continue;
			
			advantage = Math.min(advantage, them.next_checkpoint - us.next_checkpoint);
		}
		return advantage;
	}
}
