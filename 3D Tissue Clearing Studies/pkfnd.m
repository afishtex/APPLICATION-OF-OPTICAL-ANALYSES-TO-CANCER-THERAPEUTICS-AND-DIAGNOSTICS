function out=pkfnd(im,th,sz,fillFactor)
% finds local maxima in an image to pixel level accuracy.   
%  this provides a rough guess of particle
%  centers to be used by cntrd.m.  Inspired by the lmx subroutine of Grier
%  and Crocker's feature.pro
% INPUTS:
% im: image to process, particle should be bright spots on dark background with little noise
%   ofen an bandpass filtered brightfield image (fbps.m, fflt.m or bpass.m) or a nice
%   fluorescent image
% th: the minimum brightness of a pixel that might be local maxima. 
%   (NOTE: Make it big and the code runs faster
%   but you might miss some particles.  Make it small and you'll get
%   everything and it'll be slow.)
% sz:  if your data's noisy, (e.g. a single particle has multiple local
% maxima), then set this optional keyword to a value slightly larger than the diameter of your blob.  if
% multiple peaks are found withing a radius of sz/2 then the code will keep
% only the brightest.  Also gets rid of all peaks within sz of boundary
%OUTPUT:  a N x 2 array containing, [row column] coordinates of local maxima
%CREATED: Eric R. Dufresne, Yale University, Feb 4 2005
%MODIFIED: ERD, 5/2005, got rid of ind2rc.m to reduce overhead on tip by
%  Dan Blair;  added sz keyword 
% ERD, 6/2005: modified to work with one and zero peaks, removed automatic
%  normalization of image
% ERD, 6/2005: due to popular demand, altered output to give x and y
%  instead of row and column
% ERD, 8/24/2005: pkfnd now exits politely if there's nothing above
%  threshold instead of crashing rudely
% ERD, 6/14/2006: now exits politely if no maxima found
% ERD, 10/5/2006:  fixed bug that threw away particles with maxima
%  consisting of more than two adjacent points



%find all the pixels above threshold
%im=im./max(max(im)); 
ind=find(im > th);
[nr,nc]=size(im);
tst=zeros(nr,nc);
n=length(ind);
if n==0
    out=[];
    display('nothing above threshold');
    return;
end
mx=[];
%convert index from find to row and column
rc=[mod(ind,nr),floor(ind/nr)+1];
for i=1:n
    r=rc(i,1);c=rc(i,2);
    %check each pixel above threshold to see if it's brighter than it's neighbors
    %  THERE'S GOT TO BE A FASTER WAY OF DOING THIS.  I'M CHECKING SOME MULTIPLE TIMES,
    %  BUT THIS DOESN'T SEEM THAT SLOW COMPARED TO THE OTHER ROUTINES, ANYWAY.
    if r>1 & r<nr & c>1 & c<nc
        if im(r,c)>=im(r-1,c-1) & im(r,c)>=im(r,c-1) & im(r,c)>=im(r+1,c-1) & ...
         im(r,c)>=im(r-1,c)  & im(r,c)>=im(r+1,c) &   ...
         im(r,c)>=im(r-1,c+1) & im(r,c)>=im(r,c+1) & im(r,c)>=im(r+1,c+1)
        mx=[mx,[r,c]']; 
        %tst(ind(i))=im(ind(i));
        end
    end
end
%out=tst;
mx=mx';

[npks,crap]=size(mx);

%if size is specified, then get rid of pks within size of boundary + border
%from bpass filter (15 points from the edge)
if nargin>=3 & npks>0
   %throw out all pks within sz of boundary;
    ind=find(mx(:,1)>(sz+15) & mx(:,1)<(nr-(sz+15)) & mx(:,2)>(sz+15) & mx(:,2)<(nc-(sz+15)));
    mx=mx(ind,:); 
end

%prevent from finding peaks within size of each other
[npks,crap]=size(mx);
if npks > 1 
    %CREATE AN IMAGE WITH ONLY PEAKS
    nmx=npks;
    tmp=0.*im; %variable declaration, similar to zeros()
    for i=1:nmx
        tmp(mx(i,1),mx(i,2))=im(mx(i,1),mx(i,2)); %tmp is zero everywhere except where the peaks are
    end
    %LOOK IN NEIGHBORHOOD AROUND EACH PEAK, PICK THE BRIGHTEST
    for i=1:nmx
        roi=tmp( (mx(i,1)-floor(sz/2)):(mx(i,1)+(floor(sz/2)+1)),(mx(i,2)-floor(sz/2)):(mx(i,2)+(floor(sz/2)+1))) ; %defines the region of interest around the peak
        [mv,indi]=max(roi); %save max value of the columns in the roi and the column position
        [mv,indj]=max(mv); %save the max value of the rows and the row position
        tmp( (mx(i,1)-floor(sz/2)):(mx(i,1)+(floor(sz/2)+1)),(mx(i,2)-floor(sz/2)):(mx(i,2)+(floor(sz/2)+1)))=0;
        tmp(mx(i,1)-floor(sz/2)+indi(indj)-1,mx(i,2)-floor(sz/2)+indj-1)=mv;
    end
    ind=find(tmp>0);
    mx=[mod(ind,nr),floor(ind/nr)+1];
end

[npks,crap]=size(mx);
if npks > 1 
    %CREATE AN IMAGE WITH ONLY PEAKS
    nmx=npks;
    tmp=0.*im; %variable declaration, similar to zeros()
    for i=1:nmx
        tmp(mx(i,1),mx(i,2))=im(mx(i,1),mx(i,2)); %tmp is zero everywhere except where the peaks are
    end
    %LOOK IN NEIGHBORHOOD AROUND EACH PEAK, PICK THE BRIGHTEST
    for i=1:nmx
        %added by andrew fisher 20190219
        %remove peaks in areas where it does not fill at least *fillFactor* of the circle of
        %interest
        imROI = im( (mx(i,1)-floor(sz/2)):(mx(i,1)+(floor(sz/2)+1)),(mx(i,2)-floor(sz/2)):(mx(i,2)+(floor(sz/2)+1)));
        emptyness = find(imROI(:) < th);
        if length(emptyness) >= floor(fillFactor*length(imROI(:)))
            tmp( (mx(i,1)-floor(sz/2)):(mx(i,1)+(floor(sz/2)+1)),(mx(i,2)-floor(sz/2)):(mx(i,2)+(floor(sz/2)+1)))=0;
        end
        %make sure there is a local contrast larger than one pixel, look at
        %the maximum third of pixels compared to the minimum third.
        mid = logical([0,0,0,0,0,0,0,0,0,0,0,0,0,0;...
               0,0,0,0,0,0,0,0,0,0,0,0,0,0;...
               0,0,0,0,0,0,0,0,0,0,0,0,0,0;...
               0,0,0,1,1,1,1,1,1,1,1,0,0,0;...
               0,0,0,1,1,1,1,1,1,1,1,0,0,0;...
               0,0,0,1,1,1,1,1,1,1,1,0,0,0;...
               0,0,0,1,1,1,1,1,1,1,1,0,0,0;...
               0,0,0,1,1,1,1,1,1,1,1,0,0,0;...
               0,0,0,1,1,1,1,1,1,1,1,0,0,0;...
               0,0,0,1,1,1,1,1,1,1,1,0,0,0;...
               0,0,0,1,1,1,1,1,1,1,1,0,0,0;...
               0,0,0,0,0,0,0,0,0,0,0,0,0,0;...
               0,0,0,0,0,0,0,0,0,0,0,0,0,0;...
               0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
        edge = logical([1,1,1,1,1,1,1,1,1,1,1,1,1,1;...
                1,0,0,0,0,0,0,0,0,0,0,0,0,1;...
                1,0,0,0,0,0,0,0,0,0,0,0,0,1;...
                1,0,0,0,0,0,0,0,0,0,0,0,0,1;...
                1,0,0,0,0,0,0,0,0,0,0,0,0,1;...
                1,0,0,0,0,0,0,0,0,0,0,0,0,1;...
                1,0,0,0,0,0,0,0,0,0,0,0,0,1;...
                1,0,0,0,0,0,0,0,0,0,0,0,0,1;...
                1,0,0,0,0,0,0,0,0,0,0,0,0,1;...
                1,0,0,0,0,0,0,0,0,0,0,0,0,1;...
                1,0,0,0,0,0,0,0,0,0,0,0,0,1;...
                1,0,0,0,0,0,0,0,0,0,0,0,0,1;...
                1,0,0,0,0,0,0,0,0,0,0,0,0,1;...
                1,1,1,1,1,1,1,1,1,1,1,1,1,1]);
        if mean(imROI(mid)) < 3*mean(imROI(edge))
            tmp( (mx(i,1)-floor(sz/2)):(mx(i,1)+(floor(sz/2)+1)),(mx(i,2)-floor(sz/2)):(mx(i,2)+(floor(sz/2)+1)))=0;
        end
%         if mean(maxk(imROI(:),floor(size(imROI,1)*size(imROI,2)/3))) < 2*mean(mink(imROI(:),floor(size(imROI,1)*size(imROI,2)/3)))
%             tmp( (mx(i,1)-floor(sz/2)):(mx(i,1)+(floor(sz/2)+1)),(mx(i,2)-floor(sz/2)):(mx(i,2)+(floor(sz/2)+1)))=0;
%         end
    end
    ind=find(tmp>0);
    mx=[mod(ind,nr),floor(ind/nr)+1];
end

if size(mx)==[0,0]
    out=[];
else
    out = mx;
%     out(:,2)=mx(:,1);
%     out(:,1)=mx(:,2);
end
