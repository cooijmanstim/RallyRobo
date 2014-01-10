function [ game ] = createDataStructure( tiles )

game.state.checkpoints = [];
game.state.robots.position = [];
game.state.robots.direction = [];
game.state.robots.direction = [];
game.features = [];
%could even seperate features and checkpoints since they only have to be processed once
 game.features.pit = [];
 game.features.repair = [];
 game.features.wall_east = [];
 game.features.wall_north = [];
 game.features.wall_west = [];
 game.features.wall_south = [];
 game.features.conveyor_east = [];
 game.features.conveyor_north = [];
 game.features.conveyor_west = [];
 game.features.conveyor_south = [];
 game.features.conveyor_turning_clockwise = [];
 game.features.conveyor_turning_counterclockwise = [];
 
 
for k = 1:size(tiles,3)
    for j = 1:size(tiles,2)
        for i = 1:size(tiles,1)
            
            if(tiles(i,j,k)==1 && k ==1)
                game.features.pit = [game.features.pit; i j];
            end
            if(tiles(i,j,k)==1 && k ==2)
                game.features.repair = [game.features.repair; i j];
            end
            if(tiles(i,j,k)==1 && k ==3)
                game.features.wall_east = [game.features.wall_east; i j];
            end
            if(tiles(i,j,k)==1 && k ==4)
                game.features.wall_north = [game.features.wall_north; i j];
            end
            if(tiles(i,j,k)==1 && k ==5)
                game.features.wall_west = [game.features.wall_west; i j];
            end
            if(tiles(i,j,k)==1 && k ==6)
                game.features.wall_south = [game.features.wall_south; i j];
            end
            if(tiles(i,j,k)==1 && k ==7)
                game.features.conveyor_east = [game.features.conveyor_east; i j];
            end
            if(tiles(i,j,k)==1 && k ==8)
                game.features.conveyor_north = [game.features.conveyor_north; i j];
            end
            if(tiles(i,j,k)==1 && k ==9)
                game.features.conveyor_west = [game.features.conveyor_west; i j];
            end
            if(tiles(i,j,k)==1 && k ==10)
                game.features.conveyor_south = [game.features.conveyor_south; i j];
            end
            if(tiles(i,j,k)==1 && k ==11)
                game.features.conveyor_turning_clockwise = [game.features.conveyor_turning_clockwise; i j];
            end
            if(tiles(i,j,k)==1 && k ==12)
                game.features.conveyor_turning_counterclockwise = [game.features.conveyor_turning_counterclockwise; i j];
            end
            if(tiles(i,j,k)==1 && k ==13)
                game.state.checkpoints = [game.state.checkpoints; i j];
            end
            if(tiles(i,j,k)==1 && k ==14)
                game.state.checkpoints = [game.state.checkpoints; i j];
            end
            if(tiles(i,j,k)==1 && k ==15)
                game.state.checkpoints = [game.state.checkpoints; i j];
            end
            if(tiles(i,j,k)==1 && k ==16)
                game.state.checkpoints = [game.state.checkpoints; i j];
            end
            
            %17-20 represent 1st robot facing respectively right up left down
            %21-24 represent 2nd robot facing respectively right up left down
            %25-28 represent 3rd robot facing respectively right up left down
            %29-32 represent 4th robot facing respectively right up left down
            
            %robot 1 right
            if(tiles(i,j,k)==1 && k ==17)
                game.state.robots.position = [game.state.robots.position; i j];
                game.state.robots.direction = [game.state.robots.direction; 0];
            end
            %up
            if(tiles(i,j,k)==1 && k ==18)
                game.state.robots.position = [game.state.robots.position; i j];
                game.state.robots.direction = [game.state.robots.direction; 1];
            end
            %left
            if(tiles(i,j,k)==1 && k ==19)
                game.state.robots.position = [game.state.robots.position; i j];
                game.state.robots.direction = [game.state.robots.direction; 2];
            end
            %down
            if(tiles(i,j,k)==1 && k ==20)
                game.state.robots.position = [game.state.robots.position; i j];
                game.state.robots.direction = [game.state.robots.direction; 3];
            end
            
            %robot 2 right
            if(tiles(i,j,k)==1 && k ==21)
                game.state.robots.position = [game.state.robots.position; i j];
                game.state.robots.direction = [game.state.robots.direction; 0];
            end
            %up
            if(tiles(i,j,k)==1 && k ==22)
                game.state.robots.position = [game.state.robots.position; i j];
                game.state.robots.direction = [game.state.robots.direction; 1];
            end
            %left
            if(tiles(i,j,k)==1 && k ==23)
                game.state.robots.position = [game.state.robots.position; i j];
                game.state.robots.direction = [game.state.robots.direction; 2];
            end
            %down
            if(tiles(i,j,k)==1 && k ==24)
                game.state.robots.position = [game.state.robots.position; i j];
                game.state.robots.direction = [game.state.robots.direction; 3];
            end
            
            %robot 3 right
            if(tiles(i,j,k)==1 && k ==25)
                game.state.robots.position = [game.state.robots.position; i j];
                game.state.robots.direction = [game.state.robots.direction; 0];
            end
            %up
            if(tiles(i,j,k)==1 && k ==26)
                game.state.robots.position = [game.state.robots.position; i j];
                game.state.robots.direction = [game.state.robots.direction; 1];
            end
            %left
            if(tiles(i,j,k)==1 && k ==27)
                game.state.robots.position = [game.state.robots.position; i j];
                game.state.robots.direction = [game.state.robots.direction; 2];
            end
            %down
            if(tiles(i,j,k)==1 && k ==28)
                game.state.robots.position = [game.state.robots.position; i j];
                game.state.robots.direction = [game.state.robots.direction; 3];
            end
            
            %robot 4 right
            if(tiles(i,j,k)==1 && k ==29)
                game.state.robots.position = [game.state.robots.position; i j];
                game.state.robots.direction = [game.state.robots.direction; 0];
            end
            %up
            if(tiles(i,j,k)==1 && k ==30)
                game.state.robots.position = [game.state.robots.position; i j];
                game.state.robots.direction = [game.state.robots.direction; 1];
            end
            %left
            if(tiles(i,j,k)==1 && k ==31)
                game.state.robots.position = [game.state.robots.position; i j];
                game.state.robots.direction = [game.state.robots.direction; 2];
            end
            %down
            if(tiles(i,j,k)==1 && k ==32)
                game.state.robots.position = [game.state.robots.position; i j];
                game.state.robots.direction = [game.state.robots.direction; 3];
            end  
            
        end
    end
end



end

