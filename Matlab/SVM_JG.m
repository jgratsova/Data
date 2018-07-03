% Prepare the workspace
close all 
clear all

% Load dataset in Matlab
load AC50001_assignment2_data.mat;


% Combine dataset
 data = [digit_eight, digit_five, digit_one];
 t_data = data';
 % Labels
 labels = cell(300,1);
 for i=1:100
     labels{i} = 'eight';
 end
 for i=101:200
     labels{i} = 'five';
 end
 for i=201:300
     labels{i} = 'one';
 end
 
 % SVM
 % Fives against the rest
labels_2 = ones(size(labels));
labels_2(1:100,1) = -1;
labels_2(201:300,1) = -1;

% 5 fold
partition = cvpartition(labels_2,'KFold',5);
acc1 = zeros(partition.NumTestSets,1);
acc2 = zeros(partition.NumTestSets,1);

d1 = zeros(300,1);
d2 = zeros(300,1);
ground_t1 = zeros(300,1);
ground_t2 = zeros(300,1);

for i = 1:partition.NumTestSets
     % Training sample set
    train_index = partition.training(i);
    % Test sample set
    test_index = partition.test(i);
    % Training truth
    training_label = labels_2(train_index);
    % Training data matrix
    training_matrix = t_data(train_index,:);
    % Testing truth
    test_label = labels_2(test_index);
    % Test data matrix
    test_matrix = t_data(test_index,:); 
    
    % SVM with Linear kernel
    model1 = svmtrain(training_label, training_matrix, '-t 0');
    g = 0.025; 
    args = sprintf('-t 2 -g %1.2f -c 1', g); 
    model2 = svmtrain(training_label, training_matrix, args);
    
    % Classify test data
    [predict_label, acc1, dec_values] = svmpredict(test_label, test_matrix, model1);
    d1(((i-1)*60+1):(60*i),1) = dec_values;
    ground_t1(((i-1)*60+1):(60*i),1) = test_label;
    [predict_label2, acc2, dec_values2] = svmpredict(test_label, test_matrix, model2);
    d2(((i-1)*60+1):(60*i),1) = dec_values2;
    
    acc1(i) = acc1(1);
    acc2(i) = acc2(1);

end
disp("Linear")
av_acc1 = mean(acc1)
av_acc2 = mean(acc2)

% ROC linear
[X1,Y1,area] = perfcurve(ground_t1,d1,1); 
[X2,Y2,area2] = perfcurve(ground_t1,d2,1);
figure; plot(X1,Y1);
hold on
plot(X2,Y2);
hold off

area_mu_linear = mean(area);
area_mu_RBF = mean(area2);
av_acc1 = mean(acc1);
av_acc2 = mean(acc2);

% G 
partG = cvpartition(labels_2,'KFold',5);
train_index = partG.training(1); 
test_index = partG.test(1); 
training_label = labels_2(train_index); 
training_matrix = t_data(train_index,:); 
test_label = labels_2(test_index); 
test_matrix = t_data(test_index,:); 

% SVM with RBF kernel
ga = zeros(100,2);
acc_g = zeros(1);
for i = 1:100
    ground_t2 = double(i)/2000; 
    args = sprintf('-t 2 -g %1.2f -c 1', ground_t2);
    model2g = fitcsvm(training_label, training_matrix, args);
    % Data testing
    [predict_labelg, accuracyg, dec_valuesg] = svmpredict(test_label, test_matrix, model2g);
    acc_g = accuracyg(1);
    ga(i, 1:2) = [ground_t2, acc_g];
end

cost = zeros(100,2);
a_cost = zeros(1);
for i = 1:100
    cost = double(i); 
    args = sprintf('-t 2 -g 0.02 -c %1.2f', cost);
    mod2c = fitcsvm(training_label, training_matrix, args);
    % Test data classification
    [predict_labelC, accuracyC, dec_valuesC] = svmpredict(test_label, test_matrix, mod2c);
    a_cost = accuracyC(1);
    cost(i, 1:2) = [cost, a_cost];
end

disp("RBF")
Average_accG = mean(acc_g)