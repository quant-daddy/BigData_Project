%% Plot
minc=min(data(:));
maxc=max(data(:));
mmc=[minc maxc];
[RMSE] = GetErrors( data,denoisedStack )

figure(1)
subplot(3,1,1); imshow(noisy_data,[]);title('Noisy or Raw Data');% caxis(mmc);colorbar;
subplot(3,1,2); imshow(data,[]);title('Pure image');% caxis(mmc);colorbar;
subplot(3,1,3); imshow(denoisedStack,[]);title('Denoised Image');% caxis(mmc);colorbar;
%title({['Correlation =', num2str(correlation) , ', RMSE =' num2str(RMSE)]})

% 
% 
% title({[' EW corr =' num2str(correlation) ', EW2 corr =' num2str(correlation2)]; ...
%      [' EW MSE =' num2str(MSE) ', EW2 MSE =' num2str(MSE2)]; ...
%      [' EW SE =' num2str(SIGN_ERROR) ', EW2 SE =' num2str(SIGN_ERROR2) ]});