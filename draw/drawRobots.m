function [  ] = drawRobots(robots)
colors = {'black','blue','red','green'};
hold on;
resize = 0.2;
for i = 1:length(robots)
    y = robots(i).position(1);
    x = robots(i).position(2);
    % TODO: transparancy, flip vertically
    file = strcat('images/',colors{i},'.png');
    image = imread(file);
    rotated = imrotate(image,radtodeg(direction_get_angle(robots(i).direction)));
    imagesc([x+resize,x+1-resize],[y+resize,y+1-resize],rotated);
end
  
   
end

