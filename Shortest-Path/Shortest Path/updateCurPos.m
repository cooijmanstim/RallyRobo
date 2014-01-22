function [ curpos, walkOfEdge ] = updateCurPos(curpos,direction,steps,tiles)
%UPDATECURPOS Summary of this function goes here
%update the current position by the number of steps
%note that this assumes going right and up is in the positive direction!
walkOfEdge = 0;
backup = 0;
boardsize = size(tiles,1);
passedFlag = 0;

if(steps == -1)
    backup = 1;
    steps = 1;
end

for i= 1:steps
       
    if(backup == 1)
        if(direction == 0)
            %checking if we would fall of an edge
            if(edgeRecognize(curpos,direction,backup,boardsize))
                walkOfEdge = 1;
                break;
            end
            
            %check if we would fall in a pit
            if(pitRecognize(curpos,direction,backup,tiles))
                walkOfEdge = 1;
                break;
            end

            %no edge or pit means being able to walk
            if~((tiles(curpos(1),curpos(2),3) == 1) || (tiles(curpos(1),curpos(2)-1,5) == 1))
            curpos(2) = curpos(2) - 1;
            end
        end
        
        if(direction == 1)
            if(edgeRecognize(curpos,direction,backup,boardsize))
                walkOfEdge = 1;
                break;
            end
            
            if(pitRecognize(curpos,direction,backup,tiles))
                walkOfEdge = 1;
                break;
            end
            
            if~((tiles(curpos(1),curpos(2),4) == 1) || (tiles(curpos(1)+1,curpos(2),6) == 1))
            curpos(1) = curpos(1) + 1;
            end
        end
        
        if(direction == 2)
            if(edgeRecognize(curpos,direction,backup,boardsize))
                walkOfEdge = 1;
                break;
            end
            
            if(pitRecognize(curpos,direction,backup,tiles))
                walkOfEdge = 1;
                break;
            end
            
            if~((tiles(curpos(1),curpos(2),5) == 1) || (tiles(curpos(1),curpos(2)+1,3) == 1))
            curpos(2) = curpos(2) + 1;
            end
        end
        
        if(direction == 3)
            if(edgeRecognize(curpos,direction,backup,boardsize))
                walkOfEdge = 1;
                break;
            end
                        
            if(pitRecognize(curpos,direction,backup,tiles))
                walkOfEdge = 1;
                break;
            end
            
            if~((tiles(curpos(1),curpos(2),6) == 1) || (tiles(curpos(1)-1,curpos(2),4) == 1))
            curpos(1) = curpos(1) - 1;
            end
        end      
    else
        if(direction == 0)
            %checking if we would fall of an edge
            if(edgeRecognize(curpos,direction,backup,boardsize))
                walkOfEdge = 1;
                break;
            end

            %checking if we walk in a pit
            if(pitRecognize(curpos,direction,backup,tiles))
                walkOfEdge = 1;
                break;
            end
            
            %no edge or pit means being able to walk
            if~((tiles(curpos(1),curpos(2),3) == 1) || (tiles(curpos(1),curpos(2)+1,5) == 1))
            curpos(2) = curpos(2) + 1;
            end
        end
        
        if(direction == 1)
            if(edgeRecognize(curpos,direction,backup,boardsize))
                walkOfEdge = 1;
                break;
            end
            
            if(pitRecognize(curpos,direction,backup,tiles))
                walkOfEdge = 1;
                break;
            end
            
            if~((tiles(curpos(1),curpos(2),4) == 1) || (tiles(curpos(1)-1,curpos(2),6) == 1))
            curpos(1) = curpos(1) - 1;
            end
            
        end
        
        if(direction == 2)
            if(edgeRecognize(curpos,direction,backup,boardsize))
                walkOfEdge = 1;
                break;
            end 
            
            if(pitRecognize(curpos,direction,backup,tiles))
                walkOfEdge = 1;
                break;
            end
            
            if~((tiles(curpos(1),curpos(2),5) == 1) || (tiles(curpos(1),curpos(2)-1,3) == 1))
            curpos(2) = curpos(2) - 1;
            end
        end
        
        if(direction == 3)
            if(edgeRecognize(curpos,direction,backup,boardsize))
                walkOfEdge = 1;
                break;
            end
               
            if(pitRecognize(curpos,direction,backup,tiles))
                walkOfEdge = 1;
                break;
            end
            
            if~((tiles(curpos(1),curpos(2),6) == 1) || (tiles(curpos(1)+1,curpos(2),4) == 1))
            curpos(1) = curpos(1) + 1;
            end
        end   
    end   
end
    
end

