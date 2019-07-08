function varargout = ez_roi_autoselect(varargin)
% EZ_ROI_AUTOSELECT MATLAB code for ez_roi_autoselect.fig
%      EZ_ROI_AUTOSELECT, by itself, creates a new EZ_ROI_AUTOSELECT or raises the existing
%      singleton*.
%
%      H = EZ_ROI_AUTOSELECT returns the handle to a new EZ_ROI_AUTOSELECT or the handle to
%      the existing singleton*.
%
%      EZ_ROI_AUTOSELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EZ_ROI_AUTOSELECT.M with the given input arguments.
%
%      EZ_ROI_AUTOSELECT('Property','Value',...) creates a new EZ_ROI_AUTOSELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ez_roi_autoselect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ez_roi_autoselect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ez_roi_autoselect

% Last Modified by GUIDE v2.5 08-Jul-2019 15:02:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ez_roi_autoselect_OpeningFcn, ...
                   'gui_OutputFcn',  @ez_roi_autoselect_OutputFcn, ...
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


% --- Executes just before ez_roi_autoselect is made visible.
function ez_roi_autoselect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ez_roi_autoselect (see VARARGIN)

% Choose default command line output for ez_roi_autoselect
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% Choose default command line output for ez_motion_correction
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Check if autoload exists
if exist('autosave_ez_autoroi.mat','file')==2 %Checks for autosave file
    load('autosave_ez_autoroi.mat'); %loads file into workspace
    write_autoroi(handles,autoroi,2) %Load settings into GUI
else
    ez_autoload_fail %Runs dialog box to find and move an autoload file
    if exist('autosave_ez_autoroi.mat','file')==2 %If no autoload selected, create default
        load('autosave_ez_autoroi.mat'); %loads file into workspace
        %Check if valid save file
        if exist('autoroi','var')~=1
            warning_text='The selected file is not a valid settings file.';
            ez_warning_small(warning_text);
            return
        else
            write_autoroi(handles,autoroi,2) %Load settings into GUI
        end
    end
end
% UIWAIT makes ez_roi_autoselect wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ez_roi_autoselect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in add_file_button.
function add_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
autoroi=parse_autoroi(handles,2);

[add_file,add_filepath]=uigetfile('*.tif','Choose file(s) to be processed.','MultiSelect','on');

if iscell(add_file)||ischar(add_file) %Checks to see if anything was selected
    
    %Checks to see if only one item was added 
    add_file=cellstr(add_file);
    
    %Check for repeats, if not, add to list
    for i = 1:length(add_file)
        full_add_file=[add_filepath char(add_file(i))]; %update full names
        
        if sum(ismember(autoroi.to_process_list,full_add_file))>0%If repeats, warning_text update
            warning_text=['File: ' char(add_file(i)) ' is already on the list.'];
            ez_warning_small(warning_text);
        else
            if isempty(autoroi.to_process_list)==1
                autoroi.to_process_list=cellstr(full_add_file); %Adds first item to list
                %Refresh list
                set(handles.to_process_list,'String',autoroi.to_process_list);
            else
                autoroi.to_process_list(end+1)=cellstr(full_add_file); %Adds to list
                %Refresh list
                set(handles.to_process_list,'String',autoroi.to_process_list);
            end
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
autoroi=parse_autoroi(handles,2);

%Get position of highlight
list_position=get(handles.to_process_list,'Value');

%Checks if anything is selected
if isempty(list_position)==1
    return
end

%Checks if anything is in the selected space
if isempty(autoroi.to_process_list)==1
    return
end

%Move position of highlight, if necessary
if list_position==size(autoroi.to_process_list,1) %Checks if in last position
    if list_position==1 %Checks if only one item is in list
        set(handles.to_process_list,'Value',1); %moves highlight to position 1
    else
        set(handles.to_process_list,'Value',list_position-1); %moves highlight up one position
    end
end

%Update internal list
autoroi.to_process_list(list_position)=[];

%Update GUI
set(handles.to_process_list,'String',autoroi.to_process_list);

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
%This function opens processed files.

%Get selected item position
list_position=get(handles.processed_list,'Value'); %Find location of highlight in list

%Checks if anything is selected
if isempty(list_position)==1
    return
end

%Get all file names
list_strings=get(handles.processed_list,'String');

%Checks if anything is in the selected space
if isempty(list_strings)==1
    return
end

%Checks if only one value is listed in list
if size (list_strings,1)==1
    list_cell{1,1}=list_strings; %Converts single value reading to be in single cell
else
    list_cell=list_strings;
end

%Get selected file name
file_string=cellstr(list_cell{list_position});

%Open file in the default program
system(file_string{1});

% --- Executes on button press in clear_button.
function clear_button_Callback(hObject, eventdata, handles)
% hObject    handle to clear_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%This button clears the list of processed files
set(handles.processed_list, 'String', ''); %Clear list
set(handles.processed_list, 'Value', 1); %Reset value of highlighter

% --- Executes on button press in run_button.
function run_button_Callback(hObject, eventdata, handles)
% hObject    handle to run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%This runs the motion correction

autoroi=parse_autoroi(handles,2); %read GUI

%Autosave
save('autosave_ez_autoroi.mat','autoroi');

%Move files to process highlight to first position
set(handles.processed_list,'Value',1);

%Find number of files to be run
file_num=size(get(handles.to_process_list,'String'),1);

%-----Initiatlize Progress variables-----
progress.to_process_size=file_num; %Check number of files in list

progress.current_file=0; %current file progress

progress.overall=0; %overall progress

progress.time_remaining=0; %estimated time remaining

progress.tic=tic; %mark start of motion correction process

progress.status_bar=[];

for i=1:file_num
    progress.current_file=i; %Marks current file number
    
    filename=autoroi.to_process_list{1};
    
    [progress]=ez_roi_autoselect_process(filename,autoroi,handles,progress);
    
    %-----------------Update lists and Autosave-------------------
    %Update files list
    if isempty(autoroi.processed_list{1})==1
        autoroi.processed_list{1}=progress.newfile;
    else
        autoroi.processed_list{end+1}=progress.newfile;
    end
    autoroi.to_process_list(1)=[];
    
    %Update files to process list
    set(handles.to_process_list,'String',autoroi.to_process_list');
    
    %Update processed Files list
    set(handles.processed_list,'String',autoroi.processed_list);
    drawnow %Updates GUI
    
    %Autosave
    save('autosave_ez_autoroi.mat','autoroi');
    %---------------End Update lists and Autosave-----------------
end

% --- Executes on button press in help_button.
function help_button_Callback(hObject, eventdata, handles)
% hObject    handle to help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function overall_progress_Callback(hObject, eventdata, handles)
% hObject    handle to overall_progress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of overall_progress as text
%        str2double(get(hObject,'String')) returns contents of overall_progress as a double


% --- Executes during object creation, after setting all properties.
function overall_progress_CreateFcn(hObject, eventdata, handles)
% hObject    handle to overall_progress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function time_remaining_Callback(hObject, eventdata, handles)
% hObject    handle to time_remaining (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_remaining as text
%        str2double(get(hObject,'String')) returns contents of time_remaining as a double


% --- Executes during object creation, after setting all properties.
function time_remaining_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_remaining (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function status_bar_Callback(hObject, eventdata, handles)
% hObject    handle to status_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of status_bar as text
%        str2double(get(hObject,'String')) returns contents of status_bar as a double


% --- Executes during object creation, after setting all properties.
function status_bar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to status_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function file_progress_Callback(hObject, eventdata, handles)
% hObject    handle to file_progress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of file_progress as text
%        str2double(get(hObject,'String')) returns contents of file_progress as a double


% --- Executes during object creation, after setting all properties.
function file_progress_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_progress (see GCBO)
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

%This function loads saved settings
autoroi_load_settings(handles)

% --- Executes on button press in save_settings_button.
function save_settings_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_settings_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%This function saves the settings for future use as a csv
autoroi_save_settings(handles)

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in workspace_save_box.
function workspace_save_box_Callback(hObject, eventdata, handles)
% hObject    handle to workspace_save_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of workspace_save_box


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


function autoroi_save_settings(handles)
%Manually save settings from GUI

[autoroi]=parse_autoroi(handles,1); %reads GUI

%Open save box
[filename,filepath] = uiputfile('*.mat');

%Check if anything was selected
if filename==0
    return
end

%Concatenate file name
full_filename=[filepath filename];

%Write to .mat file
save(full_filename,'autoroi');


function autoroi_load_settings(handles)
%Manually loads settings into GUI

%Open load box
[filename,filepath] = uigetfile('*.mat');

%Check if anything was selected
if filename==0
    return
end

%Concatenate file name
full_filename=[filepath filename];

%Load .mat file
load(full_filename);

%Check if valid save file
if exist('autoroi','var')~=1
    warning_text='The selected file is not a valid settings file.';
    ez_warning_small(warning_text);
    return
end

write_autoroi(handles,autoroi,1)


function [autoroi]=parse_autoroi(handles,parse_mode)
%Reads GUI, stores data into autoroi variable

%Template Source
autoroi.template_style=get(handles.template_style,'Value');

%Template Frames
autoroi.frames_box=get(handles.all_frames_box,'Value');
autoroi.frames_start=get(handles.frames_start,'String');
autoroi.frames_end=get(handles.frames_end,'String');

%Block Size
autoroi.block_size=get(handles.block_size,'String');

%Output
autoroi.output=get(handles.output_menu,'Value');

%Compression
autoroi.compression=get(handles.compression_menu,'Value');

%Save Template
autoroi.template=get(handles.template_save_box,'Value');

%Save .mat
autoroi.workspace=get(handles.workspace_save_box,'Value');

%Save Max
autoroi.max=get(handles.max_save_box,'Value');

if parse_mode==2
    %Files to process list
    autoroi.to_process_list=get(handles.to_process_list,'String');
    
    %Processed Files list
    autoroi.processed_list=cellstr(get(handles.processed_list,'String'));
end

function write_autoroi(handles,autoroi,write_mode)
%This function writes to the GUI
%write_mode=1 does not include the processed files list
%write_mode=2 includes the processed files list

%Template Source
set(handles.template_style,'Value',autoroi.template_style);

%Template Frames
set(handles.all_frames_box,'Value',autoroi.frames_box);
set(handles.frames_start,'String',autoroi.frames_start);
set(handles.frames_end,'String',autoroi.frames_end);

%Block Size
set(handles.block_size,'String',autoroi.block_size);

%Output
set(handles.output_menu,'Value',autoroi.output);

%Compression
set(handles.compression_menu,'Value',autoroi.compression);

%Save Template
set(handles.template_save_box,'Value',autoroi.template);

%Save .mat
set(handles.workspace_save_box,'Value',autoroi.workspace);

%Save Max
set(handles.max_save_box,'Value',autoroi.max);

if write_mode==2
    %Files to process list
    set(handles.to_process_list,'String',autoroi.to_process_list);
    
    %Processed Files list
    set(handles.processed_list,'String',autoroi.processed_list);
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
