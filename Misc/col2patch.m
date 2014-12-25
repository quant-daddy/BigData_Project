function stack = col2patch(vectorizedPatches, blockSize, imageSize, slidingDistance)

%%%%%% INPUTS:
% vectorizedPatches: 2d array whose columns contain individual vectorizedPatches
% blockSize        : 3-element vector (3x1 or 1x3) specifying the size of each block, prod(blockSize)=size(vectorizedPatches,1)
% imageSize        : 3-element vector (3x1 or 1x3) specifying the size of reconstructed stack
% slidingDistance  : positive integer scalar specifying the amount of translation between consecutive blocks
%%%%%% OUTPUT:
% stack            : 3d image stack

stack  = zeros(imageSize);
weight = zeros(imageSize);
stackSize = size(stack); if numel(stackSize)==2; stackSize = [stackSize 1]; end;
idxMat = zeros(stackSize-blockSize+1);
idxMat([[1:slidingDistance:end-1],end],[[1:slidingDistance:end-1],end],[[1:slidingDistance:end-1],end]) = 1;
idx = find(idxMat);
[xx, yy, zz] = ind2sub(size(idxMat),idx);

for kk = 1:length(idx)
  xR = xx(kk):xx(kk)+blockSize(1)-1;
  yR = yy(kk):yy(kk)+blockSize(2)-1;
  zR = zz(kk):zz(kk)+blockSize(3)-1;
  stack(xR, yR, zR)  = stack(xR, yR, zR)  + reshape(vectorizedPatches(:,kk), blockSize);
  weight(xR, yR, zR) = weight(xR, yR, zR) + ones(blockSize);
end

stack = stack./weight;

