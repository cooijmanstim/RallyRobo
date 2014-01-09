function [ts] = render_tile(featureset, robotid, robotdir, checkpointid, n, postprocessfn)
% renders a tile with given featureset and gamestate, returning the
% rendered tile if n is not passed or returning n distorted samples if it
% is.
% has the side-effect of opening and closing a figure window. :/
% TODO: replace gamestate by more specialized parameters
if ~exist('postprocessfn', 'var')
    postprocessfn = @identity;
end

if isempty(n)
    n = -1;
end

global RR BoardFigure;

ts = cell(1, n);

% make it three by three to have some tiles around it; when we distort
% the image later this will introduce some additional realistic noise
board_size = 3;

game = game_create();
game.board = board_create(board_size, board_size);
game.board = board_enable_feature(game.board, [2 2], featureset);
if ~isempty(robotid) && ~isempty(robotdir)
    game.robots(robotid).position = [2 2];
    game.robots(robotid).direction = robotdir;
end
if ~isempty(checkpointid)
    game.checkpoints(checkpointid, :) = [2 2];
end

initBoardFigure(game);
refreshBoard(game.board, game.robots, game.checkpoints);
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

% due to no identifiable cause, the image is sometimes shifted by three
% pixels in a vertical direction. detect and adapt.
d = weirdbrokenness(A, a, b);

if n < 1
    ts{1} = postprocessfn(A(a+d:b+d, a:b, :));
else
    for j = 1:n
        B = image_distort_slightly(A);
        ts{1, j} = postprocessfn(B(a+d:b+d, a:b, :));
    end
end

close(BoardFigure);

function [d] = weirdbrokenness(x, a, b)
d = 0;
if all(all(all(x(a:a+1, a:b, :) > 250))) && all(all(all(x(a+2, a:b, :) < 5)))
    d = +3;
elseif all(all(all(x(b-1:b, a:b, :) > 250))) && all(all(all(x(b-2, a:b, :) < 5)))
    d = -3;
end
