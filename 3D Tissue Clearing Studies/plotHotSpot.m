function tlsNumCells = plotHotSpot(filteredHotSpot, centers3D, color, markerSize, toPlot)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    box = [filteredHotSpot.BoundingBox];
    tlsNumCells = sum(sum(sum(centers3D(floor(box(2)):ceil(box(2))+ceil(box(5)), floor(box(1)):ceil(box(1))+ceil(box(4)), floor(box(3)):ceil(box(3))+ceil(box(6))))));
    if toPlot

        frameWidth = length(centers3D(1,:,1));
        frameLength = length(centers3D(:,1,1));

        centerIndex = find(centers3D==1);
        totalNumCells = length(centerIndex);
        centerX = zeros(totalNumCells,1);
        centerY = zeros(totalNumCells,1);
        centerZ = zeros(totalNumCells,1);
        centerZpxl = zeros(totalNumCells,1);


        for m = 1:totalNumCells
            centerZpxl(m) = ceil(centerIndex(m)/(frameWidth*frameLength));
            centerX(m) = ceil((centerIndex(m)-(centerZpxl(m)-1)*frameWidth*frameLength)/frameLength);
            centerY(m) = centerIndex(m)-(centerZpxl(m)-1)*frameWidth*frameLength-(centerX(m)-1)*frameLength;
            centerZ(m) = centerZpxl(m)*10; %goes from plane number, to um, to pixels
        end

        cubeMaxSide = max([box(4) box(5) box(6)*10]);
        xlim([floor(box(1)) floor(box(1))+cubeMaxSide+1]);
        ylim([floor(box(2)) floor(box(2))+cubeMaxSide+1]);
        zlim([floor(box(3))*10 floor(box(3))*10+cubeMaxSide+1]);
        if markerSize == 0
            ax = gca;
            AR = get(gca, 'dataaspectratio');
            if ~isequal(AR(1:3), [1 1 1])
              error('Units are not equal on X, Y, and Z, cannot create marker size that is one unit on both');
            end
            oldunits = get(ax, 'Units');
            set(ax, 'Units', 'points');
            pos = get(ax, 'Position');    %[X Y Z width height depth]
            set(ax, 'Units', oldunits');
            XL = xlim(ax);
            points_per_unit = pos(3) / (XL(2) - XL(1));
            markerSize = (points_per_unit*10) .^2 * pi / 4;
        end
        scatter3(centerX, centerY, centerZ, markerSize, 'filled',...
            'MarkerEdgeColor','k', 'MarkerFaceColor', color);

        xlim([floor(box(1)) floor(box(1))+cubeMaxSide+1]);
        ylim([floor(box(2)) floor(box(2))+cubeMaxSide+1]);
        zlim([floor(box(3))*10 floor(box(3))*10+cubeMaxSide+1]);
        xlabel('X (\mum)');   
        ylabel('Y (\mum)');
        zlabel('Z (\mum)');

        volume = filteredHotSpot.Volume;
        title(['TLS Volume: ' num2str(volume) '\mum^3'])
        hold on;
    end
end

