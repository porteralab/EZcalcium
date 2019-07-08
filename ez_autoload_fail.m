function varargout = ez_autoload_fail(varargin)
% EZ_AUTOLOAD_FAIL MATLAB code for ez_autoload_fail.fig
%      EZ_AUTOLOAD_FAIL, by itself, creates a new EZ_AUTOLOAD_FAIL or raises the existing
%      singleton*.
%
%      H = EZ_AUTOLOAD_FAIL returns the handle to a new EZ_AUTOLOAD_FAIL or the handle to
%      the existing singleton*.
%
%      EZ_AUTOLOAD_FAIL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EZ_AUTOLOAD_FAIL.M with the given input arguments.
%
%      EZ_AUTOLOAD_FAIL('Property','Value',...) creates a new EZ_AUTOLOAD_FAIL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ez_autoload_fail_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ez_autoload_fail_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ez_autoload_fail

% Last Modified by GUIDE v2.5 08-Jul-2019 14:45:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ez_autoload_fail_OpeningFcn, ...
                   'gui_OutputFcn',  @ez_autoload_fail_OutputFcn, ...
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


% --- Executes just before ez_autoload_fail is made visible.
function ez_autoload_fail_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ez_autoload_fail (see VARARGIN)

% Choose default command line output for ez_autoload_fail
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

autosave_file=varargin{1};

if ~exist('autosave_file','var')
    autosave_file='unknown_autosave_file';
end
save_string=sprintf(['The autosave file\n' autosave_file '\ncould not be found in the\ncurrent directory. \nChoose to locate the\nfile or use default settings.']);
set(handles.autosave_text,'String',save_string);



% UIWAIT makes ez_autoload_fail wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ez_autoload_fail_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in find_file_button.
function find_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to find_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global warning_text

if ~exist ('autosave_file','var')
    autosave_file='unknown_autosave_file.mat';
end

%Open load box
[filename,filepath] = uigetfile('*.mat',['Please locate ' autosave_file]);

%Check if anything was selected
if filename==0
    return
end

%Concatenate file name
full_filename=[filepath filename];

%Load .mat file
load(full_filename);

%Check if valid save file
if exist('save_file','var')~=1
    warning_text='The selected file is not a valid autosave file. Default settings will be used.';
    close;
    ez_warning_small;
    return
end

%Save .mat in current folder
save(autosave_file,'save_file');
%'autosave_ez_motcor.mat'

close;

% --- Executes on button press in use_default_button.
function use_default_button_Callback(hObject, eventdata, handles)
% hObject    handle to use_default_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
