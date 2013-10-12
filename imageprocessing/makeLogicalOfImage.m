function [ I ] = makeLogicalOfImage( I )

makebw = @(I) im2bw(I.data,median(double(I.data(:)))/1.2/255);
I = ~blockproc(I,[92 92],makebw);
imshow(I);

I = bwareaopen(I,30);
I = imclearborder(I);

end

