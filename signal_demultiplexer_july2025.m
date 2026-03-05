% CODE to DEMULTIPLEX emitted signal
% reads data from ad instruments files channel wise and segregrated the
% emitted signal into Isosbestic and GCamp signal

clearvars
close all
filename = dir('*.adicht*');
data = adi.readFile();
ldf_ch = data.getChannelByName('Channel 2');% laser doppler
GCamp_ch = data.getChannelByName('Channel 4'); % 590 nm
Ex_ch = data.getChannelByName('Channel 5');% 488 nm

Isos_ch = data.getChannelByName('Channel 6');% 415 nm

Fs =  20000; % 10k sampling rate.. 20k for 13th aug data
numtr = length(ldf_ch.n_samples);
multiplex_freq = 200;%input('Multiplex_freq');

%1) reada
%signal--------------------------------------------------------------------------
ldf_sig = ldf_ch.getData(1);
GCamp_sig = GCamp_ch.getData(1);
Ex_sig = Ex_ch.getData(1);
Isos_sig = Isos_ch.getData(1);
step_Ex = zeros(size(Ex_sig,1),1);
step_Isos = ones(size(Isos_sig,1), 1);

for i = 1:length(Ex_sig)
    if Ex_sig(i,1) >4.9
        step_Ex(i,1)= 1;
        step_Isos(i,1)=0;
    end
end
% figure, plot(Ex_sig(1:300)); hold on; plot(step_Ex(1:300),'r*')
idx_all1 = find(step_Ex==1);
tempctr =1;
ctr = 1;
window = 25:35

% for segregating the excitation...
for k = 5:length(idx_all1)
    % k
    if idx_all1(k)-idx_all1(k-1)==1% consecutive
        % k
        % k-1
        if ctr == 1
            stemp = GCamp_sig(idx_all1(k-1),1);
            extemp = step_Ex(idx_all1(k-1),1);
            ctr = ctr+1;
        else
            stemp = [stemp,GCamp_sig(idx_all1(k-1),1)];
            extemp = [extemp,step_Ex(idx_all1(k-1),1)];
            ctr = ctr+1;
        end
    else % if not consecutive anymore
        % ctr
        stemp = [stemp,GCamp_sig(idx_all1(k-1),1)];
        extemp = [extemp,step_Ex(idx_all1(k-1),1)];
        % figure(3);
        % plot(extemp); hold on; plot(stemp);
        %
        % % hold off;
        % pause
        if length(stemp)>35
            % figure(2)
            % plot(stemp(25:35));hold on;
            avg_488(tempctr) = mean(stemp(window));
            % figure(4)
            % plot(1:tempctr,avg_488(1:tempctr));

        else
            length(stemp)
            upidx = floor(length(stemp)./3);% 1.95
            lowidx = floor(length(stemp)./1.2);
            [upidx lowidx]
            avg_488(tempctr)= mean(stemp(upidx:lowidx));
        end
        ctr = 1;
        clear stemp extemp
        tempctr = tempctr+1;
    end
end
% for segregating the isos
idx_all2 = find(step_Isos==1);
tempctr =1;
ctr = 1;
for k = 2:length(idx_all2)
    % k
    if idx_all2(k)-idx_all2(k-1)==1%consecutive
        % k
        % k-1
        if ctr == 1
            ctemp = GCamp_sig(idx_all2(k-1),1);
            istemp = step_Isos(idx_all2(k-1),1);
            ctr = ctr+1;
        else
            ctemp = [ctemp,GCamp_sig(idx_all2(k-1),1)];
            isostemp = [istemp,step_Isos(idx_all2(k-1),1)];
            ctr = ctr+1;
        end

    else % if not consecutive anymore
        % ctr
        ctemp = [ctemp,GCamp_sig(idx_all2(k-1),1)];
        istemp = [istemp,step_Isos(idx_all2(k-1),1)];
        % figure(3);
        % plot(istemp); hold on; plot(ctemp);
        %
        % hold off;
        % pause

        if length(ctemp)>35
            % figure(2)
            % plot(ctemp(32:37));hold on;
            avg_415(tempctr) = mean(ctemp(window));
        else
            length(ctemp)
            upidx = floor(length(ctemp)./3);
            lowidx = floor(length(ctemp)./1.1);
            [upidx lowidx]

            % figure(3)
            % plot(ctemp(upidx:lowidx));hold on;
            avg_415(tempctr)= mean(ctemp(upidx:lowidx));
        end
        ctr = 1;
        clear ctemp istemp
        tempctr = tempctr+1;
    end
end
figure, plot(avg_488); hold on; plot(avg_415)