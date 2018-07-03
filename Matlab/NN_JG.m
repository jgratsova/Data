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

% Neural Network

% Fives against the rest
labels_4 = ones(size(labels));
labels_4(1:100,1) = 0;
labels_4(201:300,1) = 0;

data = data;
labels4 = labels_4';

% Scaled conjugate gradient backpropagation
trainFcn = 'trainscg'; 

% Pattern recognition
hidden_layer = 1;

ground_t_nn = zeros(1500,1);
dec_y = zeros(1500,1);
accuracy_nn_all = zeros(5,1);

for i = 1:5
    n = patternnet(hidden_layer);

    % Training, validation and testing performance
    n.divideParam.trainRatio = 60/100;
    n.divideParam.valRatio = 20/100;
    n.divideParam.testRatio = 20/100;
    % Training
    [n,tr] = train(n,data,labels4);
    % Testing
    y = n(data);
    e = gsubtract(labels4,y);
    performance = perform(n,labels4,y);
    tind = vec2ind(labels4);
    yind = vec2ind(y);
    percentErrors = sum(tind ~= yind)/numel(tind);

    % Recalculation
    train_t = labels4 .* tr.trainMask{1};
    valid_t = labels4 .* tr.valMask{1};
    test_t = labels4 .* tr.testMask{1};
    train_perf = perform(n,train_t,y);
    valid_perf = perform(n,valid_t,y);
    test_perf = perform(n,test_t,y);

    ground_t_nn(((i-1)*300+1):(300*i),1) = test_t';
    dec_y(((i-1)*300+1):(300*i),1) = y';
    [miss,cm] = confusion(test_t,y);
    disp(['Accuracy: ', num2str(100*(1-miss))]);
    Accuracy_nn = 100*(1-miss);
    accuracy_nn_all(i,1) = Accuracy_nn;
end

% View the Network
view(n);

[Xnn,Ynn,T,areann] = perfcurve(ground_t_nn,dec_y,1);
Area_mean_nn = mean(areann);
 Acc_mu_nn = mean(accuracy_nn_all)
 % Plot the performance
 figure;
 plotperform(tr)

 
 


