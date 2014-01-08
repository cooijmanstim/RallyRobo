function [ I ] = makeLogicalOfImage( I )

makebw = @(I) im2bw(I.data,median(double(I.data(:)))/1.2/255);
I = ~blockproc(I,[128 128],makebw);

end

