function tertiaryLymphoidStructure(sample,toPlot)
    version = 'v2';
    filepath = 'C:\Users\Andrew\Documents\Clearing TLS\';
    loadpath = [filepath 'tifs\Raw\'];
    savepath = [filepath version '\Analysis\' sample '\'];
    if ~exist(savepath, 'dir')
      mkdir(savepath);
    end
    filename = [sample];
    file = [loadpath filename];
    savefile =[savepath sample(1) '-' sample(3:end) ' filtered'];
    cellDiameterPxl = 12;
    zStep = 10; %microns between images
    numPlanes = 2; %number of conseplanes that are required to consider a cell to be a cell

    %% Load planes
    [planecentersDAPI, binaryFITC, planecentersTRITC, planecentersCy5,...
        voxel_size, imageSpecs, mmVolume, tumorMask] =...
        loadTifImages(file, cellDiameterPxl, savefile, zStep);
    boxDim = [ceil(100/voxel_size(1)),ceil(100/voxel_size(1)),10]; %[100 um X 100 um X 100 um]

    %% Find areas that are likely cells
    if ~exist([savefile ' centers3DDAPI.mat'],'file') || ~exist([savefile...
            ' centers3DTRITC.mat'],'file') || ~exist([savefile...
            ' centers3DCy5.mat'],'file') || ~exist([savefile...
            ' skelFITC.mat'],'file')

        h = waitbar(0, [sample ': Finding DAPI Cells...']);
        centers3DDAPI = findCenters3D(imageSpecs, planecentersDAPI,...
            cellDiameterPxl, numPlanes);

        waitbar(0.25, h, [sample ': Finding TRITC Cells...']);
        centers3DTRITC = findCenters3D(imageSpecs, planecentersTRITC,...
            cellDiameterPxl, numPlanes);

        waitbar(0.5, h, [sample ': Finding Cy5 Cells...']);
        centers3DCy5 = findCenters3D(imageSpecs, planecentersCy5,...
            cellDiameterPxl, numPlanes);

        centers3DDAPI(~tumorMask)=false;
        centers3DTRITC(~tumorMask)=false;
        centers3DCy5(~tumorMask)=false;
        binaryFITC(~tumorMask)=false;

        waitbar(0.75, h, [sample ': Skeletonizing FITC Vessels...']);
        dirtySkelFITC = bwskel(binaryFITC);
        cleanedSkelFITC = bwmorph3(dirtySkelFITC, 'clean');
        skelFITC = cleanedSkelFITC;

        skelprops = regionprops3(skelFITC,'Volume','VoxelIdxList');
        for i = 1:height(skelprops)
            if skelprops.Volume(i) > 500 || skelprops.Volume(i) < 10 %not any smaller than a single cell or any larger than a string of 50 cells
                skelFITC(skelprops.VoxelIdxList{i})=false;
            end
        end
        
        save([savefile ' centers3DDAPI.mat'],'centers3DDAPI');
        save([savefile ' centers3DTRITC.mat'],'centers3DTRITC');
        save([savefile ' centers3DCy5.mat'],'centers3DCy5');
        save([savefile ' skelFITC.mat'],'skelFITC');
        close(h);
    else
        load([savefile ' centers3DDAPI.mat']);
        load([savefile ' centers3DTRITC.mat']);
        load([savefile ' centers3DCy5.mat']);
        load([savefile ' skelFITC.mat']);
    end

    clear planecentersDAPI binaryFITC planecentersTRITC planecentersCy5 tumorMask;

    %% Plot cells in 3D
    marker_size = 0;
    h = waitbar(0, [sample ': Plotting DAPI Cells...']);
    [marker_size, totalDAPICells] = plot3DCenters(centers3DDAPI, imageSpecs,...
        cellDiameterPxl, marker_size, toPlot, 'b');
    waitbar(0.25, h, [sample ': Plotting TRITC Cells...']);
    [marker_size, totalTRITCCells] = plot3DCenters(centers3DTRITC, imageSpecs,...
        cellDiameterPxl, marker_size, toPlot, 'r');
    waitbar(0.5, h, [sample ': Plotting Cy5 Cells...']);
    [marker_size, totalCy5Cells] = plot3DCenters(centers3DCy5, imageSpecs,...
        cellDiameterPxl, marker_size, toPlot, 'm');
    waitbar(0.75, h, [sample ': Plotting FITC Vessels...']);
    plotVessels(skelFITC, imageSpecs, toPlot);
    close(h);
    % hold off;
    concDAPI = totalDAPICells/mmVolume;
    concTRITC = totalTRITCCells/mmVolume;
    concCy5 = totalCy5Cells/mmVolume;
    totalFITCCells = sum(sum(sum(skelFITC)))/10; %because its a skeleton and the average diameter of a cell is around 10um
    concFITC = totalFITCCells/mmVolume;


    h = waitbar(0, [sample ': Scanning DAPI Cells...']);
%     if ~exist([savefile ' boxNumDAPI.mat'],'file')
%         boxNumDAPI = boxConcentrations(centers3DDAPI,boxDim);
%         save([savefile ' boxNumDAPI.mat'],'boxNumDAPI','-v7.3');
%     else
%         load([savefile ' boxNumDAPI.mat']);
%     end
    waitbar(0.25, h, [sample ': Scanning TRITC Cells...']);
    if ~exist([savefile ' boxNumTRITC.mat'],'file')
        boxNumTRITC = boxConcentrations(centers3DTRITC,boxDim);
        save([savefile ' boxNumTRITC.mat'],'boxNumTRITC','-v7.3');
    else
        load([savefile ' boxNumTRITC.mat']);
    end
    waitbar(0.5, h, [sample ': Scanning Cy5 Cells...']);
    if ~exist([savefile ' boxNumCy5.mat'],'file')
        boxNumCy5 = boxConcentrations(centers3DCy5,boxDim);
        save([savefile ' boxNumCy5.mat'],'boxNumCy5','-v7.3');
    else
        load([savefile ' boxNumCy5.mat']);
    end
    waitbar(0.75, h, [sample ': Scanning FITC Cells...']);
    if ~exist([savefile ' boxNumFITC.mat'],'file')
        boxNumFITC = boxConcentrations(skelFITC,boxDim);
        save([savefile ' boxNumFITC.mat'],'boxNumFITC','-v7.3');
    else
        load([savefile ' boxNumFITC.mat']);
    end
    close(h);
    %clear skelFITC centers3DTRITC centers3DCy5 centers3DDAPI;
    printExcel(sample, [savepath(1:end-6) '\Combined Hot Spots' sample '.xlsx'],...
        boxDim, totalTRITCCells,totalCy5Cells,totalFITCCells,mmVolume,...
        boxNumTRITC,boxNumCy5,boxNumFITC,centers3DTRITC,centers3DCy5,...
        skelFITC,toPlot);
end
