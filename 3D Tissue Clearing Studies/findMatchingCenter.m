function [loopNum, anotherOne, planecenters] =...
    findMatchingCenter(planecenters,i,j,loopNum,below,cellDiameterPxl,numPlanes)
%findMatchingCenter Summary of this function goes here
%   Detailed explanation goes here
    n=0;
    anotherOne = 0;
    if i-loopNum > 0 && ~isempty(planecenters{1,i}) && ~isempty(planecenters{1,i-loopNum})
        for k = 1:length(planecenters{:,i-loopNum}(:,1)) %loop through the centerpoints in the k-th plane
            if pdist([planecenters{1,i}(j,:); planecenters{1,i-loopNum}(k,:)]) < cellDiameterPxl/4
                anotherOne=1;
                n=k;
            end
        end
        if anotherOne == 1
            below = below + anotherOne;
            currentLoop = loopNum;
            loopNum=loopNum+1;
            [loopNum,~,planecenters] =...
                findMatchingCenter(planecenters,i,j,loopNum,below,cellDiameterPxl,numPlanes);
        end
        if loopNum > numPlanes && anotherOne %once we find more than numPlanes points that connect to a single xy point, we delete all future points to prevent multiple counts of the same cell
            planecenters{1,i-currentLoop}(n,:) = [];
        end
    end
        
end

