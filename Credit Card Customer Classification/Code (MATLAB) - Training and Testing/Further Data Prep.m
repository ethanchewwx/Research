close all; clear all; clc;

% importing dataset
training_table = readtable("training_set.csv");
testing_table = readtable("testing_set.csv");

% splitting into labels and features
training_labels = training_table(:, 1);
training_features = training_table(:, 2:end);
testing_labels = testing_table(:, 1);
testing_features = testing_table(:, 2:end);

% saving workspace
save('coursework_dataprep');