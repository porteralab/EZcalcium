function varargout = ez_roi_detect_old(varargin)
% EZ_ROI_DETECT_OLD MATLAB code for ez_roi_detect_old.fig
%      EZ_ROI_DETECT_OLD, by itself, creates a new EZ_ROI_DETECT_OLD or raises the existing
%      singleton*.
%
%      H = EZ_ROI_DETECT_OLD returns the handle to a new EZ_ROI_DETECT_OLD or the handle to
%      the existing singleton*.
%
%      EZ_ROI_DETECT_OLD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EZ_ROI_DETECT_OLD.M with the given input arguments.
%
%      EZ_ROI_DETECT_OLD('Property','Value',...) creates a new EZ_ROI_DETECT_OLD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ez_roi_detect_old_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ez_roi_detect_old_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ez_roi_detect_old

% Last Modified by GUIDE v2.5 08-Jul-2019 15:05:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ez_roi_detect_old_OpeningFcn, ...
                   'gui_OutputFcn',  @ez_roi_detect_old_OutputFcn, ...
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


% --- Executes just before ez_roi_detect_old is made visible.
function ez_roi_detect_old_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ez_roi_detect_old (see VARARGIN)

% Choose default command line output for ez_roi_detect_old
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
% UIWAIT makes ez_roi_detect_old wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ez_roi_detect_old_OutputFcn(hObject, eventdata, handles) 
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
    
    [progress]=ez_roi_detect_process(filename,autoroi,handles,progress); 
    
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

% --- Executes on selection change in menu_regression.
function menu_regression_Callback(hObject, eventdata, handles)
% hObject    handle to menu_regression (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_regression contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_regression


% --- Executes during object creation, after setting all properties.
function menu_regression_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_regression (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_merge_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to input_merge_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_merge_thresh as text
%        str2double(get(hObject,'String')) returns contents of input_merge_thresh as a double


% --- Executes during object creation, after setting all properties.
function input_merge_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_merge_thresh (see GCBO)
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



function input_components_Callback(hObject, eventdata, handles)
% hObject    handle to input_components (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_components as text
%        str2double(get(hObject,'String')) returns contents of input_components as a double


% --- Executes during object creation, after setting all properties.
function input_components_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_components (see GCBO)
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


% --- Executes on button press in check_contours.
function check_contours_Callback(hObject, eventdata, handles)
% hObject    handle to check_contours (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_contours


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
%parse_mode=1 does not include the processed files list
%parse_mode=2 includes the processed files list

%==============Read Menus==============
%Initializaton
autoroi.menu_init=get(handles.menu_init,'Value');

%Search Method
autoroi.menu_search=get(handles.menu_search,'Value');

%Deconvolution
autoroi.menu_deconvolution=get(handles.menu_deconvolution,'Value');

%Autoregression
autoroi.menu_regression=get(handles.menu_regression,'Value');

%============Read Check Boxes===========
%Manual Refinement
autoroi.refine_components=get(handles.manual_refine,'Value');

%Save .mat
autoroi.check_mat=get(handles.check_mat,'Value');

%CSV Output
autoroi.check_csv=get(handles.check_csv,'Value');

%Display Contours
autoroi.check_contours=get(handles.check_contours,'Value');

%Display Kept ROIs
autoroi.show_kept=get(handles.check_kept,'Value');

%Display Merging Example
autoroi.check_merge=get(handles.check_merge,'Value');

%Display Component Centers
autoroi.check_center=get(handles.check_center,'Value');

%Save PDF
autoroi.check_pdf=get(handles.check_pdf,'Value');



%==========Read Frames to Analyze=======
%Start frame
autoroi.frames_start=get(handles.frames_start,'String');

%End frame
autoroi.frames_end=get(handles.frames_end,'String');

%All frames box
autoroi.frames_box=get(handles.frames_box,'Value');

%============Read Input Boxes===========
%Estimated Components
autoroi.input_components=get(handles.input_components,'String');

%Merge Threshold
autoroi.input_merge_thresh=get(handles.input_merge_thresh,'String');

%Gaussian Kernel
autoroi.input_kernel=get(handles.input_kernel,'String');

%Fudge Factor
autoroi.input_fudge=get(handles.input_fudge,'String');

%Contour Threshold
autoroi.input_contour_thresh=get(handles.input_contour_thresh,'String');

%Spatial Downsampling
autoroi.input_space_down=get(handles.input_space_down,'String');

%Temporal Downsampling
autoroi.input_time_down=get(handles.input_time_down,'String');

%Temporal Iterations
autoroi.input_time_iteration=get(handles.input_time_iteration,'String');

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

%==============Read Menus==============
%Initializaton
set(handles.menu_init,'Value',autoroi.menu_init);

%Search Method
set(handles.menu_search,'Value',autoroi.menu_search);

%Deconvolution
set(handles.menu_deconvolution,'Value',autoroi.menu_deconvolution);

%Autoregression
set(handles.menu_regression,'Value',autoroi.menu_regression);

%============Read Check Boxes===========
%Manual Refinement
if exist('autoroi.manual_refine','var')
    set(handles.manual_refine,'Value',autoroi.refine_components);
end

%Save .mat
set(handles.check_mat,'Value',autoroi.check_mat);

%CSV Output
set(handles.check_csv,'Value',autoroi.check_csv);

%Display Contours
set(handles.check_contours,'Value',autoroi.check_contours);

%Display Kept ROIs
if exist('autoroi.check_kept','var')
    set(handles.check_kept,'Value',autoroi.show_kept);
end

%Display Merging Example
set(handles.check_merge,'Value',autoroi.check_merge);

%Display Center
set(handles.check_center,'Value',autoroi.check_center);

%Save PDF (get rid of this later)
set(handles.check_pdf,'Value',autoroi.check_pdf);

%==========Read Frames to Analyze=======
%Start frame
set(handles.frames_start,'String',autoroi.frames_start);

%End frame
set(handles.frames_end,'String',autoroi.frames_end);

%All frames box
set(handles.frames_box,'Value',autoroi.frames_box);

%==========Read Input Boxes=============
%Estimated Components
set(handles.input_components,'String',autoroi.input_components);

%Merge Threshold
set(handles.input_merge_thresh,'String',autoroi.input_merge_thresh);

%Gaussian Kernel
set(handles.input_kernel,'String',autoroi.input_kernel);

%Fudge Factor
set(handles.input_fudge,'String',autoroi.input_fudge);

%Contour Threshold
set(handles.input_contour_thresh,'String',autoroi.input_contour_thresh);

%Spatial Downsampling
set(handles.input_space_down,'String',autoroi.input_space_down);

%Temporal Downsampling
set(handles.input_time_down,'String',autoroi.input_time_down);

%Temporal Iterations
set(handles.input_time_iteration,'String',autoroi.input_time_iteration);

if write_mode==2
    %Files to process list
    set(handles.to_process_list,'String',autoroi.to_process_list);
    
    %Processed Files list
    set(handles.processed_list,'String',autoroi.processed_list);
end



function input_kernel_Callback(hObject, eventdata, handles)
% hObject    handle to input_kernel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_kernel as text
%        str2double(get(hObject,'String')) returns contents of input_kernel as a double


% --- Executes during object creation, after setting all properties.
function input_kernel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_kernel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in menu_init.
function menu_init_Callback(hObject, eventdata, handles)
% hObject    handle to menu_init (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_init contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_init


% --- Executes during object creation, after setting all properties.
function menu_init_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_init (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in menu_search.
function menu_search_Callback(hObject, eventdata, handles)
% hObject    handle to menu_search (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_search contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_search


% --- Executes during object creation, after setting all properties.
function menu_search_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_search (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in menu_deconvolution.
function menu_deconvolution_Callback(hObject, eventdata, handles)
% hObject    handle to menu_deconvolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_deconvolution contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_deconvolution


% --- Executes during object creation, after setting all properties.
function menu_deconvolution_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_deconvolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_fudge_Callback(hObject, eventdata, handles)
% hObject    handle to input_fudge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_fudge as text
%        str2double(get(hObject,'String')) returns contents of input_fudge as a double


% --- Executes during object creation, after setting all properties.
function input_fudge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_fudge (see GCBO)
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



function input_contour_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to input_contour_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_contour_thresh as text
%        str2double(get(hObject,'String')) returns contents of input_contour_thresh as a double


% --- Executes during object creation, after setting all properties.
function input_contour_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_contour_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_merge.
function check_merge_Callback(hObject, eventdata, handles)
% hObject    handle to check_merge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_merge



function input_space_down_Callback(hObject, eventdata, handles)
% hObject    handle to input_space_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_space_down as text
%        str2double(get(hObject,'String')) returns contents of input_space_down as a double


% --- Executes during object creation, after setting all properties.
function input_space_down_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_space_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_time_down_Callback(hObject, eventdata, handles)
% hObject    handle to input_time_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_time_down as text
%        str2double(get(hObject,'String')) returns contents of input_time_down as a double


% --- Executes during object creation, after setting all properties.
function input_time_down_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_time_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_time_iteration_Callback(hObject, eventdata, handles)
% hObject    handle to input_time_iteration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_time_iteration as text
%        str2double(get(hObject,'String')) returns contents of input_time_iteration as a double


% --- Executes during object creation, after setting all properties.
function input_time_iteration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_time_iteration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_csv.
function check_csv_Callback(hObject, eventdata, handles)
% hObject    handle to check_csv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_csv



function frames_end_Callback(hObject, eventdata, handles)
% hObject    handle to frames_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frames_end as text
%        str2double(get(hObject,'String')) returns contents of frames_end as a double


% --- Executes during object creation, after setting all properties.
function frames_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frames_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function frames_start_Callback(hObject, eventdata, handles)
% hObject    handle to frames_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frames_start as text
%        str2double(get(hObject,'String')) returns contents of frames_start as a double


% --- Executes during object creation, after setting all properties.
function frames_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frames_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in frames_box.
function frames_box_Callback(hObject, eventdata, handles)
% hObject    handle to frames_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of frames_box


% --- Executes on button press in check_mat.
function check_mat_Callback(hObject, eventdata, handles)
% hObject    handle to check_mat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_mat


% --- Executes on button press in check_center.
function check_center_Callback(hObject, eventdata, handles)
% hObject    handle to check_center (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_center


% --- Executes on button press in check_pdf.
function check_pdf_Callback(hObject, eventdata, handles)
% hObject    handle to check_pdf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_pdf


% --- Executes on button press in manual_refine.
function manual_refine_Callback(hObject, eventdata, handles)
% hObject    handle to manual_refine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manual_refine


% --- Executes on button press in check_kept.
function check_kept_Callback(hObject, eventdata, handles)
% hObject    handle to check_kept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_kept
