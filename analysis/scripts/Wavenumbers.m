dz = 0.002; % Fill in with z resolution in units of meters
dx = 0.0024; % Fill in with x resolution in units of meters
frame = 500;
addpath('J:\April 8\BOS\Small Sech\compositeImages_3\')
filename = sprintf("%05d.mat", frame);
load(filename)
arrayRows = 190;
U = flip(u);
V = flip(v);

x = dx.*[1:size(U, 2)];
z = dz.*[1:size(U, 1)].';
[X, Z] = meshgrid(x, z);
b2 = divergence(X, Z, U, V);
BOSFrame = b2(1:arrayRows, :);

% Fill in with the frame you want to FFT (example: data(:, :, 300))
N = 1.39414;
omega = 1.0472;

k = 2*pi*(-floor(size(BOSFrame, 2)/2):(ceil(size(BOSFrame, 2)/2)-1))./...
    (size(BOSFrame, 2)*dx);
m = 2*pi*[(-floor(size(BOSFrame, 1)/2):(ceil(size(BOSFrame, 1)/2)-1))./...
    (size(BOSFrame, 1)*dz)].';

% Tukey window to reduce spectral leakage. Might not matter
 % BOSFrame = BOSFrame.*tukeywin(size(BOSFrame, 1), 0.2).*(tukeywin(size(BOSFrame, ...
 %     2), 0.2).');
BOSFrame = BOSFrame.*hann(size(BOSFrame, 1)).*(hann(size(BOSFrame, 2)).');

BOSFFT = abs(fftshift(fft2(BOSFrame))).^2;
BOSFFT = BOSFFT./(numel(BOSFrame));

PosSlope = (1.05*N^2 - omega^2)/omega^2;
NegSlope = -1*PosSlope;




FigLCM = 6.5*2.54; 
FigHCM = 3.2*2.54;
%Prev FigHCM was 2.2*2.54
xMargCM = 0.5;
yMargCM = [0.6 1.2];
%Prev yMargCM second argument was 0.85
xInnerCM = 0.5;
yInnerCM = 0.5;
Ratio = 1;

fig = figure;

addpath("J:\")
FigPos = BussinPlot(1, 1, FigLCM, FigHCM, xMargCM, yMargCM, ...
    xInnerCM, yInnerCM, Ratio);

fig.PaperSize = [FigLCM FigHCM]./2.54;

% figure
pcolor(k, m, BOSFFT)
addpath('J:/April 8/slanCM/')
colormap(slanCM('magma'))
%clim([0 500])

%cb = colorbar;
%cb.Label.String = '$|\hat{u}(k,m)|^2$';
%cb.Label.Interpreter = 'latex';
%cb.Label.FontSize = 12


xlabel('$k$ (rad m$^{-1}$)', 'Interpreter', 'latex')
ylabel('$m$ (rad m$^{-1}$)', 'Interpreter', 'latex')
xlim([-125, 125])
ylim([-125,125])
axis square;
shading interp

ax = gca;
ax.TickLabelInterpreter = 'latex';
ax.XAxis.FontSize = 11;
ax.YAxis.FontSize = 11;



hold on
plot(k, PosSlope.*k, 'w--')
plot(k, NegSlope.*k, 'w--')
%exportgraphics(gcf, 'JURPA_Wavenumbers2.pdf', 'Resolution', 1200)

