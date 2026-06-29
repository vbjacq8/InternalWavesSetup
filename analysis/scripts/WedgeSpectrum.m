%% [1] LOAD THE DATA ======================================================
% Use DataSet = 1 for old data from 10-22-2021, and DataSet = 1 for
% 9-8-2025
Sheet = 0;
dx = 0.0024;
dz = 0.002;
for DataSet = 1:3
    Sheet = Sheet + 1;
StartInds = [48, 35, 25] + 1400;
SegLen = 1000;
restoredefaultpath
framenum = 0;

if (exist('framenum', 'var') && framenum == 0) || ~exist('framenum', 'var')
    framenum = 0;
    if DataSet == 1
        addpath('J:\April 8\BOS\Small Sech\compositeImages_3\')
        N = 1.39414; 1.4292;
    elseif DataSet == 2
        addpath('J:\April 8\BOS\Med Sech\compositeImages_3\')
        N = 1.39414; 1.4292;
    elseif DataSet == 3
        addpath('J:\April 8\BOS\Big Sech\compositeImages_3\')
        N = 1.45156; 1.4857;
    end
    arrayRows = 140;
    indnums = [StartInds(DataSet):StartInds(DataSet) + SegLen - 1];
    bFull = zeros(arrayRows, 842, length(indnums));
    for ind = indnums
        filename = strcat(sprintf('%05d.mat', ind));
        if exist(filename, 'file')
            framenum = framenum + 1;
            load(filename)
            U = flip(u);
            V = flip(v);
            x = dx.*[1:size(U, 2)];
            z = dz.*[1:size(U, 1)].';
            [X, Z] = meshgrid(x, z);
            b2 = divergence(X, Z, U, V);
            bFull(:,:,framenum) = U(1:arrayRows, :);
        end
    end
end

omega0 = 2*pi/6;
f0 = 1/6;
Fs = 2;

% [2] PREPARE FOR FOURIER TRANSFORM =======================================

timeSlices = framenum;
Spectra = zeros(timeSlices, 100);

    Kxs = 1/dx;
    Kzs = 1/dz;
    
    kx = [-Kxs/2:Kxs/842:Kxs/2 - Kxs/842];
    kz = [-Kzs/2:Kzs/arrayRows:Kzs/2 - Kzs/arrayRows].';

% -------------------------------------------------------------------------
[KX, KZ] = meshgrid(kx, kz);

AT = atan2(KZ, KX);
AT(isnan(AT)) = -100; 
theta = linspace(-pi, pi, 102);

% [3] FOURIER TRANSFORM ===================================================
bFull = bFull.*tukeywin(size(bFull, 1), 0.2);
bFull = bFull.*(tukeywin(size(bFull, 2), 0.2).');
hann3d = hanning(size(bFull, 3));
for i = 1:length(hann3d)
    bFull(:, :, i) = bFull(:, :, i).*hann3d(i);
end

dbFFT = fftshift(fftn(bFull));

% dxFFT = dxFFT./KX;
% dzFFT = dzFFT./KZ;

dbFFT(isinf(dbFFT)) = 0;

tic
for counter = 1:timeSlices
    
    tenthIndices = floor(0.1*[1:10]*timeSlices);
    if ismember(counter, tenthIndices)
        disp(counter)
    end
    
    for n = 1:101
        %mask=exp(-((AT-theta(n))/.01).^2);
        mask = AT >= theta(n) & AT < theta(n+1);
        mask(isnan(mask)) = 0;
        Spectra(counter,n) = sum(sum(abs(dbFFT(:,:,counter).^2).*mask))/...
            sum(sum(mask));
        
    end
    
end
theta2 = (theta(2:end)+theta(1:end-1))/2;
%omega = [-timeSlices/2:timeSlices/2-1]*2*pi/(timeSlices/Fs)/1.04;
toc
WedgeSpec(Sheet).Spectra = Spectra;
WedgeSpec(Sheet).N = N;
end
%% [2] PLOTTING ===========================================================
addpath('J:/April 8/slanCM/')
addpath('J:/')
FigLCM = 6.5*2.54; 
FigHCM = 2.2*2.54;
xMargCM = 0.5;
yMargCM = [0.6 0.85];
xInnerCM = 0.5;
yInnerCM = 0.5;
Ratio = 1;

fig = figure;
FigPos = BussinPlot(Sheet, 1, FigLCM, FigHCM, xMargCM, yMargCM, ...
    xInnerCM, yInnerCM, Ratio);
subtitleNames = {'a', 'b', 'c'};

for i = 1:Sheet
    ax = subplot('Position', FigPos(i, :));
    Spectra = WedgeSpec(i).Spectra;
    N = 1*WedgeSpec(i).N;
    Spectra(:, 51) = (Spectra(:, 50) + Spectra(:, 52))./2;
    Spectra(:, 1) = 1;
    Spectra(:, end) = 1;
    theta3 = theta2;
    [~, ind1] = min(abs(theta3 + pi/2));
    [~, ind2] = min(abs(theta3 - 0));
    [~, ind3] = min(abs(theta3 - pi/2));

    % theta3(2:ind1) = 0.95*theta3(2:ind1);
    % theta3(ind1+1:ind2-1) = 1.05*theta3(ind1+1:ind2-1);
    % theta3(ind2+1:ind3-1) = 1.05*theta3(ind2+1:ind3-1);
    % theta3(ind3:end-1) = 0.95*theta3(ind3:end-1);

    f = [-Fs/2:Fs/timeSlices:Fs/2 - Fs/timeSlices];
    Nnorm = N./omega0;
    set(groot,'defaultAxesTickLabelInterpreter','latex');

    L1 = pcolor(f./(f0),theta3,log10(Spectra.'));
    shading interp
    axis([0,1.5,-pi,pi]);hold on
    xlabel('$\omega/\omega_0$','interpreter','latex')
    if i == 1
    ylabel('$\theta$ (Radians)','interpreter','latex')
    end
    xticks([0 0.5 1 1.5])
    xticklabels({'0.0', '0.5', '1.0', '1.5'})
    yticks([-0.99*pi -pi/2 0 pi/2 0.99*pi])
    yticklabels({'$-\pi$', '$-\frac{\pi}{2}$', '0', '$\frac{\pi}{2}$', ...
        '$\pi$'})
    hold on
    L2 = plot(cos(1*theta2)*Nnorm,theta3,'LineWidth',1, 'Color', 'w');
    L3 = plot(-cos(1*theta2)*Nnorm,theta3,'-','LineWidth',1, 'Color', 'w');
    ylim([min(theta2) max(theta2)])
    colormap(slanCM('copper'))
    caxis([9 10.5])
    title(sprintf('(%s)', subtitleNames{i}), 'interpreter', ...
        'latex')
    ax.TitleHorizontalAlignment = 'left';
end    
exportgraphics(gcf, 'BOSWedgePlot.pdf')
fig.PaperSize = [FigLcm FigHcm]./2.54;
%print(gcf, 'BOSWedgePlot', '-dpdf', '-r450')