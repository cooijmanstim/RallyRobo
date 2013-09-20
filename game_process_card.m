function [game] = game_process_card(game, card, irobot)
if card.translation == 0
    % rotation only
    game.robots.position(irobot, :) = game.robots.position(irobot, :) * card.rotation';
else
    % translation only, tile by tile
    dx = sign(card.translation) * game.robots.direction(irobot, :);
    for i = 0:abs(card.translation)
        [game, moved] = game_move_robot_maybe(game, irobot, dx);
        
        if ~moved
            break;
        end
    end
end
