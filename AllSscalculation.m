% code for calcuation of deltas aka As, Bs and predicted Cs for all animals
% as of September 25th 2025

clearvars
close all
clc


% loading section: For all Bs: Midbrain and subthalamus
%% loading section I (dataset I)-- load all vessels--changed addresses when transferred from drive to computer
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\10292022\beforecno\roi1\workspace.mat')
preroi1_fwhm = fwhm_all;
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\10292022\beforecno\roi3\workspace.mat')
preroi2_fwhm = fwhm_all;
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\08212023\chr-eyfp_dreads_m2\saline\roi\workspace.mat')
preroi3_fwhm = squeeze(fwhm_all(:,:,1));
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\11112022\precno\roi1\workspace.mat')
preroi4_fwhm = fwhm_all;
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\0624202406252024\zidreaddsf3\saline\workspace.mat')
preroi5_fwhm = fwhm_all(:,:,3);
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\07102024zidreaddsf3repeat\saline\workspace.mat')
preroi6_fwhm = fwhm_all(:,:,3);
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\07132024_zidreadds_squinhtyeye\saline\workspace.mat')
preroi7_fwhm = fwhm_all(:,:,3);


load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\10292022\cno30min\roi1\workspace.mat')
cnoroi1_fwhm = fwhm_all;
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\10292022\cno30min\roi3\workspace.mat')
cnoroi2_fwhm = fwhm_all;
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\08252023\chr-eyfp_dreadds_m2\cno25-20min\workspace.mat')
cnoroi3_fwhm = fwhm_all;
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\11112022\cno20min\roi1\workspace.mat')
cnoroi4_fwhm = fwhm_all;
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\0624202406252024\zidreaddsf3\cno\workspace.mat')
cnoroi5_fwhm = fwhm_all(:,:,3);
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\07102024zidreaddsf3repeat\cno\workspace.mat')
cnoroi6_fwhm = fwhm_all(:,:,3);
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\07132024_zidreadds_squinhtyeye\cno\workspace.mat')
cnoroi7_fwhm = fwhm_all(:,:,3);


load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\10292022\recovery_5hourspostCNo\roi1\workspace.mat')
postroi1_fwhm = fwhm_all;
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\10292022\recovery_5hourspostCNo\roi3\workspace.mat')
postroi2_fwhm = fwhm_all;
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\09162023\recovery_again_chreyfp_dreadds_m2\workspace.mat')
postroi3_fwhm = fwhm_all;
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\11112022\recovery_6hours\roi1\workspace.mat')
postroi4_fwhm = fwhm_all;
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\0624202406252024\zidreaddsf3\recovery\workspace.mat')
postroi5_fwhm = fwhm_all(:,:,3);
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\07102024zidreaddsf3repeat\recovery_july15th\workspace.mat')
postroi6_fwhm = fwhm_all(:,:,3);
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\07132024_zidreadds_squinhtyeye\recovery_july15th\workspace.mat')
postroi7_fwhm = fwhm_all(:,:,3);
%%
stim_point = 60*30;% 60 sec x 30 hz


Color_code=[0 0.6 0.9;
    0.7 0 0.5;
    0 0 0;];

offset = 0;
list= {'pre','cno','post'};

for numvessel = 1:7;%length(vessel_arr)
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
            numvessel
            tr
            if numvessel ==3 && con ==3 && tr ==6
                tr = 7;
            end
            if numvessel ==1 && con ==3 && tr ==2
                tr =3;
            end

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
        % peakvsd(con,area)= squeeze(mean(peakvsd_tr(con,area,:),3));% peak dilation
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
    delD_cno_ZI(numvessel,wind) = squeeze(mean_tr_fwhm(numvessel,2,wind));% mean of trials of cno data
    delD_sal_ZI(numvessel,wind) = squeeze(mean_tr_fwhm(numvessel,1,wind));%

    Dmax_sal_ZI(numvessel) = peakvsd(1,numvessel);% max amplitude of the baseline
    quant1_ZI(numvessel,wind) = (delD_sal_ZI(numvessel,wind)-delD_cno_ZI(numvessel,wind))./Dmax_sal_ZI(numvessel);

end
