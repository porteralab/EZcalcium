function varargout = ez_calcium_analysis(varargin)
% EZ_CALCIUM_ANALYSIS MATLAB code for ez_calcium_analysis.fig
%      EZ_CALCIUM_ANALYSIS, by itself, creates a new EZ_CALCIUM_ANALYSIS or raises the existing
%      singleton*.
%
%      H = EZ_CALCIUM_ANALYSIS returns the handle to a new EZ_CALCIUM_ANALYSIS or the handle to
%      the existing singleton*.
%
%      EZ_CALCIUM_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EZ_CALCIUM_ANALYSIS.M with the given input arguments.
%
%      EZ_CALCIUM_ANALYSIS('Property','Value',...) creates a new EZ_CALCIUM_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ez_calcium_analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ez_calcium_analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ez_calcium_analysis

% Last Modified by GUIDE v2.5 08-Jul-2019 14:56:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ez_calcium_analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @ez_calcium_analysis_OutputFcn, ...
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


% --- Executes just before ez_calcium_analysis is made visible.
function ez_calcium_analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ez_calcium_analysis (see VARARGIN)

% Choose default command line output for ez_calcium_analysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ez_calcium_analysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ez_calcium_analysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ez_motion_correction


% --- Executes on button press in two_channel_motion.
function two_channel_motion_Callback(hObject, eventdata, handles)
% hObject    handle to two_channel_motion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ROI_segment.
function ROI_segment_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in help_button.
function help_button_Callback(hObject, eventdata, handles)
% hObject    handle to help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
