%% INITIAL STRATIFICATION
MixingRho = 1.0377; % Density of mixing tank
SurfaceRho = 1.1246; % Surface density 

% For the calibration variable Calib, input conductivities in the first
% column (in S/cm) and densities in the second column (in g/cm^3)
Calib = [975e-6, 0.9992; ...
        59.3e-3, 1.0285; ...
        71.8e-3, 1.0357; ...
        123.1e-3, 1.0687;...
        154.0e-3, 1.0924; ...
        189.2e-3, 1.1266];
    
% Now make a new variable called CastCond. You can do this by 
% right-clicking on the Workspace tab on the right, and clicking New. Then 
% name the variable CastCond. This will be your conductivity cast for the 
% initial stratification, and you can input it in units of mS/cm

% The next line creates a conversion from conductivity to density using a
% cubic spline, based on the calibration. It then applies this fit to the
% conductivity cast, and converts to S/cm 
CastRho = spline(Calib(:,1), Calib(:,2), CastCond(:,1).*0.001);

% Now add on the density at the bottom and top of the tank and convert to 
% kg/m^3
CastRho = [SurfaceRho; CastRho; MixingRho].*1000;

% This next line is where we enter the z-values in m, with z = 0 at the
% surface and z < 0 below. I assume that the measurement is made in the
% middle of the conductivity probe hole, which is an offset of about 0.6875
% in
CastZ = [0, (1:length(CastData)).*0.85 + 1*0.6875, 17.219].*-0.0254;

% This next line creates a linear fit between the z values and the rho
% values, and extracts the slope
LinFit = fit(CastZ.', CastRho, 'poly1');
drho = LinFit.p1;

% Now we plot the stratification, and show the value of N using SurfaceRho
% as rho_0
figure
plot(CastRho, CastZ, 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r')
hold on
plot(drho*CastZ + LinFit.p2, CastZ, 'LineWidth', 1, 'Color', 'c')
xlim([1030 1141])
N = sqrt(9.81/SurfaceRho*abs(drho));
title(sprintf('N = %g rad/s', N), 'Interpreter', 'latex')
xlabel('$\rho$ (kg/m$^3$)', 'interpreter', 'latex')
ylabel('$z$ (m)', 'Interpreter', 'latex')

%% INTRUSIONS

% Make a new variable called IntrusCond, which will be the conductivities
% from within the intrusions in mS/cm

% Now convert to density in kg/m^3 using the same cubic spline as before
IntrusRho = spline(Calib(:,1), Calib(:,2), IntrusCond(:,1).*0.001).*1000;

% Next make a new variable of the depths at which you sampled, in m.
% Remember that z = 0 at the top, and z < 0 within the tank. 

% Now plot everything. The code currently plots the intrusion data as green
% dots. If you want to instead use lines, replace line 68 with 
% plot(IntrusRho, IntrusZ, 'g')
figure
plot(CastRho, CastZ, 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r')
hold on
plot(IntrusRho, IntrusZ, 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g')
plot(drho*CastZ + LinFit.p2, CastZ, 'LineWidth', 1, 'Color', 'c')
xlim([1030 1141])
N = sqrt(9.81/SurfaceRho*abs(drho));
title(sprintf('N = %g rad/s', N), 'Interpreter', 'latex')
xlabel('$\rho$ (kg/m$^3$)', 'interpreter', 'latex')
ylabel('$z$ (m)', 'Interpreter', 'latex')