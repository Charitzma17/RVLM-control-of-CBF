% Code to process AAV labelled images for projections to various areas


clearvars
close all
clc

% folders with the tiffs generated from the czi files for analysis....
Folderlist = {'Z:\Karishma\mCherry A1';...
    'Z:\Karishma\mCherry A2';...
    'Z:\Karishma\dbhcre_DOImCherry f1 & f2\f2\f2_tiffs';...
    'Z:\Karishma\dbhcre_DOImCherry f1 & f2\f1\f1_tiffs';};


listofareas = {'NTS';...
    'L.PCRtandIRt';...
    'AP';...
    'CVLM';...
    'L.LC';...
    'PAGandDR';...
    'L.PBNandTg';...
    'R.PBNandTg';...
    'L.VTA';...
    'L.ZI';...
    'L.LH';...
    'PVH';...
    'PVT';...
    'SFO';...
    'PO';...
    'STandseptum';...
    'R.ZI';...
    'R.LH';...
    'R.VTA';...
    'L.MRN';...
    'R.MRN';
    'R.LC';...
    'R.PCRtandIRt';};% unknown patch around the red nucleus--? converging to medial reticular nucleus... Jan 28th 2025
%PO: preoptic areas, ST: stria terminalis and septum are repesentives of the basal forebrain



% run through folders and process every section by some basic image
% processing steps
for fld = 1:length(Folderlist)
    folder_temp = Folderlist(fld);
    cd(cell2mat(folder_temp)) % switch to the folder of interest...
    % if fld>2
    %     fileList = dir('**/*.tif*');% list of folders having the tiff files
    % else
        fileList = dir('**/*ome.tif*');% list of folders having the tiff files
        start = 1;% the other two folders : folder 3 and 4 have numbering different in the files
    % end
    numFiles = length(fileList);
    for k = 1:numFiles
        FullFileName = fullfile(fileList(k).folder, fileList(k).name);
        fprintf('Processing image %d of %d : %s...\n', k, numFiles, FullFileName);
        Image = imread(FullFileName);
        % if fld>2
            % R_Ch = Image(:,:,1);% red channel for projection field
            % figure(2);imshow(R_Ch);
        % else
        %
        % Im1 = im2double(Image);
            a = 1/255;
            b = 4/255;
            R_Ch = imadjust(Image,[a b]); %jan 14 2025

            figure(2);imshow(R_Ch);
            %
            % R_Ch = uint8(R_Ch);
        %end
        listofareas
        areacodes = input('areacodes:');% input fullnames of the areas from the listofareas
        % this is to generate various masked images to only quantify the areas of
        % interest...
        if (areacodes)

        for num = 1:numel(areacodes)
            num
            mask = imfreehand;% draw area bounds based on atlas

            maskvar = mask.createMask();
            % if k>1
            maskvar_temp = uint8(maskvar);
            % maskvar_temp = double(maskvar);

            % else
                % maskvar_temp = uint16(maskvar);
            % end
            maskedI = maskvar_temp.*R_Ch;                                                     
            thresh = mean(maskedI(:));
            %
            bin_thresh = 0.65;%0.25 for f1;%0.5 for f2
            % Bin_im = imbinarize(maskedI,bin_thresh);% not using the gaussan filt
            % figure(11)
            % 
            % imshow(Bin_im);%,maskedI)

            med_RCh = maskedI;%medfilt2(maskedI,[1 1]);% [20 20] for f1 and f2
            % med_RCh(med_RCh<thresh)= 0;
            Bin_im = imbinarize(med_RCh,bin_thresh);
            MFilt_im = medfilt2(Bin_im,[5 5]); %[20 20]

            % MFilt_im = medfilt2(Bin_im,[20 20]);

            figure(12)   
            
            imshowpair(maskedI,MFilt_im);
            %
            pause(0.1)
            figure(3);
            title('Bgselect')
            noise = imcrop(R_Ch);

            table(fld,k,fld).bgnoise = mean(noise(:));
            % for intensity quantification----

            nonzeroI = med_RCh(med_RCh~=0);% non zero median filtered values
            %save all values in the table here
            table(fld,k,num).filtim = MFilt_im;
            table(fld,k,num).binthresh= bin_thresh;
            table(fld,k,num).area = FullFileName;
            table(fld,k,num).areacode = listofareas(areacodes(num));% name of the area quantified
            table(fld,k,num).avg_int = mean(nonzeroI(:));% mean pixel intensit
            table(fld,k,num).pars= [a,b,bin_thresh];

            %     table(k).pixel_density = numel(temp4==1)./(size(temp4,1).*size(temp4,2));
            table(fld,k,num).pixelfiltered = numel(MFilt_im ==1);
        end
        end
    end
end
