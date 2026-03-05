% code for calcuation of deltas aka As, Bs and predicted Cs for all animals
% as of September 25th 2025

clearvars
close all
clc




%% loading section I (dataset I)-- load all vessels--changed addresses when transferred from drive to computer
% here each of the roi is from a different mouse
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\08292023\lcdreaddss_saline\workspace.mat')
preroi1_fwhm = squeeze(fwhm_all(:,:,1));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\09042023\lcdreadds_m3\saline\workspace.mat')
preroi2_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\09042023\lcdreadds_m4\saline\workspace.mat')
preroi3_fwhm = squeeze(fwhm_all(:,:,1));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\01242024-01302024\lcdreadsf3_jan24\salin\workspace.mat')
preroi4_fwhm = squeeze(fwhm_all(:,:,1));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\04272024-04292024\lcdreadds_m1\saline\workspace.mat')
preroi5_fwhm = squeeze(fwhm_all(:,:,1));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\05102024-05132024\lcdreaddsm1_cno_repeatwithfitc\saline\workspace.mat')
preroi6_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\05102024-05132024\lcdreaddsm2_repeat_withcno_withfitc\saline\workspace.mat')
preroi7_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\06282024-07042024\lcdreaddsf1\saline\workspace.mat')
preroi8_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\07052024-07082024\lcdreaddsf2\saline\workspace.mat')
preroi9_fwhm = squeeze(fwhm_all(:,:,3));




load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\08292023\lc_dreadds_cno25min\workspace.mat')
cnoroi1_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\09042023\lcdreadds_m3\20mincno\workspace.mat')
cnoroi2_fwhm = fwhm_all;

% load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\09042023\lcdreadds_m4\cno30min\workspace.mat')
% cnoroi3_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\10232023-10242023\lcdreads_m4_cno15min\New folder\workspace.mat')
cnoroi3_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\01242024-01302024\lcdreadsf3_jan24\cno15min\workspace.mat')
cnoroi4_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\04272024-04292024\lcdreadds_m1\cno15min\workspace.mat')
cnoroi5_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\05102024-05132024\lcdreaddsm1_cno_repeatwithfitc\cno15min\workspace.mat')
cnoroi6_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\05102024-05132024\lcdreaddsm2_repeat_withcno_withfitc\cno15min\workspace.mat')
cnoroi7_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\06282024-07042024\lcdreaddsf1\cno\workspace.mat')
cnoroi8_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\07052024-07082024\lcdreaddsf2\cno15min\workspace.mat')
cnoroi9_fwhm = squeeze(fwhm_all(:,:,3));




load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\09162023\recovery_again_lcdreadds_f1\workspace.mat')
postroi1_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\09042023\lcdreadds_m3\postcno_6h\workspace.mat')
postroi2_fwhm = fwhm_all;
%

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\10232023-10242023\recoverylcdreadsm4\workspace.mat')% repeat for now
postroi3_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\01242024-01302024\lcdreadsf3_jan24\recovery_jan30_2024\workspace.mat')% repeat for now
postroi4_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\04272024-04292024\lcdreadds_m1\recover29thapril\workspace.mat')% repeat for now
postroi5_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\05102024-05132024\lcdreaddsm1_cno_repeatwithfitc\recovery_13thmay\workspace.mat')% repeat for now
postroi6_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\05102024-05132024\lcdreaddsm2_repeat_withcno_withfitc\recovery-13thmay\workspace.mat')% repeat for now
postroi7_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\06282024-07042024\lcdreaddsf1\recovery_5thjuly\workspace.mat')% repeat for now
postroi8_fwhm = squeeze(fwhm_all(:,:,3));

% load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\07052024-07082024\lcdreaddsf2\recovery\workspace.mat')% repeat for now
% postroi9_fwhm = squeeze(fwhm_all(:,:,3));

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\07102024_repeat_lcdreadds_f2recovery\workspace.mat')% repeat for now
postroi9_fwhm = squeeze(fwhm_all(:,:,3));
%%
numtr_arr = [3,4,6,7,8,9,10,11,16,17,18,20]; % trials with no z motion
stim_point = 60*30;% 60 sec x 30 hz


Color_code=[0 0.6 0.9;
    0.7 0 0.5;
    0 0 0;];

offset = 0;
list= {'pre','cno','post'};

for numvessel = 1:9;%length(vessel_arr)
    % figure();
    for con = 1:3
        condtn= list(con);
        str = strcat(char(condtn),'roi',num2str(numvessel,'%2d'),'_fwhm');
        fwhm_samp = eval(str);

        time = [1:length(fwhm_samp)]./30;% calc time matrix for the plot
        numtr = size(fwhm_samp,2);

        clear norm_all_fwhm
        secoff = 10;
        % figure();
        for tr = 1:numtr;%length(numtr_arr)
            %             tr = numtr_arr(tr1);
            
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
    delD_cno_LC(numvessel,wind) = squeeze(mean_tr_fwhm(numvessel,2,wind));% mean of trials of cno data
    delD_sal_LC(numvessel,wind) = squeeze(mean_tr_fwhm(numvessel,1,wind));%

    Dmax_sal_LC(numvessel) = peakvsd(1,numvessel);% max amplitude of the baseline
    quant1_LC(numvessel,wind) = (delD_sal_LC(numvessel,wind)-delD_cno_LC(numvessel,wind))./Dmax_sal_LC(numvessel);

end
