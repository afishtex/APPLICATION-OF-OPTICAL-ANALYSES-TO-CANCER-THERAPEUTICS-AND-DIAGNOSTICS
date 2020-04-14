function [ numberOfParticles, speed, averages, avgSpeedPerVid, stdSpeedPerVid, avgSpeedPerPartPerVid, stdSpeedPerPartPerVid ] = AverageSpeeds( flowrate, speed )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    dbstop if error
    try
        if isempty(speed)
            %totalStoppedParticles = 0;
            numberOfParticles = 0;
            averages = [];
            avgSpeedPerVid = NaN;
            stdSpeedPerVid = NaN;
            avgSpeedPerPartPerVid = NaN;
            stdSpeedPerPartPerVid = NaN;
        else
            maximum = ((3/4)*(flowrate*10^9/60)*(127^2-117^2))/(2500*127^3); % V = (3/4)Q(H^2-y^2)/(WH^3)   um/s within 10um of the surface (cell height between 1-4 um in vitro; http://www.sciencedirect.com/science/article/pii/S0006349500765714) DOF ~ 700nm
            minimum = 3.6;% if it moves farther than 1.8 um, it cannot move back because of the 10 pixel backward limit, doubled for insurance. cannot use equation because the whole point is to account for drag on the cells((3/4)*(flowrate*10^9/60)*(127^2-126.4^2))/(2500*127^3); % um/s within 400nm of the surface (height of a particle)
%             stopparts = unique(speed(1,speed(3,:)<minimum));
%             totalStoppedParticles = CountStoppedParticles( speed, stopparts, minimum );
            speed(:,speed(3,:)<minimum)=NaN;
            speed(:,speed(3,:)>maximum)=NaN; %removes velocities moving faster than the flow profile would allow
            speed(:,isoutlier(speed(3,:))) = NaN; %removes outliers in hopes of removing false information from the datasets
            p = 1;
            tempspeeds = [];
            averages = [];
            cropspeedums = speed(:,~isnan(speed(1,:)));
            while p < length(cropspeedums(1,:))
                k = cropspeedums(1,p);
                while p < length(cropspeedums(1,:)) && cropspeedums(1,p) == k
                    tempspeeds = [tempspeeds cropspeedums(3,p)];
                    p = p+1;
                end
                if length(tempspeeds)>1 %ensure there is enough points to create a reasonable average
                    averages = [averages [k;mean(tempspeeds)]];
                end
                tempspeeds = [];
            end
            numberOfParticles = length(averages);
            if ~isempty(speed)
                avgSpeedPerVid = mean(mean(speed(3,:),'omitnan'),'omitnan');
                stdSpeedPerVid = std(speed(3,:),'omitnan'); %***is this still acurate after outliers have been removed?
            else
                avgSpeedPerVid = NaN;
                stdSpeedPerVid = NaN;
            end
            if ~isempty(averages)
                avgSpeedPerPartPerVid = mean(averages(2,:));
                stdSpeedPerPartPerVid = std(averages(2,:));
            else
                avgSpeedPerPartPerVid = NaN;
                stdSpeedPerPartPerVid = NaN;
            end
        end
    catch ME
        disp(ME.stack(1));
        throw(ME);
    end
end

