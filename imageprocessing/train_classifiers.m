global RR;

load tile_featureset_training_data.mat tiles featuresets gamestates;

% rename tiles to avoid false assumptions about its structure
xs = tiles;
clear tiles;

ys = [featuresets(:, RR.features.conveyor_north)
      false(size(gamestates, 1), 1)];

[xs, ys] = training_images_to_matrix(xs, ys);

% svmtrain accepts only floating-point values
xs = double(xs)/255;

[itrain, itest] = crossvalind('HoldOut', size(xs, 1), 0.2);

xstest = xs(itest, :);
ystest = ys(itest, :);
xs(itest, :) = [];
ys(itest, :) = [];

svm = svmtrain(xs, ys);
ystest_estimate = svmclassify(svm, xstest);

C = confusionmat(ystest, ystest_estimate)
