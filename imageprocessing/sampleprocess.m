%% Read In a File
I_cam = imread('Unbenannt.png');
imshow(I_cam);

I = I_cam;
boardsizeX = 12;
boardsizeY = 12;
% %% Crop the Image (1) 
% hold on
% x = 550;
% h_g = plot(175+[0 x x 0 0],80+[0 0 x x 0],'g');
% hold off
% 
% %% Crop the Image (2) 
% 
% I = I_cam(80+(1:x),175+(1:x));
% imshow(I);

%% Convert to Black and White 
makebw = @(I) im2bw(I.data,median(double(I.data(:)))/1.2/255);
I = ~blockproc(I,[size(I,1),size(I,2)],makebw);

imshow(I);

%% Remove Noise 
I = bwareaopen(I,30);
imshow(I);
%% Clear the border
I = imclearborder(I);
imshow(I);

%% Find the largest box 
hold on;
R = regionprops(I,'Area','BoundingBox','PixelList');
NR = numel(R);

maxArea = 0;
for x = 1:NR
    A(x) = prod(R(x).BoundingBox(3:4));
    if R(x).Area > maxArea
        maxArea = R(x).Area;
        kmax = x;
    end
end


BBmax = R(kmax).BoundingBox;
DIAG1 = sum(R(kmax).PixelList,2);
DIAG2 = diff(R(kmax).PixelList,[],2);

[m,dUL] = min(DIAG1);    [m,dDR] = max(DIAG1);
[m,dDL] = min(DIAG2);    [m,dUR] = max(DIAG2);

pts = R(kmax).PixelList([dUL dDL dDR dUR dUL],:);
h_pts = plot(pts(:,1),pts(:,2),'m','linewidth',3);

XYLIMS = [BBmax(1) + [0 BBmax(3)] BBmax(2) + [0 BBmax(4)]];

%% Identify tiles inside the box 


%corners of tiles
Tiles = zeros(boardsizeX,boardsizeY,2);
widthOneTile = BBmax(3)/boardsizeX;
heightOneTile = BBmax(4)/boardsizeY;
for x = 1:boardsizeX
    for y = 1:boardsizeY
        Tiles(x,y,:) = [BBmax(1)+(x-1)*BBmax(3) BBmax(2)+(y-1)*BBmax(4)];
    end
end



%% Draw the grid based on the corners

T = cp2tform(pts(1:4,:),0.5 + [0 0; boardsize 0; boardsize boardsize; 0 boardsize],'projective');
for n = 0.5 + 0:boardsize, [x,y] = tforminv(T,[n n],[0.5 boardsize+0.5]); plot(x,y,'g'); end
for n = 0.5 + 0:boardsize, [x,y] = tforminv(T,[0.5 boardsize+0.5],[n n]); plot(x,y,'g'); end
%% Only keep elements in the boxes 
T = cp2tform(pts(1:4,:),[0.5 0.5; boardsize+0.5 0.5; boardsize+0.5 boardsize+0.5; 0.5 boardsize+0.5],'projective');
Plocal = (tformfwd(T,Tiles));
Plocal = round(2*Plocal)/2;

del = find(sum(Plocal - floor(Plocal) > 0 |  Plocal < 1 | Plocal > boardsize,2)) ;
Tiles(del,:) = [];

delete(nonzeros(h_digitcircles(del)));

%% Show the coordinate transforms 
figure;
T = cp2tform(pts(1:4,:),500*[0 0; 1 0; 1 1; 0 1],'projective');
IT = imtransform(double(I),T);
imshow(IT);
%% Show the template data 
% figure;
% 
% for n = 1:9
%     subplot(3,3,n),imagesc(NT{n});
% end
% colormap gray;
%% Calculate the Solution


Plocal = identifynumbers_fun(pts,Tiles,NT,I);
M = zeros(9);
for x = 1:boardsize(Plocal,1)
    M(Plocal(x,2),Plocal(x,1)) = Plocal(x,3);
end
M_sol = drawgraph(M);

