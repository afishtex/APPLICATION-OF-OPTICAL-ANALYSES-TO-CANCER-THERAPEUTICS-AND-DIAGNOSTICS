function printExcel(sample, filename, boxDim,totalTRITCCells,totalCy5Cells,totalFITCCells,mmVolume,boxNumTRITC,boxNumCy5,boxNumFITC,centers3DTRITC,centers3DCy5,skelFITC, toPlot)
%UNTITLED Summary of this function goes here
%   FITC is divided by 10X more because it is a single line so each cell
%   with approx 10um diameter would have 10 pixels across it.

[index210, filteredHotSpots210] = findHotSpots(boxNumTRITC,boxNumCy5,boxNumFITC,2,10,50);

[index220, ~] = findHotSpots(boxNumTRITC,boxNumCy5,boxNumFITC,2,20,50);

[index230, ~] = findHotSpots(boxNumTRITC,boxNumCy5,boxNumFITC,2,30,50);

[index22, ~] = findHotSpots(boxNumTRITC,boxNumCy5,boxNumFITC,2,2,50);

[index25, ~] = findHotSpots(boxNumTRITC,boxNumCy5,boxNumFITC,2,5,50);

[index510, filteredHotSpots510] = findHotSpots(boxNumTRITC,boxNumCy5,boxNumFITC,5,10,50);

[index520, ~] = findHotSpots(boxNumTRITC,boxNumCy5,boxNumFITC,5,20,50);

[index530, ~] = findHotSpots(boxNumTRITC,boxNumCy5,boxNumFITC,5,30,50);

[index52, ~] = findHotSpots(boxNumTRITC,boxNumCy5,boxNumFITC,5,2,50);

[index55, ~] = findHotSpots(boxNumTRITC,boxNumCy5,boxNumFITC,5,5,50);

[index1010, ~] = findHotSpots(boxNumTRITC,boxNumCy5,boxNumFITC,10,10,50);

[index1020, filteredHotSpots1020] = findHotSpots(boxNumTRITC,boxNumCy5,boxNumFITC,10,20,50);

[index1030, ~] = findHotSpots(boxNumTRITC,boxNumCy5,boxNumFITC,10,30,50);

[index102, ~] = findHotSpots(boxNumTRITC,boxNumCy5,boxNumFITC,10,2,50);

[index105, ~] = findHotSpots(boxNumTRITC,boxNumCy5,boxNumFITC,10,5,50);

totalNumCells = sum([totalTRITCCells,totalCy5Cells,totalFITCCells]);


hotSpotTRITCCells210 = zeros(1,height(filteredHotSpots210));
hotSpotCy5Cells210 = zeros(1,height(filteredHotSpots210));
hotSpotFITCCells210 = zeros(1,height(filteredHotSpots210));
for n = 1:height(filteredHotSpots210)
    if toPlot
        h = figure;
    end
    hotSpotTRITCCells210(n) = plotHotSpot(filteredHotSpots210(n,:), centers3DTRITC, 'r', 0, toPlot);
    hotSpotCy5Cells210(n) = plotHotSpot(filteredHotSpots210(n,:), centers3DCy5, 'm', 0, toPlot);
    hotSpotFITCCells210(n) = plotHotSpot(filteredHotSpots210(n,:), skelFITC, 'g', 10, toPlot);
    if toPlot
        pause;
        close(h);
    end
end

hotSpotTRITCCells510 = zeros(1,height(filteredHotSpots510));
hotSpotCy5Cells510 = zeros(1,height(filteredHotSpots510));
hotSpotFITCCells510 = zeros(1,height(filteredHotSpots510));
for n = 1:height(filteredHotSpots510)
    if toPlot
        h = figure;
    end
    hotSpotTRITCCells510(n) = plotHotSpot(filteredHotSpots510(n,:), centers3DTRITC, 'r', 0, toPlot);
    hotSpotCy5Cells510(n) = plotHotSpot(filteredHotSpots510(n,:), centers3DCy5, 'm', 0, toPlot);
    hotSpotFITCCells510(n) = plotHotSpot(filteredHotSpots510(n,:), skelFITC, 'g', 10, toPlot);
    if toPlot
        pause;
        close(h);
    end
end

hotSpotTRITCCells1020 = zeros(1,height(filteredHotSpots1020));
hotSpotCy5Cells1020 = zeros(1,height(filteredHotSpots1020));
hotSpotFITCCells1020 = zeros(1,height(filteredHotSpots1020));
for n = 1:height(filteredHotSpots1020)
    if toPlot
        h = figure;
    end
    hotSpotTRITCCells1020(n) = plotHotSpot(filteredHotSpots1020(n,:), centers3DTRITC, 'r', 0, toPlot);
    hotSpotCy5Cells1020(n) = plotHotSpot(filteredHotSpots1020(n,:), centers3DCy5, 'm', 0, toPlot);
    hotSpotFITCCells1020(n) = plotHotSpot(filteredHotSpots1020(n,:), skelFITC, 'g', 10, toPlot);
    if toPlot
        pause;
        close(h);
    end
end


exl = {'Volume (mm^3)' 'Total Cells' 'Immune Cell Concentration (Cells/mm^3)' 'Total TRITC Cells' 'TRITC Cell Concentration (Cells/mm^3)' 'Total Cy5 Cells' 'Cy5 Cell Concentration (Cells/mm^3)' 'Total FITC Cells' 'FITC Cell Concentration (Cells/mm^3)' '' '' ''};
exl(2,:) = {mmVolume totalNumCells totalNumCells/mmVolume totalTRITCCells totalTRITCCells/mmVolume totalCy5Cells totalCy5Cells/mmVolume totalFITCCells totalFITCCells/mmVolume '' '' ''};
exl(3,:) = {'' '' '' '' '' '' '' '' '' '' '' ''};
exl(4,:) = {'Number of Cells of Each Type in Box' '' 'Populated TRITC Boxes' 'Populated Cy5 Boxes' 'Populated FITC Boxes' 'Box Dimensions' '' '' '' 'Hot Spots' '' ''};
exl(5,:) = {2 'FITC25' length(find(floor(boxNumTRITC/2)>0)) length(find(floor(boxNumCy5/2)>0)) length(find(floor(boxNumFITC/25)>0)) [num2str(boxDim(1)) 'x' num2str(boxDim(2)) 'x' num2str(boxDim(3))] '' '' '' '' 'B Cells' ''};
exl(6,:) = {5 '' length(find(floor(boxNumTRITC/5)>0)) length(find(floor(boxNumCy5/5)>0)) length(find(floor(boxNumFITC/50)>0)) '' '' '' '' '2' '5' '10'};
exl(7,:) = {10 '' length(find(floor(boxNumTRITC/10)>0)) length(find(floor(boxNumCy5/10)>0)) length(find(floor(boxNumFITC/100)>0)) '' '' '' '2' index22 index52 index102};
exl(8,:) = {20 '' length(find(floor(boxNumTRITC/20)>0)) length(find(floor(boxNumCy5/20)>0)) length(find(floor(boxNumFITC/200)>0)) '' '' '' '5' index25 index55 index105};
exl(9,:) = {30 '' length(find(floor(boxNumTRITC/30)>0)) length(find(floor(boxNumCy5/30)>0)) length(find(floor(boxNumFITC/300)>0)) '' '' 'T Cells' '10' index210 index510 index1010};
exl(10,:) = {40 '' length(find(floor(boxNumTRITC/40)>0)) length(find(floor(boxNumCy5/40)>0)) length(find(floor(boxNumFITC/400)>0)) '' '' '' '20' index220 index520 index1020};
exl(11,:) = {50 '' length(find(floor(boxNumTRITC/50)>0)) length(find(floor(boxNumCy5/50)>0)) length(find(floor(boxNumFITC/500)>0)) '' '' '' '30' index230 index530 index1030};
exl(12,:) = {'' '' '' '' '' '' '' '' '' '' '' ''};
exl(13,:) = {'' '' '/mm^3' '' '' '' '' '' '' '' '' ''};
exl(14,:) = {'Number of Cells of Each Type in Box' 'Hot Spots' 'Populated TRITC Boxes' 'Populated Cy5 Boxes' 'Populated FITC Boxes' '' '' '' '' 'Hot Spots/mm^3' '' ''};
exl(15,:) = {2 'FITC25' length(find(floor(boxNumTRITC/2)>0))/mmVolume length(find(floor(boxNumCy5/2)>0))/mmVolume length(find(floor(boxNumFITC/25)>0))/mmVolume '' '' '' '' '' 'B Cells' ''};
exl(16,:) = {5 '' length(find(floor(boxNumTRITC/5)>0))/mmVolume length(find(floor(boxNumCy5/5)>0))/mmVolume length(find(floor(boxNumFITC/50)>0))/mmVolume '' '' '' '' '2' '5' '10'};
exl(17,:) = {10 '' length(find(floor(boxNumTRITC/10)>0))/mmVolume length(find(floor(boxNumCy5/10)>0))/mmVolume length(find(floor(boxNumFITC/100)>0))/mmVolume '' '' '' '2' index22/mmVolume index52/mmVolume index102/mmVolume};
exl(18,:) = {20 '' length(find(floor(boxNumTRITC/20)>0))/mmVolume length(find(floor(boxNumCy5/20)>0))/mmVolume length(find(floor(boxNumFITC/200)>0))/mmVolume '' '' '' '5' index25/mmVolume index55/mmVolume index105/mmVolume};
exl(19,:) = {30 '' length(find(floor(boxNumTRITC/30)>0))/mmVolume length(find(floor(boxNumCy5/30)>0))/mmVolume length(find(floor(boxNumFITC/300)>0))/mmVolume '' '' 'T Cells' '10' index210/mmVolume index510/mmVolume index1010/mmVolume};
exl(20,:) = {40 '' length(find(floor(boxNumTRITC/40)>0))/mmVolume length(find(floor(boxNumCy5/40)>0))/mmVolume length(find(floor(boxNumFITC/400)>0))/mmVolume '' '' '' '20' index220/mmVolume index520/mmVolume index1020/mmVolume};
exl(21,:) = {50 '' length(find(floor(boxNumTRITC/50)>0))/mmVolume length(find(floor(boxNumCy5/50)>0))/mmVolume length(find(floor(boxNumFITC/500)>0))/mmVolume '' '' '' '30' index230/mmVolume index530/mmVolume index1030/mmVolume};
exl(22,:) = {'' '' '' '' '' '' '' '' '' '' '' ''};
exl(23,:) = {'210 Volumes' '210 TRITC' '210 Cy5' '210 FITC' '510 Volumes' '510 TRITC' '510 Cy5' '510 FITC' '1020 Volumes' '1020 TRITC' '1020 Cy5' '1020 FITC'};
% looking at the volumes of these TLS
for i = 1:max([index210 index1020 index510])
    if i<=min([index210 index1020 index510])
        exl(23+i,:) = {filteredHotSpots210{i,1} hotSpotTRITCCells210(i) hotSpotCy5Cells210(i) hotSpotFITCCells210(i) filteredHotSpots510{i,1} hotSpotTRITCCells510(i) hotSpotCy5Cells510(i) hotSpotFITCCells510(i) filteredHotSpots1020{i,1} hotSpotTRITCCells1020(i) hotSpotCy5Cells1020(i) hotSpotFITCCells1020(i)};
    elseif i<=index210 && i<=index510
        exl(23+i,:) = {filteredHotSpots210{i,1} hotSpotTRITCCells210(i) hotSpotCy5Cells210(i) hotSpotFITCCells210(i) filteredHotSpots510{i,1} hotSpotTRITCCells510(i) hotSpotCy5Cells510(i) hotSpotFITCCells510(i) '' '' '' ''};
    elseif i<=index210 && i<=index1020
        exl(23+i,:) = {filteredHotSpots210{i,1} hotSpotTRITCCells210(i) hotSpotCy5Cells210(i) hotSpotFITCCells210(i) '' '' '' '' filteredHotSpots1020{i,1} hotSpotTRITCCells1020(i) hotSpotCy5Cells1020(i) hotSpotFITCCells1020(i)};
    elseif i<=index510 && i<=index1020
        exl(23+i,:) = { '' '' '' '' filteredHotSpots510{i,1} hotSpotTRITCCells510(i) hotSpotCy5Cells510(i) hotSpotFITCCells510(i) filteredHotSpots1020{i,1} hotSpotTRITCCells1020(i) hotSpotCy5Cells1020(i) hotSpotFITCCells1020(i)};
    elseif i<=index210
        exl(23+i,:) = {filteredHotSpots210{i,1} hotSpotTRITCCells210(i) hotSpotCy5Cells210(i) hotSpotFITCCells210(i) '' '' '' '' '' '' '' ''};
    elseif i<=index510
        exl(23+i,:) = {'' '' '' '' filteredHotSpots510{i,1} hotSpotTRITCCells510(i) hotSpotCy5Cells510(i) hotSpotFITCCells510(i) '' '' '' ''};
    elseif i<=index1020
        exl(23+i,:) = {'' '' '' '' '' '' '' '' filteredHotSpots1020{i,1} hotSpotTRITCCells1020(i) hotSpotCy5Cells1020(i) hotSpotFITCCells1020(i)};
    end
end

xlswrite(filename, exl, sample);
end

