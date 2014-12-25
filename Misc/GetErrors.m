function [RMSE,L1,correlation] = GetErrors(data,denoised )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    RMSE=sqrt(mean((denoised(:)-data(:)).^2));    
    correlation=corr(data(:),denoised(:));
    L1 = mean(abs(denoised(:)-data(:)));
    
end

