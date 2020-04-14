function [ imag,iasym,iwidth,ir2,foutf,foutg ] = process_fluor(d,x,ml,r2l)
%PROCESS_FLUOR Fits the fluorescence data
%   fits to a lognormal function

%   Author(s): A. Fisher, K. Meissner
%   Centre of NanoHealth, College of Science, 
%   Swansea University, Singleton Park, Swansea, SA2 8PP, United Kingdom

    lognorm2 = fittype(@(a,b,c,I0,offset,x) offset+(I0*b./(x-a)).*exp(-c^2).* ...
        exp(-(1/(2*c^2))*(log((x-a)./b)).^2)); 
    [rmax, cmax, ~] = size(d);
    foutf = cell(rmax,cmax);
    foutg = cell(rmax,cmax);
    wb = waitbar(0,'Processing Spectra...');
        for r = 1:rmax
            for c = 1:cmax
                [F, G] = fit(x',squeeze(d(r,c,:)),lognorm2,'StartPoint',...
                    [mean([min(x)-eps -max(x)]),500,.5,...
                    max(d(r,c,:))-mean(d(r,c,end-20:end)),mean(d(r,c,end-20:end))],...
                    'Upper',[min(x)-eps,2000,10,max(d(r,c,:)),max(d(r,c,:))],...
                    'Lower',[-max(x),eps,eps,0,0]);

                foutf{r,c} = F;
                foutg{r,c} = G;

                if F.I0 <= ml
                    imag(r,c) = 0; %if mag < 0, make all values 0 = bad fit
                    iasym(r,c) = 0; 
                    iwidth(r,c) = 0; 
                    ir2(r,c) = 0; 
                elseif G.rsquare < r2l
                    imag(r,c) = 0; %if r^2 too small, make all values 0 = bad fit
                    iasym(r,c) = 0; 
                    iwidth(r,c) = 0; 
                    ir2(r,c) = 0; 
                else
                    imag(r,c) = F.I0; %make an image from the magnitude of fit
                    iasym(r,c) = F.c; %make an image from the asymmetry of fit
                    iwidth(r,c) = F.b; %make an image from the width of fit
                    ir2(r,c) = G.rsquare;
                end
            end
            waitbar(r/rmax);
        end
    close(wb)
    % figure;
    % 
    % subplot(2,2,1);
    % imagesc(imag/max(max(imag)));
    % caxis([0,1]);
    % colorbar;
    % title('Normalized Magnitude');
    % subplot(2,2,2);
    % imagesc(iasym);
    % colorbar;
    % title('Assymetry');
    % subplot(2,2,3);
    % imagesc(iwidth);
    % colorbar;
    % title('Width');
    % subplot(2,2,4);
    % imagesc(ir2);
    % caxis([0,1]);
    % colorbar;
    % title('R Squared');    
end
