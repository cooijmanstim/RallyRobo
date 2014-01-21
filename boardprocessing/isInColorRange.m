function [ isInRange ] = isInColorRange( rgbSample,rgbRequired )
isInRange = true;
range = 10;
for i = 1:3
   if rgbSample(i)<rgbRequired(i)-range |rgbSample(i)> rgbRequired(i)+range 
    isInRange = false;
   end
end


end

