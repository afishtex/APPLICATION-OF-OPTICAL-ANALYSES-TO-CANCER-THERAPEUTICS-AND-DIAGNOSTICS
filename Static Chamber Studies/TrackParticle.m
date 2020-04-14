function [ distances, particle, prevparticle, BWprops ]...
    = TrackParticle( BWprops, loc, particle, prevparticle, masks, prevCenter )
%TRACKPARTICLE Track brownian motion of particles within a certain radius
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
                prevCenter = BWprops{loc}(1).Centroid;
                if masks(round(prevCenter(2)), round(prevCenter(1))) == 1
                    OnCell = true;
                else
                    OnCell = false;
                end
                firstdistances = [particle; loc; OnCell; NaN;...
                            BWprops{loc}(1).Centroid(1); BWprops{loc}(1).Centroid(2)];
                BWprops{loc}(1) = [];
                [ prevdistances, particle, prevparticle, BWprops ]...
                    = TrackParticle( BWprops, loc-1, particle, prevparticle, masks, prevCenter );
                if isempty(prevdistances)
                    firstdistances(1) = NaN;
                else
                    firstdistances(1) = prevdistances(1,1);
                end
                distances = [prevdistances firstdistances distances];
            else
                for i = 1:length(BWprops{loc})
                    if abs(pdist([BWprops{loc}(i).Centroid; prevCenter])) < 20
                        if diff([prevparticle particle]) > 1
                            particle = prevparticle+1;
                        end
                        prevparticle = particle;
                        if masks(round(BWprops{loc}(i).Centroid(2)), round(BWprops{loc}(i).Centroid(1))) == 1
                            OnCell = true;
                        else
                            OnCell = false;
                        end
                        distances = [particle; loc; OnCell; pdist([prevCenter; BWprops{loc}(i).Centroid]);...
                            BWprops{loc}(i).Centroid(1); BWprops{loc}(i).Centroid(2)];
                        prevCenter = BWprops{loc}(i).Centroid;
                        BWprops{loc}(i) = [];
                        [ prevdistances, particle, prevparticle, BWprops ]...
                            = TrackParticle( BWprops, loc-1, particle, prevparticle, masks, prevCenter );
                        distances = [prevdistances distances];
                        break;
                    end
                end
                break;
            end
        end
    end
catch ME
    disp(ME.stack(1));
    throw(ME);
end
end

