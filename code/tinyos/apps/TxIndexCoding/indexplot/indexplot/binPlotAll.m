%main function for plotting

clear all
close all

%change with each value of N
idx1 = 'erasurelogindex12.txt';
rnd1 = 'erasurerandomlogindex12.txt';
N = 12;


Awhole = load(idx1);
Bwhole = load(rnd1);

A = Awhole(Awhole(:,1)==N,3:end); %change when erasure vector??
B = Bwhole(Bwhole(:,1)==N,3:end); 

epStr12 = A(:,3);
epRnd12 = B(:,3);
gainStr12 = A(:,1)./A(:,2); %either index or random coding
gainRnd12 = B(:,1)./B(:,2);

idx1 = 'erasurelogindex8.txt';
rnd1 = 'erasurerandomlogindex8.txt';
N = 8;


Awhole = load(idx1);
Bwhole = load(rnd1);

A = Awhole(Awhole(:,1)==N,3:end); %change when erasure vector??
B = Bwhole(Bwhole(:,1)==N,3:end); 

epStr8 = A(:,3);
epRnd8 = B(:,3);
gainStr8 = A(:,1)./A(:,2); %either index or random coding
gainRnd8 = B(:,1)./B(:,2);
idx1 = 'erasurelogindex4.txt';
rnd1 = 'erasurerandomlogindex4.txt';
N = 4;


Awhole = load(idx1);
Bwhole = load(rnd1);

A = Awhole(Awhole(:,1)==N,3:end); %change when erasure vector??
B = Bwhole(Bwhole(:,1)==N,3:end); 

epStr4 = A(:,3);
epRnd4 = B(:,3);
gainStr4 = A(:,1)./A(:,2); %either index or random coding
gainRnd4 = B(:,1)./B(:,2);

xmax = max([epStr12; epRnd12; epStr8; epRnd8; epStr4; epRnd4]);
yran = [min([gainStr12; gainRnd12; gainStr8; gainRnd8; gainStr4; gainRnd4])... 
    max([gainStr12; gainRnd12; gainStr8; gainRnd8; gainStr4; gainRnd4])];
%yran = [0 4]; %same for all?

legstr = {};
figure
hold on;
%plot(eps8,str8,'--o',eps8,rnd8,'--x',eps4,str4,'--+',eps4,rnd4,'--*',[0 1],[1 1],'k')
% plot(eps8,str8,'--o',eps8,rnd8,'--x',eps4,str4,'--d',eps4,rnd4,'--*',eps12,str12,'--s',eps12,rnd12,'--+',[0 1],[1 1],'k')
MS = 12;
plot(epStr4,gainStr4,'bd', 'markersize', MS)
plot(epRnd4,gainRnd4,'b*', 'markersize', MS)
legstr{end+1} = 'Structured, K = 4';
legstr{end+1} = 'Random, K = 4';
plot(epStr8,gainStr8,'ro', 'markersize', MS)
plot(epRnd8,gainRnd8,'rx', 'markersize', MS)
legstr{end+1} = 'Structured, K = 8';
legstr{end+1} = 'Random, K = 8';
plot(epStr12,gainStr12,'gs', 'markersize', MS)
plot(epRnd12,gainRnd12, 'g+', 'markersize', MS)
legstr{end+1} = 'Structured, K = 12';
legstr{end+1} = 'Random, K = 12';
plot([0 1], [1 1], '-.k')
legstr{end+1} = 'TDM'
hold off;
%plot(eps8,str8,'--o',eps8,rnd8,'--x',geps8,gstr8,'--+',geps8,grnd8,'--*');
xlim([0 xmax])
%title('Index Coding Gain Over TDMA')
xlabel('Probability of Erasure')
ylim(yran)
ylabel('Gain')
legend(legstr)
set(gca,'FontSize',24)
xlhand = get(gca,'xlabel');
set(xlhand,'string','Probability of Erasure','fontsize',24)
ylhand = get(gca,'ylabel');
set(ylhand,'string','Coding Gain','fontsize',24)
%legend('Structured, N = 8', 'Random, N = 8', 'Structured, N = 4','Random, N = 4', 'TDMA', 'Location', 'Northwest')
%legend('Structured, N = 8', 'Random, N = 8', 'Structured, N = 4','Random, N = 4', 'Structured, N = 12', 'Random, N = 12', 'TDMA', 'Location', 'Northwest')
% legend(['Structured, N = ' num2str(N)], ['Random, N= ' num2str(N)], 'TDMA', 'Location', 'Northwest')




%legend('Structured, N = 8', 'Random, N= 8', 'GreedyStructured, N = 8', 'GreedyRandom, N = 8');

%figure
%plot(eps12,str12,'--o',eps12,rnd12,'--x',[0 1],[1 1],'k')
%xlabel('Probability of Erasure')
%ylim(yran)
%ylabel('Gain')

%histogram to determine what to run next
%[[eps12 1]' histStr4 histRnd4 histStr8 histRnd8 histStr12 histRnd12]
