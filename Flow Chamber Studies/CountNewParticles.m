function [totalparticles, newparticles] = CountNewParticles( old, present, cellimg )
%CountNewParticles Summary of this function goes here
%   Detailed explanation goes here
    n = 1;
    while n <= length(old{1})
        temp = old{1};
        if ~cellimg(round(temp(n).Centroid(2)), round(temp(n).Centroid(1)))
            old{1}(n) = [];
            n = n-1;
        end
        n = n+1;
    end
    m = 1;
    while m <= length(present{1})
        temp = present{1};
        if ~cellimg(round(temp(m).Centroid(2)), round(temp(m).Centroid(1)))
            present{1}(m) = [];
            m = m-1;
        end
        m = m+1;
    end

    newparticles = length(present{1});
    if ~isempty(old{1})
        for i = 1:length(present{1})
            for j = 1:length(old{1})
                temppres = present{1};
                tempold = old{1};
                if pdist([temppres(i).Centroid; tempold(j).Centroid]) < 10
                    newparticles = newparticles-1;
                end
            end
        end
    else
        newparticles = length(present{1});
    end
    totalparticles = length(present{1});
end

