% code for calcuation of deltas aka As, Bs and predicted Cs for all animals
% as of September 25th 2025

clearvars
close all
clc


%% loading section--------
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\02162024\doubledreadsslczi\m1_swap\saline\workspace.mat')
preroi1_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\02162024\doubledreadsslczi\m1_swap\cno15-20min\workspace.mat')
cnoroi1_fwhm = fwhm_all;

% load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\02162024\doubledreadsslczi\m1_swap\recovery_19feb2024\redowith fiber\workspace.mat')
% postroi1_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\03012024\doubledreaddsm2_repeatfrom16th-19thfeb\workspace.mat')
postroi1_fwhm = fwhm_all;

%loading section II (dataset II)-- load all vessels--changed addresses when transferred from drive to computer
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\02162024\doubledreadsslczi\m2_swap\saline\New Folder\workspace.mat')
preroi2_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\02162024\doubledreadsslczi\m2_swap\cno20min\workspace.mat')
cnoroi2_fwhm = fwhm_all;

% load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\02162024\doubledreadsslczi\m2_swap\recovery_feb19th_2024\workspace.mat')
% postroi11_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\03012024\doubledreadsm1_repeatfrom16th-19thfebfeb\New Folder\workspace.mat')
postroi2_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\0419202404222024\doubledreadds_\saline\roi2\fullframespersecon\workspace.mat')
preroi3_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\0419202404222024\doubledreadds_\cno15min\workspace.mat')
cnoroi3_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\0419202404222024\doubledreadds_\recovery_22april\workspace.mat')
postroi3_fwhm = fwhm_all;



% redo of double dreadds....
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\05102024-05132024\doiubdledreaddsm1_repeat_cnowithfitccy5.5combo\saline_fitc\workspace.mat')
preroi4_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\05102024-05132024\doiubdledreaddsm1_repeat_cnowithfitccy5.5combo\cno15min\workspace.mat')
cnoroi4_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\05102024-05132024\doiubdledreaddsm1_repeat_cnowithfitccy5.5combo\recover_13thmay\workspace.mat')
postroi4_fwhm = squeeze(fwhm_all(:,:,3));




% new data may 2024
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\06132024-06172024\doubledreaddsf1_april24_2024\saline\workspace.mat')
preroi5_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\06132024-06172024\doubledreaddsf1_april24_2024\CNO10min\workspace.mat')
cnoroi5_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\06132024-06172024\doubledreaddsf1_april24_2024\recovery17thjune\workspace.mat')
postroi5_fwhm = squeeze(fwhm_all(:,:,3));



load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\06172024-06202024\doubledreaddsm1_may2nd1stsurgery\saline\workspace.mat')
preroi6_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\06172024-06202024\doubledreaddsm1_may2nd1stsurgery\cno15min\workspace.mat')
cnoroi6_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\06172024-06202024\doubledreaddsm1_may2nd1stsurgery\recovery_20thjune\workspace.mat')
postroi6_fwhm = squeeze(fwhm_all(:,:,3));



% repeat of m1 from may 2024

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\07112024_doubledreaddsm1_repeat\saline\workspace.mat')
preroi7_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\07112024_doubledreaddsm1_repeat\cno\workspace.mat')
cnoroi7_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\07112024_doubledreaddsm1_repeat\recovery15thjuly\workspace.mat')
postroi7_fwhm = squeeze(fwhm_all(:,:,3));

% new double dreadds data


load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\sep26_2024_doubldreadds_m1\saline\workspace.mat')
preroi8_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\sep26_2024_doubldreadds_m1\cno15min\workspace.mat')
cnoroi8_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\sep26_2024_doubldreadds_m1\recovery\workspace.mat')
postroi8_fwhm = squeeze(fwhm_all(:,:,3));





load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\sep27_2024_doubledreadds_f3\saline\workspace.mat')
preroi9_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\sep27_2024_doubledreadds_f3\cno\workspace.mat')
cnoroi9_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\sep27_2024_doubledreadds_f3\recovery\workspace.mat')
postroi9_fwhm = squeeze(fwhm_all(:,:,3));


%%
stim_point = 60*30;% 60 sec x 30 hz


Color_code=[0 0.6 0.9;
    0.7 0 0.5;
    0 0 0;];

offset = 0;
list= {'pre','cno','post'};

for numvessel = 1:9;%length(vessel_arr)
    figure();
    for con = 1:3
        condtn= list(con);
        str = strcat(char(condtn),'roi',num2str(numvessel,'%2d'),'_fwhm');
        fwhm_samp = eval(str);

        time = [1:length(fwhm_samp)]./30;% calc time matrix for the plot
        numtr = size(fwhm_samp,2);

        clear norm_all_fwhm
        secoff = 10;
        figure();
        for tr = 1:numtr;%length(numtr_arr)
            %             tr = numtr_arr(tr1);
            numvessel
            tr
           

            baseline_fwhm = fwhm_samp(secoff*30:59*30,tr);% 800 frames before stim for baseline
            stim_fwhm = fwhm_samp(stim_point:stim_point+150,tr);% 5sec of stim times 30 Hz
            norm_fwhm = (fwhm_samp(secoff*30:end,tr)- mean(baseline_fwhm(:)))./mean(baseline_fwhm(:));
            if ~isnan(norm_fwhm)
                avgnorm_fwhm = norm_fwhm;% just for plotting
                norm_all_fwhm(:,tr) = avgnorm_fwhm;% saving the plotted traces as a matrix
                avgnorm_stim = avgnorm_fwhm(stim_point-secoff*30:stim_point-secoff*30+150);% 5sec of stim times 30 Hz
                peakvsd_tr(con,numvessel,tr)= max(avgnorm_stim);% peak dilation
            end

        end
        meanall = mean(norm_all_fwhm,2);

        % Parameters
        sigma_sec = 0.5;  % Try 1.0–2.0 seconds for more smoothing
        win_pts = round(3 * sigma_sec * 30);  % total window ~ ±3σ
        if mod(win_pts, 2) == 0
            win_pts = win_pts + 1;  % make window odd for symmetry
        end
        % Generate Gaussian window
        g = gausswin(win_pts);
        g = g / sum(g);  % normalize kernel

        % Apply Gaussian smoothing
        mean_smooth = conv(meanall, g, 'same');
        mean_tr_fwhm(numvessel,con,:) = mean_smooth;% mean across trials
        peakvsd(con,numvessel)= max(mean_smooth(stim_point-secoff*30:stim_point-secoff*30+150));
    end
    wind = 1:3301;
    delD_cno_DD(numvessel,wind) = squeeze(mean_tr_fwhm(numvessel,2,wind));% mean of trials of cno data
    delD_sal_DD(numvessel,wind) = squeeze(mean_tr_fwhm(numvessel,1,wind));%

    Dmax_sal_DD(numvessel) = peakvsd(1,numvessel);% max amplitude of the baseline
    quant1_DD(numvessel,wind) = (delD_sal_DD(numvessel,wind)-delD_cno_DD(numvessel,wind))./Dmax_sal_DD(numvessel);

end
