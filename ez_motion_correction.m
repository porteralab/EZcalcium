function varargout = ez_motion_correction(varargin)
% EZ_MOTION_CORRECTION MATLAB code for ez_motion_correction.fig
%      EZ_MOTION_CORRECTION, by itself, creates a new EZ_MOTION_CORRECTION or raises the existing
%      singleton*.
%
%      H = EZ_MOTION_CORRECTION returns the handle to a new EZ_MOTION_CORRECTION or the handle to
%      the existing singleton*.
%
%      EZ_MOTION_CORRECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EZ_MOTION_CORRECTION.M with the given input arguments.
%
%      EZ_MOTION_CORRECTION('Property','Value',...) creates a new EZ_MOTION_CORRECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ez_motion_correction_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ez_motion_correction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ez_motion_correction

% Last Modified by GUIDE v2.5 09-Nov-2019 17:30:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ez_motion_correction_OpeningFcn, ...
                   'gui_OutputFcn',  @ez_motion_correction_OutputFcn, ...
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


% --- Executes just before ez_motion_correction is made visible.
function ez_motion_correction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ez_motion_correction (see VARARGIN)

% Choose default command line output for ez_motion_correction
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ez_motion_correction wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ez_motion_correction_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in add_button.
function add_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

motcor = parse_motcor(handles,2);

supported_files = {'*.tif; *.tiff; *.mat; *.avi;',...
    'Supported Files (.tif, .tiff, .mat, .avi)';...
    '*.*','All Files'};

[add_file,add_filepath] = uigetfile(supported_files,'Choose file(s) to be processed.','MultiSelect','on');

if iscell(add_file)||ischar(add_file) %Checks to see if anything was selected
    
    %Checks to see if only one item was added 
    if ~iscell(add_file); add_file = cellstr(add_file); end
    
    %Check for repeats, if not, add to list
    for i = 1:length(add_file)
        full_add_file = [add_filepath add_file{i}]; %update full names
        
        if sum(ismember(motcor.to_process_list,full_add_file)) > 0%If repeats, warning_text update
            warning_text = ['File: ' add_file{i} ' is already on the list.'];
            ez_warning_small(warning_text);
        else
            motcor.to_process_list = vertcat(motcor.to_process_list,cellstr(full_add_file)); %Adds to list
            set(handles.to_process_list,'String',motcor.to_process_list); %Refresh list
        end
    end
end


% --- Executes on selection change in to_process_list.
function to_process_list_Callback(hObject, eventdata, handles)
% hObject    handle to to_process_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns to_process_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from to_process_list


% --- Executes during object creation, after setting all properties.
function to_process_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to to_process_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in remove_button.
function remove_button_Callback(hObject, eventdata, handles)
% hObject    handle to remove_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

motcor = parse_motcor(handles,2);

%Get position of highlight
list_position = get(handles.to_process_list,'Value');

%Checks if anything is in the selected space
if isempty(motcor.to_process_list) == 1
    return
end

if list_position == size(motcor.to_process_list,1) %Checks if in last position
    if list_position == 1 %Checks if only one item is in list
        set(handles.to_process_list,'Value',1); %moves highlight to position 1
    else
        set(handles.to_process_list,'Value',list_position-1); %moves highlight up one position
    end
end

%Update internal list
if size(motcor.to_process_list,1) == 1
    motcor.to_process_list = blanks(0);
else
    motcor.to_process_list(list_position) = '';
end

%Update GUI
set(handles.to_process_list,'String',motcor.to_process_list);


% --- Executes on selection change in processed_list.
function processed_list_Callback(hObject, eventdata, handles)
% hObject    handle to processed_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns processed_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from processed_list


% --- Executes during object creation, after setting all properties.
function processed_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processed_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in open_button.
function open_button_Callback(hObject, eventdata, handles)
% hObject    handle to open_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get selected item position
list_position = get(handles.processed_list,'Value'); %Find location of highlight in list

%Checks if anything is selected
if isempty(list_position) == 1
    return
end

%Get all file names
list_strings = get(handles.processed_list,'String');

%Checks if only one value is listed in list
if size (list_strings,1) == 1
    list_cell{1,1} = list_strings; %Converts single value reading to be in single cell
else
    list_cell = list_strings;
end

%Get selected file name
file_string = cellstr(list_cell{list_position});
file_string = file_string{1};

%Open file in the default program or load into matlab if .mat file
if strcmp((file_string(end-3:end)),'.mat') 
    disp(['Loading ' file_string ' into base workspace']);
    load(file_string);
    assignin('base','image_data',image_data);
    disp('Loading complete!');
else
    system(file_string);
end


% --- Executes on button press in clear_button.
function clear_button_Callback(hObject, eventdata, handles)
% hObject    handle to clear_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.processed_list, 'String', blanks(0)); %Clear list
set(handles.processed_list, 'Value', 1); %Reset value of highlighter


% --- Executes on button press in run_button.
function run_button_Callback(hObject, eventdata, handles)
% hObject    handle to run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This runs the motion correction

motcor = parse_motcor(handles,2); %read GUI

%Move files to process highlight to first position
set(handles.processed_list,'Value',1);

%Find number of files to be run
file_num = size(get(handles.to_process_list,'String'),1);

for i = 1:file_num
    filename = motcor.to_process_list{1};
    disp(['Starting motion correction for ' filename]);
    FOV = size(read_file(filename,1,1));
    
    % Set options
    switch motcor.grid_size
        case 1
            grid_size = 32;
        case 2
            grid_size = 48;
        case 3
            grid_size = 64;
        case 4
            grid_size = 96;
        case 5
            grid_size = 128;
    end
    us_fac = str2double(motcor.us_fac);
    max_shift = str2double(motcor.max_shift);
    init_batch = str2double(motcor.initial_batch_size);
    bin_width = str2double(motcor.bin_width);
    [fpath,fname] = fileparts(filename);
    filename_mcor = fullfile(fpath,[fname '_mcor.tif']);
        
    if motcor.non_rigid == 0
        options = NoRMCorreSetParms(...
            'd1',FOV(1),...
            'd2',FOV(2),...
            'us_fac',us_fac,...
            'max_shift',max_shift,...
            'init_batch',init_batch,...
            'bin_width',bin_width,...
            'output_type','tiff',... %currently hard-coded to save tiff
            'tiff_filename',filename_mcor);
    elseif motcor.non_rigid == 1
        options = NoRMCorreSetParms(...
            'd1',FOV(1),...
            'd2',FOV(2),...
            'grid_size',[grid_size,grid_size],...
            'us_fac',us_fac,...
            'max_shift',max_shift,...
            'init_batch',init_batch,...
            'bin_width',bin_width,...
            'output_type','tiff',...
            'tiff_filename',filename_mcor);
    end
    
    % Run motion correction
    normcorre_batch_even(filename,options)
    
    % Update file list
    if isempty(motcor.processed_list{1}) == 1
        motcor.processed_list{1} = filename_mcor;
    else
        motcor.processed_list{end+1} = filename_mcor;
    end
    motcor.to_process_list(1) = [];
   
    
    %Update files to process list
    set(handles.to_process_list,'String',motcor.to_process_list');
    
    %Update processed Files list
    set(handles.processed_list,'String',motcor.processed_list);
    drawnow %Updates GUI
end


% --- Executes on button press in help_button.
function help_button_Callback(hObject, eventdata, handles)
% hObject    handle to help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Open documentation file in the default program
filepath = fileparts([mfilename('fullpath') '.m']);
system([filepath '/HELP.pdf']); %Load documentation



function initial_batch_size_Callback(hObject, eventdata, handles)
% hObject    handle to initial_batch_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of initial_batch_size as text
%        str2double(get(hObject,'String')) returns contents of initial_batch_size as a double


% --- Executes during object creation, after setting all properties.
function initial_batch_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to initial_batch_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in grid_size_popupmenu.
function grid_size_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to grid_size_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns grid_size_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from grid_size_popupmenu


% --- Executes during object creation, after setting all properties.
function grid_size_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to grid_size_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in non_rigid_checkbox.
function non_rigid_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to non_rigid_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of non_rigid_checkbox



function max_shift_Callback(hObject, eventdata, handles)
% hObject    handle to max_shift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_shift as text
%        str2double(get(hObject,'String')) returns contents of max_shift as a double


% --- Executes during object creation, after setting all properties.
function max_shift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_shift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bin_width_Callback(hObject, eventdata, handles)
% hObject    handle to bin_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bin_width as text
%        str2double(get(hObject,'String')) returns contents of bin_width as a double


% --- Executes during object creation, after setting all properties.
function bin_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bin_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_settings_button.
function load_settings_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_settings_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

motcor_load_settings(handles)


% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

motcor_save_settings(handles)


function us_fac_Callback(hObject, eventdata, handles)
% hObject    handle to us_fac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of us_fac as text
%        str2double(get(hObject,'String')) returns contents of us_fac as a double


% --- Executes during object creation, after setting all properties.
function us_fac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to us_fac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function motcor_save_settings(handles)
%Manually save settings from GUI

[motcor] = parse_motcor(handles,1); %reads GUI

%Open save box
[filename,filepath] = uiputfile('*.mat');

%Check if anything was selected
if filename == 0
    return
end

%Concatenate file name
full_filename = [filepath filename];

%Write to .mat file
save(full_filename,'motcor');


function motcor_load_settings(handles)
%Manually loads settings into GUI

%Open load box
[filename,filepath] = uigetfile('*.mat');

%Check if anything was selected
if filename == 0
    return
end

%Concatenate file name
full_filename = [filepath filename];

%Load .mat file
load(full_filename);

%Check if valid save file
if exist('motcor','var') ~= 1
    warning_text = 'The selected file is not a valid settings file.';
    ez_warning_small(warning_text);
    return
end

write_motcor(handles,motcor,1)


function [motcor] = parse_motcor(handles,parse_mode)
%Reads GUI, stores data into motcor variable

motcor.non_rigid = get(handles.non_rigid_checkbox,'Value');
motcor.grid_size = get(handles.grid_size_popupmenu,'Value');
motcor.us_fac = get(handles.us_fac,'String');
motcor.max_shift = get(handles.max_shift,'String');
motcor.initial_batch_size = get(handles.initial_batch_size,'String');
motcor.bin_width = get(handles.bin_width,'String');

if parse_mode == 2
    %Files to process list
    motcor.to_process_list = get(handles.to_process_list,'String');
    
    %Processed Files list
    motcor.processed_list = cellstr(get(handles.processed_list,'String'));
end

function write_motcor(handles,motcor,write_mode)
%This function writes to the GUI
%write_mode = 1 does not include the processed files list
%write_mode = 2 includes the processed files list

set(handles.non_rigid_checkbox,'Value',motcor.non_rigid);
set(handles.grid_size_popupmenu,'Value',motcor.grid_size);
set(handles.us_fac,'String',motcor.us_fac);
set(handles.max_shift,'String',motcor.max_shift);
set(handles.initial_batch_size,'String',motcor.initial_batch_size);
set(handles.bin_width,'String',motcor.bin_width);

if write_mode == 2
    %Files to process list
    set(handles.to_process_list,'String',motcor.to_process_list);
    
    %Processed Files list
    set(handles.processed_list,'String',motcor.processed_list);
end


% --- Executes on button press in non_rigid_help.
function non_rigid_help_Callback(hObject, eventdata, handles)
% hObject    handle to non_rigid_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("Whether to use non-rigid motion correction or not. Non-rigid motion correction splits the field of view into a number of overlapping patches to correct for within-frame motion artifacts. While this can give more accurate results, it is considerably slower than rigid motion correction. The option ""Grid Size"" will be ignored if this is not selected.","Help",'replace')


% --- Executes on button press in grid_size_help.
function grid_size_help_Callback(hObject, eventdata, handles)
% hObject    handle to grid_size_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Grid Size"" defines the size of each patches in pixels when using non-rigid motion correction. It will have no effect if ""Non-rigid Motion Correction"" is not selected.","Help",'replace')


% --- Executes on button press in us_fac_help.
function us_fac_help_Callback(hObject, eventdata, handles)
% hObject    handle to us_fac_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Upsampling Factor"" defines the upsampling factor for subpixel registration.","Help",'replace')


% --- Executes on button press in max_shift_help.
function max_shift_help_Callback(hObject, eventdata, handles)
% hObject    handle to max_shift_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Max Shift"" defines the maximum rigid shift in pixels allowed in each direction.","Help",'replace')


% --- Executes on button press in initial_batch_size_help.
function initial_batch_size_help_Callback(hObject, eventdata, handles)
% hObject    handle to initial_batch_size_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Initial Batch Size"" defines the number of frames from the beginning used for calculating the initial template.","Help",'replace')


% --- Executes on button press in bin_width_help.
function bin_width_help_Callback(hObject, eventdata, handles)
% hObject    handle to bin_width_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Bin Width"" defines the number of frames of each bin, over which the registered frames are averaged to update the template.","Help",'replace')


% --- Executes on button press in settings_help.
function settings_help_Callback(hObject, eventdata, handles)
% hObject    handle to settings_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("The ""Save Settings"" button allows the user to save all settings under a specific name of your choosing. Settings are saved as .mat files. The ""Load Settings"" button allows one to load all saved settings in future sessions.","Help",'replace')
