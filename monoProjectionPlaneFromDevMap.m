function projectedPlaneOutput = monoProjectionPlaneFromDevMap(InputNii, MipThickness, ProjectionPlane, StartSlice, EndSlice)

%InputNii.img = uint8(InputNii.img / max(InputNii.img(:)) * 256-1);

MatrixSize = size(InputNii.img);
%disp(MatrixSize);

% Set incrimination step to "1" or "-1" 
if EndSlice > StartSlice
    IncriminationStep = 1;
else
    IncriminationStep =-1;
end
        
% Define dimensions of output plane depending on if a lateral or an axial
% projection shall be calculated 

if strcmp(ProjectionPlane,'lateral')
    projectedPlaneOutput = zeros(MatrixSize(2),MatrixSize(3));
    lateral = true;
else
    projectedPlaneOutput = zeros(MatrixSize(1),MatrixSize(2));
    lateral = false;
end

% create maximum intensitiy projection for each voxel
for i=1:size(projectedPlaneOutput, 1)
    for j=1:size(projectedPlaneOutput, 2)
        
        
        clear VoxelValue;
        CountNotZero = 0;
        BrainFound = false;
        
        %Run through first half of image
        for SliceSelector = StartSlice:IncriminationStep:EndSlice
            
            if lateral == true;
                CurrentVoxel = InputNii.img(SliceSelector,i,j);
            else
                CurrentVoxel = InputNii.img(i,j, SliceSelector);
            end
            if CurrentVoxel < 0
                CurrentVoxel = 0;
            end
            
            % Eliminate negative Voxels, whereever they should come from...
            if CurrentVoxel > 0
                BrainFound = true;
            end
            if BrainFound == true
                CountNotZero = CountNotZero + 1;
            end
            if CountNotZero > MipThickness
                break
            end
            
            VoxelValue(SliceSelector) = CurrentVoxel;
            
            
        end
        
          
        projectedPlaneOutput(i,j) = max(VoxelValue);
               
    end
end
end