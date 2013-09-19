function [ ] = refreshBoard(board,robots) 
% paints over the existing graphic
[m,n,nFeatures] = size(board);
drawGrid(m,n);
drawObjects(board);
drawRobots(robots);

end

