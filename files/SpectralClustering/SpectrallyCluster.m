% We've changed this file to screw around with the segmentation,
% and now, it's our file! Muah ha ha ha ha!

function SpectrallyCluster(FileName,groupfilename,k,Neighbors,sigma)

    global debug;
    dState = debug;
    debug = false; % Change this line to {dis,en}able debug statements
    % relates to any ddisp and dprintf statements
    
    if ~exist('FileName','var')
        FileName = ['/scratch/tgelles1/summer2014/ADNI_features/' ...
                    'CSV_NORM/organized_small.csv'];
    end
    
    if ~strcmp(FileName(1),'/')
        FileName = strcat(['/scratch/tgelles1/summer2014/' ...
                           'slicExact120/features/CSV_NORM/'], FileName);
    end
    
    if ~exist('sigma','var')
        sigma = 1;
    end
    
    if ~exist('k','var')
        fprintf('Setting k to 40\n');
        k = 40; %number of clusters
    end
    
    if ~exist('Neighbors','var')
        fprintf('Finding 30 nearest neighbors\n');
        Neighbors = 30;
    end

    saveData  = true;      % Whether or not to save the data once computed
    
    disp(FileName)
    Data = csvread(FileName);
    [m n d] = size(Data);
    Data = double(Data);
    Data = normalizeData(Data');
    
    
    if isequal(saveData, 1)
        [savePath, saveFile, ~] = fileparts(FileName);
        savePath = strcat(savePath,'/');
        
        csvwrite(strcat(savePath,saveFile,'_normed.nld'), Data);
    end

    % now for the clustering
    fprintf('Creating Similarity Graph...\n');
    % Adding code to 
    SimGraph = sv_SimGraph_NearestNeighbors(Data, Neighbors, 1, sigma);
     
    % Tests to see if the simgraph looks good
    % figure
    if debug
        hist(SimGraph(:));
        title('Original Simgraph histogram')
        
        nonZind = find(SimGraph);
        simVals = SimGraph(nonZind);
        
        figure
        hist(simVals);
        title('Histogram of nonzero SimGraph values')
    end 
    
    try
        comps = graphconncomp(SimGraph, 'Directed', false);
        fprintf('- %d connected components found\n', comps);
    end

    if saveData
        save(strcat(savePath,saveFile,'_simgraph.mat'), 'SimGraph');
    end
    
    fprintf('Clustering Data...\n');
    C = SpectralClustering(SimGraph, k, 2);
    %C2 = SpectralClustering(SimGraph, k, 1+1);
    
    % if any(find(C ~= C2))
    %     ddisp('We gots ourselves some nondeterministic clusters by C');
    % end
    
    % convert and restore full size
    D = convertClusterVector(C);
    %D2 = convertClusterVector(C2);
    
    % if any(find(D ~= D2))
    %     ddisp('We gots ourselves some nondeterministic clusters by D');
    % end

    groups = csvread(groupfilename);
    
    % Time to see if any of our work was good
    accuracy = mean(D(:,1) == groups);
    fprintf('Accuracy is %f.\n',accuracy);
    
    % Let's make a confusion matrix to see if our results mean anything
    conf = zeros(k);
    for i = 1:k
        for j = 1:k
            conf(i,j) = sum((D(:,1) == i) .* (groups == j));
        end
    end
    
    disp(conf)
    
    
    
    if saveData
        results = zeros(size(Data',1),size(Data',2) + 1);
        results(:,1) = D;
        results(:,2:end) = Data';
        csvwrite(strcat(savePath,saveFile, ...
                        '_clustered.csv'),results);
        clear results
    end
        
    debug = dState;
end

