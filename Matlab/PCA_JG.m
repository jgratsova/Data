% Prepare the workspace
close all 
clear all

% Load dataset in Matlab
load AC50001_assignment2_data.mat;

% Combine dataset
 data = [digit_eight, digit_five, digit_one];
 
% PCA
% PCA to reduce the dimensions of each image descriptor to two using the first two principal components
 trans_data = data';
 [coeff,score] = pca(trans_data, 'NumComponents', 2);
 figure;
 hold on;
 scatter(score(1:100,1), score(1:100,2),'r', 'x')
 scatter(score(101:200,1), score(101:200,2), 'g', 'x')
 scatter(score(201:300,1), score(201:300,2), 'b', 'x')
 title ('PCA');
 legend('Eights', 'Fives', 'Ones','Location','SE');
 grid on;
 hold off;
 
% K-means clustering, k=3
 rng(1); % For reproducibility
[idx,C] = kmeans(score,3);
x1 = min(score(:,1)):0.01:max(score(:,1));
x2 = min(score(:,2)):0.01:max(score(:,2));
[x1G,x2G] = meshgrid(x1,x2);
 % Define a fine grid on the plot
XGrid = [x1G(:),x2G(:)];
% Use kmeans to compute the distance from each centroid to points on a grid
idx2Region = kmeans(XGrid,3,'MaxIter',100,'Start',C);
%idx2Region = kmeans(XGrid,3,'Distance','cosine');

% Plot the cluster regions
figure;
gscatter(XGrid(:,1),XGrid(:,2),idx2Region,...
    [0,0.75,0.75;0.75,0,0.75;0.75,0.75,0],'..');
hold on
scatter(score(1:100,1), score(1:100,2),'c', 'x')
 scatter(score(101:200,1), score(101:200,2), 'm', 'x')
 scatter(score(201:300,1), score(201:300,2), 'y', 'x')
 title 'K-means clustering, k=3';
 legend('Region 1','Region 2','Region 3','Eights', 'Fives', 'Ones','Location','SE');
hold off


% Clustering using hierarchical clustering
rng(1);
% Chebychev distance
Cheb = pdist(score, 'chebychev');
chebtree = linkage(Cheb, 'weighted');
cophenet(chebtree, Cheb)
figure;
dendrogram(chebtree, 0);
gca.TickDir = 'out';
gca.TickLength = [.005 0];
gca.XTickLabel = [];
title 'Chebychev dendrogram';

% Cosine distance
cosD = pdist(score,'cosine');
costree = linkage(cosD, 'average');
cophenet(costree,cosD)
figure;
dendrogram(costree,0);
gca.TickDir = 'out';
gca.TickLength = [.002 0];
gca.XTickLabel = [];
title 'Cosine dendrogram';

% Plotting hierarchical clustering
hidx = cluster(costree,'criterion','distance','cutoff',0.85);
figure;
for i = 1:5
    clust = find(hidx==i);
    plot(score(clust,1),score(clust,2),'x');
    hold on
end
title 'Hierarchical clustering';
hold off
