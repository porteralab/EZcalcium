Instructions on using roigui.m for ROI selection

step1. Open example.mat, this file contains some example data of mouse cortex images (GCaMP expressing cells)
step2. Run 'roigui(im)'

click on the image to select ROI, there are 4 different possible mode

(1) Ring/Auto
(2) Ring/Circle
(3) Disc/Auto
(4) Disc/Circle

(1) and (2) are used to select ring (donut) shaped object; (3) and (4) are used to select disc (round) shaped object
Use the mouse scroll wheel if you need to change the expected size of the ROI (i.e. the size of the black circle around the mouse cursor).

The PlotSel botton will plot the dFF trace of the selected ROIs

The Export botton will creat a structure called 'ROI_list' in the base workspace containing infomations about the selected ROIs (including list of pixels, average fluorescent trace (fmean) etc..)

For further question please contact Tsai-Wen Chen (chent@janelia.hhmi.org)
