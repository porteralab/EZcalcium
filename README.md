# EZcalcium
Calcium imaging analysis made easy. EZcalcium is a flexible, user-friendly toolbox for analysis of calcium imaging data, controlled by a set of intuitive graphical user interfaces (GUI) based on MATLAB.

## Components & general workflow

EZcalcium contains three main modules: **Motion Correction**, **ROI Detection**, and **ROI Refinement**. Typically, an imaging data file is processed through this workflow.

**Motion Correction** consists of a non-rigid method of template matching, background subtraction, and the ability to export corrected videos with lossless compression.

**ROI Detection**, built off of the [CaImAn toolbox](https://github.com/porteralab/CaImAn-MATLAB) (Giovannucci et al., 2019), includes automated ROI detection, signal extraction, and deconvolution of fluorescence calcium signals.

**ROI Refinement** enables the user to sort and view ROIs, manually exclude ROIs, and use automated, customized ROI exclusion criteria, including spatial and activity-dependent metrics.

## System requirements

We recommend 64-bit MATLAB R2018a (version 9.4) or newer on any operating system for using the EZcalcium within MATLAB. The toolbox was finalized and tested heavily in R2018a and is likely to be the most compatible without modification in that environment. A 64-bit version of MATLAB is required to process files larger than 800 MB.

The following MATLAB toolboxes are required: Signal Processing, Statistics, and Parallel Computing.

EZcalcium, especially the ROI Detection module, uses functions from the [CaImAn toolbox](https://github.com/porteralab/CaImAn-MATLAB). Make sure it's in the MATLAB PATH as well.

The amount of available system RAM necessary for a system depends on the size of the data being processed. Ideally, the amount of system RAM should be at least 3x the file size of the raw, uncompressed data. CPU requirements for the EZcalcium are minimal, but processing is vastly improved with multiple cores. The toolbox also runs faster when the data to be analyzed is located on a solid-state drive, since large amounts of data must be read and, in the case of Motion Correction, written.
