function complete = PlotHistogram( average )
%PlotHistogram Summary of this function goes here
%   Detailed explanation goes here
    complete = 0;
    lognorm2 = fittype(@(a,b,c,I0,offset,x) offset+(I0*b./(x-a)).*exp(-c^2).*exp(-(1/(2*c^2))*(log((x-a)./b)).^2)); 
    x = 0:10:300;
    n = zeros(length(average(:,1)),length(x));
    y = zeros(1,length(average(:,1)));
    for u = 1:length(average(:,1))
        if average{u}
            n(u,:) = hist(average{u}(2,:),x);
        end
    end
    if ~isempty(n)
        for v = 1:length(n(1,:))
            y(v) = mean(n(:,v));
        end
        [F, ~] = fit(x',y',lognorm2,'StartPoint',[mean([min(x)-eps -max(x)]),500,.5,max(y)-mean(y(end-20:end)),mean(y(end-20:end))],...
            'Upper',[min(x)-eps,2000,10,max(y),max(y)],'Lower',[-max(x),eps,eps,0,0]);
        xres = 0:.1:300;
        funct = F.offset+(F.I0*F.b./(xres-F.a)).*exp(-F.c^2).*exp(-(1/(2*F.c^2))*(log((xres-F.a)./F.b)).^2);
        [pks, locs] = findpeaks(funct,xres);
        figure;
        bar(x, n');
        legend('show');
        hold on;
        plot(F);
        hold off;
        xlabel('Average Particle Speed (\mum/sec)');
        ylabel('Frequency');
        text(locs+10, pks, [num2str(locs) ' \mum/s']);
        complete = 1;
    end
    
end

