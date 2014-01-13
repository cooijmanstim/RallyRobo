function [game] = game_from_java(jgame)
global RR;
import RallyRobo.Board;

game = game_create(Board.InteriorHeight, Board.InteriorWidth);

for i = 1:Board.InteriorHeight
    for j = 1:Board.InteriorWidth
        for k = 1:RR.nfeatures
            if jgame.board.has_feature(i, j, k-1)
                board_enable_feature(game.board, [i j], k);
            end
        end
    end
end

for i = 1:jgame.board.checkpoints.size()
    game = game_add_checkpoint(game, jgame.board.checkpoints.get(i-1));
end

game.robots = robots_from_java(jgame.robots);
end
