fileDir = 'C:\Users\Andrew\Documents\Clearing TLS\v2\Analysis';
outfile = 'C:\Users\Andrew\Documents\Clearing TLS\v2\Analysis\Combined Hot Spots.xlsx';
addpath(fileDir);
fileNames = dir(fileDir);
fileNames = {fileNames.name};
fileNames = fileNames(cellfun(...
    @(f)contains(f,'.xlsx'),fileNames)); %~isempty(strfind(f,'.xlsx'))
for f = 1:numel(fileNames)
    fTable = readtable(fileNames{f},'Sheet',fileNames{f}(end-8:end-5));
    writetable(fTable,outfile,'Sheet',fileNames{f}(end-8:end-5));
end