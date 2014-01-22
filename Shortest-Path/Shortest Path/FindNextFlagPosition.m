function [ flagposition ] = FindNextFlagPosition( tiles,flag )
if(flag == 3)
    flag = flag -1;
    [flagposition(1), flagposition(2)] = find(tiles(:,:,(flag+13)));
else
    [flagposition(1), flagposition(2)] = find(tiles(:,:,(flag+13)));
end

