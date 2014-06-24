function featureList = getSLICFeatures(labels, tissues, centerInfo, ...
                                               cropOffset, filename)
    
    
    fprintf('Getting SLIC Features\n');
    
    avgIntensity = getAvgIntensity(centerInfo);
    avgVol = getAvgVol(centerInfo);
    
    varIntensity = getVarIntensity(centerInfo);
    varVolume = getVarVolume(centerInfo);
        
    surfaceArea = getSurfaceArea(labels, centerInfo);
    avgSurfaceArea = getAvgSurfaceArea(surfaceArea);
    varSurfaceArea = getVarSurfaceArea(surfaceArea);


    if (~isnan(tissues))
        tissueInfo = getTissueInfo(labels, tissues, centerInfo,cropOffset);

        [percentSVGM percentSVWM percentSVCSF] = ...
            getTissuePercentages(tissueInfo);
    end
        
    
    fprintf('Average Intensity: %f\n', avgIntensity);
    fprintf('Average Volume: %f\n', avgVol);
    fprintf('Average Surface Area: %f\n', avgSurfaceArea);
    fprintf('Intensity Variance: %f\n', varIntensity);
    fprintf('Volume Variance: %f\n', varVolume);
    fprintf('Surface Area Variance: %f\n', varSurfaceArea);
    
    if (~isnan(tissues))
        fprintf(['Percentage of Predominately GM Supervoxels: ' ...
                 '%f\n'], percentSVGM);
        fprintf(['Percentage of Predominately WM Supervoxels: ' ...
                 '%f\n'], percentSVWM);
        fprintf(['Percentage of Predominately CSF Supervoxels: ' ...
                 '%f\n'], percentSVCSF);
    end
    %fprintf('Printing graph of average intensities');
    %graphIntensities(centerInfo);
    
    if (~isnan(tissues))
        featureList = cell(9, 2);
    else
        featureList = cell(6, 2);
    end
    
    featureList{1, 1} = 'Average Intensity';
    featureList{1, 2} = avgIntensity;
    featureList{2, 1} = 'Average Volume';
    featureList{2, 2} = avgVol;
    featureList{3, 1} = 'Average Surface Area';
    featureList{3, 2} = avgSurfaceArea;
    featureList{4, 1} = 'Intensity Variance';
    featureList{4, 2} = varIntensity;
    featureList{5, 1} = 'Volume Variance';
    featureList{5, 2} = varVolume;
    featureList{6, 1} = 'Surface Area Variance';
    featureList{6, 2} = varSurfaceArea;
    
    if (~isnan(tissues))
        featureList{7, 1} = ['Percentage of Predominately GM ' ...
                            'Supervoxels'];
        featureList{7, 2} = percentSVGM;
        featureList{8, 1} = ['Percentage of Predominately WM ' ...
                            'Supervoxels'];
        featureList{8, 2} = percentSVWM;
        featureList{9, 1} = ['Percentage of Predominately CSF ' ...
                            'Supervoxels'];
        featureList{9, 2} = percentSVCSF;
    end
end

function isSV = isSurfaceVoxel(i, j, k, labels)
    
    
    isSV = false;
    if (i==1 || i==size(labels, 1) || j==1 || j==size(labels, 2) || ...
        k==1 || k==size(labels, 3))
        
        isSV = true;
        return;
    end

    for sub_i = [i-1 i+1]
        if labels(sub_i,j,k) ~= labels(i,j,k)
            isSV = true;
            return;
        end
    end
    for sub_j = [j-1 j+1]
        if labels(i,sub_j,k) ~= labels(i,j,k)
            isSV = true;
            return;
        end
    end

    for sub_k = [k-1 k+1]
        if labels(i,j,sub_k) ~= labels(i,j,k)
            isSV = true;
            return;
        end
    end
end

function graphIntensities(centerInfo)
    figure
    plot(centerInfo(:,4),'x');
    title('Average supervoxel intensities');
    ylabel('Intensity');
    xlabel('Supervoxel intensity');
end


function avgIntensity = getAvgIntensity(centerInfo)

    avgIntensity = mean(centerInfo(:, 4));    
end

function avgVol = getAvgVol(centerInfo)

    avgVol = mean(centerInfo(:, 5));
end
    
function varIntensity = getVarIntensity(centerInfo)

    varIntensity = var(centerInfo(:, 4));
end
 
function varVolume = getVarVolume(centerInfo)

    varVolume = var(centerInfo(:, 5));
end


function surfaceArea = getSurfaceArea(labels, centerInfo)

    surfaceArea = zeros(size(centerInfo, 1), 1);
    for i= 1:size(labels, 1)
        for j = 1:size(labels, 2)
            for k = 1:size(labels, 3)
                
                if isSurfaceVoxel(i, j, k, labels)
                    surfaceArea(labels(i, j, k)) = surfaceArea(labels(i, ...
                                                                      j, k)) + 1;
                end
            end
        end
    end
end
    
function avgSurfaceArea = getAvgSurfaceArea(surfaceArea)

    avgSurfaceArea = mean(surfaceArea);

end

function varSurfaceArea = getVarSurfaceArea(surfaceArea)

    varSurfaceArea = var(surfaceArea);
end

function [percentSVGM percentSVWM percentSVCSF] = ...
        getTissuePercentages(tissueInfo)
    
    totGM = 0;
    totWM = 0;
    totCSF = 0;
    for i=1:size(tissueInfo, 1)
        
        switch tissueInfo(i, 5)
          case 2
            totCSF = totCSF + 1;
          case 3
            totGM = totGM + 1;
          case 4
            totWM = totWM + 1;
        end
    end
    
    percentSVGM = (totGM) / (totGM + totWM + totCSF);
    percentSVWM = (totWM) / (totGM + totWM + totCSF);
    percentSVCSF = (totCSF) / (totGM + totWM + totCSF);    
end