# EZcalcium
Calcium imaging analysis made easy. EZcalcium is a flexible, user-friendly toolbox for analysis of calcium imaging data, controlled by a set of intuitive graphical user interfaces (GUI) based on MATLAB.

## Components & general workflow

EZcalcium contains three main modules: **Motion Correction**, **ROI Detection**, and **ROI Refinement**. Typically, an imaging data file is processed through this workflow.

**Motion Correction**, based on the [NoRMCorre toolbox](https://github.com/porteralab/NoRMCorre), applies image alignment to correct for motion artifacts in the raw imaging data.

**ROI Detection**, based on the [CaImAn toolbox](https://github.com/porteralab/CaImAn-MATLAB), performs automated ROI detection, signal extraction, and deconvolution of fluorescence calcium signals.

**ROI Refinement** enables the user to inspect deteced ROIs, manually exclude ROIs, and use automated, customized ROI exclusion criteria, including spatial and activity-dependent metrics.

Step-by-step instructions for using each modules can be found on the [EZcalcium GitHub Wiki page](https://github.com/porteralab/EZcalcium/wiki), as well as the included [HELP.pdf](https://github.com/porteralab/EZcalcium/blob/master/HELP.pdf) file.

## System requirements and installation

The amount of required available system memory depends on the size of the data being processed. Ideally, the amount of total system memory should be at least 3x of the size of a single raw, uncompressed data file. CPU requirements are minimal, but processing speed is vastly improved with multiple cores. The toolbox also runs faster when the data to be analyzed is stored on a solid-state drive, since large amounts of data must be read and, in the case of Motion Correction, written.

We recommend 64-bit MATLAB R2018a (version 9.4) or newer on Windows or macOS for using the EZcalcium. The following MATLAB toolboxes are required:

* Image Processing (required by **Motion Correction**, **ROI Detection** and **ROI Refinement**)
* Parallel Computing (required by **Motion Correction** and **ROI Detection**)
* Signal Processing (required by **ROI Detection**)
* Statistics and Machine Learning (required by **Motion Correction**, **ROI Detection** and **ROI Refinement**)

To install EZcalcium:

1. Click the green "Clone or download" button on the top right of this page;
2. Click "Download ZIP" to download the file;
3. Extract the downloaded ZIP file to your favourite place;
4. In MATLAB, go to HOME - ENVIRONMENT - Set Path, in the Set Path window, click "Add with Subfolders...", select the folder that contains the files you just extracted, then click "Save" and "Close".

EZcalcium heavily depends on [CaImAn](https://github.com/porteralab/CaImAn-MATLAB) and [NoRMCorre](https://github.com/porteralab/NoRMCorre). Make sure you also download and add them on the MATLAB path as well by repeating the same procedures above.
