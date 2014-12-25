addpath('data_dict');
addpath('Misc');
addpath('/Users/Suraj/Dropbox/Min-Suraj/BB/Results/BB');

dictSource = 'threeDictsForSurajandMin.mat';
dataSource = 'twoDimagesForSurajandMin.mat';
dataType='raw'; %'raw' or 'noisy'
dictName = 'D1_5x5x1'; % Set patch size accordingly
patch_size = [5 5 1];
snr = 1;
noise_seed = 12;
slide=1;

if strcmp(dataType,'raw')
    snr=[];
end

maxcomp_arr = 2:2:50;
threshold_array = 0:0.01:1;

for j = 1:length(threshold_array)
maxcomp=2;
threshold=threshold_array(j);
params=v2struct(dictSource,dataSource,dataType,snr,noise_seed,dictName,patch_size,slide,maxcomp,threshold);
file_name=GetNameFig(params);
%figure_handle = openfig(file_name);
%openfig(file_name,'reuse');
figure(1); hold;
figure(figure_handle);
pause(0.5);
end


