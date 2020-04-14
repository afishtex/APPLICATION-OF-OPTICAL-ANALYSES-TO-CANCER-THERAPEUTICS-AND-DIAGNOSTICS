function totalStoppedParticle = CountStoppedParticles( speedum, stopparts, minimum )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
totalStoppedParticle = 0;
n = 1;
    while n <= length(stopparts)
        temppart = speedum(:,speedum(1,:)==stopparts(n));
        temppart = temppart(:,temppart(3,:)<minimum);
%         if length(temppart(1,:)) > 50 %if the particle is stuck for at least 50 frames
%             if mean(temppart(6,:))<0.5 %eccentricity is round
                if pdist([temppart(4,1) temppart(5,1); temppart(4,end) temppart(5,end)]) < 10 %distance from the first center to the last center is less than 10, checking for particles that are stopped but the code thought they jumped from one point to another
                    m = n+1;
                    while m <= length(stopparts) %concatinate and delete duplicate particles
                        temppart2 = speedum(:,speedum(1,:)==stopparts(m));
                        if pdist([temppart(4,1) temppart(5,1); temppart2(4,1) temppart2(5,1)]) < 10 && pdist([temppart(4,1) temppart(5,1); temppart2(4,end) temppart2(5,end)]) < 10
                            temppart = [temppart temppart2];
                            stopparts(m)=[];
                            m = m-1;
                        end
                        m = m+1;
                    end
                    if length(temppart(1,:)) > 50 %if the particle is stuck for at least 50 frames
                        if mean(temppart(6,:))<0.5 %eccentricity is round
                            totalStoppedParticle = totalStoppedParticle+1;
                        end
                    end
                    stopparts(n)=[];
                else
                    %beggining of temppart
                    m = n+1;
                    while m <= length(stopparts)
                        temppart2 = speedum(:,speedum(1,:)==stopparts(m));
                        if pdist([temppart(4,1) temppart(5,1); temppart2(4,1) temppart2(5,1)]) < 10 && pdist([temppart(4,1) temppart(5,1); temppart2(4,end) temppart2(5,end)]) < 10
                            temppart = [temppart temppart2];
                            stopparts(m)=[];
                            m = m-1;
                        end
                        m = m+1;
                    end
                    if length(temppart(1,:)) > 50 %if the particle is stuck for at least 50 frames
                        if mean(temppart(6,:))<0.5 %eccentricity is round
                            totalStoppedParticle = totalStoppedParticle+1;
                        end
                    end
                    %end of temppart
                    m = n+1;
                    while m <= length(stopparts)
                        temppart2 = speedum(:,speedum(1,:)==stopparts(m));
                        if pdist([temppart(4,end) temppart(5,end); temppart2(4,1) temppart2(5,1)]) < 10 && pdist([temppart(4,end) temppart(5,end); temppart2(4,end) temppart2(5,end)]) < 10
                            temppart = [temppart temppart2];
                            stopparts(m)=[];
                            m = m-1;
                        end
                        m = m+1;
                    end
                    if length(temppart(1,:)) > 50 %if the particle is stuck for at least 50 frames
                        if mean(temppart(6,:))<0.5 %eccentricity is round
                            totalStoppedParticle = totalStoppedParticle+1;
                        end
                    end
                    stopparts(n)=[];
                end
%             else
%                 n = n+1;
%             end
%         else
%             n = n+1;
%         end
    end

end

