% code to input the centrality values for the primary nodes of the network
%date:April 8th 2024
%(1,1) is the number of efferents as in the outgoing edges and (1,2) is the
%number of afferents as in incoming edges
% this is from the documentation from the papers in the google doc efferent
% and afferent connectivity data


centralitydata.LC(1,1) = 34;
centralitydata.LC(1,2) = 18;

% centralitydata.CVL(1,1) = 2;
% centralitydata.CVL(1,2) = 21;

centralitydata.Tg(1,1) = 18;% this is LDT/PPT
centralitydata.Tg(1,2) = 22;

% centralitydata.AP(1,1) = 7;
% centralitydata.AP(1,2) = 4;

centralitydata.NTS(1,1) = 28;
centralitydata.NTS(1,2) = 17;

centralitydata.PO(1,1) = 7;% basal forebrain should include parts of preoptic areas and stria terminalis
centralitydata.PO(1,2) = 11; ;

centralitydata.PAG(1,1) = 21;%
centralitydata.PAG(1,2) = 24;

centralitydata.DR(1,1) = 22;% dorsal raphe
centralitydata.DR(1,2) = 21;

centralitydata.PVT(1,1) = 26;
centralitydata.PVT(1,2) = 25;

centralitydata.LH(1,1) = 30;
centralitydata.LH(1,2) = 31;

centralitydata.ZI(1,1) = 30;
centralitydata.ZI(1,2) = 24;

% centralitydata.PAG(1,1) = 13;
% centralitydata.PAG(1,2) = 19;

centralitydata.PVH(1,1) = 14;
centralitydata.PVH(1,2) = 16;

centralitydata.PCRtandIRt(1,1) = 21;
centralitydata.PCRtandIRt(1,2) = 24;

centralitydata.PBN(1,1) = 20;
centralitydata.PBN(1,2) = 18;

centralitydata.RVLM(1,1) = 13;
centralitydata.RVLM(1,2) = 20;

fieldnames = {'NTS';...
    'PCRtandIRt';...
    'LC';...
    'PAG';...
    'DR';...
    'PBN';...
    'Tg';...
    'ZI';...
    'LH';...
    'PVH';...
    'PVT';...
    'PO';};
idx = length(fieldnames);
for listo = 1:idx
    in_out(listo,:) = getfield(centralitydata,fieldnames{listo});
end

figure(80)
plot(1:idx,in_out(1:idx,1),'^',"MarkerSize",14,...
    "MarkerEdgeColor",[0 0 0],"MarkerFaceColor",[0 0 0]);
hold on;
plot(1:idx,in_out(1:idx,2),'o',"MarkerSize",10,...
    "MarkerEdgeColor",[0 0 0],"MarkerFaceColor",[0.6 0.6 0.6]);

plot(1:idx,sum(in_out(1:idx,:),2),'d',"MarkerSize",15,...
    "MarkerEdgeColor",[0 0 0],"MarkerFaceColor",[0.6 0 0]);
% yline(mean(in_out(:,1)+in_out(:,2)),'g.-')
ylabel('Degree')
xticks(1:idx);
xticklabels(fieldnames);
set(gca,'FontSize',20);
box off;
lgd = legend('efferents','afferents','centrality')
lgd.Location = 'northoutside';
lgd.Orientation="horizontal";
ldf.Fontsize = 16;
set(gcf,'position',[10,10,700,500])

deg = sum(in_out(1:idx,:),2);
regions = fieldnames(:);

[deg_sorted, idx1] = sort(deg,'descend');

regions_sorted = regions(idx1);

n = numel(deg_sorted);
n_top = ceil(0.8*n);

top_idx = 1:n_top;
bottom_idx = n_top+1:n;

figure, hold on;

bar(top_idx, deg_sorted(top_idx), 'FaceColor',[0.8 0 0]);

bar(bottom_idx, deg_sorted(bottom_idx),'FaceColor',[0 0 0.8])

set(gca,'FontSize',24);
yline(35,'--k','LineWidth',1);
xticks(1:idx);
xticklabels(fieldnames(idx1));
set(gcf,'position',[10,80,700,500])
bw = 3.7;
[xi, f] = ksdensity(deg,'BandWidth',bw);
regions = fieldnames(:);
figure; hold on;
plot(f,xi,'k-','LineWidth',2)
% Colors (distinct)
C = jet(n);

% Put dots near baseline with small vertical jitter (optional)
yBase = 0.2 * max(xi);
rng(1)
yJ = yBase + (rand(n,1)-0.5) * (0.01 * max(xi));  % small jitter

h = gobjects(n,1);
for i = 1:n
    h(i) = scatter(deg(i), yJ(i), 70, ...
        'MarkerFaceColor', C(i,:), ...
        'MarkerEdgeColor', 'k', ...
        'LineWidth', 1);
end

xline(35,'r--','LineWidth',2)
ylabel('Kernel density estimate');
box off;
set(gca,'FontSize',24);
legend(h, regions, 'Location','west')  % or 'bestoutside'
set(gcf,'position',[10,80,700,800])
















