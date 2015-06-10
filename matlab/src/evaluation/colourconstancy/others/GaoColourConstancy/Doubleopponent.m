function DO = Doubleopponent(SO,Sgaus,Lgaus,k)

Sx=imfilter(SO,Sgaus,'conv','replicate');   % run the filter accross rows
Csmooth=imfilter(Sx,Sgaus','conv','replicate'); % and then accross columns
Lx=imfilter(SO,Lgaus,'conv','replicate');   % run the filter accross rows
Ssmooth=imfilter(Lx,Lgaus','conv','replicate'); % and then accross columns
DO=Csmooth - k*Ssmooth;