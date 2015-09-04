%% make histograms
ic4 = dlmread('erasurelogindex4.txt');
ic8 = dlmread('erasurelogindex8.txt');
ic12 = dlmread('erasurelogindex12.txt');
rc4 = dlmread('erasurerandomlogindex4.txt');
rc8 = dlmread('erasurerandomlogindex8.txt');
rc12 = dlmread('erasurerandomlogindex12.txt');
%%
% grab cols corresponding to erasures
eic4 = ic4(:,6:end);
eic8 = ic8(:,6:end);
eic12 = ic12(:,6:end);
erc4 = rc4(:,6:end);
erc8 = rc8(:,6:end);
erc12 = rc12(:,6:end);
erasures_ic = [eic4(:)' eic8(:)' eic12(:)'];
erasures_rc = [erc4(:)' erc8(:)' erc12(:)'];

figure(1)
hist([erasures_ic erasures_rc], 50)
set(gca,'FontSize',24)
xlhand = get(gca,'xlabel');
set(xlhand,'string','Probability of Erasure','fontsize',24)
ylhand = get(gca,'ylabel');
set(ylhand,'string','Number of Occurrences','fontsize',24)
set(gca,'XTick',[0:.1:1])
%%
% grab cols corresponding to TDM transmissions
ntdm4 = [ic4(:,3); rc4(:,3)];
ntdm8 = [ic8(:,3); rc8(:,3)];
ntdm12 = [ic12(:,3); rc12(:,3)];
nic4 = ic4(:,4);
nic8 = ic8(:,4);
nic12 = ic12(:,4);
nrc4 = rc4(:,4);
nrc8 = rc8(:,4);
nrc12 = rc12(:,4);
%%
figure(2)
hist(ntdm12, 40)
set(gca,'FontSize',20)
xlhand = get(gca,'xlabel');
set(xlhand,'string','Number of Transmissions','fontsize',24)
ylhand = get(gca,'ylabel');
set(ylhand,'string','Number of Occurrences','fontsize',24)
set(gca,'XTick',[0:5:80])
% set(gca,'XTickLabel',['0';' ';'1';' ';'2';' ';'3';' ';'4'])
figure(3);
hist(nrc12, 40)
set(gca,'FontSize',20)
xlhand = get(gca,'xlabel');
set(xlhand,'string','Number of Transmissions','fontsize',24)
ylhand = get(gca,'ylabel');
set(ylhand,'string','Number of Occurrences','fontsize',24)
set(gca,'XTick',[0:10:150])
figure(4);
hist(nic12, 40)
set(gca,'FontSize',20)
xlhand = get(gca,'xlabel');
set(xlhand,'string','Number of Transmissions','fontsize',24)
ylhand = get(gca,'ylabel');
set(ylhand,'string','Number of Occurrences','fontsize',24)
set(gca,'XTick',[0:5:80])

