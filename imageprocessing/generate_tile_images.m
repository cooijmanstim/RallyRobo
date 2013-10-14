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
gamestates = [];
% 4 checkpoints
for i = 1: 4
    gamestates(end+1).checkpointid = i;
end

%robot in 4 directions
for direction = RR.directions.asrows'
    gamestates(end+1).robotdir = direction';
end

% make the shape similar to that of featuresets
gamestates = gamestates';

zerofeatureset = false(1, RR.nfeatures);

tiles = cell(size(featuresets, 1) + size(gamestates, 1), 1+max(0, n));
for i = 1:size(featuresets, 1)
    tiles(i, :) = render_tile(featuresets(i, :), [], [], [], n);
end
for i = 1:size(gamestates, 1)
    tiles(size(featuresets, 1) + i, :) = render_tile(zerofeatureset, 1, gamestates(i).robotdir, gamestates(i).checkpointid, n);
end
