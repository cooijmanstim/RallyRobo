function [game] = board_enable_feature(game, x, feature)
	game.board.set_feature(x(1), x(2), feature);
end