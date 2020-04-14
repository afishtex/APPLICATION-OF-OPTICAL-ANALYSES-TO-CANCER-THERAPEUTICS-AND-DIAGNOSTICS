function bgscellimg = RemoveBackground_v2( cellimg )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    r=6;
    figure(1);
    imshow(cellimg);
    H1 = impoint(gca);
    position = wait(H1);
    [xgrid1, ygrid1] = meshgrid(1:size(cellimg,2), 1:size(cellimg,1));
    bgmask = ((xgrid1-position(1)).^2 + (ygrid1-position(2)).^2) <= r.^2;
    bgvalues = cellimg(bgmask);
    bg = sum(bgvalues(:))/length(find(bgmask==1));
    bgscellimg = cellimg-bg;

end

