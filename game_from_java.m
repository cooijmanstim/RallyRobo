function [game] = game_from_java(jgame)
import RallyRobo.Game;

game = game_create(Game.InteriorHeight, Game.InteriorWidth);

for i = 1:Game.InteriorHeight
    for j = 1:Game.InteriorWidth
        for k = 1:RR.nfeatures
            if jgame.board.has_feature(i, j, k-1)
                board_enable_feature(game.board, [i j], k);
            end
        end
    end
end

for i = 1:jgame.board.checkpoints.length
    game = game_add_checkpoint(game, jgame.board.checkpoints.get(i));
end

game.robots = robots_from_java(jgame.robots);
end
