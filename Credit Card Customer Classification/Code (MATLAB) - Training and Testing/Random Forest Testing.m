%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% loading workspaces %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('coursework_dataprep');
load('coursework_training_rf');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TESTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getting predicted class over testing dataset, using trained random forest
pred_class_test = predict(B, testing_features);

% converting to correct format
testing_labels_conv = table2array(testing_labels);
testing_pred_class_conv = str2num(cell2mat(pred_class_test));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EVALUATING RESULTS ON TESTING SET %%%%%%%%%%%%%
% plotting ROC and getting AUC
[TESTING_X_RF,TESTING_Y_RF,TESTING_T_RF,TESTING_AUC_RF,TESTING_OPTROCPT_RF] = perfcurve(testing_labels_conv, testing_pred_class_conv, 1);
figure()
plot(TESTING_X_RF,TESTING_Y_RF)
xlabel('False positive rate');
ylabel('True positive rate');
title('ROC for Classification by Random Forest - Testing');
TESTING_AUC_RF

% plotting confusion matrix
figure()
confusionchart(testing_labels_conv, testing_pred_class_conv);

% computing f1 score on testing results
C_RF_TEST = confusionmat(testing_labels_conv, testing_pred_class_conv);
TP_RF_TEST = C_RF_TEST(1,1); FN_RF_TEST = C_RF_TEST(1,2);
FP_RF_TEST = C_RF_TEST(2,1); TN_RF_TEST = C_RF_TEST(2,2);
sens_rf_test = TP_RF_TEST/(TP_RF_TEST + FN_RF_TEST)
spec_rf_test = TN_RF_TEST/(FP_RF_TEST + TN_RF_TEST)
f1_score_rf_test = TP_RF_TEST/(TP_RF_TEST+0.5*(FP_RF_TEST + FN_RF_TEST))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% saving worksapce %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save('coursework_testing_rf');