function vectorizedPatches = myLARSdenoiser(vectorizedPatches, dictionary, maxcomps, threshold)

%parfor kk = 1:size(vectorizedPatches,2)
parfor kk = 1:size(vectorizedPatches,2)
  [Ws, lambdas, Cps, last_break, active_set] = lars_regression(vectorizedPatches(:,kk), dictionary, maxcomps, false);
  Ws = squeeze(Ws(:,:,end));
  Ws(Ws<threshold) = 0;
  vectorizedPatches(:,kk) = dictionary*Ws;
end