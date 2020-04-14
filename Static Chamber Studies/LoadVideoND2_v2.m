function [ filtBW, BWprops, times, delta, framerate ] = LoadVideoND2_v2( filename, filenamestd, savepath, res)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    %% load particle locations
    savename4 = [filenamestd ' particle locs.mat'];
    savename5 = [filenamestd ' particle props.mat'];
    savename6 = [filenamestd ' frame times.mat'];
    savename7 = [filenamestd ' frame deltas.mat'];
    if exist([savepath savename4], 'file') ~= 2
        BWprops = cell(1,1);
        delta = zeros(1,1);
        reader = bfGetReader(filename);
        %extract filter
        datasize = reader.getImageCount();
        filtBW = cell(datasize,1);
        BWprops = cell(datasize,1);
        times = zeros(datasize, 2);
        %extract timing
        timingmetastr = char(reader.getSeriesMetadata());
        [timingstartindex, timingstopindex] = regexp(timingmetastr, 'timestamp #[0-9]+=[0-9]+.[0-9]+');
        h = waitbar(0, 'Processing...');
        for n = 1:datasize
            %extract timing
            timeframestart = find(timingmetastr(timingstartindex(n):timingstopindex(n)) == '#')+timingstartindex(n);
            timestart = find(timingmetastr(timingstartindex(n):timingstopindex(n)) == '=')+timingstartindex(n);
            times(n,1) = str2double(timingmetastr(timeframestart:timestart-2));
            times(n,2) = str2double(timingmetastr(timestart:timingstopindex(n)));
            %extract frames and change to binary
            img = bfGetPlane(reader, n);
            initialGrey = mat2gray(img);
            gry = imadjust(initialGrey,[mean(initialGrey(:)); mean(initialGrey(:))+3*std(initialGrey(:))], [0; 1]); %change with each image
            filtgry = imfilter(gry,ones(5,5) / 25);
            BW = imbinarize(filtgry,0.5); %%%%%%NEEDS TO BE INDIVIDUALIZED
            BW2 = bwmorph(BW, 'bridge');
            filtBW{n} = bwareafilt(BW2,[10,400]);
            filtBW{n}(:,:,2) = zeros(res);
            filtBW{n}(:,:,3) = zeros(res);
            BWprops{n} = regionprops(filtBW{n}, 'Centroid', 'PixelList', 'PixelIdxList');
            waitbar(n/datasize,h);
        end
        times = sort(times,1); %make sure times are in the correct frame order
        delta = zeros(1,length(times)-1);
        for i = 2:length(times)
            delta(i-1) = times(i,2)-times(i-1,2); %time between each frame
        end
        framerate = 1/(sum(delta)/length(times)); %frames per second
            
        save([savepath savename4], 'filtBW');
        save([savepath savename5], 'BWprops');
        save([savepath savename6], 'times');
        save([savepath savename7], 'delta');
        close(h);
    else
        load([savepath savename4], 'filtBW');
        load([savepath savename5], 'BWprops');
        load([savepath savename6], 'times');
        load([savepath savename7], 'delta');
        framerate = 1/(sum(delta)/length(times)); %frames per second
    end

end

