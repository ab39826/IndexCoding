%main function for plotting

clear all
%close all

binRes = .05;

idx1 = 'erasurelogindex8.txt';
rnd1 = 'erasurerandomlogindex8.txt';

% gidx1 = 'log12_11_2012greedy.txt';
% grnd1 = 'log12_11_2012greedyrandom.txt';

% [gstr8,grnd8,geps8] = binPlot(binRes,gidx1,grnd1,8);

[str8, rnd8, eps8, histStr8, histRnd8] = binPlot(binRes,idx1,rnd1,8);
[str4, rnd4, eps4, histStr4, histRnd4] = binPlot(binRes,'erasurelogindex4.txt','erasurerandomlogindex4.txt',4);
[str12, rnd12, eps12, histStr12, histRnd12] = binPlot(binRes,'erasurelogindex12.txt','erasurerandomlogindex12.txt',12);

xmax = eps12(max([find(~isnan(str12)) find(~isnan(rnd12))])); %change to fit both
%yran = [min([gainStrAvg gainRndAvg]) max([gainStrAvg gainRndAvg])];
yran = [0 4];

legstr = {};
figure
%plot(eps8,str8,'--o',eps8,rnd8,'--x',eps4,str4,'--+',eps4,rnd4,'--*',[0 1],[1 1],'k')
hold on;
plot(eps4,str4,'b-d','linewidth', 2, 'markersize', 12); legstr{end+1} = 'Structured, K = 4'; 
plot(eps4,rnd4,'b--*','linewidth', 2, 'markersize', 12); legstr{end+1} = 'Random, K = 4';
plot(eps8,str8,'r-o','linewidth', 2, 'markersize', 12); legstr{end+1} = 'Structured, K = 8';
plot(eps8,rnd8,'r--x','linewidth', 2, 'markersize', 12); legstr{end+1} = 'Random, K = 8'; 
plot(eps12,str12,'g-s','linewidth', 2, 'markersize', 12); legstr{end+1} = 'Structured, K = 12'; 
plot(eps12,rnd12,'g--+','linewidth', 2, 'markersize', 12); legstr{end+1} = 'Random, K = 12'; 
plot([0 1],[1 1],'-.k', 'linewidth', 1); legstr{end+1} = 'TDM';
hold off;
%plot(eps8,str8,'--o',eps8,rnd8,'--x',geps8,gstr8,'--+',geps8,grnd8,'--*');
xlim([0 xmax])
%title('Index Coding Gain Over TDMA')
xlabel('Probability of Erasure')
ylim(yran)
ylabel('Gain')
%legend('Structured, N = 8', 'Random, N = 8', 'Structured, N = 4','Random, N = 4', 'TDMA', 'Location', 'Northwest')
% legend('Structured, K = 8', 'RNC, K = 8', 'Structured, K = 4','RNC, K = 4', 'Structured, K = 12', 'RNC, K = 12', 'TDM', 'Location', 'Northwest')
legend(legstr)
set(gca,'FontSize',24)
xlhand = get(gca,'xlabel');
set(xlhand,'string','Probability of Erasure','fontsize',24)
ylhand = get(gca,'ylabel');
set(ylhand,'string','Coding Gain','fontsize',24)



%legend('Structured, N = 8', 'Random, N= 8', 'GreedyStructured, N = 8', 'GreedyRandom, N = 8');

%figure
%plot(eps12,str12,'--o',eps12,rnd12,'--x',[0 1],[1 1],'k')
%xlabel('Probability of Erasure')
%ylim(yran)
%ylabel('Gain')

%histogram to determine what to run next, center point and corresponding number of runs
[eps12' histStr4(1:end-1) histRnd4(1:end-1) histStr8(1:end-1) histRnd8(1:end-1) histStr12(1:end-1) histRnd12(1:end-1)]
disp('Structured coding gain over RNC')
disp('4')
str4./rnd4
disp('8')
str8./rnd8
disp('12')
str12./rnd12