function [game] = board_enable_checkpoints(game,checkpoints)
for i = 1 : game.board.checkpoints.size
    if size(checkpoints{i},1)>0
        game.board.checkpoints.set(i, checkpoints{i});
    end
end

end