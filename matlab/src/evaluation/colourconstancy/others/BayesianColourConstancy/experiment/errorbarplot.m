
function errorbarplot(meanpoints,stderr,description,meanpoints2,stderr2,meanpoints3,stderr3)

%figure(1);clf
%a = randn(5,1);
%b = rand(5,1);
%if ~exist('yd','var')
xdev = 0;%;0.05 * mean(stderr);
%end

ydev = 0.4;
lw = 2;
%scale = 1.16; % for 95% significance level
scale = min_errorbar_scale(stderr',.95)
a = meanpoints;
b = scale * stderr;
plot(a,1:numel(a),'o','LineWidth',lw);
hold on;
ax =axis;
set(gca,'YTick',1:numel(a));
%set(gca,'YTickLabel',{'alg1','alg2','alg3','alg4','alg5'});
if exist('description','var')
    set(gca,'YTickLabel',description);
else
    set(gca,'YTickLabel',[]);
end
set(gca,'FontSize',16);
ax(1) = min(meanpoints-stderr)-.3*mean(stderr);
ax(2) = max(meanpoints+stderr)+.3*mean(stderr);
axis([ax(1) ax(2) 0.5 numel(a)+0.5]);

for i=1:numel(b)
    
    str = linspace(a(i)-b(i),a(i)+b(i),100);
    plot(str,i*ones(numel(str),1),'-','LineWidth',lw);
    pt(1,1) = a(i)-b(i);
    pt(2,1) = a(i)-b(i)+xdev;
    
    pt2(1,1) = i;
    pt2(2,1) = i-ydev;
    plot(pt,pt2,'b-','LineWidth',lw);
    
    pt2(1,1) = i;
    pt2(2,1) = i+ydev;
    plot(pt,pt2,'b-','LineWidth',lw);
    
    pt(1,1) = a(i)+b(i);
    pt(2,1) = a(i)+b(i)-xdev;

    pt2(1,1) = i;
    pt2(2,1) = i-ydev;
    plot(pt,pt2,'b-','LineWidth',lw);
    
    pt2(1,1) = i;
    pt2(2,1) = i+ydev;
    plot(pt,pt2,'b-','LineWidth',lw);
    
end

axis_pct

if exist('meanpoints2','var')
    
    a = meanpoints2;
    b = scale * stderr2;
    
    ax(1) = min([ax(1),(min(meanpoints2-stderr2)-.2*mean(stderr2))]);
    ax(2) = max([ax(2),(meanpoints2+stderr2)+.2*mean(stderr2)]);
    axis([ax(1) ax(2) 0.5 numel(a)+0.5]);
    
    
    plot(a,1:numel(a),'rs');
    for i=1:numel(b)

	str = linspace(a(i)-b(i),a(i)+b(i),100);
	plot(str,i*ones(numel(str),1),'r--','LineWidth',lw);
	pt(1,1) = a(i)-b(i);
	pt(2,1) = a(i)-b(i)+ydev;
	
	pt2(1,1) = i;
	pt2(2,1) = i-xdev;
	plot(pt,pt2,'r--');
	
	pt2(1,1) = i;
	pt2(2,1) = i+xdev;
	plot(pt,pt2,'r--');
	
	pt(1,1) = a(i)+b(i);
	pt(2,1) = a(i)+b(i)-ydev;

	pt2(1,1) = i;
	pt2(2,1) = i-xdev;
	plot(pt,pt2,'r--');
	
	pt2(1,1) = i;
	pt2(2,1) = i+xdev;
	plot(pt,pt2,'r--');
	
    end

    
end


