%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% loading workspaces %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('coursework_dataprep');
load('coursework_training_nb');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TESTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% converting to correct format
testing_labels_conv = table2array(testing_labels);
testing_features_conv = table2array(testing_features);

% binning features with selected number of bins
testing_features_binned = testing_features_conv;
% iterating over columns and discretizing non-categorical columns
for i=1:size(testing_features_conv, 2)
    if ~ismember(i, categorical_columns_index)
        [feature_binned, edges_features] = discretize(testing_features_conv(:,i),selected_num_bins);
        testing_features_binned(:, i) = feature_binned;
    end
end

% getting predicted class over testing dataset, using each trained naive bayes
grid_nb_pred = 1:size(testing_labels_conv, 1)*11;
grid_nb_pred = reshape(grid_nb_pred, [size(testing_labels_conv,1),11]);
for i=1:10
    grid_nb_pred(:,i) = predict(nb_selected.Trained{i}, testing_features_binned);
end

% applying majority voting
grid_nb_pred(:,11) = sum(grid_nb_pred(:,1:10), 2);
for i=1:size(grid_nb_pred,1)
    if grid_nb_pred(i,11) > 5
        grid_nb_pred(i,11) = 1;
    else
        grid_nb_pred(i,11) = 0;
    end
end

% storing predicted class from majority voting into a variable
testing_pred_class_nb = grid_nb_pred(:,11);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EVALUATING RESULTS ON TESTING SET %%%%%%%%%%%%%
% plotting ROC and getting AUC
[testing_X_NB,testing_Y_NB,testing_T_NB,testing_AUC_NB,testing_OPTROCPT_NB] = perfcurve(testing_labels_conv, testing_pred_class_nb, 1);
plot(testing_X_NB,testing_Y_NB)
xlabel('False positive rate');
ylabel('True positive rate');
title('ROC for Classification by Naive Bayes - Testing');
testing_AUC_NB

% plotting confusion matrix
figure()
confusionchart(testing_labels_conv, testing_pred_class_nb)

% computing f1 score on testing results
C_NB_TEST = confusionmat(testing_labels_conv, testing_pred_class_nb);
TP_NB_TEST = C_NB_TEST(1,1); FN_NB_TEST = C_NB_TEST(1,2);
FP_NB_TEST = C_NB_TEST(2,1); TN_NB_TEST = C_NB_TEST(2,2);
sens_nb_test = TP_NB_TEST/(TP_NB_TEST + FN_NB_TEST)
spec_nb_test = TN_NB_TEST/(FP_NB_TEST + TN_NB_TEST)
f1_score_nb_test = TP_NB_TEST/(TP_NB_TEST+0.5*(FP_NB_TEST + FN_NB_TEST))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% saving workspace %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save('coursework_testing_nb');