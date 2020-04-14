function masks = CellMasks( path, name )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

filename = [path '\' name];
    try
        reader = bfGetReader(filename);
        filtermetastr = char(reader.getGlobalMetadata());
        %extract filter
        fluor = regexp(filtermetastr, 'BF'); %'\(TRITC');
        if fluor %check difference between TRITC and BF
            %extract frames and change to binary
            bfimg = bfGetPlane(reader, 1);
            initialGrey = mat2gray(bfimg);
            figure; imshow(initialGrey);
            condition = true;
            masks = false(size(initialGrey)); %initialize with zeros
            i = 1;
            x={};y={};
            while condition
                [mask, x{i}, y{i}] = roipoly(initialGrey); %user created masks
                masks = masks + mask; % adds a mask to the array
                if length(find(mask==1))<10 %the cuttoff condition
                    condition = false;
                    x{i} = [];
                    y{i} = [];
                end
                i = i+1;
            end
            masks(masks>1) = 1; %adjusts for overlapping cells
            figure(1); imshow(initialGrey);
            hold on;
            for j = 1:length(x)
                h=fill(x{j},y{j},'c');
                set(h,'FaceColor','none');
                set(h,'EdgeColor','c');
                set(h,'LineWidth',2);
            end
        end
        reader.close();
    catch ME
        disp(ME.stack(1));
        throw(ME);
    end

    

end

