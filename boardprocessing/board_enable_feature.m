function [game] = board_enable_feature(game, x, feature)
if isGameState
    if ~isempty(feature.checkpointid)
		game.ncheckpoints = game.ncheckpoints +1;
        game.state.checkpoints(feature.checkpointid) = x;
    end
else
	game.board.set_feature(x(1), x(2), feature);
end
end