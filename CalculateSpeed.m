function [ speed, speedon, speedoff, numparticles ] = CalculateSpeed( BWprops, deltatimes, umPerPix, orient, masks )
%CALCULATESPEED Summary of this function goes here
%   Detailed explanation goes here
    dbstop if error
    speed = [];
    speedon = [];
    speedoff = [];
    numparticles = 0;
    startparticles = 0;
    startloc = length(BWprops);
    try
        distance = TrackParticle( BWprops, startloc, startparticles, startparticles, orient);
        if ~isempty(distance)
            speed(1:2,:) = distance(1:2,:);
            speed(4:6,:) = distance(4:6,:);
            for i = 1:length(distance(3,:))
            speed(3,i) = distance(3,i)*umPerPix./deltatimes(distance(2,i));
                if masks(round(speed(5,i)), round(speed(4,i))) == 1
                    speedon = [speedon speed(:,i)];
                else
                    speedoff = [speedoff speed(:,i)];
                end
            end
            numparticles = speed(1,1);
        else
            speed = NaN(3,1);
        end
    catch ME
        disp(ME.stack(1));
        throw(ME);
    end
end

