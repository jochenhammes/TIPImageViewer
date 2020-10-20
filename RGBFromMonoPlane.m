function [ RGBPlane ] = RGBFromMonoPlane( monoPlane, colorMap, cutOff, contourOverlay)
%Creates RGBImage from MonoImage

%contourOverlay: Dateiname der Contourdate, die mitangezeigt werden soll.
%cutOff:  Z-Wert, der als oberes Limit der color-LUT angzeigt werden soll.
%cutOffMax: Maximaler Z-Wert-Threshold, der im Output-File vorkommt.

%% Thresholding, wenn cutOff und cutOffMax angegeben sind.

if exist('cutOff','var') && ~isempty(cutOff)
    monoPlane(monoPlane>cutOff) = cutOff;
    %disp(max(monoPlane(:)));
    %monoPlane = monoPlane/cutOffMax*cutOff;
    monoPlane = monoPlane/cutOff;
    %disp(max(monoPlane(:)));
    %monoPlane = monoPlane/max(monoPlane(:));
    
end;

if ~exist('contourOverlay','var')
    contourOverlay = '';
end;


%monoPlane = monoPlane / max(monoPlane(:));


monoPlane(1,1)=1;
monoPlane(1,2)=0;
monoPlane(monoPlane==0)=0.02;

RGBPlane = grs2rgb(monoPlane, colorMap);

if ~strcmp(contourOverlay, '')

    imgContour = imread(contourOverlay);

    for i = 1:size(imgContour, 1)
        for j = 1:size(imgContour, 2)
            if imgContour(i,j) > 0
                RGBPlane(i,j,:) = 1;
            end
        end
    end
    
end




end
