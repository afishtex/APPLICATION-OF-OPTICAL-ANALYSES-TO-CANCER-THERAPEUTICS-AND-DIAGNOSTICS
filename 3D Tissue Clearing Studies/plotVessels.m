function plotVessels(skelFITC,imageSpecs,toPlot)
%plotVessels Summary of this function goes here
%   Detailed explanation goes here
    frameWidth = imageSpecs(1);
    frameLength = imageSpecs(2);
%     se = strel('sphere',2);
%     dilatedSkel = imdilate(skelFITC,se);
    vesselIndex = find(skelFITC==1);
    numCells = length(vesselIndex);
    for m = 1:numCells
        vesselZ(m) = ceil(vesselIndex(m)/(frameWidth*frameLength));
        vesselX(m) = ceil((vesselIndex(m)-(vesselZ(m)-1)*frameWidth*frameLength)/frameLength);
        vesselY(m) = vesselIndex(m)-(vesselZ(m)-1)*frameWidth*frameLength-(vesselX(m)-1)*frameLength;
        vesselZ(m) = vesselZ(m)*10; %goes from plane number, to um, to pixels
    end
    if toPlot
        plot3(vesselY,vesselX,vesselZ,'.','Color','g'); %row,col,z
    end
end

