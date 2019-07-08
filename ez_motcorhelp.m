function varargout = ez_motcorhelp(varargin)
% I wrote this code because what else are you going to do on a Sunday in the middle of nowhere?
% The general setup functions can be copy-pasted between different handles, until you add a new handle.
% First draft: DC 9/21/14
% EZ_MOTCORHELP MATLAB code for ez_motcorhelp.fig
%      EZ_MOTCORHELP, by itself, creates a new EZ_MOTCORHELP or raises the existing
%      singleton*.
%
%      H = EZ_MOTCORHELP returns the handle to a new EZ_MOTCORHELP or the handle to
%      the existing singleton*.
%
%      EZ_MOTCORHELP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EZ_MOTCORHELP.M with the given input arguments.
%
%      EZ_MOTCORHELP('Property','Value',...) creates a new EZ_MOTCORHELP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ez_motcorhelp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ez_motcorhelp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ez_motcorhelp

% Last Modified by GUIDE v2.5 08-Jul-2019 14:58:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ez_motcorhelp_OpeningFcn, ...
                   'gui_OutputFcn',  @ez_motcorhelp_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ez_motcorhelp is made visible.
function ez_motcorhelp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ez_motcorhelp (see VARARGIN)

% Choose default command line output for ez_motcorhelp
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ez_motcorhelp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ez_motcorhelp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in genhelp.
function genhelp_Callback(hObject, eventdata, handles)
% hObject    handle to genhelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Reset all background colors of buttons and change this one to a dark color.
set(handles.genhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.roigenhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.selectroihelp,'BackgroundColor',[.94 .94 .94]);
set(handles.roiselecthelp,'BackgroundColor',[.94 .94 .94]);
set(handles.mchelp,'BackgroundColor',[.94 .94 .94]);
set(handles.fdhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.cahelp,'BackgroundColor',[.94 .94 .94]);
set(hObject, 'BackgroundColor',[.8 .8 .8]);
%Sets title of box to the string of this button
newtitle=get(hObject,'String');
set(handles.helpbox,'Title',newtitle);
%Fills in text boxes with information
set(handles.helptext1,'String',{'USING HELP',...
'This is the help section of Calcium Analysis. Click on any of the buttons above to open up a help topic. You may leave this window open as you work in case you have any questions. However, MATLAB won''t update the help text if you select a new topic and it''s already busy processing something else (such as aligning images in Motion Correction).',...
'   ',...
'MATLAB VERSION COMPATIBILITY',...
'This program was written and tested heavily on a computer running 64-bit version of Windows 8.1 with a freshly-installed version of MATLAB R2012a with many common toolboxes installed. You may get errors, particularly in MATLAB versions older than 2009 when the syntax for many commands were different. As with all MATLAB programs, there is also no guarantee that this will work with newer versions of MATLAB.',...
'   ',...
'FILENAME LENGTH',...
'This program often will automatically save filenames by appending existing filenames with what modifications have been performed. You may run into the issue of having filenames that are too long. If this is a concern, you should start with shorter filenames by renaming prior to motion correction and let this program append the shortened names. This will allow Autoload to work properly.'});
set(handles.helptext2,'String',{});

% --- Executes on button press in roigenhelp.
function roigenhelp_Callback(hObject, eventdata, handles)
% hObject    handle to roigenhelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Reset all background colors of buttons and change this one to a dark color.
set(handles.genhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.roigenhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.selectroihelp,'BackgroundColor',[.94 .94 .94]);
set(handles.roiselecthelp,'BackgroundColor',[.94 .94 .94]);
set(handles.mchelp,'BackgroundColor',[.94 .94 .94]);
set(handles.fdhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.cahelp,'BackgroundColor',[.94 .94 .94]);
set(hObject, 'BackgroundColor',[.8 .8 .8]);
%Sets title of box to the string of this button
newtitle=get(hObject,'String');
set(handles.helpbox,'Title',newtitle);
%Fills in text boxes with information
set(handles.helptext1,'String',{'AUTOSAVE',...
'This is an option in the Calcium Analysis GUI. What it does is automatically save every time you draw or delete an ROI by any method. Since it is constantly saving, you may experience slowdown issues if you have very large videos. If this is a problem for you, disable Autosave prior to launching ROI Selection and only use the manual Save button. Both Save and Autosave save your data as a MATLAB workspace ending in your filename appended with "_data.mat". Both these functions will automatically overwrite any existing data of the same name, so be wary when reloading old data.',...
'   ',...
'VIEWING OPTIONS',...
'Several options are available for you to use on the viewing screen. Average is the default option, which is an average of all the frames. With Raw Images, you can scroll through the images or play your video live as you are selecting ROIs. MaxProj is a maximum intensity projection of all frames, while Standard Deviation is the standard deviation of all frames, and Median Abs. Dev. is the median absolute deviation, a robust, outlier-resistant analog of standard deviation.',...
'   ',...
'You can also set the lookup table of the view. Color modes available are Grey, Hot, and Jet. The bars on the right will adjust the range of pixels displayed and alter the displayed range of pixel values.'});
set(handles.helptext2,'String',{'SELECTION OPTIONS',...
'Ring: This selects just the outer ring of an ROI, its brightest portion. The purpose of this is to exclude the nucleus and look at rest of the soma, which should have the highest concentration of your calcium indicator. This results in an increased dF/F signal and a better signal-to-noise ratio for a cleaner signal. It is recommended you use this when you can.',...
'   ',...
'Disk: If the nucleus is not in the plane of the region of soma being scanned, this is a very good option. It will select a filled-in version of the Ring option.',...
'   ',...
'Auto Border: This feature automatically traces your cell soma. It is based off of finding a circular path through a bright ring of fluorescence (see Supplementary Figure 14 of Tsai-Wen Chen, et al, Nature 2013).',...
'   ',...
'Circle Border: Sometimes you just have to do things yourself. Use this to trace a cell you see if you can''t get it to work with the Auto Border. It will draw a circular ROI just inside of the black circle.'});


% --- Executes on button press in selectroihelp.
function selectroihelp_Callback(hObject, eventdata, handles)
% hObject    handle to selectroihelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.genhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.roigenhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.selectroihelp,'BackgroundColor',[.94 .94 .94]);
set(handles.roiselecthelp,'BackgroundColor',[.94 .94 .94]);
set(handles.mchelp,'BackgroundColor',[.94 .94 .94]);
set(handles.fdhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.cahelp,'BackgroundColor',[.94 .94 .94]);
set(hObject, 'BackgroundColor',[.8 .8 .8]);
%Sets title of box to the string of this button
newtitle=get(hObject,'String');
set(handles.helpbox,'Title',newtitle);
%Fills in text boxes with information
set(handles.helptext1,'String',{'IMPORTANT BUTTONS',...
'Delete [keyboard]: When you have an ROI selected, you can hit the Delete key and remove it from the list and from the viewer window If you just created an ROI and it turned out unforgivably ugly, it is already the one currently selected, so you can just hit Delete right away and remove it.',...
'   ',...
'Scroll Wheel: Using the scroll wheel on a mouse will change the size of your circle for auto-tracing. If you are using a laptop, you may find it easier to plug in an external mouse for this purpose. You should select a ring size that will wrap just around the outside of your cell.',...
'   ',...
'CELL SHAPE ABNORMALITIES',...
'If your cells don''t look roughly circular (the cells themselves, not the traces ROIs), either you''re playing around with some interesting cells, or your settings in ScanImage may be off. Check to make sure your scan angle is proportional to your region being scanned (1 X, 0.5 Y for a 256x128 pixel scan, for example). Alternatively, you may have forgotten to or incorrectly downsampled an oversampled video.'});
set(handles.helptext2,'String',{'Cells on the outer edges of scanning may have their individual scanlines incorrectly lined up. You can attempt to trace these manually. This error is formed during scanning and is caused by inaccurate movement of mirrors (mirrors sometimes take time to accelerate when changing direction). If mirrors are overheating or otherwise failing, this error will become more and more pronounced. If you see this happening during imaging, please abort imaging immediately so as to not damage the mirrors. If this error is happening all over your field, or only one one side or the other, this was likely an error during acquisition. Consult someone who knows how to manually adjust ScanImage configurations (offsets, etc.) or whatever image acquisition software you are using.',...
'   ',...
'SELECTION TIPS',...
'Expand size of viewer window to the occupy the full window of a monitor. In another monitor, have the original video playing as well as the controls. Most monitors cannot display faster than 60 frames per second, so do not view the original video any faster than this or frames are being skipped and you could miss brief flashes.'});


% --- Executes on button press in roiselecthelp.
function roiselecthelp_Callback(hObject, eventdata, handles)
% hObject    handle to roiselecthelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.genhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.roigenhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.selectroihelp,'BackgroundColor',[.94 .94 .94]);
set(handles.roiselecthelp,'BackgroundColor',[.94 .94 .94]);
set(handles.mchelp,'BackgroundColor',[.94 .94 .94]);
set(handles.fdhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.cahelp,'BackgroundColor',[.94 .94 .94]);
set(hObject, 'BackgroundColor',[.8 .8 .8]);
%Sets title of box to the string of this button
newtitle=get(hObject,'String');
set(handles.helpbox,'Title',newtitle);
%Fills in text boxes with information
set(handles.helptext1,'String',{'OVERVIEW',...
'A view of your ROIs should pop up, often as Figure 2 if you have no other figures open. Use this figure to trace your ROIs using the left click of the mouse to select regions to trace.',...
'   ',...
'VIEWING PROBLEMS',...
'If all your views are terrible, it may be that image correction failed somehow. Check the corrected video and make adjustments to the Motion Correction settings and try again. If there is motion in the Z direction (may look like sudden, bright flashes across the field), these frames may not be useable. Some ways to reduce the number of such frames are by spending more time habituating your mouse to your rig, reducing stress of the mouse (increased general handling time, thorough cleaning of the rig to remove scent of other mice, etc.), ensuring that your headbars are securely fastened, and keeping a close eye on image acquisition to know whether or not your should reacquire. You may also need to increase the amount of sedative/anesthesia you are applying if you are using such techniques, but make sure they are still in your desired brain state (awake, asleep, etc.).'});
set(handles.helptext2,'String',{'You can effectively remove all movement of the skull relative to the objective and still get movement of the brain due to movement within the skull. Behavioral training will help reduce movement where mechanical restraints cannot. We are dealing with data on a scale of microns, and a one micron vertical shift can ruin your entire acquisition. Depending on the nature of your data and how you will analyze them later, it may be possible to remove these frames from your video manually in a program like ImageJ/Fiji. This is often the case when imaging spontaneous activity. You can try removing frames and redoing Motion Correction.'});


% --- Executes on button press in mchelp.
function mchelp_Callback(hObject, eventdata, handles)
% hObject    handle to mchelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.genhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.roigenhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.selectroihelp,'BackgroundColor',[.94 .94 .94]);
set(handles.roiselecthelp,'BackgroundColor',[.94 .94 .94]);
set(handles.mchelp,'BackgroundColor',[.94 .94 .94]);
set(handles.fdhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.cahelp,'BackgroundColor',[.94 .94 .94]);
set(hObject, 'BackgroundColor',[.8 .8 .8]);
%Sets title of box to the string of this button
newtitle=get(hObject,'String');
set(handles.helpbox,'Title',newtitle);
%Fills in text boxes with information
set(handles.helptext1,'String',{'OVERVIEW',...
'This function performs a non-rigid, two-pass motion correction on a .tif video. The first pass aligns the video to the average frame of the video. The second pass aligns the video to a preview frame, except for the first few frames which would have no reference because prior frames would not exist. Status is updated in the MATLAB Command Window.',...
'   ',...
'CHANNELS',...
'1 Channel Correction is your only option if you''re only collecting data from a single channel, as if you inserted a single calcium indicator and there is no other fluorescence. If you''re using this, only use the Channel 1 loading option. Anything in Channel 2 will be ignored while this option is selected. This is the default option.',...
'   ',...
'2 Channel Correction requires both a main data channel and a second reference channel. An example of this would be the mRuby-P2A-GCaMP6 virus that labels all GCaMP6-expressing cells (green) with an mRuby label (red). If acquired with the red and green channels simultaneously, you can load the reference channel (red) into channel 2, with your main data channel of interest (green), into channel 1. The corrections of channel 1 will be based off of the more accurate and reliable channel 1.'});
set(handles.helptext2,'String',{'PARAMETERS',...
'Block Size determines the size of "blocks" used to align the image. A smaller Block Size results in a more stable result, but can increase computation time.',...
'   ',...
'Reference Frame is the frame number used as a reference during the second pass. The larger the value, the longer time you''ll need to have a stable first several frames. If there is a movement early on, it may be repeated through the motion correction and result in a periodic, rhythmic wobble.'});


% --- Executes on button press in fdhelp.
function fdhelp_Callback(hObject, eventdata, handles)
% hObject    handle to fdhelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.genhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.roigenhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.selectroihelp,'BackgroundColor',[.94 .94 .94]);
set(handles.roiselecthelp,'BackgroundColor',[.94 .94 .94]);
set(handles.mchelp,'BackgroundColor',[.94 .94 .94]);
set(handles.fdhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.cahelp,'BackgroundColor',[.94 .94 .94]);
set(hObject, 'BackgroundColor',[.8 .8 .8]);
%Sets title of box to the string of this button
newtitle=get(hObject,'String');
set(handles.helpbox,'Title',newtitle);
%Fills in text boxes with information
set(handles.helptext1,'String',{'OVERVIEW',...
'This program allows you to generate and open a PDF of your raw traces, with ten traces per page. They are plotted simply by frame on the X axis with just raw fluorescence data on the Y axis. The numbers on the left correspond with the ROI numbers used in the ROI selection GUI. This program will only work with ROIs selected using the included Calcium Analysis program.',...
'   ',...
'OPEN ERROR',...
'If you do not have a PDF reader installed and set as the default program to open PDFs, you may get an error when attempting to open the PDF. Your PDF has still be generated, you just can''t open it until you install a PDF reader.',...
'   ',...
'PERMISSION ERRORS',...
'You may get a permission error. This is often a Windows-induced error as it tries to protect the Program Files folder, assuming you installed MATLAB inside of it. You should locate the folder [MATLAB Install Folder]\toolbox\matlab\graphics\private. Right click on the "private" folder and click on "Properties." Go to the "Security" tab and ensure that your user account has full access to everything in this folder. Enabling these permissions will require Administrator permission.'});
set(handles.helptext2,'String',{});


% --- Executes on button press in cahelp.
function cahelp_Callback(hObject, eventdata, handles)
% hObject    handle to cahelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.genhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.roigenhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.selectroihelp,'BackgroundColor',[.94 .94 .94]);
set(handles.roiselecthelp,'BackgroundColor',[.94 .94 .94]);
set(handles.mchelp,'BackgroundColor',[.94 .94 .94]);
set(handles.fdhelp,'BackgroundColor',[.94 .94 .94]);
set(handles.cahelp,'BackgroundColor',[.94 .94 .94]);
set(hObject, 'BackgroundColor',[.8 .8 .8]);
%Sets title of box to the string of this button
newtitle=get(hObject,'String');
set(handles.helpbox,'Title',newtitle);
%Fills in text boxes with information
set(handles.helptext1,'String',{'ABOUT THIS PROGRAM',...
'This program will allow you to take your raw videos from image acquisition, motion correct them, and extract fluorescence data from ROIs you select in a semi-automated manner. It will also extract your raw traces into a single, multi-page PDF if you desire. It is designed to only work with multipage .tif files, but it is possible to rewrite it. This program also does not perform downsampling, which can be done as a batch process in a program like ImageJ/Fiji.',...
'   ',...
'This program is largely an adaptation of scripts written by Tsai-Wen Chen, Patrick Mineault, and James Herman, with modifications and a cohesive GUI made by the Portera-Cailliau lab.',...
'   ',...
'AUTOLOAD',...
'Check this box to enable the Autoload feature (it is checked by default). With Autoload enabled, once you run a program, the file that should be generated is automatically loaded into the program immediately below. You may get an error if the file has not yet been generated, if you renamed or moved the file, or, in the case of ROI selection, you didn''t trace any ROIs.',...
'   ',...
'RESTART BUTTON',...
'Clears all variables set by this program as well as its subprograms. Also closes all windows and figures generated, so do not press this button if you have any open figures you wanted to save but haven''t yet, such as the ROI selection figure. F Data Preview automatically generates, saves, and opens figures as a multipage PDF, so you don''t have to worry about saving those manually.'});
set(handles.helptext2,'String',{});
