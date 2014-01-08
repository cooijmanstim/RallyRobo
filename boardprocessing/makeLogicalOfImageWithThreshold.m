function [ out ] = makeLogicalOfImageWithThreshold( I ,treshold)

out = zeros(size(I));
for x = 1:size(I,1)
    for y = 1:size(I,2)
        out(x,y)=(I(x,y)<treshold);
    end
end

end

