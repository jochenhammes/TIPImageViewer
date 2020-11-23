function [OutputRGB] = overlaySlices(pathToInputNii, pathToDicom)
%% Environment

%Test

pathToInputNii = 'inputImages/BET_zDev_automatedCGN_SRTM2_BPnd_image.nii';
pathMNI_T1 = 'TemplateImages/ch2_79x75x78.nii';
pathToDicom = '/DATA/hammesj/PI2620_KinMod/Gripp/10000000/10000001/10000002/10001533';

MipThickness = 5;

%Load  Nii-File
InputNii = load_nii(pathToInputNii);
MNI_T1 = load_nii(pathMNI_T1);

maxVoxelValue = max(InputNii.img(:));
upperThreshholdSlices = maxVoxelValue/2;
lowerThreshholdSlices = maxVoxelValue/8;

MatrixSize = size(InputNii.img);
EvenMatrixSize = MatrixSize+mod(MatrixSize,2);


ySize=500;
xSize=455;

yRow(1) = 10; % Offset of Top Part of Output RGB
yRow(2)  = 20; % Offset of Middle Part of Output RGB
yRow(3)  = 100;% Offset of Lower Part of Output RGB <-- Slices go here

xOffsetColorBar = 410;

textColor = [1 1 1];

outputScalingFactor = 3;

NewRGB = zeros(ySize,xSize,3);
%NewRGB(:,:,3) = 1;


%% Prepare colormap/LUT
myMap = jet(256);
newPartMap=zeros(33,3);
newPartMap(:,3) = 0:0.0156:0.5;
myMap=vertcat(newPartMap,myMap);

myMap(1:2,:)=0;
%myMap((end-2):end,:)=1;


%% Creation and placement of RGB-Slices

for i=1:15
    %imshow(NewRGB)
    %pause(0.5)
    
    verticalOffset = 0;
    horizontalOffset = 10+100*(i-1);
    if (i>4 & i<9)
        verticalOffset = 100;
        horizontalOffset = 10+100*((i-4)-1);
    end
    if (i>8 & i<13)
        verticalOffset = 200;
        horizontalOffset = 10+100*((i-8)-1);
    end
    if i>12
        verticalOffset = 300;
        horizontalOffset = 10+100*((i-12)-1);
    end
    CurrentSliceMono = monoProjectionPlaneFromDevMap(InputNii,10,'axial',5*(i-1)+1,5*i);
    CurrentSliceRGB = RGBFromMonoPlane(CurrentSliceMono, myMap, upperThreshholdSlices);

    %Place T1-MRI    
    CurrentSliceMNI_T1 = monoProjectionPlaneFromDevMap(MNI_T1,10,'axial',5*i-1,5*i);
    NewRGB = placeMonoOnRGB(NewRGB, fliplr(imrotate(CurrentSliceMNI_T1, 90)), horizontalOffset,yRow(3)+verticalOffset); 
    
    %Place Z-Map with transparency Map
    transparencyMap = fliplr(imrotate((CurrentSliceMono > lowerThreshholdSlices),90));
    NewRGB = placeRGBImage(NewRGB, fliplr(imrotate(CurrentSliceRGB, 90)), horizontalOffset,yRow(3)+verticalOffset, transparencyMap); 
    

end


%% Color Bars

ColorBar = RGBFromMonoPlane(repmat((256:-2:1)',1,10), myMap);
%NewRGB = placeRGBImage(NewRGB, ColorBar, xOffsetColorBar,yRow(1));
%NewRGB = placeRGBImage(NewRGB, ColorBar, xOffsetColorBar,yRow(2));
NewRGB = placeRGBImage(NewRGB, ColorBar, xOffsetColorBar,yRow(3));


%% Resize image

NewRGB = imresize(NewRGB,outputScalingFactor);
%imshow(NewRGB);

%save image to file
imwrite(NewRGB, 'slices.png');

%% Read DICOM header
dicomHeader = dicominfo(pathToDicom);

patientData.Name = [dicomHeader.PatientName.FamilyName ', ' dicomHeader.PatientName.GivenName];
patientData.DoB = [dicomHeader.PatientBirthDate(7:8) '.' dicomHeader.PatientBirthDate(5:6) '.' dicomHeader.PatientBirthDate(1:4)]
patientData.StudyDate = [dicomHeader.StudyDate(7:8) '.' dicomHeader.StudyDate(5:6) '.' dicomHeader.StudyDate(1:4)]


%% Write text to image via external CLI tool

textDelim = '''';
%disp(textDelim);

%Draw title to image
systemCommandToDrawText = ['convert -pointsize 50 -fill white -draw "text 20,60 ' ...
    textDelim 'PI2620 Tau-PET Analysis' textDelim ...
    ' " slices.png newslices.png'];
system(systemCommandToDrawText)

systemCommandToDrawText = ['convert -pointsize 35 -fill white -draw "text 20,100 ' ...
    textDelim 'Z-transformed deviations of non displaceable binding from controls' textDelim ...
    ' " newslices.png newslices.png'];
system(systemCommandToDrawText)


%Draw annotations to LUT
systemCommandToDrawText = ['convert -pointsize 35 -fill white -draw "text ' ...
    num2str(xOffsetColorBar * outputScalingFactor) ...
    ',' num2str(yRow(3) * outputScalingFactor - 20) ' ' ...
    textDelim 'Z' textDelim ...
    ' " newslices.png newslices.png'];
system(systemCommandToDrawText)


systemCommandToDrawText = ['convert -pointsize 35 -fill white -draw "text ' ...
    num2str(xOffsetColorBar * outputScalingFactor + 40) ...
    ',' num2str(yRow(3) * outputScalingFactor + 40) ' ' ...
    textDelim num2str(upperThreshholdSlices, '%2.1f') textDelim ...
    ' " newslices.png newslices.png'];
system(systemCommandToDrawText)


systemCommandToDrawText = ['convert -pointsize 35 -fill white -draw "text ' ...
    num2str(xOffsetColorBar * outputScalingFactor + 40) ...
    ',' num2str(yRow(3) * outputScalingFactor + 350) ' ' ...
    textDelim num2str(lowerThreshholdSlices, '%2.1f') textDelim ...
    ' " newslices.png newslices.png'];
system(systemCommandToDrawText)





%Draw patient data to image
systemCommandToDrawText = ['convert -pointsize 35 -fill white -draw "text 20,160 ' ...
    textDelim 'Patient: ' patientData.Name ' , *' patientData.DoB textDelim ...
    ' " newslices.png newslices.png'];
system(systemCommandToDrawText)

systemCommandToDrawText = ['convert -pointsize 35 -fill white -draw "text 20,200 ' ...
    textDelim 'Study Date: ' patientData.StudyDate textDelim ...
    ' " newslices.png newslices.png'];
system(systemCommandToDrawText)




%% return result bitmap
OutputRGB = NewRGB;


end