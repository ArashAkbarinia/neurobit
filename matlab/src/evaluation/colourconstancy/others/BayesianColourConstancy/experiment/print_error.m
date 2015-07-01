function print_error(str,err)

err=sort(err,'ascend');

top75 = err(1:ceil(3/4*numel(err)));
worst25 = err(ceil(3/4*numel(err))+1:end);
fprintf('%s : \n',str);
fprintf('\tRMSE = %2.0f +- %2.0f\n',1000*rms(err),1000*rmsstderr(err));
fprintf('\tTOP75 = %2.0f +- %2.0f\n',1000*rms(top75),1000*rmsstderr(top75));
fprintf('\tWORST75 = %2.0f +- %2.0f\n',1000*rms(worst25),1000*rmsstderr(worst25));
