function predictions = predict_tree(tree,features)

features = features(:,tree.selectedFeatures);

numInstances = size(features,1);
features = [features, ones(numInstances,1)];
numLabels = tree.numLabels;
predictions = zeros(numInstances,numLabels);

for i = 1:1:numInstances
    featuresInstance = features(i,:);
    currentNode = 1;
    while(currentNode > 0)
        weightsNode = tree.weights(currentNode,:);
        assignment = (featuresInstance*weightsNode' > 0);
        if(assignment)
            currentNode = tree.nextNode(currentNode,1);
        else
            currentNode = tree.nextNode(currentNode,2);
        end
    end
    predictions(i,:) = tree.predictions(-1.*currentNode,:) .* tree.predWeights';
end

end

