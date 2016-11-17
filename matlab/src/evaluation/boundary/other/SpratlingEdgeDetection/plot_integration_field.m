function plot_integration_field(type,fignum)
%phases=[0,180];  %even (on and off)
phases=[90,270];; %odd (on and off)                 
%phases=[0,180,90,270]; %even and odd
texture=1;
lateral=1;
wScale=0.5;
[w,v]=filter_definitions_V1_simple_diffGauss([],[],1, 0,phases);
if texture
  [w,v]=filter_definitions_V1_simple_diffGauss(w,v,1, 0,phases);
  phases=[phases;phases];
end
if lateral
  %[w,v]=filter_definitions_V1_recurrent_cpcp(w,v,wScale.*[1,1,0.5,0.5], 1,phases);
  %[w,v]=filter_definitions_V1_recurrent_test_equal(w,v,wScale, 1,phases);
  [w,v]=filter_definitions_V1_recurrent(w,v,wScale, 1,phases);
end
if max(phases)==180, wScale=wScale/2; end

[nMasks,nChannels]=size(w);
if texture, nMasks=nMasks/2; end

if nargin<1 || isempty(type), type=0; end
if nargin<2 || isempty(fignum), fignum=0; end

if type==0 || type==1
  %PLOT RAW FILTERS - separately for edge-edge, edge-texture, texture-edge and texture-texture
  for pre=0:texture
    for post=0:texture
      fignum=fignum+1;
      figure(fignum), clf, 
      k=0; 
      %plot recurrent weights
      for j=1:nMasks, 
        k=k+1; 
        for i=1+2:nMasks+2, 
          k=k+1; 
          maxsubplot(1+nMasks,1+nMasks,k),
          plot_cropped_image(w{pre*nMasks+j,post*nMasks+i},0,[0,wScale]), 
        end
      end
      %plot ff weights of pre and post synaptic targets of recurrent weights 
      for j=1:nMasks, 
        maxsubplot(1+nMasks,1+nMasks,1+(j-1)*(1+nMasks)), 
        plot_cropped_image(w{pre*nMasks+j,1}-w{pre*nMasks+j,2},0,[-0.025,0.025]),
        maxsubplot(1+nMasks,1+nMasks,nMasks*(1+nMasks)+1+j), 
        plot_cropped_image(w{post*nMasks+j,1}-w{post*nMasks+j,2},0,[-0.025,0.025]), 
      end
      set(gcf,'PaperPosition',[0 0 1+nMasks 1+nMasks]);
      cmap=colormap('gray');cmap=1-cmap;colormap(cmap);
    end
  end
end

if type==0 || type==2
  %PLOT CONNECTIONS AS LINES
  backgnd=0;
  len=5;
  gap=1;
  wid=2;
  imsize=[0,0];
  for pre=3:nChannels, for post=1:nMasks, imsize=max(imsize,size(w{post,pre}));end, end 
  a=imsize(1); b=imsize(2);
  halfsz=ceil(a/2);
  ngridpts=floor((halfsz-len/2)/(len+gap));
  gridlocations=halfsz-ngridpts*(len+gap):(len+gap):halfsz+ngridpts*(len+gap);
  gridscale=7;
  bar=define_bar(gridscale*len,wid);
  GP=global_parameters;
  
  %show pre-synaptic RFs scaled by strength of connection
  for edgetext=0:texture
    post=1+edgetext*nMasks;
    fignum=fignum+1;
    It=backgnd+zeros(a*gridscale,b*gridscale);
    Ie=backgnd+zeros(a*gridscale,b*gridscale);
    for pre=3:nChannels
      angle=GP.V1angles(mod(pre-3,8)+1);
      if pre>2+nMasks, contrast=-1; else, contrast=1; end
      if size(w{post,pre},1)>1
        w{post,pre}=padarray(w{post,pre},ceil(0.5*([a,b]-size(w{post,pre}))));
        for x=gridlocations
          for y=gridlocations
            if contrast==1
              Ie=draw_bar(Ie,x*gridscale,y*gridscale,bar,angle,w{post,pre}(x,y),backgnd);
            else
              It=draw_bar(It,x*gridscale,y*gridscale,bar,angle,w{post,pre}(x,y),backgnd);
            end
          end
        end
      end
    end
    figure(fignum),clf, plot_cropped_image(Ie-It,0,[-wScale,wScale]);
    set(gcf,'PaperPosition',[0 0 10 10]);
  end
end

if type==3
  %PLOT RAW FILTERS - all in one go
  fignum=fignum+1;figure(fignum),clf, 
  [nMasks,nChannels]=size(v);
  k=0; 
  for j=1:nMasks, 
    for i=1:nChannels, 
      k=k+1; 
      maxsubplot(nMasks,nChannels,k), 
      plot_cropped_image(v{j,i},0,[0,1]), 
    end, 
  end
end


function bar=define_bar(len,wid);
%draw a bar with maximum intensity=1 against a background with intensity=0.

maxlen=odd(len,1);
minlen=odd(len,0);
maxwid=odd(wid,1);
minwid=odd(wid,0);

bar=zeros(max(maxlen,maxwid)+2);
cent=ceil((max(maxlen,maxwid)+2)/2);

lenval=(len-max(0,minlen));
if minlen>=1; lenval=lenval/2; end
widval=(wid-max(0,minwid));
if minwid>=1; widval=widval/2; end

hlen=floor(maxlen/2);
hwid=floor(maxwid/2);
bar(cent-hwid:cent+hwid,cent-hlen:cent+hlen)=lenval*widval;

hlen=floor(maxlen/2);
hwid=floor(minwid/2);
bar(cent-hwid:cent+hwid,cent-hlen:cent+hlen)=lenval;

hlen=floor(minlen/2);
hwid=floor(maxwid/2);
bar(cent-hwid:cent+hwid,cent-hlen:cent+hlen)=widval;

hlen=floor(minlen/2);
hwid=floor(minwid/2);
bar(cent-hwid:cent+hwid,cent-hlen:cent+hlen)=1;


function I=draw_bar(I,x,y,bar,angle,contrast,backgnd)
%if nargin<6, contrast=1; end
%if nargin<7, backgnd=0.5; end

%norm=sum(sum(bar));
bar=imrotate(bar,angle,'bilinear','crop'); 
%bar=bar.*(norm./sum(sum(bar)));
bar=(bar.*contrast)+backgnd;
len=size(bar,1);
hlen=fix((len-1)/2);
if contrast>=0;
  I(x-hlen:x+hlen,y-hlen:y+hlen)=max(I(x-hlen:x+hlen,y-hlen:y+hlen),bar);
else
  I(x-hlen:x+hlen,y-hlen:y+hlen)=min(I(x-hlen:x+hlen,y-hlen:y+hlen),bar);
end
