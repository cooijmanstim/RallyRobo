function [ edge ] = edgeRecognize( curpos,curdir,backup,boardSize )
%this function return 1 if are on the edges 
edge=0;
if(backup == 0)
    if((curdir == 0) && (curpos(2)==boardSize))
        edge = 1;
    end
    
    if((curdir == 1) && (curpos(1)==1))
        edge = 1;
    end

    if((curdir == 2) && (curpos(2)==1))
        edge = 1;
    end
    
    if((curdir == 3) && (curpos(1)==boardSize))
        edge = 1;
    end
    
else
    %in case of backing up 
    if((curdir == 0) && (curpos(2)==1))
        edge = 1;
    end
    
    if((curdir == 1) && (curpos(1)==boardSize))
        edge = 1;
    end

    if((curdir == 2) && (curpos(2)==boardSize))
        edge = 1;
    end
    
    if((curdir == 3) && (curpos(1)==1))
        edge = 1;
    end
end

end

