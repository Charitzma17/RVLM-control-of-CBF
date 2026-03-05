% Integrate all AAV analyzed data saved across different tables due memory
% allocation issue.
% Optimized version — May 2025
clearvars
close all
clc

%% === Folder and area definitions ===
Folderlist = {
    'Z:\Karishma\mCherry A2';
    'Z:\Karishma\dbhcre_DOImCherry f1 & f2\f2\f2_tiffs';
    'Z:\Karishma\dbhcre_DOImCherry f1 & f2\f1\f1_tiffs';
    'E:\AAV_newbatch_october_mcherrydata_2025\dbleF1'
    'E:\AAV_newbatch_october_mcherrydata_2025\dblef3';};

listofareas = {
    'NTS'; 'L.PCRtandIRt'; 'AP'; 'CVLM'; 'L.LC'; 'PAGandDR';
    'L.PBNandTg'; 'R.PBNandTg'; 'L.VTA'; 'L.ZI'; 'L.LH'; 'PVH';
    'PVT'; 'SFO'; 'PO'; 'STandseptum'; 'R.ZI'; 'R.LH'; 'R.VTA';
    'L.MRN'; 'R.MRN'; 'R.LC'; 'R.PCRtandIRt'
};

load volume.mat;

volume_sorted = [volume(1); sum(volume(2:3)); volume(4); volume(5); volume(6);
    sum(volume(7:8)); sum(volume(9:11)); volume(12); volume(13); volume(14);
    volume(15); volume(16); volume(17); volume(18); sum(volume(19:24)); sum(volume(25:30))];

volume_ids = {
    'NTS'; 'PCRtandIRt'; 'AP'; 'LC'; 'PAGandDR'; 'PBNandTg'; 'MRN';
    'VTA'; 'ZI'; 'LH'; 'PVH'; 'PVT'; 'SFO'; 'PO'; 'STandSeptum'
};

%% === Preallocation ===
maxSections = 50; % set to reasonable upper limit per area
numFolders = length(Folderlist);
numAreas = length(listofareas);

mean_I      = nan(numFolders, numAreas, maxSections);
numel_pix   = nan(numFolders, numAreas, maxSections);
mean_noise  = nan(numFolders, numAreas, maxSections);
matchingIDs = nan(numFolders, numAreas, maxSections, 3);

%% === Main processing loop ===
tic
for fl = 1:numFolders
    folder = Folderlist{fl};
    files = dir(fullfile(folder, '*table*.mat'));

    for filenum = 1:length(files)
        filePath = fullfile(folder, files(filenum).name);

        % Only load the variable containing "table" in its name
        info = whos('-file', filePath);
        varNames = {info.name};
        tableVar = varNames{contains(varNames, 'table', 'IgnoreCase', true)};
        if isempty(tableVar)
            warning('No "table" variable found in %s', filePath);
            continue;
        end
        data = load(filePath, tableVar);
        sAll = data.(tableVar)(:);  % flatten 3D structure

        % Loop through all entries once
        for n = 1:numel(sAll)
            s = sAll(n);
            if ~isfield(s, 'areacode') || isempty(s.areacode)
                continue;
            end

            % Find area index
            idxArea = find(strcmp(listofareas, s.areacode));
            if isempty(idxArea)
                continue;
            end

            % Determine section counter for that area
            existing = squeeze(mean_I(fl, idxArea, :));
            countr = find(isnan(existing), 1, 'first');
            if isempty(countr) || countr > maxSections
                continue; % skip if beyond preallocated limit
            end

            % Fill data
            mean_I(fl, idxArea, countr) = s.avg_int;
            numel_pix(fl, idxArea, countr) = nnz(s.filtim == 1);
            if isfield(s, 'bgnoise') && ~isempty(s.bgnoise)
                mean_noise(fl, idxArea, countr) = s.bgnoise;
            end

            % Get [i, j, k] coordinates efficiently
            [i, j, k] = ind2sub(size(data.(tableVar)), n);
            matchingIDs(fl, idxArea, countr, :) = [i, j, k];
        end
    end

    fprintf('Processed folder %d/%d: %s\n', fl, numFolders, folder);
end
toc

%% === Save outputs ===
save('AAV_integrated_results.mat', 'mean_I', 'numel_pix', 'mean_noise', 'matchingIDs', 'listofareas', 'Folderlist');
fprintf('Results saved to AAV_integrated_results.mat\n');
