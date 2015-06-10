function gaus = Gauss1D(sigma)

  GaussianDieOff = 0.0001;
  pw = 1:100; % possible widths
  ssq = sigma^2;
  width = find(exp(-(pw.*pw)/(2*ssq))>GaussianDieOff,1,'last');
  if isempty(width)
    width = 1;  % the user entered a really small sigma
  end

  t = (-width:width);
  gaus = exp(-(t.*t)/(2*ssq))/sqrt(2*pi*ssq);     % the gaussian 1D filter
