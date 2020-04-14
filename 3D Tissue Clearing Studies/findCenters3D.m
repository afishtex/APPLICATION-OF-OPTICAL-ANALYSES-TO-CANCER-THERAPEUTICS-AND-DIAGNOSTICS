function centers3D = findCenters3D(imageSpecs,planecenters,cellDiameterPxl,numPlanes)
%findCenters3D Finds cells that are at least numPlanes in depth
%   and no longer than numPlanes+1 in depth

    frameWidth = imageSpecs(1);
    frameLength = imageSpecs(2);
    planes = imageSpecs(3);
    centers3D = false(frameWidth, frameLength, planes);
    for i = planes:-1:2 %loop through the planes
        j = 1;
        if ~isempty(planecenters{:,i})
            while j <= length(planecenters{:,i}(:,1)) %loop through the center points in the i-th plane
                loopNum = 1;
                below = 0;
                [loopNum, below, planecenters] = ...
                    findMatchingCenter(planecenters,i,j,loopNum,below,cellDiameterPxl,numPlanes);
                if loopNum < numPlanes+1 && below
                    centers3D(planecenters{1,i}(j,1),planecenters{1,i}(j,2),i) = 1; %create a binary matrix of center points in 3D space
                end
                j = j+1;
            end
        end
    end

end

