function [ ] = refreshBoard(game)
% paints over the existing graphic
drawGrid(game.board.interiorWidth, game.board.interiorHeight);
drawObjects(game.board);
drawCheckpoints(game.board.checkpoints, game.board.interiorWidth);
drawRobots(game.robots);
end
