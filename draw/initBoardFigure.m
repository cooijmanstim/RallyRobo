function [ ] = initBoardFigure(game)
%  draws a figure of the boardgame
global BoardFigure;


BoardFigure = figure('name','Robo Rally');
axis ( [0, game_width(game)+2, 0, game_height(game)+2 ] );
axis image;
set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', [],'Visible','off');
set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', [],'Visible','off');
set(BoardFigure,'color','white');
hold on;
end

