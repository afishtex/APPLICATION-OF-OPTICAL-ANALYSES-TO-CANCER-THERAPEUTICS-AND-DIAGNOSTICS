function filtBW2 = LoadCellsConfluent( path, name )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
dbstop if error
    filename = [path '\' name];
    try
        reader = bfGetReader(filename);
        %extract frames and change to binary
        img = bfGetPlane(reader, 1);
        
        initialGrey = mat2gray(img);
        adj = imadjust(initialGrey);
        %filtgry = wiener2(initialGrey,[4 4]); %could be causing edge effects
        %filtgry = imfilter(gry,ones(3,3) / 9);
        BW = imbinarize(adj,0.3);
        dilatedImage = imdilate(BW,strel('disk',2));
        BW2 = bwmorph(dilatedImage, 'bridge');
        BW3 = imfill(BW2,'holes');
        filtBW = bwareafilt(BW3,[500,inf]);%a little more than a 1um particle up to a 3um particle area
        %filtBW2 = bwpropfilt(filtBW,'Eccentricity',[0 0.95]);
%         figure;
%         imshow(filtBW); %play video
%         figure;
%         imshow(initialGrey);
        filtBW2 = imresize(filtBW,[1440 1920]);
        reader.close();
    catch ME
        disp(ME.stack(1));
        throw(ME);
    end

end

