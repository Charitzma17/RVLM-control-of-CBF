% CODE to process tifMap files obtained from the two photon microscope..
% Code first extracts the channel immages,
% applies basic image processing, rotates the image if vessel is diagonal,
% makes a binary masked tif stack, followed by summing along the vessel
% axis to convert to a 1-D signal, then calculated full width half maximum.
% all trials stored as a mat file for calculating stim triggered avg across
% trials



clearvars
close all
clc

%
% addition of one more loop for roi1 since multiple frequencies.....

list = {'roi1_6mw_5s_ON';...
    'roi1_6mw_10hz';...
    'roi1_6mw_30hz';...
    'roi1_6mw_50hz';};
numtrials = 15;
for names = 1:length(list)
    tic

    trname = list{names};
    for numtr = 1:numtrials
        imname = strcat(trname,'_tr_000',num2str(numtr,'%0.2d'),'.tif');

        y1 = tiffMap(imname);
        ves_chan = squeeze(y1(3,:)); % cy5.5 channel
        % stim_chan = squeeze(y1(4,:));% channel 4 is the electrical signal of the optogenetic stim
        %
        for i = 1:size(ves_chan,3)% total number of frames or units of time

            imdisp1 = ves_chan(:,:,i);
            i
            if numtr ==1 && i ==1 && names ==1
                imdisp = imshow(max(ves_chan,[],3));% plotting the max projection
                %         disp_img = imshow(img2);
                [temp1, roi1] = imcrop(imdisp);
                sumdir = input('rowvector=1 or columvector=2:')

            end
            Image = imcrop(imdisp1,roi1);% crop first before applying filters and pre processing
            nbins = 256;
            counts = imhist(Image,nbins);
            p = counts / sum(counts); % probability of each intensity
            img1 = im2double(Image); % convert to double
            img2=imadjust(img1,[0.45 0.56]); % adjust contrast
            figure(2); imshow(img2)
            % pause
            img3 = medfilt2(img2,[8 8]); % smoothing filter
            img3 = imfill(img3,'holes'); % fill holes
            img4 = imbinarize(img3,'global'); % binarize

            %         disp1 = imcrop(img2,roi1);% w/o segmentation, cropped to the roi1

            % fill additional holes... for centerline extraction
            disp1 = imfill(img4,'holes');
            centerline_m = bwmorph(disp1,'thin',Inf);
            edge_m = bwmorph(disp1,'remove');
            inver_disp = imcomplement(disp1);% image needs to be complemented for distance transform

            dist_transform = bwdist(inver_disp);
            centerline_coords = find(centerline_m==1);
            radius  = dist_transform(centerline_coords);

            %store vars for all frames and trials
            radius_all{:,i,numtr,names}=radius;
            dist_tran_all(:,:,i,numtr,names)=dist_transform;
            cent_all(:,:,i,numtr,names)=centerline_m;
            edge_all(:,:,i,numtr,names)=edge_m;
            disp_all(:,:,i,numtr,names)=disp1;
            % calculate full width half max as confirmation
            data = sum(disp1,sumdir);% sum along the vessel axis
            % Find the half max value.
            halfMax = (min(data) + max(data)) / 2;
            % Find where the data first drops below half the max.
            index1 = find(data >= halfMax, 1, 'first');
            % Find where the data last rises above half the max.
            index2 = find(data >= halfMax, 1, 'last');
            fwhm = index2-index1 + 1; % FWHM in indexes.
            %         % OR, if you have an x vector
            %         fwhmx = data(index2) - data(index1);

            fwhm_all(i,numtr,names)= fwhm;% # idx length of at half max
            % UNCOMMENT TO CHECK THE PARAMETERS
            % figure(1);
            %
            % title(num2str(i,'%1d'))
            % subplot(221)
            % imshow(img4)
            % subplot(222)
            % imshow(disp1)
            % subplot(223)
            % imshowpair(centerline_m,edge_m)
            % subplot(224)
            % imagesc(dist_transform);
            % pause(0.001)
            % figure(100);
            %         title(num2str(i,'%1d'))
            % %
            %         plot(radius); hold on;
            %          figure(101);
            %         title(num2str(i,'%1d'))
            % %
            %         plot(data); hold on;
            % pause
        end
        numtr
        hold off;
    end
end
% saving section
toc;
save workspace % saves the full width
save('dist_tran_all','dist_tran_all','-v7.3' )
save('cent_all','cent_all','-v7.3')
save('disp_all','disp_all','-v7.3')
save('edge_all','edge_all','-v7.3')