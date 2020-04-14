function masks = CellMasks_v2( cellimg )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    %bgscellimg = RemoveBackground_v2(cellimg);
    initialGrey = mat2gray(cellimg);
    BW = imbinarize(initialGrey,0.05);
    masks = bwareafilt(BW,[50,inf]);
    BWoutline = bwperim(masks);
    Segout = cellimg; 
    Segout(BWoutline) = max(Segout(:)); %add color
    figure, imshow(Segout);
end

