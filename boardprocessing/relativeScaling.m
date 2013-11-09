function [ im_out ] = relativeScaling( im,threshold )

im_out=zeros(size(im,1),size(im,2)); 

for i=2:size(im,1)-1
        for j=2:size(im,2)-1    
            if ((im(i,j+1)-im(i,j)) > threshold) || ((im(i,j-1)-im(i,j)) > threshold) || ((im(i+1,j)-im(i,j)) > threshold) || ((im(i-1,j+1)-im(i,j)) > threshold)
                im_out(i,j)=1;
            else
                im_out(i,j)=0;
            end
        end
end

end

