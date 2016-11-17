function [wFF,wFB]=filter_definitions_V1_recurrent(wFF,wFB,weightScale,appendToChannels,phaseVals)
%defines filters to calculate the recurrent input to V1 prediction neurons. Which filters are defined is controlled by the phaseVals parameter, which must correspond to the phases used to define the FF weights. If phaseVals is a 1xn vector, then lateral connections for edge elements are defined. If phaseVals is a 2xn matrix, then lateral connections for both edge and texture elements are defined.
GP=global_parameters;

disp('filter_definitions_V1_recurrent');
if nargin<3 || isempty(weightScale), weightScale=0.5; end
disp(['  weightScale=',num2str(weightScale)]);

if nargin<1 || isempty(wFF)
  nMasksInitial=0;
  nChannelsInitial=0;
else %append new filters onto those already defined
  if appendToChannels
    nMasksInitial=0;
    nChannelsInitial=size(wFF,2);
  else
    nMasksInitial=size(wFF,1); 
    nChannelsInitial=0;
  end
end
if nargin<5 || isempty(phaseVals), phaseVals=[0,180,90,270]; end


%represent texture element phases as values+100001 so as to distinguish them from edge element phases 
et=100000;
if size(phaseVals,1)>1
  phaseVals(2,:)=1+et+phaseVals(2,:);
end
phaseVals=phaseVals';


%set lateral connection weights to zero, as default
maxang=180;
angles=[0:GP.V1angleStep:maxang-1]; %same set of RF orientations is assumed 
nAngles=length(angles);
i=nMasksInitial;
for postPhase=phaseVals(:)'
  for postOri=1:nAngles 
    %for each post-synaptic filter
    i=i+1;
    j=nChannelsInitial;
    for prePhase=phaseVals(:)'
      for preOri=1:nAngles
        %define weights to each pre-synaptic channel
        j=j+1;
        wFF{i,j}=single(0);
        wFB{i,j}=single(0);
      end
    end
  end
end


%define lateral connctions
iStart=nMasksInitial-nAngles;
for postPhase=phaseVals(:)'
  iStart=iStart+nAngles;
  jStart=nChannelsInitial-nAngles;
  for prePhase=phaseVals(:)'
    jStart=jStart+nAngles;
    
    %convert back phase of texture elements
    if postPhase>et, truepostPhase=postPhase-et-1; else, truepostPhase=postPhase; end
    if prePhase>et, trueprePhase=prePhase-et-1; else, trueprePhase=prePhase; end

    %decide on type of connection, which depends on whether pre- and post-synaptic
    %neurons are edge or texture elements
    connectionType=0;
    if postPhase<et && prePhase<et && truepostPhase==trueprePhase, connectionType=1; end %boundary-to-boundary connection
    if postPhase>et && prePhase>et && truepostPhase==trueprePhase, connectionType=2; end %texture-to-texture connection
    if postPhase<et && prePhase>et && truepostPhase==trueprePhase, connectionType=3; end %texture-to-boundary connection
    if postPhase>et && prePhase<et && truepostPhase==trueprePhase, connectionType=4; end %boundary-to-texture connection
    maxang=360;
    if truepostPhase==0 || truepostPhase==180 || connectionType==3 || connectionType==4
      maxang=180;
    end

    if truepostPhase==270 || trueprePhase==270 || truepostPhase==180 || trueprePhase==180
      %assumes phases are defined in pairs, i.e. 0,180 and 90,270 in that
      %order. Lateral weights are defined for both phases at once when phase=0
      %or phase=90.
      connectionType=0; 
    end
    
    if connectionType>0
      wScale=weightScale; if connectionType>2, wScale=weightScale*0.5; end
      %wScale=weightScale*maxang/360
      if wScale>0
        wFF=filter_def_all_angles(wFF,iStart,jStart,maxang,connectionType,wScale);
      end
    end
  end
end


%normalise recurrent weights
i=nMasksInitial;
for postPhase=phaseVals(:)'
  for postOri=1:nAngles 
    maxW=0;

    %for each post-synaptic filter
    i=i+1;
    j=nChannelsInitial;
    for prePhase=phaseVals(:)'
      for preOri=1:nAngles
        %find maximum weight from all pre-synaptic channels
        j=j+1;
        maxW=max(maxW,max(max(wFF{i,j})));
      end
    end

    %define feedback weights as same as feedforward weights normalised by maximum value
    j=nChannelsInitial;    
    for prePhase=phaseVals(:)'
      for preOri=1:nAngles
        j=j+1;
        wFB{i,j}=wFF{i,j}./maxW;
      end
    end
    
  end
end



function wFF=filter_def_all_angles(wFF,iStart,jStart,maxang,connectionType,weightScale)
GP=global_parameters;
angles=[0:GP.V1angleStep:360-1];
nAngles=length(angles);

%LATERAL WEIGHTS FOR POST-SYNAPTIC FILTER AT ZERO ORIENTATION
if connectionType==1 || connectionType==3
  wLateral=filter_def_zero_angle_colinear(angles,maxang,connectionType);
else
  wLateral=filter_def_zero_angle_parallel(angles,maxang,connectionType);
end  
%COPY WEIGHTS TO FOR NODES AT ALL ORIENTATIONS
i=iStart;
for postOri=1:nAngles 
  %for each post-synaptic filter
  i=i+1;
  postAngle=angles(postOri);
  j=jStart;
  for preOri=1:nAngles
    %define weights to each pre-synaptic channel, by appropriately revolving
    %the lateral weigths
    j=j+1;
    relativeOri=mod(preOri-postOri,nAngles)+1;
    mask=max(0,imrotate(wLateral{relativeOri},postAngle,'bicubic','crop'));
    %ensure rotation doesn't rescale weights:
    mask=mask.*sum(sum(wLateral{relativeOri}))/sum(sum(mask));
    wFF{i,j}=weightScale.*mask;
    wFF{i,j}=single(wFF{i,j});
  end
end



function wLateral=filter_def_zero_angle_colinear(angles,maxang,connectionType)
%DEFINE LATERAL WEIGHTS FOR NODE WITH ORIENTATION ZERO 
%set size of integration field
GP=global_parameters;
if connectionType==3 || connectionType==4
  angleOffset=90;
else
  angleOffset=0;
end

%set parameters for integration field
sigmaA=maxang/6;         %curvature (degree of preference for straighter lines)
sigmaC=GP.V1angleStep;   %co-circularity (accuracy with which RF is tangent to curve)
sigmaD=6;                %distance (degree of preference for preferred distance)
sigmaE=2*sigmaD;         %excentricity (prefered distance for lateral connections)

  
%define size of mask: must have an odd dimension
sz=odd(2*sigmaE+5*sigmaD);
halfsz=ceil(sz/2);

disp(['  colinear (',int2str(connectionType),', ',int2str(maxang),'): sigmaA=',num2str(sigmaA),' sigmaC=',num2str(sigmaC),' sigmaD=',num2str(sigmaD),' sigmaE=',num2str(sigmaE)]);

sumWeights=0;
k=0;
for angle=angles
  k=k+1;
  for x=0:halfsz-1
    for y=0:halfsz-1
      if y==0 && x==0, alpha=0; 
      else alpha=atan(y/x)*180/pi; end

      dist=sqrt(x^2+y^2)-sigmaE;
      
      %weights for 1st (and 3rd) quadrant
      diff=(angle-angleOffset)-2*alpha;
      diff=min(abs(all_angles(diff,maxang)));
      w1(x+1,y+1)=exp( -((diff^2)/(2*sigmaC^2)) ...   %co-circularity
                       -((dist^2)/(2*sigmaD^2)) ...   %distance
                       -((alpha^2)/(2*sigmaA^2)) );   %curvature
      
      %weights for 4th (and 2nd) quadrant
      diff=(angle-angleOffset)+2*alpha;
      diff=min(abs(all_angles(diff,maxang)));
      w4(x+1,y+1)=exp( -((diff^2)/(2*sigmaC^2)) ...   %co-circularity
                       -((dist^2)/(2*sigmaD^2)) ...   %distance
                       -((alpha^2)/(2*sigmaA^2)) );   %curvature
    end
  end
  %copy weights into integration field
  wLateral{k}(1:halfsz,halfsz:sz)=rot90(w1,1); %1st quadrant
  wLateral{k}(halfsz:sz,halfsz:sz)=w4'; %4th quadrant
  wLateral{k}(1:halfsz,1:halfsz)=rot90(w4',2); %2nd quadrant
  wLateral{k}(halfsz:sz,1:halfsz)=rot90(w1,-1); %3rd quadrant

  if connectionType==3 || connectionType==2
    wLateral{k}=rot90(wLateral{k},-1);
  end

  sumWeights=sumWeights+sum(sum(wLateral{k}));
end
sumWeights




function wLateral=filter_def_zero_angle_parallel(angles,maxang,connectionType)
%DEFINE LATERAL WEIGHTS FOR NODE WITH ORIENTATION ZERO 
%set size of integration field
GP=global_parameters;
if connectionType==3 || connectionType==4
  angleOffset=90;
else
  angleOffset=0;
end

%set parameters for integration field
sigmaA=maxang/6;           %parallelism
sigmaC=GP.V1angleStep;     %perpendicularity
sigmaD=6;                  %distance (degree of preference for preferred distance)
sigmaE=2*sigmaD;           %excentricity (prefered distance for lateral connections)


%define size of mask: must have an odd dimension
sz=odd(2*sigmaE+5*sigmaD);
halfsz=ceil(sz/2);

disp(['  parallel (',int2str(connectionType),', ',int2str(maxang),'): sigmaA=',num2str(sigmaA),' sigmaC=',num2str(sigmaC),' sigmaD=',num2str(sigmaD),' sigmaE=',num2str(sigmaE)]);

sumWeights=0;
k=0;
for angle=angles
  diff=angle-angleOffset;
  diff=min(abs(all_angles(diff,maxang)));
  k=k+1;
  for x=0:halfsz-1
    for y=0:halfsz-1
      if y==0 && x==0, alpha=0; 
      else alpha=90-atan(y/x)*180/pi; end
      
      dist=sqrt(x^2+y^2)-sigmaE;
      
      %weights for 1st (and 3rd) quadrant
      w1(x+1,y+1)=exp( -((alpha^2)/(2*sigmaC^2)) ...  %perpendicularity
                       -((dist^2)/(2*sigmaD^2)) ...   %distance
                       -((diff^2)/(2*sigmaA^2)) );    %parallelism

      %weights for 4th (and 2nd) quadrant
      w4(x+1,y+1)=exp( -((alpha^2)/(2*sigmaC^2)) ...  %perpendicularity
                       -((dist^2)/(2*sigmaD^2)) ...   %distance
                       -((diff^2)/(2*sigmaA^2)) );    %parallelism
    end
  end
  %copy weights into integration field
  wLateral{k}(1:halfsz,halfsz:sz)=rot90(w1,1); %1st quadrant
  wLateral{k}(halfsz:sz,halfsz:sz)=w4'; %4th quadrant
  wLateral{k}(1:halfsz,1:halfsz)=rot90(w4',2); %2nd quadrant
  wLateral{k}(halfsz:sz,1:halfsz)=rot90(w1,-1); %3rd quadrant

  if connectionType==4 || connectionType==1
    wLateral{k}=wLateral{k}';
  end

  sumWeights=sumWeights+sum(sum(wLateral{k}));
end
sumWeights


function angles=all_angles(angle,maxang)
angles=[angle,angle+maxang,angle-maxang,angle+2*maxang,angle-2*maxang];