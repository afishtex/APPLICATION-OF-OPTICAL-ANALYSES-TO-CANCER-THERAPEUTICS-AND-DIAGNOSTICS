%can take a folder of nd2 files and pull out the fluorescent ones and then
%calculate average speed and std of the particles in each with relation to 
%its flowrate

dbstop if error
% filestart = 'F:\Shared\Data exchange\Fisher\Flow Chamber\';
date = '';
% surface = '';
particle = 'SCR';
% run = 1;
% filepath = [filestart date '\' surface particle '\' num2str(run) '\']; %starting folder
fileext = '.nd2';
myFileFolderInfo = dir([filepath '*' fileext]);
numfiles = length(myFileFolderInfo);
savepath = [filepath, 'Analysis20190123\'];
if ~exist(savepath,'file')
    mkdir(savepath);
end
playVideo = 0; %show video and trace particle/flow orientation
saveVideo =  0;
stoppedParticles = 0;
saveWorkspace = 1;
saveData = 1;
distPerPixel = 0.36; %0.18 um/pixel at 20X, 0.36 um/pixel at 10X
numberOfParticles = zeros(numfiles,1);
avgSpeedPerVid = NaN(numfiles,1);
stdSpeedPerVid = NaN(numfiles,1);
speedums = cell(numfiles,1); %how to declare length of speedums when
% some files have different frame rates
numberOfOnParticles = zeros(numfiles,1);
avgOnSpeedPerVid = NaN(numfiles,1);
stdOnSpeedPerVid = NaN(numfiles,1);
speedonums = cell(numfiles,1);
numberOfOffParticles = zeros(numfiles,1);
avgOffSpeedPerVid = NaN(numfiles,1);
stdOffSpeedPerVid = NaN(numfiles,1);
speedoffums = cell(numfiles,1);
BWprops = cell(numfiles,1);
deltatimes = cell(numfiles,1);
stoppedParticleLocs = cell(numfiles+1,1);
averages = cell(numfiles,1);
onaverages = cell(numfiles,1);
offaverages = cell(numfiles,1);
totalStoppedParticles = zeros(1,numfiles);
totalStoppedOnParticles = zeros(1,numfiles);
totalStoppedOffParticles = zeros(1,numfiles);
newStoppedParticles = zeros(1,numfiles);
newStoppedOnParticles = zeros(1,numfiles);
newStoppedOffParticles = zeros(1,numfiles);
cellimg = false(1440, 1920);
excelSheets = {'Number Of Moving Particles/Video' 'Number of Stopped Particles/Video' 'Number of New Stopped Particles/Video' 'Average Speed/Video' 'Standard Deviation/Video' 'Average Particle Speed/Video' 'Particle Standard Deviation/Video'...
    'Number Of Moving Particles On Cells/Video' 'Number of Stopped Particles On Cells/Video' 'Number of New Stopped Particles On Cells/Video' 'Average Speed On Cells/Video' 'Standard Deviation On Cells/Video' 'Average Particle Speed On Cells/Video' 'Particle Standard Deviation On Cells/Video'...
    'Number Of Moving Particles Off Cells/Video' 'Number of Stopped Particles Off Cells/Video' 'Number of New Stopped Particles Off Cells/Video' 'Average Speed Off Cells/Video' 'Standard Deviation Off Cells/Video' 'Average Particle Speed Off Cells/Video' 'Particle Standard Deviation Off Cells/Video'...
    'Average Speed/Flow Rate' 'Standard Deviation/Flow Rate' 'Average Particle Speed/Flow Rate' 'Particle Standard Deviation/Flow Rate'...
    'Average Speed On Cells/Flow Rate' 'Standard Deviation On Cells/Flow Rate' 'Average Particle Speed On Cells/Flow Rate' 'Particle Standard Deviation On Cells/Flow Rate'...
    'Average Speed Off Cells/Flow Rate' 'Standard Deviation Off Cells/Flow Rate' 'Average Particle Speed Off Cells/Flow Rate' 'Particle Standard Deviation Off Cells/Flow Rate' ''}; %'Average Particle Speed/Flow Rate' 'Particle Standard Deviation/Flow Rate' 
xlsavename = [date ' ' particle ' Particle Speeds Angled Line w gaps.xlsx'];
xlsavepath = [savepath xlsavename];
% crossArea = .254*2.5;
filecount = 1;
startcount = 1;
orientation = 180;
totalstoppedparticleimage = zeros(1440, 1920);
try
    while filecount <= numfiles
        if myFileFolderInfo(filecount).bytes > 10000000
            if filecount == 1
                [~, stopindex] = regexp(myFileFolderInfo(filecount).name, '[0-9]+ul-min');
                wksavename = ['Workspace ' myFileFolderInfo(filecount).name(1:stopindex)];
                wksavepath = [savepath wksavename '.mat'];
            end
            if ~exist(wksavepath,'file')
                tic
                
                [BWprops{filecount}, deltatimes{filecount}, stoppedParticleLocs{filecount+1}, orientation, totalstoppedparticleimage] = LoadVideoBF(myFileFolderInfo(filecount).folder, myFileFolderInfo(filecount).name, playVideo, saveVideo, orientation, totalstoppedparticleimage);
                toc
            elseif filecount == 1
                load(wksavepath, 'BWprops', 'deltatimes', 'stoppedParticleLocs', 'orientation', 'totalstoppedparticleimage');
            end
            if ~isempty(BWprops{filecount})
                [flowstartindex, flowstopindex] = regexp(myFileFolderInfo(filecount).name, '[0-9]+ul-min');
                flowrate = str2double(myFileFolderInfo(filecount).name(flowstartindex:flowstopindex-6));
                if filecount == 1
                    prevflowrate = flowrate;
                end
                if flowrate ~= prevflowrate
                    tempspd = [];
                    temppartspd = [];
                    for i = startcount:filecount-1
                        if isempty(speedums{i})
                            tempspd = [tempspd NaN];
                        else
                            tempspd = [tempspd speedums{i}(3,:)];
                        end
                        if isempty(averages{i})
                            temppartspd = [temppartspd NaN];
                        else
                            temppartspd = [temppartspd averages{i}(2,:)];
                        end
                    end
                    avgSpeedFlowRate = [prevflowrate, mean(tempspd,'omitnan')];
                    stdSpeedFlowRate = [prevflowrate, std(tempspd,'omitnan')];
                    avgParticleSpeedFlowRate = [prevflowrate, mean(temppartspd,'omitnan')];
                    stdParticleSpeedFlowRate = [prevflowrate, std(temppartspd,'omitnan')];
        
                    temponspd = [];
                    temponpartspd = [];
                    for k = startcount:filecount-1
                        if isempty(speedonums{k})
                            temponspd = [temponspd NaN];
                        else
                            temponspd = [temponspd speedonums{k}(3,:)];
                        end
                        if isempty(onaverages{k})
                            temponpartspd = [temponpartspd NaN];
                        else
                            temponpartspd = [temponpartspd onaverages{k}(2,:)];
                        end
                    end
                    avgOnSpeedFlowRate = [prevflowrate, mean(temponspd,'omitnan')];
                    stdOnSpeedFlowRate = [prevflowrate, std(temponspd,'omitnan')];
                    avgOnParticleSpeedFlowRate = [prevflowrate, mean(temponpartspd,'omitnan')];
                    stdOnParticleSpeedFlowRate = [prevflowrate, std(temponpartspd,'omitnan')];

                    tempoffspd = [];
                    tempoffpartspd = [];
                    for k = startcount:filecount-1
                        if isempty(speedoffums{k})
                            tempoffspd = [tempoffspd NaN];
                        else
                            tempoffspd = [tempoffspd speedoffums{k}(3,:)];
                        end
                        if isempty(offaverages{k})
                            tempoffpartspd = [tempoffpartspd NaN];
                        else
                            tempoffpartspd = [tempoffpartspd offaverages{k}(2,:)];
                        end
                    end
                    avgOffSpeedFlowRate = [prevflowrate, mean(tempoffspd,'omitnan')];
                    stdOffSpeedFlowRate = [prevflowrate, std(tempoffspd,'omitnan')];
                    avgOffParticleSpeedFlowRate = [prevflowrate, mean(tempoffpartspd,'omitnan')];
                    stdOffParticleSpeedFlowRate = [prevflowrate, std(tempoffpartspd,'omitnan')];
                    
                    if saveWorkspace
                        save(wksavepath);
                    end
                    if saveData
                        excelSheets(2,22:33) = {avgSpeedFlowRate(2) stdSpeedFlowRate(2) avgParticleSpeedFlowRate(2) stdParticleSpeedFlowRate(2)...
                        avgOnSpeedFlowRate(2) stdOnSpeedFlowRate(2) avgOnParticleSpeedFlowRate(2) stdOnParticleSpeedFlowRate(2)...
                        avgOffSpeedFlowRate(2) stdOffSpeedFlowRate(2) avgOffParticleSpeedFlowRate(2) stdOffParticleSpeedFlowRate(2)}; 
                        xlswrite(xlsavepath, excelSheets(:,:), num2str(prevflowrate));
                    end
                    prevflowrate = flowrate;
                    startcount = filecount;
                    excelSheets = {'Number Of Moving Particles/Video' 'Number of Stopped Particles/Video' 'Number of New Stopped Particles/Video' 'Average Speed/Video' 'Standard Deviation/Video' 'Average Particle Speed/Video' 'Particle Standard Deviation/Video'...
                        'Number Of Moving Particles On Cells/Video' 'Number of Stopped Particles On Cells/Video' 'Number of New Stopped Particles On Cells/Video' 'Average Speed On Cells/Video' 'Standard Deviation On Cells/Video' 'Average Particle Speed On Cells/Video' 'Particle Standard Deviation On Cells/Video'...
                        'Number Of Moving Particles Off Cells/Video' 'Number of Stopped Particles Off Cells/Video' 'Number of New Stopped Particles Off Cells/Video' 'Average Speed Off Cells/Video' 'Standard Deviation Off Cells/Video' 'Average Particle Speed Off Cells/Video' 'Particle Standard Deviation Off Cells/Video'...
                        'Average Speed/Flow Rate' 'Standard Deviation/Flow Rate' 'Average Particle Speed/Flow Rate' 'Particle Standard Deviation/Flow Rate'...
                        'Average Speed On Cells/Flow Rate' 'Standard Deviation On Cells/Flow Rate' 'Average Particle Speed On Cells/Flow Rate' 'Particle Standard Deviation On Cells/Flow Rate'...
                        'Average Speed Off Cells/Flow Rate' 'Standard Deviation Off Cells/Flow Rate' 'Average Particle Speed Off Cells/Flow Rate' 'Particle Standard Deviation Off Cells/Flow Rate' ''}; %'Average Particle Speed/Flow Rate' 'Particle Standard Deviation/Flow Rate' 
                    stoppedParticles = 0;
                end
                [speedums{filecount},speedonums{filecount},speedoffums{filecount},numberOfParticles(filecount)] = CalculateSpeed(BWprops{filecount}, deltatimes{filecount}, distPerPixel, orientation, cellimg); %how to declare length of speedums when
                if numberOfParticles(filecount)
                    [numberOfParticles(filecount), speedums{filecount}, averages{filecount}, avgSpeedPerVid(filecount), stdSpeedPerVid(filecount), avgSpeedPerPartPerVid(filecount), stdSpeedPerPartPerVid(filecount)] = AverageSpeeds(flowrate, speedums{filecount});
                    [numberOfOnParticles(filecount), speedonums{filecount}, onaverages{filecount}, avgOnSpeedPerVid(filecount), stdOnSpeedPerVid(filecount), avgOnSpeedPerPartPerVid(filecount), stdOnSpeedPerPartPerVid(filecount)] = AverageSpeeds(flowrate, speedonums{filecount});
                    [numberOfOffParticles(filecount), speedoffums{filecount}, offaverages{filecount}, avgOffSpeedPerVid(filecount), stdOffSpeedPerVid(filecount), avgOffSpeedPerPartPerVid(filecount), stdOffSpeedPerPartPerVid(filecount)] = AverageSpeeds(flowrate, speedoffums{filecount});
                    [totalStoppedParticles(filecount), newStoppedParticles(filecount)] = CountNewParticles(stoppedParticleLocs(filecount), stoppedParticleLocs(filecount+1),ones(size(cellimg))); %pass cellimg into this to use it to decide on v off cell attachments
                    [totalStoppedOnParticles(filecount), newStoppedOnParticles(filecount)] = CountNewParticles(stoppedParticleLocs(filecount), stoppedParticleLocs(filecount+1),cellimg); %pass cellimg into this to use it to decide on v off cell attachments
                    [totalStoppedOffParticles(filecount), newStoppedOffParticles(filecount)] = CountNewParticles(stoppedParticleLocs(filecount), stoppedParticleLocs(filecount+1),imcomplement(cellimg)); %pass cellimg into this to use it to decide on v off cell attachments
                    if playVideo
                        figure(3);
                        curaxes = axes;
                        img = zeros(size(initialimage{1}));
                        for m = 1:length(initialimage)-1
                            tempimg = imbinarize(img,0.5);
                            if nonzeros(speedums{filecount}(2,:) == m)
                                row = floor(speedums{filecount}(5,speedums{filecount}(2,:) == m));
                                col = floor(speedums{filecount}(4,speedums{filecount}(2,:) == m));
                                for u = 1:length(col)
                                    x1=row(u)-10;
                                    x2=row(u)+10;
                                    y1=col(u)-10;
                                    y2=col(u)+10;
                                    if x1 < 1
                                        x1=1;
                                    end
                                    if y1<1
                                        y1=1;
                                    end
                                    if x2>length(tempimg(:,1))
                                        x2 = length(tempimg(:,1));
                                    end
                                    if y2>length(tempimg(1,:))
                                        y2 = length(tempimg(1,:));
                                    end
                                    tempimg(x1:x2, y1:y2)=1;
                                    tempimg(x1+3:x2-3, y1+3:y2-3)=0;
                                end
                            end
                            imshow(tempimg, 'Parent', curaxes); %play video
                            pause(1/10);
                        end
                    end
                    excelSheets(filecount-startcount+2,1:21) = {numberOfParticles(filecount) totalStoppedParticles(filecount) newStoppedParticles(filecount) avgSpeedPerVid(filecount) stdSpeedPerVid(filecount) avgSpeedPerPartPerVid(filecount) stdSpeedPerPartPerVid(filecount)...
                        numberOfOnParticles(filecount) totalStoppedOnParticles(filecount) newStoppedOnParticles(filecount) avgOnSpeedPerVid(filecount) stdOnSpeedPerVid(filecount) avgOnSpeedPerPartPerVid(filecount) stdOnSpeedPerPartPerVid(filecount)...
                        numberOfOffParticles(filecount) totalStoppedOffParticles(filecount) newStoppedOffParticles(filecount) avgOffSpeedPerVid(filecount) stdOffSpeedPerVid(filecount) avgOffSpeedPerPartPerVid(filecount) stdOffSpeedPerPartPerVid(filecount)};
                    if isempty(speedums{filecount})
                        temp = NaN;
                    else
                        temp = speedums{filecount}(3,:);
                    end
                    if isempty(averages{filecount})
                        temppart = NaN;
                    else
                        temppart = averages{filecount}(2,:);
                    end
                    excelSheets(1, 35+2*(filecount-startcount)) = {'Raw Data'};
                    excelSheets(2:length(temp(~isnan(temp)))+1, 35+2*(filecount-startcount)) = num2cell(temp(~isnan(temp)));
                    excelSheets(1, 36+2*(filecount-startcount)) = {'Averages'};
                    excelSheets(2:length(temppart(~isnan(temppart)))+1, 36+2*(filecount-startcount)) = num2cell(temppart(~isnan(temppart)));
                    clearvars temp temppart;
                end
                filecount=filecount+1;
            else
                myFileFolderInfo(filecount) = [];
                numberOfParticles(filecount) = [];
                avgSpeedPerVid(filecount) = [];
                stdSpeedPerVid(filecount) = [];
                speedums(filecount,:) = [];
                numberOfOnParticles(filecount) = [];
                avgOnSpeedPerVid(filecount) = [];
                stdOnSpeedPerVid(filecount) = [];
                speedonums(filecount,:) = [];
                numberOfOffParticles(filecount) = [];
                avgOffSpeedPerVid(filecount) = [];
                stdOffSpeedPerVid(filecount) = [];
                speedoffums(filecount,:) = [];
                BWprops(filecount,:) = [];
                deltatimes(filecount,:) = [];
                stoppedParticleLocs(filecount) = [];
                averages(:,filecount) = [];
                onaverages(:,filecount) = [];
                offaverages(:,filecount) = [];
                totalStoppedParticles(filecount) = [];
                totalStoppedOnParticles(filecount) = [];
                totalStoppedOffParticles(filecount) = [];
                newStoppedParticles(filecount) = [];
                newStoppedOnParticles(filecount) = [];
                newStoppedOffParticles(filecount) = [];
                numfiles = length(myFileFolderInfo);
            end
        else
            cellfile = regexp(myFileFolderInfo(filecount).name, 'FITC');
            if cellfile
                cellimg = LoadCellsConfluent(myFileFolderInfo(filecount).folder, myFileFolderInfo(filecount).name);
            end
            myFileFolderInfo(filecount) = [];
            numberOfParticles(filecount) = [];
            avgSpeedPerVid(filecount) = [];
            stdSpeedPerVid(filecount) = [];
            speedums(filecount,:) = [];
            numberOfOnParticles(filecount) = [];
            avgOnSpeedPerVid(filecount) = [];
            stdOnSpeedPerVid(filecount) = [];
            speedonums(filecount,:) = [];
            numberOfOffParticles(filecount) = [];
            avgOffSpeedPerVid(filecount) = [];
            stdOffSpeedPerVid(filecount) = [];
            speedoffums(filecount,:) = [];
            BWprops(filecount,:) = [];
            deltatimes(filecount,:) = [];
            numfiles = length(myFileFolderInfo);
        end
    end
    
    %%used to capture the data from the final video in a folder
    if filecount > 1
        tempspd = [];
        temppartspd = [];
        for k = startcount:filecount-1
            if isempty(speedums{k})
                tempspd = [tempspd NaN];
            else
                tempspd = [tempspd speedums{k}(3,:)];
            end
            if isempty(averages{k})
                temppartspd = [temppartspd NaN];
            else
                temppartspd = [temppartspd averages{k}(2,:)];
            end
        end
        avgSpeedFlowRate = [prevflowrate, mean(tempspd,'omitnan')];
        stdSpeedFlowRate = [prevflowrate, std(tempspd,'omitnan')];
        avgParticleSpeedFlowRate = [prevflowrate, mean(temppartspd,'omitnan')];
        stdParticleSpeedFlowRate = [prevflowrate, std(temppartspd,'omitnan')];
        
        temponspd = [];
        temponpartspd = [];
        for k = startcount:filecount-1
            if isempty(speedonums{k})
                temponspd = [temponspd NaN];
            else
                temponspd = [temponspd speedonums{k}(3,:)];
            end
            if isempty(onaverages{k})
                temponpartspd = [temponpartspd NaN];
            else
                temponpartspd = [temponpartspd onaverages{k}(2,:)];
            end
        end
        avgOnSpeedFlowRate = [prevflowrate, mean(temponspd,'omitnan')];
        stdOnSpeedFlowRate = [prevflowrate, std(temponspd,'omitnan')];
        avgOnParticleSpeedFlowRate = [prevflowrate, mean(temponpartspd,'omitnan')];
        stdOnParticleSpeedFlowRate = [prevflowrate, std(temponpartspd,'omitnan')];
        
        tempoffspd = [];
        tempoffpartspd = [];
        for k = startcount:filecount-1
            if isempty(speedoffums{k})
                tempoffspd = [tempoffspd NaN];
            else
                tempoffspd = [tempoffspd speedoffums{k}(3,:)];
            end
            if isempty(offaverages{k})
                tempoffpartspd = [tempoffpartspd NaN];
            else
                tempoffpartspd = [tempoffpartspd offaverages{k}(2,:)];
            end
        end
        avgOffSpeedFlowRate = [prevflowrate, mean(tempoffspd,'omitnan')];
        stdOffSpeedFlowRate = [prevflowrate, std(tempoffspd,'omitnan')];
        avgOffParticleSpeedFlowRate = [prevflowrate, mean(tempoffpartspd,'omitnan')];
        stdOffParticleSpeedFlowRate = [prevflowrate, std(tempoffpartspd,'omitnan')];
        
        if saveWorkspace
            save(wksavepath);
        end
        if saveData
            excelSheets(2,22:33) = {avgSpeedFlowRate(2) stdSpeedFlowRate(2) avgParticleSpeedFlowRate(2) stdParticleSpeedFlowRate(2)...
                avgOnSpeedFlowRate(2) stdOnSpeedFlowRate(2) avgOnParticleSpeedFlowRate(2) stdOnParticleSpeedFlowRate(2)...
                avgOffSpeedFlowRate(2) stdOffSpeedFlowRate(2) avgOffParticleSpeedFlowRate(2) stdOffParticleSpeedFlowRate(2)};
            xlswrite(xlsavepath, excelSheets(:,:), num2str(prevflowrate));
        end
    end
    allPeak = PlotHistogram(averages);
    if allPeak
        title({filepath; 'All Averages'});
        savefig([savepath 'AllAverageParticleSpeedHistogram']);
    end
    onPeak = PlotHistogram(onaverages);
    if onPeak
        title({filepath; 'On Averages'});
        savefig([savepath 'OnAverageParticleSpeedHistogram']);
    end
    offPeak = PlotHistogram(offaverages);
    if offPeak
        title({filepath; 'Off Averages'});
        savefig([savepath 'OffAverageParticleSpeedHistogram']);
    end
    normalizedtotalstoppedparticleimage = mat2gray(totalstoppedparticleimage/numfiles);
    bwnormalizedtotalstoppedparticleimage = imbinarize(normalizedtotalstoppedparticleimage, 0.25);
    stoppedparticleregions = regionprops(bwnormalizedtotalstoppedparticleimage, normalizedtotalstoppedparticleimage, 'WeightedCentroid', 'MeanIntensity');
    histogram([stoppedparticleregions.MeanIntensity].*100,ceil(max([stoppedparticleregions.MeanIntensity].*100) - min([stoppedparticleregions.MeanIntensity].*100)));
    xlabel('% of Video Stationary');
    ylabel('Number of Particles');
    if ~isempty(stoppedparticleregions)
        title({filepath; 'Length of Stopped Particles'});
        savefig([savepath 'LengthOfStoppedParticles']);
    end
    
catch ME
    disp(ME.stack(1));
    throw(ME);
end