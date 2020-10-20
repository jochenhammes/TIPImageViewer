function outputImage = placeRGBImage(baseImage, imageToPlace,x,y, transparencyMap)
%   places an RGB image onto another RGB-image


xSize = size(imageToPlace,2);
ySize = size(imageToPlace,1);
outputImage = baseImage;

if exist('transparencyMap','var')
    for i = 1:ySize
        for j = 1:xSize
            if transparencyMap(i,j) > 0
                outputImage(i+y,j+x,:) = imageToPlace(i,j,:);
            end
        end
    end
    
else    
    outputImage((1+y):(y+ySize),(1+x):(x+xSize),:) = imageToPlace(:,:,:);
end;


end
