function [ pit ] = pitRecognize( curpos,curdir,backup,tiles )
%this function return 1 if are on the edges 
pit=0;
    if(backup == 0)
        if((curdir == 0) && (tiles(curpos(1),curpos(2)+1,1) == 1))
            pit = 1;
        end

        if((curdir == 1) && (tiles(curpos(1)-1,curpos(2),1) == 1))
            pit = 1;
        end

        if((curdir == 2) && (tiles(curpos(1),curpos(2)-1,1) == 1))
            pit = 1;
        end

        if((curdir == 3) && (tiles(curpos(1)+1,curpos(2),1) == 1))
            pit = 1;
        end

    else
        %in case of backing up 
         if((curdir == 0) && (tiles(curpos(1),curpos(2)-1,1) == 1))
            pit = 1;
        end

        if((curdir == 1) && (tiles(curpos(1)+1,curpos(2),1) == 1))
            pit = 1;
        end

        if((curdir == 2) && (tiles(curpos(1),curpos(2)+1,1) == 1))
            pit = 1;
        end

        if((curdir == 3) && (tiles(curpos(1)-1,curpos(2),1) == 1))
            pit = 1;
        end
    end

end

