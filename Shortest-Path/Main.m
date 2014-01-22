close all ; clear all;
% picture here
pictureFromFile = 'enter picture name';
[picture, map]= imread(pictureFromFile);

%initialize game
gridSize = 12;
game = RallyRobo.Game(gridSize, gridSize);
for i = 1:4
    game.board.add_checkpoint([0 0]);
    game.add_robot([1 1], RallyRobo.Direction.East);
end

% identify board
game = getGameFromImage(picture,game);

%showing the processed image
figure;
initBoardFigure(game);
refreshBoard(game);

%check to see if the image detection worked
%datastructure is provided by the tutors for the backupfunction
%allPlayersPosAndDir is provided by the tutors for the backupfunction
[datastructureFromImage, playerposFromImage] = backupfunction_inverse(game);
if(datastructure == datastructureFromImage)
    disp('Board correctly recognized');
end
if(allPlayersPosAndDir == playerposFromImage)
    disp('players positions and directions correctly recognized');
end

%the shortest path algorithm
%the algorithm uses the data provided by the tutors
[cards] = algorithm(playerColor,v,checkpointVector,lockedCardsArray,datastructure,allPlayersPosAndDir)
%playerColor = the color of the player we control, its translated to the
%robotID later on
%v = input vector with the cards we draw
%checkpointVector = used to determine the last visited checkpoint of all
%the robots
%lockedCardsArray = The array with lockedCards if there are any, as well as
%providing us the number of cards we obtain
%datastructure = The datastructure of the board, in case the image
%recognition fails.
%allPlayersPosandDir = the players position and direction, if robots are
%virtual, they have a minus sign infront of them