function [tiles,featuresets] = generate_tile_images()
global RR;

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

assert(all(featuresets(:) == 0 | featuresets(:) == 1));
featuresets = logical(featuresets);

tiles = cell(size(featuresets, 1), 1);

global BoardFigure;
for i = 1:size(featuresets, 1)
    featureset = featuresets(i, :);
    
    % make it three by three to have some tiles around it; when we distort
    % the image later this will introduce some additional realistic noise
    board_size = 3;
    game = game_create(board_size, board_size, 0, 0);

    game.board = board_enable_feature(game.board, [2 2], featureset);

    initBoardFigure(game);
    refreshBoard(game.board, game.state.robots, game.state.checkpoints);
    axes = get(BoardFigure, 'CurrentAxes');
    % make sure the tiles as displayed have the right width and height
    % and a comfortable offset so nothing is obscured by window chrome.
    board_size_px = board_size*(RR.tile_size+1); % +1 to include grid line
    set(axes, 'Units', 'pixels');
    set(axes, 'Position', [10 10 board_size_px board_size_px]);
    % if we don't refresh, matlab will capture whatever is *behind* where
    % the figure should be. zzz
    refresh(BoardFigure);
    
    % grab the image
    A = frame2im(getframe(axes));
    
    % the image contains the outer gridlines and is therefore too large by
    % one pixel in both dimensions.
    assert(all([size(A, 1) size(A, 2)] == board_size_px+1));

    close(BoardFigure);
    
    % extract the center tile without including grid lines
    offset = 1;
    % +1 for 1-based indexing, +1 for grid line, +1 for grid line
    a = 1+1+offset*(RR.tile_size+1);
    % -1 for halfopen interval
    b = a+RR.tile_size-1;
    
    % somehow, the presence of a conveyor belt changes the position and/or
    % scale of the whole image ever so slightly.
    if any(featureset(RR.features.conveyor_east:RR.features.conveyor_south))
        a = a - 1;
        b = b - 1;
    end
    
    tiles{i} = A(a:b, a:b, :);
end
