function [ grayimage_out] = rgbtograyscale( rgbimage_in )

grayimage_out=zeros(size(rgbimage_in,1),size(rgbimage_in,2));

for i=1:size(rgbimage_in,1)
        for j=1:size(rgbimage_in,2)
            w= rgbimage_in(i,j,:);
            grayimage_out(i,j)=0.2989*w(1)+ 0.5870*w(2) + 0.1140*w(3);
            

        end
end

end


