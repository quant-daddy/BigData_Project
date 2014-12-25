addpath('data_dict');
addpath('/..');
addpath('Misc');
addpath('Plot');

dictSource = 'threeDictsForSurajandMin.mat';
dataSource = 'twoDimagesForSurajandMin.mat';
dataType='noisy'; %'raw' or 'noisy'
dictName = 'D1_5x5x1'; % Set patch size accordingly
patch_size = [5 5 1];
snr = 1;
noise_seed = 12;
slide=1;

%% Generate data if needed
load(dictSource);
load(dataSource);
if strcmp(dataType,'noisy')
    data = stack;
    stream = RandStream('mt19937ar','Seed',noise_seed);
    RandStream.setGlobalStream(stream);
    noisy_data = data+(std(data(:))/sqrt(snr))*normrnd(0,1,size(data));
elseif strcmp(dataType,'raw')
    data = stack;
    snr=[];
    noisy_data = cutRawStack;
end

M = size(eval(dictName),2);
threshold_array = 0.1:0.1:1;
maxcomp_arr = unique(round(1:(M/100):M));
%figure(1);
%        subplot(1,3,1); imshow(noisy_data,[]);% caxis(mmc);colorbar;title('Noisy Data');
%        subplot(1,3,2); imshow(data,[]);% caxis(mmc);colorbar;title('Orignal Data');
%        hold on;
%title({['Correlation =', num2str(correlation) , ', RMSE =' num2str(RMSE)]})

for i = 1:length(maxcomp_arr)
    for j = 1:length(threshold_array)
        maxcomp = maxcomp_arr(i);
        threshold = threshold_array(j);
        params=v2struct(dictSource,dataSource,dataType,snr,noise_seed,dictName,patch_size,slide,maxcomp,threshold);
        file_name=GetNameMat(params);
        load(file_name);
        imshow(denoisedStack,[]);title(['iter=',num2str(100*(i-1)+j)]);
        %[RMSE,L1,correlation] = GetErrors( data,denoisedStack);
        
        %figure_handle = openfig(file_name);
        %openfig(file_name,'reuse');
       % subplot(1,3,3); imshow(denoisedStack,[]);% caxis(mmc);colorbar;
        %figure(1);
        pause(0.3);
    end
end



