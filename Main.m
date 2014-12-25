

%% Starting Matlabpool (can be used on multiple core machines or cluster)
% Uncomment this section if the machine has multiple core (for example 12)

% maxNumCompThreads(12)
% 
% if matlabpool('size') == 0 % checking to see if my pool is already open
%     matlabpool(12)
% else
%     matlabpool close
%     matlabpool(12)
% end

%% Adding path of different directories for support files
addpath('Misc','Plot','Regression_fns','data_dict');
dictSource = 'threeDictsForSurajandMin.mat';
dataSource = 'twoDimagesForSurajandMin.mat';
load(dictSource);
load(dataSource);

%% Specifying Parameter and running Main.m
dataType='raw'; %'raw' or 'noisy'
snr = 5; % ratio of variance of signal and noise( if noisy data is chosen)
dictName = 'D1_5x5x1'; % Other dictionaries 'D1_9x9x1', 'D1_13x13x1'  
patch_size = [5 5 1]; %patch size must match the dictionary dimension (for example 5 x 5 x 1 as above)

%% Choose Model Parameters

noise_seed = 12;
slide = 1;
maxcomp = 5; % Maximum number of dictionary components to allow to construct any patch
threshold = 0.05; % Coefficient threshold for including a dictionary component

%% Generate data if needed
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

params=v2struct(dictSource,dataSource,dataType,snr,noise_seed,dictName,patch_size,slide,maxcomp,threshold);

dict = eval(dictName);

%% Algorithm
tic
vectorizedPatches = patch2col(noisy_data, patch_size, slide);
patchMeans = mean(vectorizedPatches); % This dictionary assumes data is zero mean
vectorizedPatches = vectorizedPatches - repmat(patchMeans,prod(patch_size),1);
denoisedPatches = myLARSdenoiser(vectorizedPatches, dict, maxcomp, threshold);
denoisedStack = col2patch(denoisedPatches+repmat(patchMeans,prod(patch_size),1), patch_size,...
    size(data), slide);
tt=toc;

[RMSE,L1,correlation] = GetErrors(data,denoisedStack);


file_name=GetNameMat(params);
Plotter;
%save(file_name,'denoisedStack','params','tt');
%saveas(figure(1),file_name,'fig')
%save(file_name,'denoisedStack','dict','noisy_data','data','params','tt');
