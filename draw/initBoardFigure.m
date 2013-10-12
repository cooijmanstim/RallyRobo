function [ ] = initBoardFigure(game)
%  draws a figure of the boardgame
global BoardFigure;


BoardFigure = figure('name','Robo Rally');
axis ( [1, game.width+1, 1, game.height+1 ] );
axis image;
set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', [],'Visible','off');
set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', [],'Visible','off');
set(BoardFigure,'color','white');
hold on;
end

