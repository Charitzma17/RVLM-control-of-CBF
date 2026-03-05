clearvars
clc

% cd '\\dk-server.dk.ucsd.edu\data\afassihizakeri\ThermalCamera\Jacob_Expriment\10_18_2023'
% MoviePath =
MoviePath = 'C:\Users\kchhabria\Desktop\RVL_Stim_ThermalCam-Karishma-2024-02-06\videos';%data#1
% MoviePath = 'C:\Users\kchhabria\Desktop\doubledreaddsm1_c1rvlmstim5sON-0011-KC-2025-07-18\videos';%data#2
% MoviePath = 'C:\Users\kchhabria\Desktop\doubledreaddsm2_reanalyse-KC-2025-07-23\videos';%data#4
% MoviePath = 'C:\Users\kchhabria\Desktop\doubledreaddsf2_reanalyse-KC-2025-07-23\videos';%data#3

cd (MoviePath)
% DLCfilename='ar51before-0001DLC_resnet50_ThermalcameralowerviewSep22shuffle5_500000_filtered.csv'
DLCfilename='lcdreaddsf3_c1rvlmstim5sON-0031DLC_resnet50_RVL_Stim_ThermalCamFeb6shuffle1_100000_filtered.csv';%data#1
% DLCfilename='doubledreaddsm1_c1rvlmstim5sON-0011DLC_resnet50_doubledreaddsm1_c1rvlmstim5sON-0011Jul18shuffle1_100000';%data#2
% DLCfilename='doubledreaddsf2sep24_c1rvlmstim5sON-0001DLC_resnet50_doubledreaddsf2_reanalyseJul23shuffle1_100000';%data#3
% DLCfilename='doubledreaddsf2sep24_c1rvlmstim5sON-0001DLC_resnet50_doubledreaddsf2Jul16shuffle1_100000';%data#4
% DLCfilename='doubledreaddsm2_c1rvlmstim5sON-0008DLC_resnet50_doubledreaddsm2_reanalyseJul23shuffle1_100000';%data#4


opts = detectImportOptions(DLCfilename);
opts.VariableNames={'frames', 'x1','y1','L1'...
    ,'x2','y2','L2'};


Tnose = readtable(DLCfilename,opts);

% temprature data path
thisdir = 'E:\thermalcamera_breathingWArash\Karishma';%data#1
% thisdir = 'E:\thermalcamera_breathingWArash\exp2\lastexp';%data#2
% thisdir = 'E:\thermalcamera_breathingWArash\doubledreaddsf2sep24_c1rvlmstim5sON-0001';%data#3
% thisdir ='E:\thermalcamera_breathingWArash\exp3\Karishma_ThermalCam\CSVfiles';%data4

% a=dir (thisdir);
%     selectframes=

% A = readmatrix(fullfile(thisdir, filename))
%% just to check the movie
figure(9)
Prefix = 'lcdreaddsf3_c1rvlmstim5sON-0031_'; %  csv prefix of data#1
% Prefix = 'doubledreaddsm1_c1rvlmstim5sON-0011_'; %  csv prefix of data#2
% Prefix = 'doubledreaddsf2sep24_c1rvlmstim5sON-0001_'; %  csv prefix of data#3
% Prefix = 'doubledreaddsm2_c1rvlmstim5sON-0008_'; %  csv prefix of data#4

NumberofFrames = 1e5;
framofinterest = 1:20:59000;
for i=framofinterest
    i
    filename = fullfile(thisdir, [Prefix  num2str(i) '.csv']);
    data  = readmatrix(filename);
    imagesc(log(data))
    if i ==1
        [roi,rectout]= imcrop();
    else
        roi = imcrop(data,rectout);
    end
    
%    log_img = log(roi);       % your log image
% gamma   = 2;              % <1 makes midrange more stretched
% scaled  = log_img.^gamma;   % nonlinear remapping
% imagesc(scaled);
% colormap(hsv);
% colorbar;

% --- Log-transform your image ---
Ilog = log(roi);

% --- Display ---
imagesc(Ilog);
% axis image off;
% Turn off both x and y ticks
set(gca, 'XTick', [], 'YTick', []);

% Or if you only want to hide labels but keep the gridlines:
set(gca, 'XTickLabel', [], 'YTickLabel', []);
% Set limits (clip outliers for nicer contrast if needed)
% lo = prctile(Ilog(:), 2);   % lower 2% cutoff
% hi = prctile(Ilog(:), 98);  % upper 98% cutoff
caxis([3.21 3.25]);

% --- Warp the HSV colormap ---
N = 256;                        % number of colors
x = linspace(0,1,N);            % original colormap positions
gamma_map = 0.8;                % <1 = more midrange resolution
map = hot(N);
map_warped = interp1(x, map, x.^gamma_map, 'linear', 'extrap');

colormap(map_warped);
cb = colorbar;
ylabel(cb, 'log intensity');
set(gca,'FontSize',24)
set(gcf,'units','points','position',[0,500,500,500])

% pause

     out_dir = 'E:\thermalcamera_breathingWArash\pictures_for_figure\hsvscalebarex_september16th_2025';   % <-- change to your folder
    if ~exist(out_dir,'dir'), mkdir(out_dir); end

    fname   = strcat('breathingcycle',num2str(i,'%02d'));                  % <-- change to your filename
    f       = gcf;                                        % current figure handle

    % % Raster (good for slides/manuscripts)
    % exportgraphics(f, fullfile(out_dir,[fname '.png']), 'Resolution',300, 'BackgroundColor','white');

    % Vector (great for Illustrator)
    exportgraphics(f, fullfile(out_dir,[fname '.pdf']), 'ContentType','vector', 'BackgroundColor','white');
    % hold on
    % plot(Tnose.x2(i),Tnose.y2(i),'go')
    % plot(Tnose.x1(i),Tnose.y1(i),'go')
    % pause
    % hold off

end



%% Average log-images over 20 frames, then display & save
figure(9)
Prefix = 'lcdreaddsf3_c1rvlmstim5sON-0031_'; % csv prefix
NumberofFrames = 1e5;
framofinterest = 50000:1:59000;

batchSize = 50;  % average over 20 images
out_dir = 'E:\thermalcamera_breathingWArash\pictures_for_figure\hsvscalebarex_september16th_2025';
if ~exist(out_dir,'dir'), mkdir(out_dir); end

% rectout = []; % initialize ROI

for k = 1:batchSize:length(framofinterest)
    frames_batch = framofinterest(k:min(k+batchSize-1,end)); % up to 20 frames
    batch_sum = [];
    
    for idx = 1:numel(frames_batch)
        i = frames_batch(idx);
        filename = fullfile(thisdir, [Prefix num2str(i) '.csv']);
        data  = readmatrix(filename);

        imagesc(log(data))
        % crop ROI on first frame
        if k ==1 && i ==1
            [roi,rectout]= imcrop();
        else
            roi = imcrop(data,rectout);
        end

        Ilog = log(roi);

        if isempty(batch_sum)
            batch_sum = zeros(size(Ilog));
        end
        batch_sum = batch_sum + Ilog;
    end

    % average the batch
    Iavg = batch_sum ./ numel(frames_batch);

    % --- Display averaged image ---
    imagesc(Iavg);
    set(gca,'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[]);
    caxis([3.21 3.25]);
    
    % warp hot colormap
    N = 256; x = linspace(0,1,N);
    gamma_map = 0.8;
    map = hot(N);
    map_warped = interp1(x, map, x.^gamma_map, 'linear', 'extrap');
    colormap(map_warped);
    cb = colorbar; ylabel(cb,'log (Temperature)');
    set(gca,'FontSize',28,'FontName','Arial')
    set(gcf,'units','points','position',[0,500,800,500])
% pause(0.1)
    %--- Save averaged figure ---
    fname = sprintf('breathingcycle_avg%05d-%05d', frames_batch(1), frames_batch(end));
    f = gcf;
    exportgraphics(f, fullfile(out_dir,[fname '.pdf']), 'ContentType','vector', 'BackgroundColor','white');
end

%% initialize vars (K added on July 16th 2025)
tic 
% CenterTemprature = nan(size(Tnose.x1,1),2);
% thismeantemp2 = nan(size(Tnose.x1,1),1);
% thismeantemp = nan(size(Tnose.x1,1),1);


%
for i=1:size(Tnose.x1,1)

    filename = fullfile(thisdir, [Prefix num2str(i) '.csv']);
    data  = readmatrix(filename);

    % thistemp(i,:) =[data(round(Tnose.y2(i)),round(Tnose.x2(i)))
    %                                                                                                                                                                                                             
    CenterTemprature(i,:) =[data(round(Tnose.y2(i)),round(Tnose.x2(i))) data(round(Tnose.y2(i)),round(Tnose.x2(i)))];

    neighborhood = [-1, -1; -1, 0; -1, 1; 0, -1; 0, 0; 0, 1; 1, -1; 1, 0; 1, 1];
    % Define coordinates for first immediate neighbors
    first_neighbor = [-1, -1; -1, 0; -1, 1; 0, -1; 0, 1; 1, -1; 1, 0; 1, 1];

    % Define coordinates for second immediate neighbors
    second_neighbor = [-2, -2; -2, -1; -2, 0; -2, 1; -2, 2; -1, -2; -1, 2; 0, -2; 0, 2; 1, -2; 1, 2; 2, -2; 2, -1; 2, 0; 2, 1; 2, 2];
    img = data;
    x = round(Tnose.y2(i));
    y= round(Tnose.x2(i));% Coordinates of the pixel of interest
    % Compute the indices of first immediate neighbors
    first_neighbor_indices = bsxfun(@plus, [x, y], first_neighbor);

    % Compute the indices of second immediate neighbors
    second_neighbor_indices = bsxfun(@plus, [x, y], second_neighbor);

    % Filter out indices that are outside the image bounds
    valid_first_indices = all(first_neighbor_indices >= 1 & first_neighbor_indices <= [size(img, 1), size(img, 2)], 2);
    valid_second_indices = all(second_neighbor_indices >= 1 & second_neighbor_indices <= [size(img, 1), size(img, 2)], 2);
    first_neighbor_indices = first_neighbor_indices(valid_first_indices, :);
    second_neighbor_indices = second_neighbor_indices(valid_second_indices, :);
    ind = sub2ind(size(data),[ first_neighbor_indices(:,1) ;second_neighbor_indices(:,1)],[ first_neighbor_indices(:,2) ;second_neighbor_indices(:,2)]);
    thismeantemp(i,1) =mean(data(ind));

    x = round(Tnose.y1(i));
    y= round(Tnose.x1(i));% Coordinates of the pixel of interest
    % Compute the indices of first immediate neighbors
    first_neighbor_indices = bsxfun(@plus, [x, y], first_neighbor);

    % Compute the indices of second immediate neighbors
    second_neighbor_indices = bsxfun(@plus, [x, y], second_neighbor);

    % Filter out indices that are outside the image bounds 
    valid_first_indices = all(first_neighbor_indices >= 1 & first_neighbor_indices <= [size(img, 1), size(img, 2)], 2);
    valid_second_indices = all(second_neighbor_indices >= 1 & second_neighbor_indices <= [size(img, 1), size(img, 2)], 2);
    first_neighbor_indices = first_neighbor_indices(valid_first_indices, :);
    second_neighbor_indices = second_neighbor_indices(valid_second_indices, :);
    ind = sub2ind(size(data),[ first_neighbor_indices(:,1) ;second_neighbor_indices(:,1)],[ first_neighbor_indices(:,2) ;second_neighbor_indices(:,2)]);
    thismeantemp(i,2) =mean(data(ind));

end
toc;
%%
Fs = 333;
T=(1:size(thismeantemp,2))./Fs;
figure()
plot(T,nanmean(thismeantemp(:,2)'))
