function vectorizedPatches = patch2col(stack, blockSize, slidingDistance)

%%%%%% INPUTS:
% stack            : 3d image stack or cell array containing 3d image stacks
% blockSize        : 3-element vector (3x1 or 1x3) specifying the sizeof each block
% slidingDistance  : positive integer scalar specifying the amount of translation between consecutive blocks
%%%%%% OUTPUT:
% vectorizedPatches: 2d array whose columns contain individual vectorizedPatches

if ~iscell(stack) % single image stack
  stackSize = size(stack); if numel(stackSize)==2; stackSize = [stackSize 1]; end;
  idxMat = zeros(stackSize-blockSize+1);
  % take blocks in distances of 'slidingDistance', but always take the first and last one in each dimension
  idxMat([[1:slidingDistance:end-1],end],[[1:slidingDistance:end-1],end],[[1:slidingDistance:end-1],end]) = 1;
  idx = find(idxMat);
  [xx, yy, zz] = ind2sub(size(idxMat),idx);
  vectorizedPatches = zeros(prod(blockSize),length(idx));
  for kk = 1:length(idx)
    currentBlock = stack(xx(kk):xx(kk)+blockSize(1)-1, yy(kk):yy(kk)+blockSize(2)-1, zz(kk):zz(kk)+blockSize(3)-1);
    vectorizedPatches(:,kk) = currentBlock(:);
  end
else              % potentially more than one image stacks
  vectorizedPatches = [];
  for ii = 1:numel(stack)
    stackSize = size(stack{ii}); if numel(stackSize)==2; stackSize = [stackSize 1]; end;
    idxMat = zeros(stackSize-blockSize+1);
    % take blocks in distances of 'slidingDistance', but always take the first and last one in each dimension
    idxMat([[1:slidingDistance:end-1],end],[[1:slidingDistance:end-1],end],[[1:slidingDistance:end-1],end]) = 1;
    idx = find(idxMat);
    [xx, yy, zz] = ind2sub(size(idxMat),idx);
    thisVectorizedPatches = zeros(prod(blockSize),length(idx));
    for kk = 1:length(idx)
      currentBlock = stack{ii}(xx(kk):xx(kk)+blockSize(1)-1, yy(kk):yy(kk)+blockSize(2)-1, zz(kk):zz(kk)+blockSize(3)-1);
      thisVectorizedPatches(:,kk) = currentBlock(:);
    end
    vectorizedPatches = [vectorizedPatches thisVectorizedPatches];
  end
end

