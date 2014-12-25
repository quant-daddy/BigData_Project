function vectorizedPatches = patch2colOnWhites(stack, blockSize)

%%%%%% INPUTS:
% stack            : 3d image stack or cell array containing 3d image stacks
% blockSize        : 3-element vector (3x1 or 1x3) specifying the sizeof each block
%%%%%% OUTPUT:
% vectorizedPatches: 2d array whose columns contain individual vectorizedPatches

bx = blockSize(1)-1; by = blockSize(2)-1; bz = blockSize(3)-1;

if ~iscell(stack) % single image stack
  % find blocks including at least one white voxel
  [xx, yy, zz] = ind2sub(size(stack), find(imdilate(stack, ones(blockSize))));
  % preallocate a possible slightly larger array
  vectorizedPatches = zeros(prod(blockSize), numel(xx));
  counter = 1;
  for kk = 1:numel(xx)
    if ~any([xx(kk)+bx yy(kk)+by zz(kk)+bz]>size(stack))
      tmp = stack(xx(kk):xx(kk)+bx, yy(kk):yy(kk)+by, zz(kk):zz(kk)+bz);
      vectorizedPatches(:, counter) = tmp(:);
      counter = counter+1;
    end
  end
  % remove unused portion
  vectorizedPatches(:, counter:end) = [];
else              % potentially more than one image stacks
  vectorizedPatches = [];
  for ii = 1:numel(stack)
    % find blocks including at least one white voxel
    [xx, yy, zz] = ind2sub(size(stack{ii}), find(imdilate(stack{ii}, ones(blockSize))));
    % preallocate a possible slightly larger array
    thisVectorizedPatches = zeros(prod(blockSize), numel(xx));
    counter = 1;
    for kk = 1:numel(xx)
      if ~any([xx(kk)+bx yy(kk)+by zz(kk)+bz]>size(stack{ii}))
        tmp = stack{ii}(xx(kk):xx(kk)+bx, yy(kk):yy(kk)+by, zz(kk):zz(kk)+bz);
        thisVectorizedPatches(:, counter) = tmp(:);
        counter = counter+1;
      end
    end
    % remove unused portion
    vectorizedPatches = [vectorizedPatches thisVectorizedPatches(:, 1:counter-1)];
  end
end
