function PrintFittingResults(myoutput, myresults, RSS, myexitflag, FittingDataStd)

switch myexitflag
  case 1
    disp('fminsearch converged to a solution')
  case 0
    disp('Number of iterations exceeded options. MaxIter or number of function evaluations exceeded options.MaxFunEvals.');
  case -1
    disp('The algorithm was terminated by the output function');
end

disp (myoutput);
disp ('=======Results:=======');
disp (['centre (l,s,Y) = (', num2str(myresults(1)), ', ', num2str(myresults(2)), ', ', num2str(myresults(3)), ').']);
disp (['axes (a,b,c)   = (', num2str(myresults(4)), ', ', num2str(myresults(5)), ', ', num2str(myresults(6)), ').']);
disp (['rotation =  (', num2str(rad2deg(myresults(7))), ', ', num2str(rad2deg(myresults(8))), ', ', num2str(rad2deg(myresults(9))), ') deg.']);
disp (['RS1: ', num2str(RSS(1))]);
disp (['RS2: ', num2str(RSS(2))]);
disp (['RSS gain: ', num2str(RSS(1) - RSS(2))]);
disp (['Std Dev (l,s,Y) = (', num2str(FittingDataStd(1)), ', ', num2str(FittingDataStd(2)), ', ', num2str(FittingDataStd(3)), ')']);

end
