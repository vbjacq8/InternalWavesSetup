# Generation and Visualization of Linear Internal Waves

## How We Position The Apparatus
Before we discuss how each step is done, we outline the general positioning of our apparatus components.
* We place the tank on top of a four-legged metal platform about 2 feet in height
* We create scaffolding around the tank with aluminum extrusion (80/20), which supports the electronics that drive our two motors. Each motor is attached to a carriage: one that holds the conductivity probe that can move down the height of the tank, and one that holds the topography that can move across the width of the tank.
* For Shadowgraphing, we place a whiteboard behind and parallel to the tank. On the opposite side, our heat lamp illuminates the tank.
* For BOS, we use the same whiteboard and place it 280 cm in front of the tank. Then, on the opposite side of the tank we place three cameras of equal spacing at eye-level with the tank, scaffolded by 80/20 and tripods (for reference, we place it 146 cm away from the tank)
//TODO: Add cartoons for the Shadowgraph setup. 
* For BOS, we also position a projector below the tank, such that a clear random dot pattern illuminates ONLY the whiteboard, and nothing else.

![](media/SetupSchematic.pdf)

Given these are in place, we begin our first step to produce linear internal waves. 

## 1. Tank Stratification 

The first step in producing linear internal waves is establishing a stable, linearly stratified fluid within the wave tank. One method to do this is using the two-bucket method. Our implementation involves a saltwater resevoir, a freshwater resevoir, two peristaltic pumps, and a bilge pump. Freshwater is slowly pumped into the saltwater resevoir as bilge pumps ensure mixing. The mixture in the saltwater resevoir is then pumped out and into the wave tank at twice the rate as freshwater is pumped into it. We also clamp the tank to stop any bulging effects that can get in the way of our visualization. 

To minimize the turbulence of the wave tank inflow, the inflow pump runs into a sponge diffuser positioned at the water surface.  As the tank fills, the diffuser distributes 
incoming water evenly and floats upward with the rising water level, allowing the density gradient to develop gradually throughout the depth of the tank.

![](/setup/media/Diffuser.jpg)

If peristaltic pumps are not available, mechanical ones will do just fine. If those are not available, a siphon can be used to transport water from the mixing tank. Alternatively, one may use beakers to fill the sponge diffuser, starting with saltwater and gradually decreasing the density of the solution. However, this will lead to more of a staircase profile that will have error in regards to linear internal waves. One could wait for diffusion to even out the staircase if needed. 

After filling is complete, the stratification profile is quantified using conductivity measurements. Conductivity probes are lowered through the water column at multiple depths, and the measured conductivity values are converted to salinity and density. These measurements verify the linearity of the density gradient and allow determination of the buoyancy frequency, (N), which governs the propagation characteristics of internal waves. These probes can be expensive, so an open-source alternative that can be explored are Conduino sensors. 

Because density also relies on temperature, mapping conductivity to density is unique each day. If one uses conductivity, calibration is required. We calibrate our readings by taking six samples of increasingly saline saltwater solutions, making sure they are at the same temperature as the stratification. Using a handheld densitometer and conductivity probe (which we detached from the carriage on the side of the tank), we can create a cubic spline that allows us to extract density from conductivity. This avoids intruding on the stratification with a handheld densitometer. It is important that the samples MUST include the most and least saline values used in the stratification. Because we use a spline, we do this to avoid extrapolation.

## 2. Internal Wave Generation

Once a stable stratification has been established, internal waves are generated through oscillatory forcing of a submerged topographic feature. The topography used in our system follows a hyperbolic secant squared profile,

$h(x) = h_0\mathrm{sech}^2\left(\frac{x}{h_0}\right)-h_0\mathrm{sech}^2\left(\frac{l_0}{h_0}\right)$

where $h_0$ is the maximum topographic height and $l_0$ is half-length of the topography.

Using Parker Automation software, we drive the motor to oscillate the topography in sinusoidal fashion. This generates internal gravity waves that propagate throughout the tank. The motor and The forcing frequency and amplitude can be adjusted to investigate different regions of the internal-wave dispersion relation while remaining within the linear wave regime. A possible DIY alternative to the forcing mechanism may include a servo motor controlled by a Raspberry Pi computer, or something similar: in a simpler setup one can forgo the $\mathrm{sech}^2$ shape and simply use a plastic PVC pipe that moves up and down. 

## 3 Shadowgraph Visualization

A simple method for observing the generated waves is shadowgraph imaging. In this technique, a parallel light source is directed through the tank toward a whiteboard. Internal waves create small density gradients that alter the local refractive index of the fluid, causing light rays to bend slightly as they pass through the stratified medium. This bending produces visible fluctuations that reveal wave structure and propagation patterns. Shadowgraph imaging provides an intuitive and inexpensive means of visualizing internal waves, making it well suited for demonstrations and qualitative observations.\

![]()

## 4 Background-Oriented Schlieren (BOS) Measurements

For quantitative measurements, our primary method is BOS, which utilizes a random dot background pattern positioned behind the tank and multiple high-resolution cameras.

Our three cameras are synchronized with Bobcat software to image the entire wave field, allowing coverage of the full tank at a resolution near 4K (3296 x 2472). To calibrate, we put a ruler aligned with the inside of the stratified tank, and take photos of it on each camera. Using dpivsoft allows us to find the length scale of a pixel in the frame. As we start oscillation, we capture photos at $2 \ \text{Hz}$. This acquisition rate is sufficient to resolve the relatively slow evolution of the internal-wave dynamics.

BOS builds on the same idea as shadowgraphing: internal waves drive density gradients that alter the local refractive index, producing small apparent displacements of the background pattern. In BOS, the displacements are extracted through image-correlation techniques and converted into refractive-index gradient fields. Using the known relationship between refractive index, density, and salinity, the BOS measurements provide quantitative information about the evolving internal-wave field. The software we use to extract this information is called dpivsoft and can be read about in [the analysis folder](../analysis/scripts/)

The resulting displacement and density-gradient fields enable detailed analysis of wave propagation, dispersion, beam structure, and other dynamical phenomena within the stratified fluid, which may be seen in the accompanying paper's ![Fig 2a](/setup/media/Fig2a.pdf).

## 5 FFT and Analysis

### Wavenumbers
For further quantitative results, the density-gradient field extracted from BOS imaging may be put through a two-dimensional spatial FFT (Fast Fourier Transform). Transforming the data from physical space $(x,z)$ to wavenumber space $(k,m)$ reveals the spatial frequencies that contain the most energy. The result is a graph of the spectral peaks that correspond to the most dominant internal-wave modes. To reduce spectral leakage, a windowing method may be used, such as a Hann window. An example of an FFT on the density field is seen in the accompanying paper's ![Fig 2b](/setup/media/Fig2b.pdf).


### Wedge Spectrum
In Appendix A, we present an alternative method of looking at the data. While ![Fig 2b](/setup/media/Fig2b.pdf) finds the distribution of energy based on wavenumber, we can visualize the distribution of energy along angles. 
//TODO: describe how this works
