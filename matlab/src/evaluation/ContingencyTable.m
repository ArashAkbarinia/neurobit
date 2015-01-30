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

% specificity
spec = TN / (FP + TN);

% positive predictive value
ppv = TP / (TP + FP);

% negative predictive value
npv = TN / (FN + TN);

end
