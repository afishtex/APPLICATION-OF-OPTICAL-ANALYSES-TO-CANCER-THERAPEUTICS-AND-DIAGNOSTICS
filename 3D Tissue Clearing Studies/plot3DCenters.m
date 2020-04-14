function [marker_size, numCells] =...
    plot3DCenters(centers3D, imageSpecs, cellDiameterPxl,...
    marker_size, toPlot, color)
%plot3DCenters Summary of this function goes here
%   Detailed explanation goes here

    frameWidth = imageSpecs(1);
    frameLength = imageSpecs(2);
    centerIndex = find(centers3D==1);
    numCells = length(centerIndex);
    centerX = zeros(numCells,1);
    centerY = zeros(numCells,1);
    centerZ = zeros(numCells,1);


    for m = 1:numCells
        centerZ(m) = ceil(centerIndex(m)/(frameWidth*frameLength));
        centerX(m) = ceil((centerIndex(m)-(centerZ(m)-1)*frameWidth*frameLength)/frameLength);
        centerY(m) = centerIndex(m)-(centerZ(m)-1)*frameWidth*frameLength-(centerX(m)-1)*frameLength;
        centerZ(m) = centerZ(m)*10; %goes from plane number, to um. 10 um per plane step
    end
    if marker_size == 0 && toPlot
        figure;
        xlim([0 2000]);
        ylim([0 2000]);
        zlim([0 2000]);

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
        marker_size = (points_per_unit*cellDiameterPxl) .^2 * pi / 4;
    end
    if toPlot
        scatter3(centerX, centerY, centerZ, marker_size, 'filled',...
            'MarkerEdgeColor','k', 'MarkerFaceColor', color);
            xlabel('X (\mum)');   
            ylabel('Y (\mum)');
            zlabel('Z (\mum)');
            xlim([0 2000]);
            ylim([0 2000]);
            zlim([0 2000]);
        hold on;
    end
end

