%% analysing the pupil diameter from avi movie files..
% 1. reads the video files
% 2. masks the eye out for further image processing.
% 3. applies image processing such as contrast enhancement, binarization,
% fill holes and median filtering
% 4. fits an elipse to the pupil and calculates the radius and predicts
% pupil area.

clearvars
close all
clc
list = dir("*.avi.");

%mask creation for all trials
for l = 2:length(list)
    vidobj = VideoReader(list(l).name); % read video
    vidobj.CurrentTime = 0.5; % get current time
    count = 1;
    numfr = vidobj.NumFrames;
    frame = read(vidobj,1);
    Image = frame;
    nbins = 256;
    counts = imhist(Image,nbins);
    p = counts / sum(counts); % probability of each intensity
    img1 = im2double(Image);
    img2=imadjust(img1,[0 0.5]);
    imID = img2(:,:,1);
0
    imshow(imID);
    h = imfreehand; %draw something
    mask = ~h.createMask();
    %     imID(mask) = 1;
    maskall{l} = mask;
end


%% actual image processing and pupil
%quantification----------------------------------------------
for l = 1:length(list)
    mask= cell2mat(maskall(l));
    vidobj = VideoReader(list(l).name);
    numfr = vidobj.NumFrames;

    for count = 1:numfr
        vidframe = read(vidobj,count);
        %     allframes{count}= vidframe;
        %         figure(1);

        Image = vidframe;
        nbins = 256;
        counts = imhist(Image,nbins);
        p = counts / sum(counts); % probability of each intensity
        img1 = im2double(Image);
        img2=imadjust(img1,[0 0.5]);
        imID = img2(:,:,1);% single channel contrasted image
        % imshow(imID);
        imID(mask) = 1;
        img3 = imcomplement(imID); % flip colors
        img4 = imadjust(img3,[0.57 0.8]); % contrast enhancement
        img5 = imbinarize(img4,'global'); % binarize image
        img6 = imfill(img5,'holes');% fill holes
        img7 = medfilt2(img6,[5 5]); % smooth median filter
        figure(1)
        subplot(121)
        imshowpair(imID,img7)
        stats = regionprops('table',img7,'Centroid',...
            'MajorAxisLength','MinorAxisLength','Orientation');
        centers = stats.Centroid;
        diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
        radii = diameters/2;
        hold on
        viscircles(centers,radii);
        hold off
        %
        % arash's fitting code
        % if size(stats.Centroid,1)<2
        %     theta = linspace(0,2*pi);
        %     col = (stats.MajorAxisLength/2)*cos(theta);
        %     row = (stats.MinorAxisLength/2)*sin(theta);
        %     M = makehgtform('translate',[stats.Centroid, 0],'zrotate',deg2rad(-1*stats.Orientation));
        %     D = M*[col;row;zeros(1,numel(row));ones(1,numel(row))];
        % else
        %     theta = linspace(0,2*pi);
        %     col = (stats.MajorAxisLength(1)/2)*cos(theta);
        %     row = (stats.MinorAxisLength(1)/2)*sin(theta);
        %     M = makehgtform('translate',[stats.Centroid(1,:), 0],'zrotate',deg2rad(-1*stats.Orientation(1)));
        %     D = M*[col;row;zeros(1,numel(row));ones(1,numel(row))];
        % end
        % Visualize the result
        % figure
        if sum(img7(:))~=0% if the pupil is still detecable and eye not closed
            w_pix(l,count) = numel(find(img7==1));
            pupil_area(l,count) = pi.*(stats.MajorAxisLength(1)).*(stats.MinorAxisLength(1));

            subplot(122)
            plot(1:count,pupil_area(l,1:count),'k');
            hold on;
            %     pause(1/vidobj.FrameRate);
            set(gcf,'position',[10,10,2000,1000])
            % subplot(132);
            % imshowpair(img2,img7);
            % hold on;
            % plot(D(1,:),D(2,:),'r','LineWidth',2)

        end

    end
    count
    hold off;
end

%% plots the change in pupil area over time of the experiment
fps_cam = 20;% acquire a frame every 50 millisec...
samp_time = 0.05; % sample every 50 millisecs
brown = [171 104 87]./255;

for i = 1:size(pupil_area,1)
    samps = pupil_area(i,:);
    m_pupil = movmean(samps,20);
    len = length(m_pupil);
    est_tottime = len.*samp_time;
    % est_dur = (est_t/len):(est_t/len):est_t;
    est_dur = [samp_time:samp_time:est_tottime];
    figure,
    plot(est_dur./60,samps,'Color',[0.9 0.7 0.6]);% plitting it with time in min hence the division by 60
    hold on;
    plot(est_dur./60,m_pupil,'LineWidth',2,'Color',brown);% plitting it with time in min hence the division by 60
    yline(mean(m_pupil(:)),'k--','LineWidth',3)% seeing changes from the mean...
    hold off;
    % title(num2str(i,'%2d'));
    % xlim([0 carbogen_tarr(i-1)]);% doing i-1 coz the first video analysed was not actual data correpsonding to the carbogen
    set(gca,'FontSize',24);
    ylim([0 12000])
    ylabel('Mean Pupil area');
    xlabel('Time(min)')
    box off;
    set(gcf,'units','points','position',[10,10,1200,400])
    saveas(gcf,strcat('E:\fiberphotometryKC\GCampm1\september4\pupilGCampM117septr',num2str(i,'%2d'),'.png'))
end


%% normalize pupil area: Jan 25th, 2023

numtr = size(pupil_area,1)
for l = 1:size(pupil_area,1)
    samp = pupil_area(l,1:6000);
    base = pupil_area(l,1:500);
    mean_base = mean(base(:));
    norm_pupil =  (samp- mean_base)./mean_base;
    %     plot(norm_pupil)
    norm_all_pupil(l,:)= norm_pupil;
end

% plot
Fs_pupil = 50;
fac = 20;
mean_pupil = mean(norm_all_pupil,1);
std_pupil = std(norm_all_pupil,[],1)./sqrt(numtr);
sm_mean = movmean(mean_pupil,fac);
time = [1:size(norm_all_pupil,2)]./(Fs_pupil);
time = time-60;
% calculate upper and lower bounds for the plot with shaded areas
up_pupil = mean_pupil + std_pupil;
up_sm = movmean(up_pupil,fac);
low_pupil = mean_pupil - std_pupil;
low_sm = movmean(low_pupil,fac);
figure(3)
fill([time fliplr(time)], [up_sm fliplr(low_sm)], [0 0.6 0], 'linestyle', 'none');
alpha(0.2)
hold on;
plot(time,sm_mean ,'Color',[0 0.6 0],'LineWidth',2);
hold on;
ylabel('\DeltaPupil_{Area}');
xlabel('Time (s)')
xlim([-40 40])
ylim([-0.7 1])
set(gca,'FontSize', 32)
set(gcf,'position',[10,10,1500,500])
% hold off
title('')
box off;
xticks([])
yticks([])
