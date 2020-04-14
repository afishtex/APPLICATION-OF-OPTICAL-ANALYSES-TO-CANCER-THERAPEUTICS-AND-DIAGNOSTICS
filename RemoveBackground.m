function bgsibfimg = RemoveBackground( bfimg )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    ibfimg = imcomplement(bfimg);
    r=6;
    figure(1);
    imshow(ibfimg);
    H1 = impoint(gca);
    position = wait(H1);
    [xgrid1, ygrid1] = meshgrid(1:size(ibfimg,2), 1:size(ibfimg,1));
    bgmask = ((xgrid1-position(1)).^2 + (ygrid1-position(2)).^2) <= r.^2;
    bgvalues = ibfimg(bgmask);
    bg = sum(bgvalues(:))/length(find(bgmask==1));
    bgsibfimg = ibfimg-bg;

end

