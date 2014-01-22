% The cards in Roborally are numbered 1 to 84 (times 10):
% 1) Move 3 (6 cards)               79...84	
% 2) Move 2 (12)                    67...78
% 3) Move 1 (18)                    49...66
% 4) Back up (6)                    43...48 
% 5) Rotate clockwise (18)          8...42, even numbers
% 6) Rotate counterclockwise (18)   7...41, odd numbers
% 7) U-turn (6)                     1...6


%function [playCards] = algorithm(v,userposition, flagposition, currentdirection,allowedCards, tiles)
%playCards = the cards we want to play + the ending pos + ending direction
%+ distance to checkpoint

function [realCards] = algorithm(playerColor,v,checkpointVector,lockedCardsArray,dataStructure,allPlayersPosAndDir)
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

%ticID was used to measure computational times
%ticID = tic;

%testing purposes: for drawing random cards
%v = randperm(84,lockedCardsArray(6))

%robotID's: red = 1
%           green = 2
%           blue = 3
%           black = 4
%           pink = 5
if(strcmp(playerColor, 'red'))
    robotID = 1;
end
if(strcmp(playerColor, 'green'))
    robotID = 2;
end
if(strcmp(playerColor, 'blue'))
    robotID = 3;
end
if(strcmp(playerColor, 'black'))
    robotID = 4;
end
if(strcmp(playerColor, 'pink'))
    robotID = 5;
end

%the next flag to visit
ObjectiveFlag = checkpointVector(robotID);

%using the backupfunction to determine the board and where the players are
%its stored in 2 different ways, game is a structure, tiles is a 3D matrix
[game, tiles] = Backupfunction(dataStructure,allPlayersPosAndDir);

%finding the position of all checkpoints
%later on also used to determine how many checkpoints there are
checkpointPositions = findCheckPoints(tiles);

%finding the position of our own robot with its direction
[userposition, currentdirection] = findposition(tiles,robotID);

if(lockedCardsArray(6) > 5)
    allowedCards = 5; %numberOfCards(robotID,6);
else
    allowedCards = lockedCardsArray(robotID,6);
end

%converting the numbers of the cards to their respective categorie: i.e. 
%move 3 is categorie 1 so every card with a number between 79 and 84 is a 1
combination = convertCards(v);

%constructs all possible paths,
%allowedCards is the number of cards were allowed to play
if(lockedCardsArray(robotID,6)<5)
    allpaths = nchoosek(combination,lockedCardsArray(robotID,6));
else
    allpaths = nchoosek(combination,5);
end

%calculating all the permutations for the non-locked cards
allperms = [];
for i = 1:size(allpaths,1)
    allperms = [allperms; perms(allpaths(i,:))];
end

%if there are locked cards we put them at the end of every possible
%permutations so they are played
lockedCardsOriginal = [];
if(lockedCardsArray(robotID,6)<5)
    lockedCards= [];
    for j = (lockedCardsArray(robotID,6)+1):5
        lockedCardsOriginal = [lockedCardsOriginal, lockedCardsArray(robotID,j)];
        lockedCards = convertCards(lockedCardsOriginal);
    end
    for i = 1:size(allperms,1)
        tempMatrix(i,:) = [allperms(i,:) lockedCards];
    end   
    allperms = tempMatrix;
end


%removing multiple occurences of paths so we dont check the same path twice
if(lockedCardsArray(robotID,6)>3)
allperms = unique(allperms,'rows');
end

%calculating the value of each path, how far it gets us
goodPaths = calculatepath(allperms,currentdirection, userposition, ObjectiveFlag, checkpointPositions,tiles );

%in the very unlikely case that every path drives us off the board or in a
%pit, the goodPaths array will be empty. To prevent an error we will just
%play cards at random.
if(isempty(goodPaths))
    goodPaths = allperms((randi(size(allperms),1)),:);
end

%sorting the array on best paths first and then taking the highest out
sortedPaths = sortrows(goodPaths, [-9 10]);
sortedPaths(1,1:(length(sortedPaths(1,:))));
playCards = sortedPaths(1,1:(length(sortedPaths(1,:))));

%converting the path back to the cards we originaly obtained
realCards = [];

if(lockedCardsArray(robotID,6)<5)
    t=lockedCardsArray(robotID,6);
else 
    t=5;
end
    for i = 1:t
        if(playCards(i) == 1)
            trueNumber = max(v(find(v >=79 & v <=84)));
            realCards = [realCards trueNumber];
            v = v(v~=trueNumber);
            v = [v 85];
        end
        if(playCards(i) == 2)
            trueNumber = max(v(find(v >=67 & v <=78)));
            realCards = [realCards trueNumber];
            v = v(v~=trueNumber);
            v = [v 85];
        end
        if(playCards(i) == 3)
            trueNumber = max(v(find(v >=49 & v <=66)));
            realCards = [realCards trueNumber];
            v = v(v~=trueNumber);
            v = [v 85];
        end
        if(playCards(i) == 4)
            trueNumber = max(v(find(v >=43 & v <=48)));
            realCards = [realCards trueNumber];
            v = v(v~=trueNumber);
            v = [v 85];
        end
        if(playCards(i) == 5 || playCards(i)== 6 )
            if(playCards(i) == 5)            
                tempCards=v(find(mod(v,2)==0));
            else
                tempCards=v(find(mod(v,2)==1));
            end
            trueNumber = max(tempCards(find(tempCards >=7 & tempCards <=42)));
            realCards = [realCards trueNumber];
            v = v(v~=trueNumber);
            v = [v 85];
        end
        if(playCards(i) == 7)
            trueNumber = max(v(find(v >=1 & v <=6)));
            realCards = [realCards trueNumber];
            v = v(v~=trueNumber);
            v = [v 85];
        end
    end
    
    if~(isempty(lockedCardsOriginal))
        realCards = [realCards lockedCardsOriginal];
    end
    
    %ticID was used for measuring computational time
    %ticID = toc(ticID);
end


