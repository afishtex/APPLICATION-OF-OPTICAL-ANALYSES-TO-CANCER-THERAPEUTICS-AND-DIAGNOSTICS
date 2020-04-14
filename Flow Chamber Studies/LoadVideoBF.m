function [ BWprops, delta, stoppedparticleprops, orientation, totalstoppedparticleimage ] = LoadVideoBF( path, name, vid, saveV, orientation, totalstoppedparticleimage )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
dbstop if error
    filename = [path '\' name];
    try
        BWprops = cell(1,1);
        delta = zeros(1,1);
        reader = bfGetReader(filename);
        filtermetastr = char(reader.getGlobalMetadata());
        %extract filter
        fluor = regexp(filtermetastr, 'BF1'); %'\(TRITC');
        clearvars filtermetastr filename;
        if fluor %check difference between TRITC and BF
            datasize = reader.getImageCount();
            img = cell(datasize,1);
            filtBW3 = cell(datasize,1);
            BWprops = cell(datasize,1);
            times = zeros(datasize, 2);
            %extract timing
            timingmetastr = char(reader.getSeriesMetadata());
            [timingstartindex, timingstopindex] = regexp(timingmetastr, 'timestamp #[0-9]+=[0-9]+.[0-9]+');

            if vid
                figure(1);
                currAxes = axes;
                figure(2);
                otherAxes = axes;
            end
%             orient = [];
            h = waitbar(0,[name ', Please wait...']);
            for n = 1:datasize
                %extract timing
                timeframestart = find(timingmetastr(timingstartindex(n):timingstopindex(n)) == '#')+timingstartindex(n);
                timestart = find(timingmetastr(timingstartindex(n):timingstopindex(n)) == '=')+timingstartindex(n);
                times(n,1) = str2double(timingmetastr(timeframestart:timestart-2));
                times(n,2) = str2double(timingmetastr(timestart:timingstopindex(n)));
                %extract frames and change to binary
                img = imcomplement(bfGetPlane(reader, n));
                
                initialGrey = mat2gray(img);
%                 [N,edges] = histcounts(initialGrey);
%                 loc = N == max(N);
%                 mfn = edges(loc); %most frequent number (mode)
%                 if n == 1
%                     minimum = mean(initialGrey(:));
%                     maximum = mean(initialGrey(:))+3*std(initialGrey(:));
%                 end
                %gry = imadjust(initialGrey,[minimum; maximum], [0; 1]); %change with each image
%                 filtgry = wiener2(gry,[4 4]); %could be causing edge effects
                %filtgry = imfilter(gry,ones(3,3) / 9);
                %srfiltgry = RemoveShadow(filtgry);
                BW = imbinarize(initialGrey,mean(initialGrey(:))+3.5*std(initialGrey(:))); %%%%%%NEEDS TO BE INDIVIDUALIZED .95
                %BW2 = bwmorph(BW, 'bridge');
                filtBW = bwareafilt(BW,[40,100]);%a little more than a 1um particle up to a 3um particle area
                filtBW2 = bwpropfilt(filtBW,'Eccentricity',[0 0.75]);
                filtBW3{n} = bwpropfilt(filtBW2,'Solidity',[0.9 1]);
                BWprops{n} = regionprops(filtBW3{n}, 'Eccentricity', 'Orientation', 'Area', 'Centroid', 'Solidity');
%                 for i = length(BWprops{n}):-1:1
% %                     if BWprops{n}(i).Area < 10
% %                         BWprops{n}(i) = [];
%                     if BWprops{n}(i).Eccentricity > 0.5
%                         orient = [orient BWprops{n}(i).Orientation];
%                     end
%                 end
                if vid
                    imshow(filtBW3{n}, 'Parent', currAxes); %play video
                    imshow(initialGrey, 'Parent',otherAxes);
%                     pause(1/100000);
                end
                waitbar(n/datasize,h);
            end
            close(h);
            if isnan(orientation)
                figure;
                imshow(initialGrey);
                direction = imline(gca);
                position = wait(direction);
                orientation = atan2d(position(2,2)-position(1,2),position(2,1)-position(1,1)); %y posititions swapped due to the y axis being zero in the top left corner and increasing as it goes down
            end
%             orient(orient<-45) = orient(orient<-45)+180;
%             orientation = [mean(orient),std(orient)];
            times = sort(times,1); %make sure times are in the correct frame order
            delta = zeros(1,length(times)-1);
            for i = 2:length(times)
                delta(i-1) = times(i,2)-times(i-1,2); %time between each frame
            end
            framerate = 1/(sum(delta)/length(times)); %frames per second
            savename = ['Binary ' name(1:end-4)];
            savepath = [path '\Analysis1\' savename];
            if saveV
                v = VideoWriter(savepath);
                v.FrameRate = framerate;
                open(v);
                g = waitbar(0,'Saving Video, Please wait...');
            end
            individualstoppedparticleimage = zeros(1440,1920);
            for j = 1:length(filtBW3)
                if saveV
                    writeVideo(v,uint8(filtBW3{j})*255); 
                    waitbar(j/length(filtBW3),g);
                end
                individualstoppedparticleimage = individualstoppedparticleimage+filtBW3{j};
            end
            normalizedstoppedparticleimage = individualstoppedparticleimage./length(filtBW3);
            totalstoppedparticleimage = totalstoppedparticleimage+normalizedstoppedparticleimage;
            bwstoppedparticle = imbinarize(mat2gray(normalizedstoppedparticleimage));
            bw2stoppedparticle = bwpropfilt(bwstoppedparticle,'Eccentricity',[0 0.5]);
            stoppedparticleprops = regionprops(bw2stoppedparticle, 'Centroid');
%             figure;
%             imshow(bw2stoppedparticle);
%             greystoppedparticleimage = mat2gray(normalizedstoppedparticleimage);
%             individualstoppedparticleregions = regionprops(bw2stoppedparticle, greystoppedparticleimage, 'WeightedCentroid', 'MeanIntensity');
%             figure;
%             histogram([individualstoppedparticleregions.MeanIntensity],20);
            if saveV
                close(g);
                close(v);
            end
        end
        reader.close();
    catch ME
        disp(ME.stack(1));
        throw(ME);
    end

end

