function [ filtBW, BWprops, times, delta, framerate ] = LoadVideoAVI_v2( filepath, filenamestd, myFileFolderInfo, numberOfFrames, savepath, res )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    %% load particle locations
    savename4 = [filenamestd ' particle locs.mat'];
    savename5 = [filenamestd ' particle props.mat'];
    if exist([savepath savename4], 'file') ~= 2
        h = waitbar(0, 'Processing...');
        img = cell(numberOfFrames,1);
        for frame = 1:numberOfFrames-1
            rfpfilename = myFileFolderInfo(frame+1).name;
            img{frame} = imread([filepath rfpfilename]);
            initialGrey = mat2gray(rgb2gray(img{frame}));
            BW = imbinarize(initialGrey,0.2); %%%%%%NEEDS TO BE INDIVIDUALIZED
            BW2 = bwmorph(BW, 'bridge');
            filtBW{frame} = bwareafilt(BW2,[10,400]);
            filtBW{frame}(:,:,2) = zeros(res);
            filtBW{frame}(:,:,3) = zeros(res);
            BWprops{frame} = regionprops(filtBW{frame}(:,:,1), 'Centroid', 'PixelList', 'PixelIdxList');
            waitbar(frame/numberOfFrames,h);
        end
        save([savepath savename4], 'filtBW');
        save([savepath savename5], 'BWprops');
        close(h);
    else
        load([savepath savename4], 'filtBW');
        load([savepath savename5], 'BWprops');
    end
    times = [1:numberOfFrames; 0:10:10*(numberOfFrames-1)];
    delta = ones(1,numberOfFrames)*10;
    framerate = numberOfFrames/60; %frames per second

end

