function file_name = GetNameMat( params )
% generate file name for saves
%   Detailed explanation goes here


thres = params.threshold;
maxcomp = params.maxcomp;
noiseSeed = params.noise_seed;
dataType=params.dataType;
dictName=params.dictName;
slide = params.slide;
snr = params.snr;

file_name=fullfile([dataType '_' dictName '_slide=' num2str(slide) '_noiseSeed=' num2str(noiseSeed)...
    '_snr=' num2str(snr) '_thres=' num2str(thres) '_maxcomp=' num2str(maxcomp) '.mat']);
% file_name=fullfile('Results', ['neuron=' n_type '_conn=' c_type 'N=' num2str(N) '_obs=' num2str(obs) '_T=' num2str(T)...
%     '_glasso=' num2str(gla) '_rpen=' num2str(rpen) '_wscale=' num2str(wscale) '_wseed=' num2str(wseed) '.mat']);

end

