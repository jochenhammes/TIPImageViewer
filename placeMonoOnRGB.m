function outputImage = placeMonoOnRGB(baseImage, imageToPlace,x,y)
%   places an RGB image onto another RGB-image

xSize = size(imageToPlace,2);
ySize = size(imageToPlace,1);

outputImage = baseImage;

imageToPlace = imageToPlace/max(imageToPlace(:));

outputImage((1+y):(y+ySize),(1+x):(x+xSize),1) = imageToPlace(:,:);
outputImage((1+y):(y+ySize),(1+x):(x+xSize),2) = imageToPlace(:,:);
outputImage((1+y):(y+ySize),(1+x):(x+xSize),3) = imageToPlace(:,:);
end
