load('BB.mat');
n = size(ERR,2)
m = size(ERR{1},2)

%RMSE,L1,correlation
err1 = zeros(n,m);
for i=1:n
    for j=1:m
        err1(i,j)=ERR{i}{j}(1);
    end
end

%maxcomp_array = 2:2:50;
%threshold_array = [0.0:0.005:0.05,0.06:0.01:0.2,0.3:0.05:1];
imagesc(err1); colorbar;
%set(gca,'XTickMode','manual');
%set(gca,'XTick',1:41,'XTickLabel',mat2str(threshold_array));
