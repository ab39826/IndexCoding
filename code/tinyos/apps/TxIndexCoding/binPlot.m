function [gainStrAvg, gainRndAvg, binCenters, histStr, histRnd] = binPlot(binRes,indexFile,randomFile,N)

%clear all
%close all

%load erasurelogindex4.txt
%load erasurerandomlogindex4.txt
%load both and calculate both at once?

%Awhole = erasurelogindex4;
%Bwhole = erasurerandomlogindex4;

Awhole = load(indexFile);
Bwhole = load(randomFile);

%N = 4;
A = Awhole(Awhole(:,1)==N,3:end); %change when erasure vector??
B = Bwhole(Bwhole(:,1)==N,3:end); 

%binRes = .1;
binEdges = 0:binRes:1;
binCenters = binEdges(1:end-1) + binRes/2;
epStr = A(:,3);
epRnd = B(:,3);
gainStr = A(:,1)./A(:,2); %either index or random coding
gainRnd = B(:,1)./B(:,2);

[histStr,binNo] = histc(epStr,binEdges);
[histRnd,binRandNo] = histc(epRnd,binEdges);
%gainStrAvg = zeros(size(binCenters));
gainStrAvg = nan(size(binCenters));
gainRndAvg = gainStrAvg;

for i = 1:length(binCenters)
	gainStrBin = gainStr(binNo == i);
	if (length(gainStrBin) >= 20)
	%only average if sufficient number in gainStrBin? comment out for raw data
        gainStrAvg(i) = mean(gainStrBin);
	end
	gainRndBin = gainRnd(binRandNo == i);
	if (length(gainRndBin) >= 20)
        gainRndAvg(i) = mean(gainRndBin);
    end
end

%xmax = binCenters(max([find(~isnan(gainStrAvg)) find(~isnan(gainRndAvg))])); %change to fit both
%yran = [min([gainStrAvg gainRndAvg]) max([gainStrAvg gainRndAvg])];
%yran = [0 5];
%yran = [0 4];

%figure
%plot(binCenters,gainStrAvg,'--o',binCenters,gainRndAvg,'--x',[0 1],[1 1],'k')
%xlim([0 xmax])
%%title('Index Coding Gain Over TDMA')
%xlabel('Probability of Erasure')
%ylim(yran)
%ylabel('Gain')
%legend(['Structured, N = ' num2str(N)], ['Random, N= ' num2str(N)], 'TDMA', 'Location', 'Northwest')


%%check epsilons over time?
%epsRange = [1:3]
%%epsVec = B(:,4:end);
%epsVec = B(:,3+epsRange);
%figure
%plot(epsVec)
%title('Erasure Probabilities for Each Node')
%xlabel('Iteration')

end
