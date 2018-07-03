% Prepare the workspace
close all 
clear all

% Load dataset in Matlab
load AC50001_assignment2_data.mat;

% Combine dataset
 data = [digit_eight, digit_five, digit_one];

% LDA

% Labels
 labels_1 = cell(300,1);
 for i=1:100
     labels_1{i} = 'eight';
 end
 for i=101:200
     labels_1{i} = 'five';
 end
 for i=201:300
     labels_1{i} = 'one';
 end
 
 % Class means
 mean_8 = mean(digit_eight')';
 mean_5 = mean(digit_five')';
 mean_1 = mean(digit_one')';
 mean_all = (mean_8+mean_5+mean_1)./3;
 
 % Class covariance matrix
 S8 = cov(digit_eight');
 S5 = cov(digit_five');
 S1 = cov(digit_one');
 
 % Within class scatter matrix
 Sw = S8+S5+S1;
 
 % Adjust Sw
 idmatrix = eye(784);
 idmatrix = idmatrix*0.01;
 Sw = Sw + idmatrix;
 n=100;
 
 % Between class scatter matrix
 Sb8 = 100*(mean_8-mean_all)*(mean_8-mean_all)';
 Sb5 = 100*(mean_5-mean_all)*(mean_5-mean_all)';
 Sb1 = 100*(mean_1-mean_all)*(mean_1-mean_all)';
 SB = Sb8 + Sb5 + Sb1;
 
 % LDA projection
 invSw = inv(Sw);
 invSw_by_SB = invSw * SB;
 
 % Vector Projection 
 [V,D] = eigs(invSw_by_SB);
 LDA_score = data'*V(:,1:2);

 % K-means clustering, k=3
  rng(1);
 [idx,C] = kmeans(LDA_score,3);
 x1 = min(LDA_score(:,1)):0.01:max(LDA_score(:,1));
 x2 = min(LDA_score(:,2)):0.01:max(LDA_score(:,2));
 [x1G,x2G] = meshgrid(x1,x2);
 XGrid = [x1G(:),x2G(:)]; 

 idx2Region = kmeans(XGrid,3,'MaxIter',100,'Start',C);
 
 % Plot the cluster regions
 figure;
gscatter(XGrid(:,1),XGrid(:,2),idx2Region,...
    [0,0.75,0.75;0.75,0,0.75;0.75,0.75,0],'..');
hold on;
scatter(LDA_score(1:100,1), LDA_score(1:100,2),'r')
scatter(LDA_score(101:200,1), LDA_score(101:200,2),'g')
scatter(LDA_score(201:300,1), LDA_score(201:300,2),'b')
title 'LDA';
legend('Region 1','Region 2','Region 3','Eights','Fives','Ones','Location','SouthEast');
hold off;