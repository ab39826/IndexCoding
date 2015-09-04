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

figure
%plot(eps8,str8,'--o',eps8,rnd8,'--x',eps4,str4,'--+',eps4,rnd4,'--*',[0 1],[1 1],'k')
plot(eps8,str8,'--o',eps8,rnd8,'--x',eps4,str4,'--d',eps4,rnd4,'--*',eps12,str12,'--s',eps12,rnd12,'--+',[0 1],[1 1],'-.k')

%plot(eps8,str8,'--o',eps8,rnd8,'--x',geps8,gstr8,'--+',geps8,grnd8,'--*');
xlim([0 xmax])
%title('Index Coding Gain Over TDMA')
xlabel('Probability of Erasure')
ylim(yran)
ylabel('Gain')
%legend('Structured, N = 8', 'Random, N = 8', 'Structured, N = 4','Random, N = 4', 'TDMA', 'Location', 'Northwest')
legend('Structured, N = 8', 'Random, N = 8', 'Structured, N = 4','Random, N = 4', 'Structured, N = 12', 'Random, N = 12', 'TDMA', 'Location', 'Northwest')




%legend('Structured, N = 8', 'Random, N= 8', 'GreedyStructured, N = 8', 'GreedyRandom, N = 8');

%figure
%plot(eps12,str12,'--o',eps12,rnd12,'--x',[0 1],[1 1],'k')
%xlabel('Probability of Erasure')
%ylim(yran)
%ylabel('Gain')

%histogram to determine what to run next, center point and corresponding number of runs
[eps12' histStr4(1:end-1) histRnd4(1:end-1) histStr8(1:end-1) histRnd8(1:end-1) histStr12(1:end-1) histRnd12(1:end-1)]
