function [tiles,featuresets, gamestatesets] = generate_tile_images(n)
% n is sample size; generates a set of distorted images for each featureset
if nargin < 1
    n = 1;
end

global RR;

init();

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

tiles = cell(size(featuresets, 1), n);

%% for robot and checkpoint generation
gamestatesets = {};
counter = 1;
% 4 checkpoints
for i = 1: 4
    gamestate = [];
    gamestate.checkpoints = zeros(i, 2);
    gamestate.checkpoints(i,:) = [2,2];
    gamestate.robots.position = zeros(0, 2);
    gamestate.robots.direction = repmat(RR.directions.byname.east, [0 1]);
    gamestatesets{counter} = gamestate;
    counter = counter +1;
end

%robot in 4 directions
directions = fieldnames(RR.directions.byname);
for i = 1:  length(directions)
    gamestate = [];
    gamestate.checkpoints = zeros(0, 2);
    gamestate.robots.position = [2,2];
    gamestate.robots.direction = repmat(RR.directions.asrows(i,:), [1 1]);
    gamestatesets{counter} = gamestate;
    counter = counter +1;
end


%% make placeholders for gamestates/features
zerofeatureset = false(1, RR.nfeatures);
zerogamestate = [];
nrobots = 0;
ncheckpoints = 0;
zerogamestate.checkpoints = zeros(ncheckpoints, 2);
zerogamestate.robots.position = zeros(nrobots, 2);
zerogamestate.robots.direction = repmat(RR.directions.byname.east, [nrobots 1]);
%%
global BoardFigure;
for i = 1:size(featuresets, 1) + size(gamestatesets,2)
    if i <= size(featuresets, 1)
        featureset = featuresets(i, :);
        gamestate = zerogamestate;
    else
        featureset = zerofeatureset;
        gamestate = gamestatesets{i - size(featuresets, 1)};
    end
    
    % make it three by three to have some tiles around it; when we distort
    % the image later this will introduce some additional realistic noise
    board_size = 3;
    game = game_create(board_size, board_size, 0, 0);
    
    game.board = board_enable_feature(game.board, [2 2], featureset);
    
    initBoardFigure(game);
    refreshBoard(game.board, gamestate.robots, gamestate.checkpoints);
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
    
    if any(i == [3 5 7 9])
        %figure; image(A(a:b, a:b, :));
        i
    end
    
    % due to no identifiable cause, the image is sometimes shifted by three
    % pixels in a vertical direction. detect and adapt.
    d = weirdbrokenness(A, a, b);
    
    % include the clean tile in the sample
    tiles{i, 1} = A(a+d:b+d, a:b, :);
    
    for j = 2:n
        B = image_distort_slightly(A);
        tiles{i, j} = B(a+d:b+d, a:b, :);
    end
end

function [d] = weirdbrokenness(x, a, b)
d = 0;
if all(all(all(x(a:a+1, a:b, :) > 250))) && all(all(all(x(a+2, a:b, :) < 5)))
    d = +3;
elseif all(all(all(x(b-1:b, a:b, :) > 250))) && all(all(all(x(b-2, a:b, :) < 5)))
    d = -3;
end
