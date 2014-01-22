clc; close all ; clear all;
% picture here
[picture, map]= imread('screenshotBoard0121_2.PNG');
figure, imshow(picture);
title('the original image');

%initialize game
gridSize = 12;
game = RallyRobo.Game(gridSize, gridSize);
for i = 1:4
    game.board.add_checkpoint([0 0]);
    game.add_robot([1 1], RallyRobo.Direction.East);
end

% identify board
game = getGameFromImage(picture,game);

figure;
initBoardFigure(game);
refreshBoard(game);