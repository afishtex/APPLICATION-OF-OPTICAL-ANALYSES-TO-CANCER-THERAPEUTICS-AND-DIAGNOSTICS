function [ imag,ictr,iwidth,ir2,dout,foutf,foutg  ] = ...
    process_poly(d,x,b_size,ml,wl,r2l,p,f )
%DATA_POLY remove any background drift and fit Raman peaks
%   background drift removed by subtracting a polynomial fit of the first
%   b_size points.
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
        lzt = fittype( @(a1,b1,c1,x) ...
            (a1)*((c1^2)./(((x-b1).^2)+c1^2 ))); % create Lorentzian fit
    end
    wb = waitbar(0,'Processing Spectra...');
    for r = 1:rmax
        for c = 1:cmax
            data_sh = squeeze(d(r,c,:));

            %use polynomial to remove background
            num = b_size*2; %number of background points
            data_bkgnd = zeros(num,2);
            data_bkgnd(:,1) = [shift(1:b_size);shift(end-b_size+1:end)];
            data_bkgnd(:,2) = [data_sh(1:b_size);data_sh(end-b_size+1:end)];
            [F2,~] = fit(data_bkgnd(:,1),data_bkgnd(:,2),p);
            data_sh_poly(:,1) = data_sh;
            background(:,1) = F2(shift);
            data_sh_poly(:,2) = data_sh_poly(:,1) - background(:,1);
            dout(r,c,:) = data_sh_poly(:,2);
            tmp = sort(d,'descend');
            fit_max = tmp(3)*2;
            if f == 1
                [F3,G3] = fit(shift,data_sh_poly(:,2),'Gauss1',...
                    'Lower',[0,min(shift),eps],...
                    'Upper',[fit_max,max(shift),max(shift)-min(shift)]);
            else
                [F3,G3] = fit(shift,data_sh_poly(:,2),lzt,...
                    'StartPoint',[max(data_sh_poly(:,2))/2,mean(shift),...
                    shift(2)-shift(1)],'Lower',[0,min(shift),eps],'Upper',...
                    [fit_max,max(shift),max(shift)-min(shift)]);
            end
            data_sh_poly(:,3) = F3(shift);
            foutf{r,c} = F3;
            foutg{r,c} = G3;
            if F3.a1 <= ml
                imag(r,c) = 0; %if mag < 0, make all values 0 = bad fit
                ictr(r,c) = 0; 
                iwidth(r,c) = 0; 
                ir2(r,c) = 0; 
            elseif F3.c1 < wl
                imag(r,c) = 0; %if width too large, make all values 0 = bad fit
                ictr(r,c) = 0; 
                iwidth(r,c) = 0; 
                ir2(r,c) = 0; 
            elseif G3.rsquare < r2l
                imag(r,c) = 0; %if r^2 too small, make all values 0 = bad fit
                ictr(r,c) = 0; 
                iwidth(r,c) = 0; 
                ir2(r,c) = 0; 
            else
                imag(r,c) = F3.a1; %make an image from the magnitude of fit
                ictr(r,c) = F3.b1; %make an image from the center of fit
                iwidth(r,c) = F3.c1; %make an image from the width of fit
                ir2(r,c) = G3.rsquare; %make an image from the r^2 of fit
            end

        end
        waitbar(r/rmax);
    end
    close(wb);
end

