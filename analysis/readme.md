# Analysis

## Description
This folder contains the scripts and files we utilize in the analysis involved in the accompanying paper. File "03717.mat" corresponds to a BOS frame used in scripts/Wavenumbers.m. Usually, the full collection of BOS frames collected encompass terabytes, so having a large hard drive on hand prior to data collection is reccomended. File "BOSBackground.pptx" corresponds to the random dot pattern we project onto the whiteboard.

## Scripts
This folder contains all the scripts needed for quantifying/analyzing our system. 

### DPIV
[DPIV.py](scripts/DPIV.py) and [DPIVParams.yaml](scripts/DPIVParams.yaml) are used in conjunction to create the BOS frame needed for further analysis. The script utilizes the python package [dpivsoft](https://pypi.org/project/dpivsoft/), an image cross-correlation software package originally designed for digital particle image velocimetry (https://doi.org/10.1016/j.softx.2022.101256). In this work, it is used to perform the cross-correlation analysis required for background-oriented schlieren (BOS), measuring the apparent displacement of a random-dot background between a reference image and each experimental frame.

### VerticalCast
[VerticalCast.m](scripts/VerticalCast.m) is the script we use to determine the buoyancy frequency from conductivity measurements. All it needs is calibration conductivities and densities as described in [setup](/setup/tutorial.md)

### Wavenumbers
This script takes a BOS frame and carries out a 2D spatial FFT to generate a spectra, as described in [setup](/setup/tutorial.md)

### WedgeSpectrum
//TODO: Describe this script

### BOSPatternMaker
This is a script that generates the random dot pattern needed for BOS, attributed to [Frederic Moisy](https://scholar.google.com/citations?user=U5IBg0sAAAAJ&hl=fr) on 2008/09/05


