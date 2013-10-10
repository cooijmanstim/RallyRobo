function [tiles,featuresets] = generate_tile_images()

clear; clc;

global RR;
global BoardFigure;
init();

% data set size
n = 1;

% rows are logical vectors f(i), on if the ith feature is present
featuresets = zeros(0, RR.nfeatures);

% some combinations of features make sense:
% * all combinations of walls make sense
% * all combinations of up to three walls and one of
%   - a repair point
%   - a (possibly turning) conveyor belt
% make sense

walls = RR.features.wall_east:RR.features.wall_south;
for k = 0:4
    for indices = nchoosek(walls, k)'
        featureset = zeros(1, size(featuresets, 2));
        featureset(indices) = 1;
        featuresets(end+1, :) = featureset;
        
        if k <= 3
            copy1 = featureset;
            featureset(RR.features.repair) = 1;
            featuresets(end+1, :) = featureset;
            featureset = copy1;
            
            for index = RR.features.conveyor_east:RR.features.conveyor_south
                copy2 = featureset;
                featureset(index) = 1;
                for index2 = [index RR.features.conveyor_turning_counterclockwise RR.features.conveyor_turning_clockwise]
                    copy3 = featureset;
                    featureset(index2) = 1;
                    featuresets(end+1, :) = featureset;
                    featureset = copy3;
                end
                featureset = copy2;
            end
        end
    end
end

% pits don't play well with others
featureset = zeros(1, RR.nfeatures);
featureset(RR.features.pit) = 1;
featuresets(end+1, :) = featureset;

board_size = ceil(sqrt(size(featuresets, 1)));
pad = board_size^2 - size(featuresets, 1);
featuresets(end+1:end+pad, :) = zeros(pad, size(featuresets, 2));

assert(all(featuresets(:) == 0 | featuresets(:) == 1));
featuresets = logical(featuresets);

game = game_create(board_size, board_size, 0, 0);
tile_features = reshape(featuresets, [board_size board_size RR.nfeatures]);
for x = 1:board_size
    for y = 1:board_size
        game.board = board_enable_feature(game.board, [x, y], tile_features(x, y, :));
    end
end

initBoardFigure(game);
refreshBoard(game.board, game.state.robots, game.state.checkpoints);
tiles = {board_size*board_size};

saveas(BoardFigure,'generatedTiles','bmp');
I = imread('generatedTiles.bmp');
rows = sum(I,2)/size(I,2);
rows = find(rows-255);
rowmin = rows(1);
rowmax = rows(size(rows,1));
columns = sum(I,1)/size(I,1);
columns = find(columns-255);
columnmin = columns(1);
columnmax = columns(size(columns,2));
I = I(rowmin:rowmax,columnmin:columnmax);
axis equal
widthOneTile = size(I,2)/board_size;
heightOneTile = size(I,1)/board_size;
counter = 1;
for x = 1:board_size
    for y = 1:board_size
        rect=round([widthOneTile*(x-1)+1 heightOneTile*(y-1)+1 widthOneTile heightOneTile]);
        tiles{counter} = makeLogicalOfImage(imcrop(I,rect));
        counter = counter +1;
    end
end


