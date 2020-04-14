function [filtImg, compFactor] = calcComp( giver, taker )
%loadTifImages Searches for cell sized fluorescence
%   outputs center values for all colors
    compFactor = 0;
    minimum = inf;
    for i = 0:0.1:5
        summation = sum(sum(abs(giver-taker*i)));
        if summation < minimum
            minimum = summation;
            compFactor = i;
            filtImg = giver-taker*i;
        end
    end
%     figure; imshow(giver);
%     figure; imshow(filtImg);
end