%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% loading workspaces %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('coursework_dataprep');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          TRAINING       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% converting training labels to correct format
training_labels_conv = table2array(training_labels);
training_features_conv = table2array(training_features);

%%%%%%%%%%%%%%% HYPER PARAMETER TUNING AND IMPACT ASSESSMENT %%%%%%%%%%%%%%%%
% varying number of bins and prior and recording the AUC
% setting up variables and matrix to store output
bins_to_consider = 8;
grid_nb = 1:bins_to_consider * 3 * 2;
grid_nb = reshape(grid_nb, [bins_to_consider * 2,3]);
counter = 0;
% columns of the following index are categorical and will be excluded from discretization
categorical_columns_index = [2, 4, 5, 6, 7];
for no_bins=1:bins_to_consider
    training_features_binned = training_features_conv;
%     iterating over columns and discretizing non-categorical columns
    for i=1:size(training_features_conv, 2)
        if ~ismember(i, categorical_columns_index)
            [feature_binned, edges_features] = discretize(training_features_conv(:,i),no_bins);
            training_features_binned(:, i) = feature_binned;
        end
    end
%     for each number of bins, fit two sets of naive bayes with differing priors - one with empirical and another with uniform
    for prior=1:2
        if prior == 1
            nb_hyper = fitcnb(training_features_binned, training_labels_conv, 'DistributionNames', 'mn', 'prior', 'empirical','CrossVal', 'on');
        else
            nb_hyper = fitcnb(training_features_binned, training_labels_conv, 'DistributionNames', 'mn', 'prior', 'uniform','CrossVal', 'on');
        end
%         getting predicted classification from naive bayes
        hyper_training_pred_class = kfoldPredict(nb_hyper);
%         getting AUC of prediction
        [hyper_X_NB,hyper_Y_NB,hyper_T_NB,hyper_AUC_NB,hyper_OPTROCPT_NB] = perfcurve(training_labels_conv, hyper_training_pred_class, 1);
%         storing hyper parameter values and AUC in matrix
        counter = counter + 1;
        grid_nb(counter, 1) = no_bins;   
        grid_nb(counter, 2) = prior;
        grid_nb(counter, 3) = hyper_AUC_NB;
    end
end

% plotting a 2D scatterplot of AUC against the number of bins, coloured by the prior used
gscatter(grid_nb(:, 1), grid_nb(:,3), grid_nb(:,2), 'rb')
xlabel("Number of Bins");
ylabel("AUC");
legend("Empirical", "Uniform");
title('AUC by Hyper Parameters - Naive Bayes')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MODEL SELECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%
% selecting optimal number of bins and prior distribution to use, by the largest AUC
max_index = find(grid_nb(:, 3) == max(grid_nb(:,3)));
selected_num_bins = grid_nb(max_index, 1);
selected_prior = grid_nb(max_index, 2);

%%%%%%%%%%%%% Fitting a Naive Bayes with above selected hyper parameters %%%%%%%%%%%%
% binning features with selected number of bins
training_features_binned = training_features_conv;
% iterating over columns and discretizing non-categorical columns
for i=1:size(training_features_conv, 2)
    if ~ismember(i, categorical_columns_index)
        [feature_binned, edges_features] = discretize(training_features_conv(:,i),selected_num_bins);
        training_features_binned(:, i) = feature_binned;
    end
end

% fitting Naive Bayes with above mentioned selected hyper parameters
if prior == 1
    nb_selected = fitcnb(training_features_binned, training_labels_conv, 'DistributionNames', 'mn', 'prior', 'empirical','CrossVal', 'on');
else
    nb_selected = fitcnb(training_features_binned, training_labels_conv, 'DistributionNames', 'mn', 'prior', 'uniform','CrossVal', 'on');
end

% getting predicted classification from naive bayes
training_pred_class = kfoldPredict(nb_selected);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EVALUATING RESULTS ON TRAINING SET %%%%%%%%%%%%%
% getting ROC and AUC of fitted NB
[training_X_NB,training_Y_NB,training_T_NB,training_AUC_NB,training_OPTROCPT_NB] = perfcurve(training_labels_conv, training_pred_class, 1);
figure()
plot(training_X_NB,training_Y_NB);
xlabel('False positive rate');
ylabel('True positive rate');
title('ROC for Classification by Naive Bayes - Training');
training_AUC_NB

% plotting confusion matrix
figure()
confusionchart(training_labels_conv, training_pred_class);

% computing f1 score on training set results
C_NB_TRAIN = confusionmat(training_labels_conv, training_pred_class);
TP_NB_TRAIN = C_NB_TRAIN(1,1); FN_NB_TRAIN = C_NB_TRAIN(1,2);
FP_NB_TRAIN = C_NB_TRAIN(2,1); TN_NB_TRAIN = C_NB_TRAIN(2,2);
sens_nb_train = TP_NB_TRAIN/(TP_NB_TRAIN + FN_NB_TRAIN)
spec_nb_train = TN_NB_TRAIN/(FP_NB_TRAIN + TN_NB_TRAIN)
f1_score_nb_train = TP_NB_TRAIN/(TP_NB_TRAIN+0.5*(FP_NB_TRAIN + FN_NB_TRAIN))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% saving worksapce %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save('coursework_training_nb');