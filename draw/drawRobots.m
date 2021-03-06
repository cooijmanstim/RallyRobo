function [  ] = drawRobots(robots)
hold on;
resize = 0.1;
for i = 1:robots.size()
    robot = robots.get(i-1);
    if robot.is_visible()
        yx = double(robot.position);
        y = yx(1); x = yx(2);
        angle = direction_get_angle(robot.direction.ordinal());
        file = strcat('images/PL_',num2str(i),'.JPG');
        image = imread(file);
        rotated = imrotate(image,radtodeg(angle));
        xs = [x+resize,x+1-resize];
        ys = [y+resize,y+1-resize];
        imagesc(xs,fliplr(ys),rotated);
    end
end
  
   
end

