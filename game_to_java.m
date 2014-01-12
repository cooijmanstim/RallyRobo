function [jgame] = game_to_java(game)
import RallyRobo.Game;

jgame = Game();

% performance be hurtin' with all this convertin', but that's how it is.
for i = 1:Game.InteriorHeight
    for j = 1:Game.InteriorWidth
        for k = 1:RR.nfeatures
            if board_has_feature(game.board, [i j], k)
                jgame.board.set_feature(i, j, k-1);
            end
        end
    end
end

for x = game.checkpoints'
    jgame.board.add_checkpoint(x');
end

robots_to_java(game.robots, jgame);
