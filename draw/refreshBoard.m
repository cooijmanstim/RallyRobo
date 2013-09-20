function [ ] = refreshBoard(board,robots, checkpoints) 
% paints over the existing graphic
[m,n,nFeatures] = size(board);

drawGrid(m,n);
drawCheckpoints(checkpoints);
drawObjects(board);
drawRobots(robots);

end

