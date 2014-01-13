function [  ] = drawRobots(robots)
colors = {'black','blue','red','green'};
hold on;
resize = 0.2;
for i = 1:robots.size()
    robot = robots.get(i-1);
    yx = double(robot.position);
    y = yx(1); x = yx(2);
    angle = direction_get_angle(robot.direction.ordinal());
    % TODO: transparancy, flip vertically
    file = strcat('images/',colors{i},'.png');
    image = imread(file);
    rotated = imrotate(image,radtodeg(angle));
    imagesc([x+resize,x+1-resize],[y+resize,y+1-resize],rotated);
end
  
   
end

