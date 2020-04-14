function [imag,ictr,iwidth,ir2,dout,foutf,foutg ] = ...
    process_detrend( d,x,b_size,ml,wl,r2l,f)
%DATA_DETREND remove any background drift and fit Raman peaks
%   background drift removed with MATLAB's detrend function.
%   raman peaks fit to user's choice of gaussian or lorentzian functions.

%   Author(s): A. Fisher, K. Meissner
%   Centre of NanoHealth, College of Science, 
%   Swansea University, Singleton Park, Swansea, SA2 8PP, United Kingdom

    [rmax, cmax, spec] = size(d);
    shift = x;
    dout = zeros(rmax,cmax,spec);
    foutf = cell(rmax,cmax);
    foutg = cell(rmax,cmax);
    if f ~= 1 %1 means Gaussian fit, otherwise Lorentzian
        lzt = fittype( @(a1,b1,c1,x)...
            (a1)*((c1^2)./(((x-b1).^2)+c1^2 ))); % create Lorentzian fit
    end
    wb = waitbar(0,'Processing Spectra...');
    for r = 1:rmax
        for c = 1:cmax
            data_sh = squeeze(d(r,c,:));

            %use detrend to remove background
            data_sh_detr = detrend(data_sh);
            data_sh_detr = data_sh_detr - mean(data_sh_detr(1:b_size));
            dout(r,c,:) = data_sh_detr;
            if f == 1
                [F1,G1] = fit(shift,data_sh_detr,'Gauss1');
            else
                [F1,G1] = fit(shift,data_sh_detr,lzt,'StartPoint',...
                    [max(data_sh_detr)/2,mean(shift),shift(2)-shift(1)]);
            end
            foutf{r,c} = F1;
            foutg{r,c} = G1;
            if F1.a1 <= ml
                imag(r,c) = 0; %if mag < 0, make all values 0 = bad fit
                ictr(r,c) = 0; 
                iwidth(r,c) = 0; 
                ir2(r,c) = 0; 
            elseif F1.c1 < wl
                imag(r,c) = 0; %if width too small, bad fit
                ictr(r,c) = 0; 
                iwidth(r,c) = 0; 
                ir2(r,c) = 0; 
            elseif G1.rsquare < r2l
                imag(r,c) = 0; %if rsquared too small, bad fit
                ictr(r,c) = 0; 
                iwidth(r,c) = 0; 
                ir2(r,c) = 0; 
            else
                imag(r,c) = F1.a1; %make an image from the magnitude of fit
                ictr(r,c) = F1.b1; %make an image from the center of fit
                iwidth(r,c) = F1.c1; %make an image from the width of fit
                ir2(r,c) = G1.rsquare; %make an image from the r^2 of fit
            end

        end
        waitbar(r/rmax);
    end
    close(wb);
end

