[![View EZcalcium on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/109840-ezcalcium)

# EZcalcium
Calcium imaging analysis made easy. EZcalcium is a flexible, user-friendly toolbox for analysis of calcium imaging data, controlled by a set of intuitive graphical user interfaces (GUI) based on MATLAB.

## Components & general workflow

EZcalcium contains four main modules: **Motion Correction**, **ROI Detection**, **ROI Refinement**, and **ROI Matching**. Typically, an imaging data file is processed through this workflow.

**Motion Correction**, based on the [NoRMCorre toolbox](https://github.com/porteralab/NoRMCorre), applies image alignment to correct for motion artifacts in the raw imaging data.

**ROI Detection**, based on the [CaImAn toolbox](https://github.com/porteralab/CaImAn-MATLAB), performs automated ROI detection, signal extraction, and deconvolution of fluorescence calcium signals.

**ROI Refinement** enables the user to inspect deteced ROIs, manually exclude ROIs, and use automated, customized ROI exclusion criteria, including spatial and activity-dependent metrics.

**ROI Matching**, also based on the [CaImAn toolbox](https://github.com/porteralab/CaImAn-MATLAB), helps to find the same ROIs across different sessions/experiments in an imaging series of the same field of view.

Step-by-step instructions for using each modules can be found on the [EZcalcium GitHub Wiki page](https://github.com/porteralab/EZcalcium/wiki), as well as the included [HELP.pdf](https://github.com/porteralab/EZcalcium/blob/master/HELP.pdf) file.

## System requirements and installation

The amount of required available system memory depends on the size of the data being processed. Ideally, the amount of total system memory should be at least 3x of the size of a single raw, uncompressed data file. CPU requirements are minimal, but processing speed is vastly improved with multiple cores. The toolbox also runs faster when the data to be analyzed is stored on a solid-state drive, since large amounts of data must be read and, in the case of Motion Correction, written.

We recommend 64-bit MATLAB R2020b (version 9.9) or newer on Windows or macOS for using the EZcalcium. The following MATLAB toolboxes are required:

* Image Processing (required by all four modules)
* Parallel Computing (required by **Motion Correction**, **ROI Detection** and **ROI Matching**)
* Signal Processing (required by **ROI Detection** and **ROI Matching**)
* Statistics and Machine Learning (required by all four modules)

To install EZcalcium, go to the GitHub [releases](https://github.com/porteralab/EZcalcium/releases) page, download `EZcalcium.zip` of the latest release and extract the downloaded ZIP file to your place of choice. And then in MATLAB, go to HOME - ENVIRONMENT - Set Path, and in the Set Path window, click "Add with Subfolders...", select the folder that contains the files you just extracted, then click "Save" and "Close".

Or if you are comfortable with Git, you can just clone this repository, as well as [CaImAn](https://github.com/porteralab/CaImAn-MATLAB) and [NoRMCorre](https://github.com/porteralab/NoRMCorre). Add the folders to MATLAB Path and you are good to go.
