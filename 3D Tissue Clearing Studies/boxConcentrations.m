function conc = boxConcentrations(centers,boxDim)
%boxConcentrations Counts the number of cells in each volume
%   Volume defined by boxDim
    imageDim = size(centers);
    conc = zeros(imageDim(1)-(boxDim(1)-1),imageDim(2)-(boxDim(2)-1),imageDim(3)-(boxDim(3)-1));
    if max(max(max(centers))) ~= 0
        for i = 1:size(conc,3) %:floor(boxDim(3)/10):
            for j = 1:floor(boxDim(2)/10):size(conc,2)
                for k = 1:floor(boxDim(1)/10):size(conc,1)
                    conc(k,j,i) = sum(sum(sum(centers(k:k+(boxDim(1)-1),j:j+(boxDim(2)-1),i:i+(boxDim(3)-1)))));
                end
            end
        end
    end
end