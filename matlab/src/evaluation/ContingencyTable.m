function [sens, spec, ppv, npv] = ContingencyTable(GroundTruth, TestOutcome)

% true positives
TP = TestOutcome(GroundTruth == 1);
TP = length(TP(TP == 1));

% false positives
FP = TestOutcome(GroundTruth == 0);
FP = length(FP(FP == 1));

% false negatives
FN = TestOutcome(GroundTruth == 1);
FN = length(FN(FN == 0));

% true negatives
TN = TestOutcome(GroundTruth == 0);
TN = length(TN(TN == 0));

% sensitivity
sens = TP / (TP + FN);
if isnan(sens)
  sens = 0;
end

% specificity
spec = TN / (FP + TN);
if isnan(spec)
  spec = 0;
end

% positive predictive value
ppv = TP / (TP + FP);
if isnan(ppv)
  ppv = 0;
end

% negative predictive value
npv = TN / (FN + TN);
if isnan(npv)
  npv = 0;
end

end
