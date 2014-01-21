function [game] = board_enable_robots(game,checkpoints)
for checkpoint = checkpoints
    game.board.add_checkpoint(cell2mat(checkpoint));
end

end