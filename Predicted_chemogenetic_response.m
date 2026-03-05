clearvars
close all
clc


load AllAdata.mat % all Midbrain and brainstem data

load AllBdata.mat % all subthalamus data

load AllCdata.mat % all double dreadds data
% below array is the set of mice that had viral expression and canula in
% the right location
arr = {[1,2,4,6,7,9];...
    [1,3,4,6,7];...
    [3,4,5,6,8,9]};
outdir = 'E:\2P_w_Pantong_ChR_RVLM\Data_KC\dreadds_LC_Zi_processing_data_sep2023\predicted';

allAsort = quant1_LC(cell2mat(arr(1)),:);
allBsort = quant1_ZI(cell2mat(arr(2)),:);
allCsort = quant1_DD(cell2mat(arr(3)),:);

m_Asort = mean(allAsort,1);
m_Bsort = mean(allBsort,1);
m_Csort = mean(allCsort,1);

sem_Asort = std(allAsort,[],1)./sqrt(size(allAsort,1));
sem_Bsort = std(allBsort,[],1)./sqrt(size(allBsort,1));
sem_Csort = std(allCsort,[],1)./sqrt(size(allCsort,1));
% calculating upper and lower bounds for the plot
up_A = m_Asort + sem_Asort;
low_A = m_Asort - sem_Asort;
up_B = m_Bsort + sem_Bsort;
low_B = m_Bsort - sem_Bsort;
up_C = m_Csort + sem_Csort;
low_C = m_Csort - sem_Csort;
time = (1:length(m_Asort))./30-49;
figure('Position', [0, 0, 550, 280]); hold on;
fill([time fliplr(time)], [up_A fliplr(low_A)], 'r', 'linestyle', 'none');
alpha(0.1)
fill([time fliplr(time)], [up_B fliplr(low_B)], 'g', 'linestyle', 'none');
alpha(0.1)
fill([time fliplr(time)], [up_C fliplr(low_C)], 'k', 'linestyle', 'none');
alpha(0.1)
plot(time,m_Asort,'r','LineWidth',2); 
plot((1:length(m_Bsort))./30-49,m_Bsort,'g','LineWidth',2);
plot((1:length(m_Csort))./30-49,m_Csort,'k','LineWidth',2)
% plot((1:length(quant1_LC))./30-49,quant31,'-.','Color',[0 0.6 0.9],'LineWidth',1);
l1=legend('','','','\DeltaM','\DeltaS','\Delta(M+S)')
l1.Location = 'northwest';
l1.FontSize=12.5
xticklabels('')

% xlabel('Time (s)')
xlim([-20 20])
set (gca,'FontSize',20)
filename = sprintf('allmicesumsv1.pdf');
fullpath = fullfile(outdir, filename);
exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
fprintf('Exported %s\n', fullpath);


Cpred1 = m_Asort + m_Bsort; % predicted sum 
Cpred2 = sqrt(m_Asort.^2 + m_Bsort.^2); % square norm
Cpred3 = (2.93/7.84).*m_Asort + (5.26/7.84).*m_Bsort; % weighted norm by pathlengths
% plot section
figure('Position', [0, 0, 550, 320]); hold on;
% plot((1:length(Cpred2))./30-49,Cpred2,'m-.','LineWidth',2);
plot((1:length(Cpred1))./30-49,Cpred1,'-.','Color',[0.8 0.1 0.8],'LineWidth',1);
fill([time fliplr(time)], [up_C fliplr(low_C)], 'k', 'linestyle', 'none');
alpha(0.1)
plot((1:length(m_Csort))./30-49,m_Csort,'k','LineWidth',2);
plot((1:length(Cpred2))./30-49,Cpred3,'m','LineWidth',2);
% plot((1:length(quant1_LC))./30-49,quant4,'c','LineWidth',2)
% e5 = char('\Delta(M)+\Delta(S)', ...
          % '-\alpha(\Delta M \Delta S)');
e5 = char('l_{1}\Delta(M)+l_{2}\Delta(S)');
% l = legend('\surd(\Delta M^{2}+\Delta S^{2})', ...
   l = legend( '\Delta M + \Delta S', ...
    '',...
    '\Delta(M+S)', ...
    e5, ...
    'Interpreter','tex', ...
    'Location','best');
% l.Location='southoutside';
l.FontSize=12.5;
% l.Orientation='horizontal';
xlabel('Time (s)')
xlim([-20 20])
set (gca,'FontSize',20)
filename = sprintf('allmiceavgsv1.pdf');
fullpath = fullfile(outdir, filename);
exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
fprintf('Exported %s\n', fullpath);
