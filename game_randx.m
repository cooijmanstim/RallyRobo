function [x] = game_randx(game)
[m,n,~] = size(game.board);
x = [randi(m) randi(n)];
