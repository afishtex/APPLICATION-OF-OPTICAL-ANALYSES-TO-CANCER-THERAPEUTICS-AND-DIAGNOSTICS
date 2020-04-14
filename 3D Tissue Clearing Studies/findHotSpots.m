function [index,filteredHotSpots] = findHotSpots(boxNumTRITC,boxNumCy5,boxNumFITC,numTRITCCells,numCy5Cells,numFITCCells)
%UNTITLED2 Summary of this function goes here
%   change because each step is 9 pixels apart and so the connection will
%   be much larger than 1 step. maybe strel in the xy direction only?

    heatMap=floor(boxNumTRITC/numTRITCCells).*floor(boxNumCy5/numCy5Cells).*floor(boxNumFITC/numFITCCells);
    hotSpots = heatMap>0;
    dilStep = 100;
    se = strel('cuboid',[dilStep dilStep dilStep/10]); %1.5X step size allows for small gaps between positive overlapping regions, 
        % use this to extend the box to see if there is overlap between neighbors 
        % and consider them to be a single TLS
    dilatedHotSpots = imdilate(hotSpots,se);
    hotSpotProps = regionprops3(dilatedHotSpots);
    filteredHotSpots = hotSpotProps;
    j = 1;
    while j <= height(filteredHotSpots)
        if filteredHotSpots{j,1} < 200000 % 400000 because 200x200x100 um / 10um/step in the z direction 
            filteredHotSpots(j,:) = [];
            j = j-1;
        end
        j = j+1;
    end

    %% adjust edges of the bounding box so that the hot spot can be plotted
    index = length(filteredHotSpots.Volume);
    for i=1:index
        for j = 1:3
            if j < 3 
                filteredHotSpots.BoundingBox(i,j) = filteredHotSpots.BoundingBox(i,j)+dilStep/2;% shift the dilation from center to corner
                if 100-dilStep>0
                    filteredHotSpots.BoundingBox(i,j+3) = filteredHotSpots.BoundingBox(i,j+3)+(100-dilStep);% correct for smaller dilation sizes than counting box sizes
                end
                if filteredHotSpots.BoundingBox(i,j)+filteredHotSpots.BoundingBox(i,j+3)>size(boxNumTRITC,j)+95 %make sure it doesn't go out of bounds
                    filteredHotSpots.BoundingBox(i,j+3) = floor(size(boxNumTRITC,j)+95-filteredHotSpots.BoundingBox(i,j));
                end
            else
                filteredHotSpots.BoundingBox(i,j) = filteredHotSpots.BoundingBox(i,j)+dilStep/20;% shift the dilation from center to corner
                if 100-dilStep>0
                    filteredHotSpots.BoundingBox(i,j+3) = filteredHotSpots.BoundingBox(i,j+3)+((100-dilStep)/10);% correct for smaller dilation sizes than counting box sizes
                end
                if filteredHotSpots.BoundingBox(i,j)+filteredHotSpots.BoundingBox(i,j+3)>size(boxNumTRITC,j)+9 %make sure it doesn't go out of bounds
                    filteredHotSpots.BoundingBox(i,j+3) = floor(size(boxNumTRITC,j)+9-filteredHotSpots.BoundingBox(i,j));
                end
            end
        end
    end
end

