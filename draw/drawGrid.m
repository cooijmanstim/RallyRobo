function [  ] = drawGrid( m,n )
%replaces old drawing
rectX = [1,m+1,m+1,1];
rectY = [1,1,n+1,n+1];
fill(rectX,rectY,'white');
% draws the Grid
for x = 1:m+1  % vertical lines
    line([x,x],[1,m+1],'color','black');
end

for y = 1:n+1   % horizontal lines
    line([1,n+1],[y,y],'color','black','LineWidth',1.5);
end


end

