%% load images
% date = 20171003;
% psm = 'APTES';
% media = 'PBS\';
% row = 1;
% col = 75;
% passage = 7;
fileext = '.nd2';%'.tif';
obj = 20;
umpxl = 0.18; %um/pixel at 20x
psmSplit = strsplit(psm);
% longestTrack = 0;
% msd = nan(1,2,0);
if length(psmSplit) > 1
    psmSplit{2} = [' ' psmSplit{2}];
else
    psmSplit{2} = '';
end
filepath = ['F:\Static Chamber\' num2str(date) '\' media psm '\']; %starting folder
savepath = ['G:\Postgraduate\Swansea\Thesis\Flow\Static Analysis\20190605\' media psm '\'];
xlsavepath = 'F:\Static Chamber\Particle Motion Analysis.xlsx';
numOfVids = 1;
i = 1;
% figure; hold on;
while i <= numOfVids
    %% load particle locations
    %filenamestd = ['Stimulated P' num2str(passage) ' HUVEC w ' psmSplit{1} ' PSM ' num2str(obj) 'x ' num2str(i-1)];
    filenamestd = [psmSplit{1} ' PSM ' num2str(obj) 'x ' num2str(i-1)];
    if strcmp(fileext, '.tif')
        myFileFolderInfo = dir([filepath '*' fileext]);
        numberOfFrames = length(myFileFolderInfo);
        res = [1024 1360];
        [filtBW, BWprops, times, delta, framerate] = LoadVideoAVI_v2( filepath, filenamestd, myFileFolderInfo, numberOfFrames, savepath, res);
        cellfilename = [filepath psmSplit{1} ' BF' psmSplit{2} '.tif']; %rename bf images to all match
    else
        myFileFolderInfo = dir([filepath '*' fileext]);
        myFileFolderInfo([myFileFolderInfo.bytes] < 10000000) = [];%differentiate between video and image
        numOfVids = length(myFileFolderInfo);
        filename = [filepath  myFileFolderInfo(i).name];
        res = [1440 1920];
        [filtBW, BWprops, times, delta, framerate] = LoadVideoND2_v2(filename, filenamestd, savepath, res);
        numberOfFrames = length(times(:,1));
        cellfilename = [filepath psmSplit{1} ' FITC' psmSplit{2} '.tif']; %rename bf images to all match
    end
    %cellimg = imread(cellfilename);%imadjust(imread(cellfilename));

    %% select and save roi
%     savename1 = [filenamestd ' roi.mat'];
%     savename2 = [filenamestd ' masks.mat'];
%     if exist([savepath savename2], 'file') ~= 2
%         masks = CellMasks_v2(imresize(cellimg, res));
%         roiF = getframe;
%         roiI = frame2im(roiF);
%         roi = imresize(roiI,res);
%         save([savepath savename1], 'roi');
%         save([savepath savename2],'masks');
%     else
%         load([savepath savename1]);
%         load([savepath savename2]); 
%     end

    %% track particles
    savename4 = [filenamestd ' distances-20.mat'];
    savename10 = [filenamestd ' numParticles-20.mat'];
    if exist([savepath savename4], 'file') ~= 2
        startloc = length(BWprops);
        startparticles = 0;
        distances = TrackParticle(BWprops, startloc, startparticles, startparticles, masks);
        numParticles = max(distances(1,:));
        save([savepath savename4], 'distances');
        save([savepath savename10], 'numParticles');
    else
        load([savepath savename4]);
        load([savepath savename10]);
    end
    
    %% MSD
    
%     longestTrack = max([longestTrack max(distances(2,:))]);
%     distances3D = NaN(2,longestTrack,numParticles);
%     n=1;
%     m=1;
%     for q = 2:length(distances(1,:))
%         if distances(1,q) == distances(1,q-1)
%             distances3D(:,m,n) = distances(5:6,q);
%             m = m+1;
%         else
%             n=n+1;
%             m=1;
%         end
%     end
%     
%     numberOfDT = floor(longestTrack/4);
%     tempmsd = NaN(numberOfDT,2,numParticles);
%     for k = 1:numParticles
%         trackLength = sum(~isnan(distances3D(1,:,k)));
%         if trackLength > 3
%             for dt = 1:floor(trackLength/4)
%                deltaAtCoordinates = distances3D(:,1+dt:end,k) - distances3D(:,1:end-dt,k);
%                squaredDisplacement = sum(deltaAtCoordinates.^2,1); %# dx^2+dy^2+dz^2
% 
%                tempmsd(dt,1,k) = nanmean(squaredDisplacement)*0.18^2/0.3; %# average um^2/s
%                tempmsd(dt,2,k) = nanstd(squaredDisplacement)*0.18^2/0.3; %# std um^2/s
%             end
%             loglog((1:floor(trackLength/4))*0.3, tempmsd(1:floor(trackLength/4),1,k), 'color','r');
%         end
%     end
%     msd(1:numberOfDT,:,length(msd(1,1,:))+1:length(msd(1,1,:))+numParticles) = tempmsd;
    
    
    %% plot movement paths
%     r = 2;
%     colors = ['b','r','g','c','m'];
%     while r < length(distances(1,:))
%         if distances(1,r) == distances(1,r-1)
%             plot([distances(5,r-1) distances(5,r)], [distances(6,r-1) distances(6,r)], 'color', colors(mod(distances(1,r), 5)+1));
%         end
%         r = r+1;
%     end

    %% measure segment distances
    savename5 = [filenamestd ' onDist-20.mat'];
    savename6 = [filenamestd ' offDist-20.mat'];
    savename7 = [filenamestd ' onCount-20.mat'];
    savename8 = [filenamestd ' offCount-20.mat'];
%     if exist([savepath savename5], 'file') ~= 2
        onDist = NaN(1,length(distances(1,:)));
        offDist = NaN(1,length(distances(1,:)));
        onCount = 0;
        offCount = 0;
        for k = 1:max(distances(1,:))
            tempdist = distances(:, distances(1,:) == k);
            tempdistoncell = tempdist(:, tempdist(3,:) == 1);
            tempdistoffcell = tempdist(:, tempdist(3,:) == 0);
            if ~isempty(tempdistoncell)
                for n = 1:length(tempdistoncell(1,:))-1
                    if tempdistoncell(2,n) == tempdistoncell(2,n+1) - 1
                        onCount = onCount+1;
                        onDist(onCount) = tempdistoncell(4,n);
                    end
                end
            end
            if ~isempty(tempdistoffcell)
                for m = 1:length(tempdistoffcell(1,:))-1
                    if tempdistoffcell(2,m) == tempdistoffcell(2,m+1) - 1
                        offCount = offCount+1;
                        offDist(offCount) = tempdistoffcell(4,m);
                    end
                end
            end
        end
        onDist = onDist(~isnan(onDist));
        offDist = offDist(~isnan(offDist));
        onAvg = mean(onDist);
        onStd = std(onDist);
        offAvg = mean(offDist);
        offStd = std(offDist);
        save([savepath savename5], 'onAvg');
        save([savepath savename6], 'offAvg');
        save([savepath savename7], 'onCount');
        save([savepath savename8], 'offCount');
%     else
%         load([savepath savename5]);
%         load([savepath savename6]);
%         load([savepath savename7]);
%         load([savepath savename8]);
%     end
    
    
    %% Total Distance Traveled from origin
%     savename11 = [filenamestd ' totOnDistFromOrigin-20.mat'];
%     savename12 = [filenamestd ' totOffDistFromOrigin-20.mat'];
%     savename13 = [filenamestd ' meanOnDistFromOrigin-20.mat'];
%     savename14 = [filenamestd ' meanOffDistFromOrigin-20.mat'];
%     if exist([savepath savename11], 'file') ~= 2
%         totOnDistFromOrigin = nan(3,numParticles);
%         totOffDistFromOrigin = nan(3,numParticles);
%         for q = 1:numParticles
%             tempdist = distances(:,distances(1,:)==q);
%             if length(tempdist(3,:))>1
%                 if nnz(tempdist(3,:)) == length(tempdist(3,:))
%                     totOnDistFromOrigin(1,q) = q;
%                     totOnDistFromOrigin(2,q) = pdist([[tempdist(5,end) tempdist(6,end)]; [tempdist(5,1) tempdist(6,1)]]);
%                     if totOnDistFromOrigin(2,q) <= 2*max(tempdist(4,:)) %check to see if the particle moves farther than its longest step to tell if the particle is stuck
%                         totOnDistFromOrigin(3,q) = 1;
%                     end
%                 elseif nnz(~tempdist(3,:)) == length(tempdist(3,:))
%                     totOffDistFromOrigin(1,q) = q;
%                     totOffDistFromOrigin(2,q) = pdist([[tempdist(5,end) tempdist(6,end)]; [tempdist(5,1) tempdist(6,1)]]);
%                     if totOffDistFromOrigin(2,q) <= 2*max(tempdist(4,:)) %check to see if the particle moves farther than its longest step to tell if the particle is stuck
%                         totOffDistFromOrigin(3,q) = 1;
%                     end
%                 end
%             end
%         end
%         totOnDistFromOrigin = totOnDistFromOrigin(:,~isnan(totOnDistFromOrigin(1,:)));
%         meanOnDistFromOrigin = mean(totOnDistFromOrigin(2,:));
%         totOffDistFromOrigin = totOffDistFromOrigin(:,~isnan(totOffDistFromOrigin(1,:)));
%         meanOffDistFromOrigin = mean(totOffDistFromOrigin(2,:));
%         save([savepath savename11], 'totOnDistFromOrigin');
%         save([savepath savename12], 'totOffDistFromOrigin');
%         save([savepath savename13], 'meanOnDistFromOrigin');
%         save([savepath savename14], 'meanOffDistFromOrigin');
%     else
%         load([savepath savename11]);
%         load([savepath savename12]);
%         load([savepath savename13]);
%         load([savepath savename14]);
%     end
    

    %% particle color changer
%     savename9 = [filenamestd ' filtBW.mat'];
%     if exist([savepath savename9], 'file') ~= 2
%         for p = length(distances(1,:)):-1:1
%             if distances(3,p) == 1
%                 j = 1;
%                 while j <= length(BWprops{distances(2,p)})
%                     if BWprops{distances(2,p)}(j).Centroid(1) == distances(5,p) && BWprops{distances(2,p)}(j).Centroid(2) == distances(6,p)
%                         filtBW{distances(2,p)}(BWprops{distances(2,p)}(j).PixelIdxList+(res(1)*res(2)))=1;
%                         filtBW{distances(2,p)}(BWprops{distances(2,p)}(j).PixelIdxList)=0;
%                         j = length(BWprops{distances(2,p)}) + 1;
%                     end
%                     j = j+1;
%                 end
%                 if j ~= length(BWprops{distances(2,p)}) + 2
%                     sprintf('if failed at %d, %d', p,j);
%                 end
%             else
%                 k = 1;
%                 while k <= length(BWprops{distances(2,p)})
%                     if BWprops{distances(2,p)}(k).Centroid(1) == distances(5,p) && BWprops{distances(2,p)}(k).Centroid(2) == distances(6,p)
%                         filtBW{distances(2,p)}(BWprops{distances(2,p)}(k).PixelIdxList+(res(1)*res(2)))=0;
%                         filtBW{distances(2,p)}(BWprops{distances(2,p)}(k).PixelIdxList)=1;
%                         k = length(BWprops{distances(2,p)}) + 1;
%                     end
%                     k = k+1;
%                 end
%                 if k ~= length(BWprops{distances(2,p)}) + 2
%                     sprintf('else failed at %d, %d', p,k);
%                 end
%             end
%         end
%         save([savepath savename9], 'filtBW');
%     else
%         load([savepath savename9]);
%     end
% 
    %% save blended video
%     savename3 = ['color Blended ' filenamestd '.avi'];
%     % roi = imread([savepath savename1]);
%     if exist([savepath savename3], 'file') ~= 2
%         vw = VideoWriter([savepath savename3]);
%         vw.FrameRate = framerate;
%         open(vw);
%         for n = 1:numberOfFrames-1 %%change when changing folders
%             video = imfuse(roi,filtBW{n},'blend');
%             writeVideo(vw, video);
%         end
%         close(vw);
%     end
%     xlswrite(xlsavepath, {numParticles offAvg}, num2str(date), [char(col) num2str(row+i) ':' char(col+1) num2str(row+i)]);
%     xlswrite(xlsavepath, {offCount offStd}, num2str(date), [char(col+3) num2str(row+i) ':' char(col+4) num2str(row+i)]);
    i = i+1;
%     clearvars distances filtBW BWprops roi roiIroiF video onDist offDist masks
end

%% MSD average line
% avgMSD = nanmean(msd(:,1,:),3);
% loglog((1:floor(longestTrack/4))*0.3, avgMSD,'k-*');
% xlabel('Time Lag, \tau (s)');
% ylabel('MSD (\mum^2/s)');
% title(['PSM Mean Square Displacement: ' media(1:length(media)-1) ' ' psm]);
% xlim([.1 100]);
% ylim([.1 1000]);
% set(gca,'XScale','log');
% set(gca,'YScale','log');

%% movement paths figure finishing
% title(['PSM Movement Paths: ' media(1:length(media)-1) ' ' psm]);
% xlim([0 res(2)]);
% ylim([0 res(1)]);

%% close and save graphs
% hold off;
% saveas(gcf,[savepath 'movement paths.tif']);
% close all;