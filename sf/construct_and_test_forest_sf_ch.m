function [precisionTemp,recallTemp,f1Temp,AUCTemp] = construct_and_test_forest_sf_ch(trainingFeatures,trainingLabels,testFeatures,testLabels,numTrees,minLeaf,labelSampling,featureSampling,instanceSampling,usedWeightParam)

predictions = zeros(size(testLabels));
predictionsTrain = zeros(size(trainingLabels));
numLabels = size(testLabels,2);
counts = zeros(numLabels,1);
trainCounts = zeros(size(predictionsTrain));
for j = 1:1:numTrees
    disp(['Tree ' num2str(j)]);
    tree = construct_tree_sf_ch(trainingFeatures,trainingLabels,minLeaf,labelSampling,featureSampling,instanceSampling,usedWeightParam);
    predictions = predictions + predict_tree_sf(tree,testFeatures);
    predictionsTrain = predictionsTrain + tree.oobPredictions;
    trainCounts = trainCounts + (tree.oobIndices * tree.predWeights');
    counts = counts + tree.predWeights;
end
predictions = bsxfun(@rdivide,predictions,counts');
predictionsTrain = predictionsTrain ./ trainCounts;

precisionTemp = zeros(1,numLabels);
recallTemp = zeros(1,numLabels);
f1Temp = zeros(1,numLabels);
AUCTemp = zeros(1,numLabels);

for j = 1:1:numLabels
    thresh = 0;
    bestF = 0;
    for k = 0:0.01:1
        [~,~,f1] = get_statistics(trainingLabels(:,j),predictionsTrain(:,j) >= k);
        if f1 >= bestF
            thresh = k;
            bestF = f1;
        end
    end
        
    [~,~,~,AUC] = perfcurve(testLabels(:,j),predictions(:,j),1);
    [precision,recall,f1] = get_statistics(testLabels(:,j),predictions(:,j) >= thresh);
    precisionTemp(j) = precision;
    recallTemp(j) = recall;
    f1Temp(j) = f1;
    AUCTemp(j) = AUC;
end

end