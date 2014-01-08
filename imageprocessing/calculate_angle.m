function [ alpha ] = calculate_angle( c )

dx=abs(c(2,1)-c(4,1));
dy=abs(c(2,2)-c(4,2));
alpha=atand(dy/dx);

end

