function [ distances, particle, prevparticle, BWprops ] = TrackParticle( BWprops, loc, particle, prevparticle, orient, prevcent, missedparticle )
%TRACKPARTICLE Summary of this function goes here
%   
dbstop if error
try
    distances = [];
    while ~isempty(BWprops) 
        if loc<=0
            particle = particle+1;
            break;
        end
        if loc > length(BWprops)
            particle = particle+1;
            loc = length(BWprops);
        end
        if isempty(BWprops{loc})
            BWprops(loc) = [];
            loc = loc-1;
            if loc ~= length(BWprops)
                break;
            end
        else
            if loc == length(BWprops)
                particle = particle+1;
                prevcent = BWprops{loc}(1).Centroid;
                BWprops{loc}(1) = [];
                missedparticle = 0;
                [ prevdistances, particle, prevparticle, BWprops ] = TrackParticle( BWprops, loc-1, particle, prevparticle, orient, prevcent, missedparticle );
                distances = [prevdistances distances];
            else
%                 figure(4); hold on; plot(prevcent(1), prevcent(2),'x'); xlim([0 1920]); ylim([0 1440]); pause(1/1000);
                a = tand(orient);
                b = -1;
                c = prevcent(2)-tand(orient)*prevcent(1);
                i=1;
                while i <= length(BWprops{loc})
                    %slope = atand((BWprops{loc}(i).Centroid(2)-prevcent(2))/(BWprops{loc}(i).Centroid(1)-prevcent(1)));
                    %because particles are being tracked from the end of
                    %the video to the beginning, particles with centers to
                    %the left of the last particle should not be
                    %considered. particles who are less than 10 pixels off
                    %of the slope line should be considered.
                    if BWprops{loc}(i).Centroid(1) >= prevcent(1)-10 &&...%&&abs(diff([slope(1), orient(1)])) < 3*orient(2) 
                            abs(a*BWprops{loc}(i).Centroid(1)+b*BWprops{loc}(i).Centroid(2)+c)/sqrt(a^2+b^2) < 10 %looking for the differences between the heights of the current and previous particle
                        missedparticle = 0;
                        if diff([prevparticle particle]) > 1
                            particle = prevparticle+1;
                        end
                        prevparticle = particle;
                        distances = [particle; loc; pdist([prevcent; BWprops{loc}(i).Centroid]); min([max([BWprops{loc}(i).Centroid(1) 1]) 1440]); min([max([BWprops{loc}(i).Centroid(2) 1]) 1920]); BWprops{loc}(i).Eccentricity];
                        
                        prevcent = BWprops{loc}(i).Centroid;
                        BWprops{loc}(i) = [];
                        [ prevdistances, particle, prevparticle, BWprops ] = TrackParticle( BWprops, loc-1, particle, prevparticle, orient, prevcent, missedparticle );
                        distances = [prevdistances distances];
                        missedparticle = 1; %prevent code from hitting missed particles after successfully finding a particle
                        break;
                    end
                    i=i+1;
                end
                if loc <= length(BWprops) && i == length(BWprops{loc})+1 && ~missedparticle
                    missedparticle = 1;
                    if diff([prevparticle particle]) > 1
                        particle = prevparticle+1;
                    end
                    distances = [particle; loc; NaN; prevcent(1); prevcent(2); NaN];
                    [ prevdistances, particle, prevparticle, BWprops ] = TrackParticle( BWprops, loc-1, particle, prevparticle, orient, prevcent, missedparticle );
                    if isempty(prevdistances)
                        distances = [];
                        break;
                    end
                    prevdistances(3,end) = prevdistances(3,end)/2;
                    distances(3) = prevdistances(3,end);
                    distances(4:6) = [min([max([prevdistances(4,end)+cosd(orient)*distances(3) 1]) 1440]); min([max([prevdistances(5,end)+sind(orient)*distances(3) 1]) 1920]); prevdistances(6,end)];
                    distances = [prevdistances distances];
                end
                break;
            end
%             close gcf;
        end
    end
catch ME
    disp(ME.stack(1));
    throw(ME);
end
end

