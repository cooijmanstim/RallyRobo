function [newpos, newdir, walkOfEdge] = updateConveyer( curpos,curdir,tiles )

newpos = curpos;
newdir = curdir;
walkOfEdge = 0;

        
        %conveyer east
        if(tiles(curpos(1),curpos(2),7) == 1)
            [newpos, walkOfEdge] = updateCurPos(curpos,0,1,tiles);           
        end
        %conveyer north
        if(tiles(curpos(1),curpos(2),8) == 1)
            [newpos, walkOfEdge] = updateCurPos(curpos,1,1,tiles);          
        end
        %conveyer west
        if(tiles(curpos(1),curpos(2),9) == 1)
            [newpos, walkOfEdge] = updateCurPos(curpos,2,1,tiles);          
        end
        %conveyer south
        if(tiles(curpos(1),curpos(2),10) == 1)
            [newpos, walkOfEdge] = updateCurPos(curpos,3,1,tiles);             
        end
        
        %conveyer turning clockwise
        if(tiles(newpos(1),newpos(2),11) == 1)
            newdir = mod((newdir - 1),4) ;    
        end
        %conveyer turning counterclockwise
        if(tiles(newpos(1),newpos(2),12) == 1)
            newdir = mod((newdir + 1),4) ;
        end
        
        curpos = newpos;
        
        if(walkOfEdge == 1);
            return;
        end        

end

