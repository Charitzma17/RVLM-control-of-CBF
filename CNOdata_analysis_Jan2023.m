%% code for analysing all vessels imaged per dreadd animal before during and after CNO 
% using only fwhm analysis for these animals since it works

clearvars
close all
clc

%
%% loading section II (dataset II)-- load all vessels--changed addresses when transferred from drive to computer
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\11112022\precno\roi1\workspace.mat')
preroi1_fwhm = fwhm_all;
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\11112022\precno\roi2\workspace.mat')
preroi2_fwhm = fwhm_all;
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\11112022\precno\veion\workspace.mat')
preroi3_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\11112022\cno20min\roi1\workspace.mat')
cnoroi1_fwhm = fwhm_all;
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\11112022\cno20min\roi2\workspace.mat')
cnoroi2_fwhm = fwhm_all;
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\11112022\cno20min\vein\workspace.mat')
cnoroi3_fwhm = fwhm_all;

load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\11112022\recovery_6hours\roi1\workspace.mat')
postroi1_fwhm = fwhm_all;
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\11112022\recovery_6hours\roi2\workspace.mat')
postroi2_fwhm = fwhm_all;
load ('E:\2P_w_Pantong_ChR_RVLM\Data_KC\11112022\recovery_6hours\vein\workspace.mat')
postroi3_fwhm = fwhm_all;


%% fwhm diameter analysis



% motion severe-->trials to be taken: 3,4,6,7,8,9,10,11,16,17,18,20
numtr_arr = [3,4,6,7,8,9,10,11,16,17,18,20];
stim_point = 60*30;% 60 sec x 30 hz

Color_code=[0 0 0.6;
    0.6 0 0;
    0 0.6 0;];

offset = 0;
list= {'pre','cno','post'};

for numvessel = 1:3;%length(vessel_arr)
     figure();
    for con =1:3
        condtn= list(con);
        str = strcat(char(condtn),'roi',num2str(numvessel,'%2d'),'_fwhm');
        fwhm_samp = eval(str);
        time = [1:length(fwhm_samp)]./30;% calc time matrix for the plot
        numtr = size(fwhm_samp,2);
        
        clear norm_all_fwhm
        
        for tr = 1:numtr;%length(numtr_arr)
%            

            baseline_fwhm = fwhm_samp(stim_point-800:stim_point,tr);% 800 frames before stim for baseline
            stim_fwhm = fwhm_samp(stim_point:stim_point+150,tr);% 5sec of stim times 30 Hz
            norm_fwhm = (fwhm_samp(:,tr)- mean(baseline_fwhm(:)))./mean(baseline_fwhm(:));
            if ~isnan(norm_fwhm)
                avgnorm_fwhm = movmean(norm_fwhm,30);
                norm_all_fwhm(:,tr) = avgnorm_fwhm;
                avgnorm_stim = avgnorm_fwhm(stim_point:stim_point+150);% 5sec of stim times 30 Hz
                mean_base_tr(con,numvessel,tr) = mean(baseline_fwhm(:));
                mean_stim_tr(con,numvessel,tr) = mean(stim_fwhm(:));
                time_to_peak(con,numvessel,tr) = find(max(avgnorm_stim));% taking the peak of the smoothened avgstim
            end
%             figure(2); plot(norm_fwhm);
%             hold on;
%             xline(1800)
%             xline(1950)
%             pause
        end
%         hold off;
        mean_tr_fwhm = smooth(mean(norm_all_fwhm,2));% mean across trials
        std_all_fwhm = smooth(std(norm_all_fwhm,[],2)./sqrt(numtr));
        
            up_fwhm = mean_tr_fwhm + std_all_fwhm; 
            low_fwhm = mean_tr_fwhm - std_all_fwhm;
            time = time-60;
           
            fill([time fliplr(time)], [up_fwhm' fliplr(low_fwhm')], Color_code(con,:), 'linestyle', 'none');
            alpha(0.2)
            hold on;
            plot(time,mean_tr_fwhm ,'Color',Color_code(con,:),'LineWidth',2);
            hold on;
            ylabel('\DeltaDiameter');
            xlabel('Time (s)')
            % xlim([-40 60])
            % ylim([-0.1 0.3])
            set(gca,'FontSize', 32)
%             offset =offset+0.04;
        
    end
    hold off;
end
%% old piece of code-- added the above new one on May 9th 2024
% plots trial averaged data..
stim_point = 60*30;% 60 sec x 30 hz
Color_code=[0 0 0;
    0.6 0 0;
    0 0.6 0;
    0.6 0 0.6;
    0 0 0.6;
    0.9 0 0;];
offset = 0;
for numvessel = 1:length(vessel_arr)
    str = strcat('roi',num2str(numvessel,'%2d'),'_fwhm');
    fwhm_samp = eval(str);
    time = [1:length(fwhm_samp)]./30;% calc time matrix for the plot
    numtr = size(fwhm_samp,2);
    
    clear norm_all_fwhm
    for tr1 = 1:length(numtr_arr)
        tr = numtr_arr(tr1);
        
        baseline_fwhm = fwhm_samp(stim_point-800:stim_point,tr);% 800 frames before stim for baseline
        stim_fwhm = fwhm_samp(stim_point:stim_point+150,tr);% 5sec of stim times 30 Hz
        norm_fwhm = (fwhm_samp(:,tr)- mean(baseline_fwhm(:)))./mean(baseline_fwhm(:));
        if ~isnan(norm_fwhm)
            norm_all_fwhm(:,tr) = movmean(norm_fwhm,30);
            %       
        end
    end
    hold off;
    mean_tr_fwhm = mean(norm_all_fwhm,2);% mean across trials
    std_all_fwhm = std(norm_all_fwhm,[],2)./sqrt(numtr);

    up_fwhm = mean_tr_fwhm+offset + std_all_fwhm;
    low_fwhm = mean_tr_fwhm+offset - std_all_fwhm;
    time = time-60;
    figure(1);
    fill([time fliplr(time)], [up_fwhm' fliplr(low_fwhm')], Color_code(numvessel,:), 'linestyle', 'none');
    alpha(0.2)
    hold on;
    plot(time,mean_tr_fwhm+offset ,'Color',Color_code(numvessel,:),'LineWidth',2);
    hold on;
    ylabel('\DeltaDiameter');
    xlabel('Time (s)')
    xlim([-40 60])
    ylim([-0.1 0.3])
    set(gca,'FontSize', 32)
    offset =offset+0.04;

end
