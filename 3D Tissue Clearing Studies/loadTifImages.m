function [ centersDAPI, binaryFITC, centersTRITC, centersCy5, voxel_size, imageSpecs, mmVolume, tumorMask ]...
    = loadTifImages( file, cellSizePxl, savefile, zStep )
%loadTifImages Searches for cell sized fluorescence
%   outputs center values for all colors
    oneroundavgmin = 0;
    info = imfinfo([file '.tif']);
    %% extract dimensions
    numImages = length(info);
    umPxl = 1.05;%info(1).UnknownTags(2).Value; %microns/pixel
    voxel_size = [umPxl, zStep]; %microns
    frameWidth = info(1).Width; %pixels
    frameLength = info(1).Height; %pixels
    umVolume = 0;
    numberOfColors = 4;
    planes = numImages/numberOfColors;
    imageSpecs = [frameWidth, frameLength, planes];
    tumorMask = false(imageSpecs);
    centersDAPI = cell(1,numImages/numberOfColors);
    fillFactor = 0.66;
    net = denoisingNetwork('DnCNN');
    
    if ~exist([savefile ' centersTRITC.mat'],'file')

        %% extract frames and change to binary
        centersDAPI = cell(1,numImages/numberOfColors);
        binaryFITC = false(frameWidth, frameLength, numImages/numberOfColors);
        centersTRITC = cell(1,numImages/numberOfColors);
        centersCy5 = cell(1,numImages/numberOfColors);
        h = waitbar(0, 'Loading...');
        tic;
        for n = 1:numImages/numberOfColors
            %% import and identify centers of DAPI images
            img1 = imread([file '.tif'],n*4-3);
            initialGreyDAPI = mat2gray(img1);

            Y = imboxfilt(imadjust(initialGreyDAPI),21);
            bw1 = imbinarize(Y);
            clear img1 initialGreyDAPI Y;

            %% Import and find FITC vessels
            img2 = imread([file '.tif'], n*4-2);
            volFITC = mat2gray(img2);
            img3 = imread([file '.tif'], n*4-1);
            volTRITC = mat2gray(img3);
            img4 = imread([file '.tif'], n*4);
            volCy5 = mat2gray(img4);
            [initialGreyFITC,~] = calcComp(volFITC,volTRITC); %remove background from fitc; channels shouldn't overlap
            [initialGreyTRITC,~] = calcComp(volTRITC,volFITC); %remove background from tritc; channels shouldn't overlap
            initialGreyCy5 = volCy5; %remove background from cy5; channels shouldn't overlap
            initialGreyFITC(initialGreyFITC<0) = 0;
            initialGreyTRITC(initialGreyTRITC<0) = 0;
            initialGreyCy5(initialGreyCy5<0) = 0;
            clear img2 img3 img4;

%             A2 = uint8(round(initialGreyFITC*255));

%             edgeThreshold2 = 0.2;
%             amount2 = 1;
%             B2 = localcontrast(A2, edgeThreshold2, amount2); %increase local contrast
%             denoisedB2 = denoiseImage(B2, net); %denoise the image
%             J2 = adapthisteq(denoisedB2,'clipLimit',0.01,'Distribution','uniform','NumTiles',[100,100]); %increase local contrast again
            
            gry2 = bpass(initialGreyFITC,3,cellSizePxl); %filter out small noise, similar to denoising but works between large items
            bw2 = logical(imbinarize(gry2,max(gry2(:))/10)); % threshold of 50 based on choice from 5.2B
            bw2filt = bwareafilt(bw2,[ceil(pi*(cellSizePxl/3)^2) 1000]); %from a single cell area to much larger to account for long branches of vasculature all in one plane

            binaryFITC(:,:,n) = bw2filt;

%             figure; imshow(J2);
%             figure; imshow(binaryFITC(:,:,n));
           
            clear A2 B2 J2 gry2 bw2 initialGreyFITC;
            
            
            %% import and identify centers of TRITC images
            gry3 = bpass(initialGreyTRITC,3,cellSizePxl);
            
%             bw3 = logical(imbinarize(gry3, max(gry3(:))/5));
%             bw3 = bwareafilt(bw3,[25 inf]);
%             bw3 = bwpropfilt(bw3,'Eccentricity',[0 0.9]);
%             se = strel('disk',cellSizePxl);
%             bw3 = imdilate(bw3,se);
%             gry3filt = gry3;
%             gry3filt(~bw3) = 0;
            centersTRITC{n} = pkfnd(gry3, max(max(gry3))/25,cellSizePxl, fillFactor);
%             radiiTRITC = ones(length(centersTRITC{n}(:,1)),1)*(cellSizePxl/2);
% 
%             figure; imshow(gry3);
%             viscircles([centersTRITC{n}(:,2) centersTRITC{n}(:,1)], radiiTRITC,'Color','b');
            
            clear gry3 bw3 gry3filt initialGreyTRITC;
            
            %% Import and find centers of cy5 images
%             img4 = imread([file '.tif'], n*4);
%             initialGreyCy5 = mat2gray(img4);

            gry4 = bpass(initialGreyCy5,3,cellSizePxl); % use 3 on next pass
%             bw4 = logical(imbinarize(gry4, max(gry4(:))/50));
%             bw4 = bwareafilt(bw4,[25 500]); %small cell area to 2 cells clumped
%             bw4 = bwpropfilt(bw4,'Eccentricity',[0 0.8]); %no straight lines
%             se = strel('disk',cellSizePxl); %dilate so the center can be found by pkfnd
%             bw4 = imdilate(bw4,se);
%             gry4filt = gry4;
%             gry4filt(~bw4) = 0; %remove background
            centersCy5{n} = pkfnd(gry4, max(max(gry4))/50,cellSizePxl, fillFactor);
%             radiiCy5 = ones(length(centersCy5{n}(:,1)),1)*(cellSizePxl/2);
%             
%             figure; imshow(gry4);
%             viscircles([centersCy5{n}(:,2) centersCy5{n}(:,1)], radiiCy5,'Color','b');
            
            clear img4 bw4 gry4filt initialGreyCy5;

            %% show image and digital cell location overlay
%             rgb = zeros(imageSpecs(1), imageSpecs(2),3);
%             rgb(:,:,1) = initialGreyTRITC;
%             rgb(:,:,2) = initialGreyFITC;
%             rgb(:,:,3) = initialGreyCy5;
%             for m = 1:length(centersTRITC{n}(:,1))
%                 rgb(centersTRITC{n}(m,2),centersTRITC{n}(m,1),:) = 1;
%             end
%             for p = 1:length(centersCy5{n}(:,1))
%                 rgb(centersCy5{n}(p,2),centersCy5{n}(p,1),:) = 1;
%             end
%             skeleton = bwskel(binaryFITC(:,:,n));
%             for r = 1:imageSpecs(1)
%                 for q = 1:imageSpecs(2)
%                     if skeleton(r,q)
%                         rgb(r,q,:) = 1;
%                     end
%                 end
%             end
%             figure; imshow(rgb);

            %% Volume Estimation
            sliceMask = false(frameWidth,frameLength);
            area = 0;
            grys = bw1+imbinarize(volFITC,max(max(volFITC))/50)+imbinarize(volTRITC,max(max(volTRITC))/50)+imbinarize(volCy5,max(max(volCy5))/50);
            for j = 1:10:frameLength-10 %step through lengths
                start = inf;
                finish = -inf;
                for k = 0:9 %search 10 different lengths for the largest one and use that for all 10
                    %alleviates the problem of a limited number of cells used
                    %to try and calculate a volume
                    tempstart = find(grys(:,j+k)>0,1,'first'); %index in pixels
                    tempfinish = find(grys(:,j+k)>0,1,'last'); %index in pixels
                    if tempstart < start
                        start = tempstart; %index in pixels
                    end
                    if tempfinish > finish
                        finish = tempfinish; %index in pixels
                    end
                end
                if start ~= inf && finish ~= -inf && start ~= finish
                    width = (finish-start)*umPxl; %um
                    area = area+width*umPxl*10; %um^2
                    sliceMask(start:finish,j:j+9) = true;
                end
            end
            umVolume = umVolume+(area*zStep); %um^3
            sliceMask(~imerode(sliceMask,strel('disk',50))) = false; %was 25
            tumorMask(:,:,n) = sliceMask;

            %% Display time remaining
            oneround = toc;
            oneroundavgmin = (oneroundavgmin*(n-1)+oneround/60)/n;
            waittimemin = round(oneroundavgmin*(planes-n),4,'significant');
            clear bw1 gry2 gry3 gry4 grys sliceMask;
            tic;
            waitbar(n/(numImages/numberOfColors),h,['Loading...' newline num2str(waittimemin) ' min remaining']);
        end
        mmVolume = umVolume/10^9;
        binaryFITC = logical(binaryFITC);
%         save([savefile ' centersDAPI.mat'], 'centersDAPI');
        save([savefile ' binaryFITC.mat'], 'binaryFITC');
        save([savefile ' centersTRITC.mat'], 'centersTRITC');
        save([savefile ' centersCy5.mat'], 'centersCy5');
        save([savefile ' mmVolume.mat'], 'mmVolume');
        save([savefile ' tumorMask.mat'], 'tumorMask');
        save([savefile ' imageSpecs.mat'], 'imageSpecs');
        save([savefile ' voxel_size.mat'], 'voxel_size');
        close(h);
    else
%         load([savefile ' centersDAPI.mat']);
        load([savefile ' binaryFITC.mat']);
        load([savefile ' centersTRITC.mat']);
        load([savefile ' centersCy5.mat']);
        load([savefile ' mmVolume.mat']);
        load([savefile ' tumorMask.mat']);
        load([savefile ' imageSpecs.mat']);
        load([savefile ' voxel_size.mat']);
    end
end
