function SpectraInds = ExtractDatasetIndices(MetamerReport, AllSpectra, WhichData)
%ExtractDatasetIndices  extracts the indices of specified dataset
%
% inputs
%   MetamerReport  the metamer report.
%   AllSpectra     original spectra reflectance datasets.
%   WhichData      the name of desired datasets in a cell array.
%
% outputs
%   SpectraInds  indices of the specifid datasets.
%

if isempty(WhichData) || strcmpi('all', WhichData{1})
  SpectraInds = 1:MetamerReport.NumElements;
else
  CatNames = fieldnames(AllSpectra.originals);
  ncategories = numel(CatNames);
  CatEls = zeros(ncategories, 1);
  for i = 1:ncategories
    CatEls(i) = size(AllSpectra.originals.(CatNames{i}), 1);
  end
  CatEls = cumsum(CatEls);
  SpectraInds = [];
  
  % only the selected datasets
  for i = 1:numel(WhichData)
    name = WhichData{i};
    [~, NameInd] = ismember(name, CatNames);
    if NameInd == 1
      StartInd = 1;
    else
      StartInd = CatEls(NameInd - 1, 1) + 1;
    end
    SpectraInds = [SpectraInds, StartInd:CatEls(NameInd, 1)]; %#ok
  end
  
  SpectraInds = SpectraInds';
end

end
