function [ evalList ] = calculatepath(candidatePath,curdir,curpos,goalFlag,checkpointPositions,tiles)
%CALCULATEPATH calculates every end position, given the
%current position (curpos) and the possible paths the robot can take from
%there (allpaths). to evaluate how good the end position is we also need to
%know where the objective is (flagpos). lastly we need to know the current
%direction the robot is facing (curdir)
allEndpos = [];



for i = 1: size(candidatePath,1)
    newdir = curdir;
    newpos = curpos;
    fallOff = 0;
    lastVisitedFlag = goalFlag;
    if(lastVisitedFlag < length(checkpointPositions))
        flagpos = checkpointPositions(lastVisitedFlag+1,:);
    end
    checkpointReachedScore = 0;
    
    for j = 1 : size(candidatePath,2)
        
        if(candidatePath(i,j)==1)
            %move 3 in current direction
            [newpos, fallOff] = updateCurPos(newpos,newdir,3,tiles);
        end
        if(candidatePath(i,j)==2)
            %move 2 in current direction
            [newpos, fallOff] = updateCurPos(newpos,newdir,2,tiles);
        end
        if(candidatePath(i,j)==3)
            %move 1 in current direction
            [newpos, fallOff] = updateCurPos(newpos,newdir,1,tiles);
        end
        if(candidatePath(i,j)==4)
            [newpos, fallOff] = updateCurPos(newpos,newdir,-1,tiles);
        end
        if(candidatePath(i,j)==5)
            newdir = mod((newdir - 1),4) ;
        end
        if(candidatePath(i,j)==6)
            newdir = mod((newdir + 1),4) ;
        end
        if(candidatePath(i,j)==7)
            newdir = mod((newdir + 2),4) ;
        end     
        
        
        if(fallOff == 1)
            break;
        end
        
        conveyer = 0;
        %check if we ended up on a conveyer
        %conveyer turning clockwise
        if(tiles(newpos(1),newpos(2),11) == 1)
            conveyer = 1;
        end
        %conveyer turning counterclockwise
        if(tiles(newpos(1),newpos(2),12) == 1)
            conveyer = 1;
        end
        %conveyer east
        if(tiles(newpos(1),newpos(2),7) == 1)
            conveyer = 1;
        end
        %conveyer north
        if(tiles(newpos(1),newpos(2),8) == 1)
            conveyer = 1;
        end
        %conveyer west
        if(tiles(newpos(1),newpos(2),9) == 1)
            conveyer = 1;
        end
        %conveyer south
        if(tiles(newpos(1),newpos(2),10) == 1)
            conveyer = 1;
        end
        if(conveyer == 1)
            [newpos, newdir, fallOff] = updateConveyer(newpos,newdir,tiles);
            
        end
        
        if(curpos==flagpos)            
            checkpointReachedScore = checkpointReachedScore + 100;
            
            if(lastVisitedFlag < length(checkpointPositions))
            flagpos = checkpointPositions(lastVisitedFlag+1);
            else
                S=sprintf('#Winning');
                disp(S);
            end
        end
        
        if(fallOff == 1)
            break;
        end
    end

    if(fallOff == 1)
       %do not store anything
    else         
    %store all the endpositions with their directions in endpos
        allEndpos = [allEndpos; candidatePath(i,:) newpos newdir checkpointReachedScore];       
    end  
    
end
    evalList = evaluate(allEndpos, flagpos); 
    
end

