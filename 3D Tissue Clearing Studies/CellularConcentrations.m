sample = ['C.1A'; '1.1A'; '1.2A'; '3.1A'; '3.2A'; '4.1A'; '4.1B'; '4.2A'; '4.2B'; '4.3B'];
volume = zeros(length(sample(:,1)),1);
concDAPI = zeros(length(sample(:,1)),1);
concTRITC = zeros(length(sample(:,1)),1);
concCy5 = zeros(length(sample(:,1)),1);
concFITC = zeros(length(sample(:,1)),1);
possibleTLS = zeros(length(sample(:,1)),1);
filepath = 'C:\Users\Afishtex\Documents\Postgraduate\HMRI\Clearing TLS\3D Imaging\';
savepath = [filepath 'Analysis\'];
cellDiameterPxl = 24;
toPlot = 0;
for i = 1:length(sample(:,1))
    filename = [sample(i,:) ' filtered'];
    file = [savepath sample(i,:) '\' filename];
    savefile =[savepath sample(i,:) '\' sample(i,1) '-' sample(i,3:end) ' filtered'];
    [~, ~, ~, ~, voxel_size, imageSpecs] =...
        loadTifImages(file, cellDiameterPxl, savefile);
    load([savefile ' centers3DDAPI.mat']);
    load([savefile ' centers3DTRITC.mat']);
    load([savefile ' centers3DCy5.mat']);
    load([savefile ' skelFITC.mat']);
    [volume(i),~] = estVolume(centers3DDAPI+centers3DTRITC+centers3DCy5+skelFITC,voxel_size);

    %% Plot cells in 3D
    marker_size = 0;
    h = waitbar(0, 'Loading DAPI Cells...');
    [marker_size, totalDAPICells] = plot3DCenters(centers3DDAPI, imageSpecs, voxel_size, cellDiameterPxl, marker_size, toPlot, 'b');
    waitbar(0.25, h, 'Loading TRITC Cells...');
    [marker_size, totalTRITCCells] = plot3DCenters(centers3DTRITC, imageSpecs, voxel_size, cellDiameterPxl, marker_size, toPlot, 'r');
    waitbar(0.5, h, 'Loading Cy5 Cells...');
    [marker_size, totalCy5Cells] = plot3DCenters(centers3DCy5, imageSpecs, voxel_size, cellDiameterPxl, marker_size, toPlot, 'm');
    waitbar(0.75, h, 'Loading FITC Vessels...');
    plotVessels(skelFITC, imageSpecs, voxel_size, toPlot);
    close(h);
    hold off;
    concDAPI(i) = totalDAPICells/volume(i);
    concTRITC(i) = totalTRITCCells/volume(i);
    concCy5(i) = totalCy5Cells/volume(i);
    concFITC(i) = sum(sum(sum(skelFITC)))/volume(i);
    
    %load([savefile ' boxNumDAPI.mat']);
    load([savefile ' boxNumTRITC.mat']);
    load([savefile ' boxNumCy5.mat']);
    load([savefile ' boxNumFITC.mat']);
    hotSpots=floor(boxNumTRITC/100).*floor(boxNumCy5/100).*floor(boxNumFITC/100);
    index = find(hotSpots>0);
    possibleTLS(i) = length(index);
end
T1 = table(sample, concDAPI, concTRITC, concCy5, concFITC, volume, possibleTLS);
savefile = [savepath 'Concentration Comparison.xlsx'];
writetable(T1,savefile,'Sheet',1)

group = ['C'; '1'; '3'; '4'];
averageDAPI = [mean(concDAPI(1)); mean(concDAPI(2:3)); mean(concDAPI(4:5)); mean(concDAPI(6:end))];
averageTRITC = [mean(concTRITC(1)); mean(concTRITC(2:3)); mean(concTRITC(4:5)); mean(concTRITC(6:end))];
averageCy5 = [mean(concCy5(1)); mean(concCy5(2:3)); mean(concCy5(4:5)); mean(concCy5(6:end))];
averageFITC = [mean(concFITC(1)); mean(concFITC(2:3)); mean(concFITC(4:5)); mean(concFITC(6:end))];
averageVolume = [mean(volume(1)); mean(volume(2:3)); mean(volume(4:5)); mean(volume(6:end))];
T2 = table(group, averageDAPI, averageTRITC, averageCy5, averageFITC, averageVolume);
writetable(T2,savefile,'Sheet',2);