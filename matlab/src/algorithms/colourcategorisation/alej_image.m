function out = alej_image(in,plotyn,scale,gammacorrect)

if (nargin < 2) || isempty(plotyn)
    plotyn = 1;
end
if (nargin < 3) || isempty(scale)
    scale = 1;
end
if (nargin < 4) || isempty(gammacorrect)
    %should make it 1 if you try to show a linear 
    %image onto a non-linear monitor
    gammacorrect = 0;
end

if gammacorrect
    in = in.^(1/2.2); 
end


[lin,col,pla] = size(in);

if scale
    out = (in - min(in(:))) ./ (max(in(:))-min(in(:)));
end


if plotyn
    if pla==1
        if scale
            imagesc(out); figure(gcf);
        else
            out(:,:,1) = in;
            out(:,:,2) = in;
            out(:,:,3) = in;
            image(out); figure(gcf);
        end        
    elseif pla==3
        image(out); figure(gcf);
    else
        error('wrong number of planes');
    end
end




