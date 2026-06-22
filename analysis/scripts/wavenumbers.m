dz = ; % Fill in with z resolution in units of meters
dx = ; % Fill in with x resolution in units of meters

BOSFrame = ; % Fill in with the frame you want to FFT (example: data(:, :, 300))

k = 2*pi*(-floor(size(BOSFrame, 2)/2):(ceil(size(BOSFrame, 2)/2)-1))./...
    (size(BOSFrame, 2)*dx);
m = 2*pi*[(-floor(size(BOSFrame, 1)/2):(ceil(size(BOSFrame, 1)/2)-1))./...
    (size(BOSFrame, 1)*dz)].';

% Tukey window to reduce spectral leakage. Might not matter
BOSFrame = BOSFrame.tukeywin(size(BOSFrame, 1), 0.2)....
    (tukeywin(size(BOSFrame, 2), 0.2).');

BOSFFT = abs(fftshift(fft2(BOSFrame))).^2;

PosSlope = (N^2 - omega^2)/omega^2;
NegSlope = -1*PosSlope;

figure
pcolor(k, m, BOSFFT)
xlabel('$k$ (rad m$^{-1}$)', 'Interpreter', 'latex')
ylabel('$m$ (rad m$^{-1}$)', 'Interpreter', 'latex')
shading interp
hold on
plot(k, PosSlope.*k, 'w--')
plot(k, NegSlope.*k, 'w--')