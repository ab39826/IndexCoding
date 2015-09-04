%main function for plotting

clear all
%close all

%change with each value of N
idx1 = 'erasurelogindex8.txt';
rnd1 = 'erasurerandomlogindex8.txt';
N = 8;


Awhole = load(idx1);
Bwhole = load(rnd1);

A = Awhole(Awhole(:,1)==N,3:end); %change when erasure vector??
B = Bwhole(Bwhole(:,1)==N,3:end); 

epStr = A(:,3);
epRnd = B(:,3);
gainStr = A(:,1)./A(:,2); %either index or random coding
gainRnd = B(:,1)./B(:,2);

xmax = max([epStr; epRnd]);
yran = [min([gainStr; gainRnd]) max([gainStr; gainRnd])];
%yran = [0 4]; %same for all?

figure
%plot(eps8,str8,'--o',eps8,rnd8,'--x',eps4,str4,'--+',eps4,rnd4,'--*',[0 1],[1 1],'k')
%plot(eps8,str8,'--o',eps8,rnd8,'--x',eps4,str4,'--d',eps4,rnd4,'--*',eps12,str12,'--s',eps12,rnd12,'--+',[0 1],[1 1],'k')
plot(epStr,gainStr,'o',epStr,gainRnd,'x',[0 1],[1 1],'k')

%plot(eps8,str8,'--o',eps8,rnd8,'--x',geps8,gstr8,'--+',geps8,grnd8,'--*');
xlim([0 xmax])
%title('Index Coding Gain Over TDMA')
xlabel('Probability of Erasure')
ylim(yran)
ylabel('Gain')
%legend('Structured, N = 8', 'Random, N = 8', 'Structured, N = 4','Random, N = 4', 'TDMA', 'Location', 'Northwest')
%legend('Structured, N = 8', 'Random, N = 8', 'Structured, N = 4','Random, N = 4', 'Structured, N = 12', 'Random, N = 12', 'TDMA', 'Location', 'Northwest')
legend(['Structured, N = ' num2str(N)], ['Random, N= ' num2str(N)], 'TDMA', 'Location', 'Northwest')




%legend('Structured, N = 8', 'Random, N= 8', 'GreedyStructured, N = 8', 'GreedyRandom, N = 8');

%figure
%plot(eps12,str12,'--o',eps12,rnd12,'--x',[0 1],[1 1],'k')
%xlabel('Probability of Erasure')
%ylim(yran)
%ylabel('Gain')

%histogram to determine what to run next
%[[eps12 1]' histStr4 histRnd4 histStr8 histRnd8 histStr12 histRnd12]
