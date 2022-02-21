%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% loading workspace %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('coursework_dataprep');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   TRAINING  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% converting training labels to correct format
training_labels_conv = table2array(training_labels);

%%%%%%%%%%%%%%%% HYPER PARAMETER TUNING AND IMPACT ASSESSMENT %%%%%%%%%%%%%%%%
% varying hyperparameters, refitting a random forest and recording the AUC
grid = 1:1000;
grid = reshape(grid, [250,4]);
counter = 0;
for tree=1:10
    for num_pred=1:5
        for depth=1:5
%             refitting random forest based on hyperparameters
            hyper_tree = TreeBagger(tree, training_features, training_labels, 'OOBPrediction', 'on', 'OOBPredictorImportance', 'on', 'Method', 'classification', 'NumPredictorsToSample', num_pred, 'MaxNumSplits', depth);
            hyper_pred = oobPredict(hyper_tree);
            hyper_pred_conv = str2num(cell2mat(hyper_pred));
%             getting AUC
            [hyper_X,hyper_Y,hyper_T,hyper_AUC,hyper_OPTROCPT] = perfcurve(training_labels_conv, hyper_pred_conv, 1);
%             updating index and row/column entries with the number of
%             trees, number of predictors considered, depth and AUC
            counter = counter + 1;
            grid(counter,1) = tree;
            grid(counter,2) = num_pred;
            grid(counter,3) = depth;
            grid(counter,4) = hyper_AUC;
        end
    end
end

% plotting a 3D scatterplot by the hyperparameters, coloured by the AUC
scatter3(grid(:, 1), grid(:,2), grid(:, 3), 36, grid(:,4), 'filled');
xlabel("Number of Trees");
ylabel("Number of Predictors Considered");
zlabel("Depth");
colormap(flipud(copper));
cb = colorbar();
title(cb, "AUC");
title('AUC by Hyper Parameters')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MODEL SELECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%
% selecting optimal number of trees, predictors to consider and depth,by the largest AUC
max_index = find(grid(:, 4) == max(grid(:,4)));
selected_num_trees = grid(max_index, 1)
selected_predictors = grid(max_index, 2)
selected_depth = grid(max_index, 3)

% Fitting a random forest with above selected hyper parameters
% SampleWithReplacement set to on so that datapoints can be sampled more than once
% OOBPrediction to store oob observations which can be used for oob prediction
B = TreeBagger(selected_num_trees, training_features, training_labels, 'SampleWithReplacement', 'on', 'OOBPrediction', 'on', 'Method', 'classification', 'NumPredictorsToSample',selected_predictors, 'MaxNumSplits', selected_depth);
pred_class_train = oobPredict(B);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EVALUATING RESULTS ON TRAINING SET %%%%%%%%%%%%%
pred_class_conv_train = str2num(cell2mat(pred_class_train));

% plotting ROC and getting AUC
[TRAINING_X_RF,TRAINING_Y_RF,T,TRAINING_AUC_RF,OPTROCPT] = perfcurve(training_labels_conv, pred_class_conv_train, 1);
figure()
plot(TRAINING_X_RF,TRAINING_Y_RF);
xlabel('False positive rate');
ylabel('True positive rate');
title('ROC for Classification by Random Forest - Training');
TRAINING_AUC_RF

% plotting confusion matrix
figure()
confusionchart(training_labels_conv, pred_class_conv_train);

% computing f1 score on training set results
C_RF_TRAIN = confusionmat(training_labels_conv, pred_class_conv_train);
TP_RF_TRAIN = C_RF_TRAIN(1,1); FN_RF_TRAIN = C_RF_TRAIN(1,2);
FP_RF_TRAIN = C_RF_TRAIN(2,1); TN_RF_TRAIN = C_RF_TRAIN(2,2);
sens_rf_train = TP_RF_TRAIN/(TP_RF_TRAIN + FN_RF_TRAIN)
spec_rf_train = TN_RF_TRAIN/(FP_RF_TRAIN + TN_RF_TRAIN)
f1_score_rf_train = TP_RF_TRAIN/(TP_RF_TRAIN+0.5*(FP_RF_TRAIN + FN_RF_TRAIN))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% saving workspace %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save('coursework_training_rf');