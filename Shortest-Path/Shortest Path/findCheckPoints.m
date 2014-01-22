function [ vector ] = findCheckPoints( tiles )
vector = [];
for i = 13:16
   [r c] = find(tiles(:,:,i)) ;
   vector = [vector; r c];
end
end

