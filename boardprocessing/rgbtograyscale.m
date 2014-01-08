function [ grayimage_out] = rgbtograyscale( rgbimage_in )

grayimage_out=zeros(size(rgbimage_in,1),size(rgbimage_in,2));

grayimage_out(:,:)=0.2989*rgbimage_in(:,:,1)+ 0.5870*rgbimage_in(:,:,2) + 0.1140*rgbimage_in(:,:,3);
            

end


