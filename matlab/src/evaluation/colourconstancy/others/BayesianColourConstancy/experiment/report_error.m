function [err,firstq,secq,thirdq,me,top25] = report_error(Lpred,Ltrue,varargin)

measure = 'mse';
ccmethod = 'none';
v = 0;
if nargin > 2
    for i=1:2:nargin-2
	eval(sprintf('%s = varargin{%d};',varargin{i},i+1));
    end
end

nans = sum(isnan(Ltrue),2)>0;
Ltrue(nans,:) = [];
Lpred(nans,:) = [];

nans = sum(isnan(Lpred),2)>0;
Ltrue(nans,:) = [];
Lpred(nans,:) = [];

if size(Lpred,2) == 1
    Lpred = Lpred';
end

switch measure
 case 'mse'
  if size(Lpred,2)==3
      Lpred = Lpred(:,1:2)./repmat(sum(Lpred,2),1,2);
  end
  if size(Ltrue,2)==3
      Ltrue = Ltrue(:,1:2)./repmat(sum(Ltrue,2),1,2);
  end
  
  %l = Ltrue(:,1:2)./Lpred(:,1:2)/3;
  err = sum( (Lpred-Ltrue).^2,2);

 case 'acos'
  if size(Lpred,2) == 2
      Lpred(:,3) = 1-sum(Lpred,2);
  end
  if size(Ltrue,2) == 2
      Ltrue(:,3) = 1-sum(Ltrue,2);
  end

  switch ccmethod
   case 'none'
   case 'vonkries'
    Lpred = Ltrue./Lpred./3; %sqrt(3);
    Ltrue = ones(size(Lpred))/3;
   otherwise
    error('unknown ccmethod');
  end
  
  err = acos ( sum(normalize(Ltrue).*normalize(Lpred),2) ) * 180/pi;
 otherwise
  error('no such measure implemented');
end

if v==0 && nargout ==1
    return;
end


an = sort(err);

if nargout > 1 || v>0
top25 = mean(an(round(3*numel(an)/4):end));
me = mean(an);
if numel(an)==1, firstq=an;
    else firstq = an(round(numel(an)/4));end
secq = median(an);
if numel(an)==1, thirdq=an;
else thirdq = an(round(3*numel(an)/4));end

  if v > 0
switch measure
 case 'mse'
  fprintf('error MSE: %.0f/%.0f/%.0f/%.0f/%.0f/%.0f/%.0f(max)\n',an(1),firstq,secq,me,thirdq,top25,an(end));
 case 'acos'
  fprintf('error MSE: %.1f/%.1f/%.1f/%.1f/%.1f/%.1f/%.1f(max)\n',an(1),firstq,secq,me,thirdq,top25,an(end));
end  
end
end

function a = normalize(a);

if ~isfloat(a)
    a = double(a);
end
a = a./repmat(sqrt(sum(a.^2,2)),1,size(a,2));