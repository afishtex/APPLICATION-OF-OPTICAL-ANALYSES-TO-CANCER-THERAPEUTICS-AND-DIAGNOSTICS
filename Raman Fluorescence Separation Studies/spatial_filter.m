function [ arrayout ] = spatial_filter( arrayin,filter_template )
%SPATIAL_FILTER Spatial averages an array by Nearest Neighbor (NN) or Next-
%Nearest Neighbor (NNN)
%   filter in is a 3x3 array showing the weight for each plane. Each plane
%   in arrayin should be multipled by filter and summed.
%   output array will be reduced by 2 rows and 2 columns

%   Author(s): A. Fisher, K. Meissner
%   Centre of NanoHealth, College of Science, 
%   Swansea University, Singleton Park, Swansea, SA2 8PP, United Kingdom

    [rows,cols,spec] = size(arrayin);
    arrayout = zeros(rows-2,cols-2,spec);
    filtmat = repmat(filter_template,1,1,spec);
    for r = 2:rows-1
        for c = 2:cols-1
            tmp = arrayin(r-1:r+1,c-1:c+1,:).*filtmat;
            arrayout(r-1,c-1,:) = sum(sum(tmp,1),2);
        end
    end
end

