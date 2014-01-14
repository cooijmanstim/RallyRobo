function [os] = generate_conveyor_images(rgbdata_east, height_east, width_east, directions)
grayscale_east = rgb2gray(rgbdata_east);
alphadata_east = ones(size(grayscale_east));
alphadata_east(grayscale_east > 0.9) = 0;

os = cell(size(directions));
for i = 1:length(directions)
    angle = direction_get_angle(directions(i));
    
    rgbdata = imrotate(rgbdata_east, 360*angle/2/pi);
    alphadata = imrotate(alphadata_east, 360*angle/2/pi);

    height = height_east;
    width = width_east;
    if mod(round(angle/2/pi*4), 2) == 1
        [width, height] = deal(height, width);
    end
    
    o = [];
    o.rgbdata = rgbdata;
    o.alphadata = alphadata;
    o.height = height;
    o.width = width;
    
    os{i} = o;
end
