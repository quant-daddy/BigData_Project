function projImage = arrangeDictForViewing(dictionary, blockSize, dimensionToProject)

if nargin < 3
  dimensiontoProject = 3;
end

remainingDims = setdiff([1 2 3], dimensionToProject);
atomCount = size(dictionary,2);
atomRowCount = floor(sqrt(atomCount));
atomColCount =  ceil(sqrt(atomCount));

dim1 = blockSize(remainingDims(1));
dim2 = blockSize(remainingDims(2));
projImage = zeros((dim1+1)*atomRowCount, (dim2+1)*atomColCount);
% perform maximum projection
for kk = 1:atomCount
  atomCol = rem(kk-1, atomColCount) + 1;
  atomRow = floor((kk-1)/atomColCount) + 1;
  projImage((atomRow-1)*(dim1+1)+1:atomRow*(dim1+1)-1, (atomCol-1)*(dim2+1)+1:atomCol*(dim2+1)-1) = squeeze(max(reshape(dictionary(:,kk), blockSize), [], dimensionToProject));
end
