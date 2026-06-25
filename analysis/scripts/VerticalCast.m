% > Calibration: Make a variable called "Calib" with the first column being
% conductivies and the second column being densities
% > Vertical Cast: Make a variable called "Cast" with the conductivities
addpath('J:/')
Height = 17.219*2.54; % Tank height (cm)

load('CastData2.mat') % Can uncomment if you have saved Calib and Cast as
% CastData.mat

Calib = [2.469, 1.0013; 63.3, 1.0282; 100.1, 1.0513; 127, 1.0691; ...
    182.1, 1.1141; 206.1, 1.1406];

CastRho = spline(Calib(1:end,1), Calib(1:end,2), Cast(:,1)); % Density from 
% conductivity probe (g/cm^3)
CastRho = [rhoSurf; CastRho; rhoMix].*1000; % Convert to kg/m^3

CastZ = [0, (0:length(Cast)-1).*0.85*2.54 + 1.8, Height].*-1; % Depths (cm)
CastZ = CastZ./100; % Convert to m

LinFit = fit(CastZ(1:end).', CastRho(1:end), 'poly1');
drho = LinFit.p1;
rho0 = LinFit.p1*(CastZ(end)/2) + LinFit.p2; % Mean density based on linear
% fit

figure
FigPos = BussinPlot(1, 1, 18, 10, 2, 0.9, 0.1, 0.1, 1);
ax = subplot('Position', FigPos);
plot(CastRho, CastZ, 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r')
hold on
plot(drho*CastZ + LinFit.p2, CastZ, 'LineWidth', 1, 'Color', 'c')
xlim([1030 1141])
N = sqrt(-9.81/(rho0)*drho);
title(sprintf('N = %g rad/s', N), 'Interpreter', 'latex')
hold off

%%
figure
load('CastData.mat')
plot(Calib(:, 1), Calib(:, 2))
hold on
load('CastData2.mat')
plot(Calib(:, 1), Calib(:, 2))
oldCalib = [2.469, 1.0013; 63.3, 1.0282; 100.1, 1.0513; 127, 1.0691; ...
    182.1, 1.1141; 206.1, 1.1406];
plot(oldCalib(:, 1), oldCalib(:, 2))
newCalib = [0.627, 0.9989; 90.4, 1.0484; 117.6, 1.067; 156.9, 1.0995; ...
    172.7, 1.1153; 194.1, 1.1409];
plot(newCalib(:, 1), newCalib(:, 2))
legend('April 8', 'April 9', 'Old Data', 'New Data')