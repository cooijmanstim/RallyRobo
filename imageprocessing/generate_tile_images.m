function [tiles,featuresets, gamestates] = generate_tile_images(n)
% n is sample size; positivity implies that distorted images should be
% generated
if nargin < 1
    n = -1;
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

%% for robot and checkpoint generation
gamestates = cell(0, 1);
% 4 checkpoints
for i = 1: 4
    gamestate = [];
    gamestate.checkpoints = zeros(i, 2);
    gamestate.checkpoints(i,:) = [2,2];
    gamestate.robots.position = zeros(0, 2);
    gamestate.robots.direction = repmat(RR.directions.byname.east, [0 1]);
    gamestates{end+1, :} = gamestate;
end

%robot in 4 directions
for i = 1:size(RR.directions.asrows, 1)
    gamestate = [];
    gamestate.checkpoints = zeros(0, 2);
    gamestate.robots.position = [2,2];
    gamestate.robots.direction = repmat(RR.directions.asrows(i, :), [1 1]);
    gamestates{end+1, :} = gamestate;
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

tiles = cell(size(featuresets, 1) + size(gamestates, 1), 1+max(0, n));

for i = 1:size(featuresets, 1)
    tiles(i, :) = render_tile(featuresets(i, :), zerogamestate, n);
end
for i = 1:size(gamestates, 1)
    tiles(size(featuresets, 1) + i, :) = render_tile(zerofeatureset, gamestates{i}, n);
end
