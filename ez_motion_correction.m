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

% Last Modified by GUIDE v2.5 08-Jul-2019 14:59:27

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

%Compiler code: mcc -mv -R -singleCompThread ez_motion_correction.m

% Choose default command line output for ez_motion_correction
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

autosave_file='autosave_ez_motcor.mat'; %Name autosave file

%Check if autoload exists
if exist('autosave_ez_motcor.mat','file')==2 %Checks for autosave file
    load('autosave_ez_motcor.mat'); %loads file into workspace
    write_motcor(handles,motcor,2) %Load settings into GUI
else
    ez_autoload_fail(autosave_file) %Runs dialog box to find and move an autoload file
    if exist('autosave_ez_motcor.mat','file')==2 %If no autoload selected, create default
        load('autosave_ez_motcor.mat'); %loads file into workspace
        %Check if valid save file
        if exist('motcor','var')~=1
            warning_text='The selected file is not a valid settings file.';
            ez_warning_small(warning_text);
            return
        else
            write_motcor(handles,motcor,2) %Load settings into GUI
        end
    end
end

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

%This function adds files to the To Process list
motcor=parse_motcor(handles,2);

supported_files={'*.tif; *.tiff; *.mat; *.avi;',...
    'Supported Files (.tif, .tiff, .mat, .avi)';...
    '*.*','All Files'};

%[add_file,add_filepath]=uigetfile('*.tif','Choose file(s) to be processed.','MultiSelect','on');
[add_file,add_filepath,test]=uigetfile(supported_files,'Choose file(s) to be processed.','MultiSelect','on');

if iscell(add_file)||ischar(add_file) %Checks to see if anything was selected
    
    %Checks to see if only one item was added 
    add_file=cellstr(add_file);
    
    %Check for repeats, if not, add to list
    for i = 1:length(add_file)
        full_add_file=[add_filepath char(add_file(i))]; %update full names
        
        if sum(ismember(motcor.to_process_list,full_add_file))>0%If repeats, warning_text update
            warning_text=['File: ' char(add_file(i)) ' is already on the list.'];
            ez_warning_small(warning_text);
        else
            if isempty(motcor.to_process_list)==1
                motcor.to_process_list=cellstr(full_add_file); %Adds first item to list
                %Refresh list
                set(handles.to_process_list,'String',motcor.to_process_list);
            else
                motcor.to_process_list(end+1)=cellstr(full_add_file); %Adds to list
                %Refresh list
                set(handles.to_process_list,'String',motcor.to_process_list);
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

motcor=parse_motcor(handles,2);

%Get position of highlight
list_position=get(handles.to_process_list,'Value');

%Checks if anything is selected
if isempty(list_position)==1
    return
end

%Checks if anything is in the selected space
if isempty(motcor.to_process_list)==1
    return
end

%Move position of highlight, if necessary
if list_position==size(motcor.to_process_list,1) %Checks if in last position
    if list_position==1 %Checks if only one item is in list
        set(handles.to_process_list,'Value',1); %moves highlight to position 1
    else
        set(handles.to_process_list,'Value',list_position-1); %moves highlight up one position
    end
end

%Update internal list
motcor.to_process_list(list_position)=[];

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
else
    set(handles.status_bar, 'String', 'Opening selected file');
    drawnow;
end

%Checks if only one value is listed in list
if size (list_strings,1)==1
    list_cell{1,1}=list_strings; %Converts single value reading to be in single cell
else
    list_cell=list_strings;
end

%Get selected file name
file_string=cellstr(list_cell{list_position});
file_string=file_string{1};

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

%This button clears the list of processed files
set(handles.processed_list, 'String', ''); %Clear list
set(handles.processed_list, 'Value', 1); %Reset value of highlighter



% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%This function saves the settings for future use as a csv
motcor_save_settings(handles)


% --- Executes on button press in load_settings_button.
function load_settings_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_settings_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%This function loads saved settings
motcor_load_settings(handles)


% --- Executes on button press in run_button.
function run_button_Callback(hObject, eventdata, handles)
% hObject    handle to run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%This runs the motion correction

motcor=parse_motcor(handles,2); %read GUI

%Autosave
save('autosave_ez_motcor.mat','motcor');

%Move files to process highlight to first position
set(handles.processed_list,'Value',1);

%Find number of files to be run
file_num=size(get(handles.to_process_list,'String'),1);

%-----Initiatlize Progress variables-----
progress.to_process_size=file_num; %Check number of files in list

progress.current_file=0; %current file progress

progress.current_iteration=1;

progress.overall=0; %overall progress

progress.time_remaining=0; %estimated time remaining

progress.tic=tic; %mark start of motion correction process

progress.status_bar=[];

%--------Initialize timing variables, if needed--------
% if exist('motcor.load_time_relative','var')==0
%     motcor.load_time_relative=[14 14 14 14 14]; %initial estimates of relative time needed per step
% end
% if exist('motcor.align_time_relative','var')==0
%     motcor.align_time_relative=[35 35 35 35 35];
% end
% if exist('motcor.save_time_relative','var')==0
%     motcor.save_time_relative=[50 50 50 50 50];
% end

for i=1:file_num
    progress.current_file=i; %Marks current file number
    
    filename=motcor.to_process_list{1};
    disp('Starting motion correction!');
    [progress,motcor]=ez_motion_correction_process(filename,motcor,handles,progress);
    
    %-----------------Update lists and Autosave-------------------
    %Update files list
    if isempty(motcor.processed_list{1})==1
        motcor.processed_list{1}=progress.newfile;
    else
        motcor.processed_list{end+1}=progress.newfile;
    end
    motcor.to_process_list(1)=[];
   
    
    %Update files to process list
    set(handles.to_process_list,'String',motcor.to_process_list');
    
    %Update processed Files list
    set(handles.processed_list,'String',motcor.processed_list);
    drawnow %Updates GUI
    
    %Autosave
    save('autosave_ez_motcor.mat','motcor');
    %---------------End Update lists and Autosave-----------------
end

% --- Executes on selection change in template_style.
function template_style_Callback(hObject, eventdata, handles)
% hObject    handle to template_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns template_style contents as cell array
%        contents{get(hObject,'Value')} returns selected item from template_style


% --- Executes during object creation, after setting all properties.
function template_style_CreateFcn(hObject, eventdata, handles)
% hObject    handle to template_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
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


% --- Executes on button press in help_button.
function help_button_Callback(hObject, eventdata, handles)
% hObject    handle to help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Open documentation file in the default program
system('Calcium_Analysis_Documentation.pdf');


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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


% --- Executes on button press in all_frames_box.
function all_frames_box_Callback(hObject, eventdata, handles)
% hObject    handle to all_frames_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of all_frames_box



function block_size_Callback(hObject, eventdata, handles)
% hObject    handle to block_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of block_size as text
%        str2double(get(hObject,'String')) returns contents of block_size as a double


% --- Executes during object creation, after setting all properties.
function block_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to block_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in template_save_box.
function template_save_box_Callback(hObject, eventdata, handles)
% hObject    handle to template_save_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of template_save_box


% --- Executes on selection change in compression_menu.
function compression_menu_Callback(hObject, eventdata, handles)
% hObject    handle to compression_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns compression_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from compression_menu


% --- Executes during object creation, after setting all properties.
function compression_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to compression_menu (see GCBO)
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


% --- Executes on selection change in output_menu.
function output_menu_Callback(hObject, eventdata, handles)
% hObject    handle to output_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns output_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from output_menu


% --- Executes during object creation, after setting all properties.
function output_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in max_save_box.
function max_save_box_Callback(hObject, eventdata, handles)
% hObject    handle to max_save_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of max_save_box


function motcor_save_settings(handles)
%Manually save settings from GUI

[motcor]=parse_motcor(handles,1); %reads GUI

%Open save box
[filename,filepath] = uiputfile('*.mat');

%Check if anything was selected
if filename==0
    return
end

%Concatenate file name
full_filename=[filepath filename];

%Write to .mat file
save(full_filename,'motcor');


function motcor_load_settings(handles)
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
if exist('motcor','var')~=1
    warning_text='The selected file is not a valid settings file.';
    ez_warning_small(warning_text);
    return
end

write_motcor(handles,motcor,1)


function [motcor]=parse_motcor(handles,parse_mode)
%Reads GUI, stores data into motcor variable 

%Template Source
motcor.template_style=get(handles.template_style,'Value');

%Template Frames
motcor.frames_box=get(handles.all_frames_box,'Value');
motcor.frames_start=str2double(get(handles.frames_start,'String'));
motcor.frames_end=str2double(get(handles.frames_end,'String'));

%BG Subtraction
motcor.background_subtract=get(handles.bg_sub_menu,'Value');

%Iterations
motcor.iterations=get(handles.iterations,'String');

%Batch Size
motcor.batch=get(handles.batch,'String');

%Block Size
motcor.block_size=get(handles.block_size,'String');

%Output
motcor.output=get(handles.output_menu,'Value');

%Compression
motcor.compression=get(handles.compression_menu,'Value');

%Save Template
motcor.template=get(handles.template_save_box,'Value');

%Save .mat
% motcor.workspace=get(handles.workspace_save_box,'Value');

%Save Max
motcor.max=get(handles.max_save_box,'Value');

%Load Timing
motcor.load_time_relative=str2num(get(handles.load_time,'String'));

%Alignment Timing
motcor.align_time_relative=str2num(get(handles.align_time,'String'));

%Save Timing
motcor.save_time_relative=str2num(get(handles.save_time,'String'));

if parse_mode==2
    %Files to process list
    motcor.to_process_list=get(handles.to_process_list,'String');
    
    %Processed Files list
    motcor.processed_list=cellstr(get(handles.processed_list,'String'));
end

function write_motcor(handles,motcor,write_mode)
%This function writes to the GUI
%write_mode=1 does not include the processed files list
%write_mode=2 includes the processed files list

%Template Source
set(handles.template_style,'Value',motcor.template_style);

%Template Frames
set(handles.all_frames_box,'Value',motcor.frames_box);
set(handles.frames_start,'String',motcor.frames_start);
set(handles.frames_end,'String',motcor.frames_end);

%BG Subtraction
if isfield(handles,'bg_sub_menu')
    set(handles.bg_sub_menu,'Value',motcor.background_subtract);
end

%Iterations
if isfield(handles,'iterations')
    set(handles.iterations,'String',motcor.iterations);
end

%Batch Size
if isfield(motcor,'batch')
    
    set(handles.batch,'String',motcor.batch);
end

%Block Size
set(handles.block_size,'String',motcor.block_size);

%Output
set(handles.output_menu,'Value',motcor.output);

%Compression
set(handles.compression_menu,'Value',motcor.compression);

%Save Template
set(handles.template_save_box,'Value',motcor.template);

%Save .mat
% set(handles.workspace_save_box,'Value',motcor.workspace);

%Save Max
set(handles.max_save_box,'Value',motcor.max);

%Load Timing
if isfield(motcor,'load_time_relative')
set(handles.load_time,'String',mat2str(motcor.load_time_relative));
end

%Alignment Timing
if isfield(motcor,'align_time_relative')
set(handles.align_time,'String',mat2str(motcor.align_time_relative));
end

%Save Timing
if isfield(motcor,'save_time_relative')
set(handles.save_time,'String',mat2str(motcor.save_time_relative));
end


if write_mode==2
    %Files to process list
    set(handles.to_process_list,'String',motcor.to_process_list);
    
    %Processed Files list
    set(handles.processed_list,'String',motcor.processed_list);
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



function iterations_Callback(hObject, eventdata, handles)
% hObject    handle to iterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iterations as text
%        str2double(get(hObject,'String')) returns contents of iterations as a double


% --- Executes during object creation, after setting all properties.
function iterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in bg_sub_menu.
function bg_sub_menu_Callback(hObject, eventdata, handles)
% hObject    handle to bg_sub_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns bg_sub_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bg_sub_menu


% --- Executes during object creation, after setting all properties.
function bg_sub_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bg_sub_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function current_iteration_Callback(hObject, eventdata, handles)
% hObject    handle to current_iteration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of current_iteration as text
%        str2double(get(hObject,'String')) returns contents of current_iteration as a double


% --- Executes during object creation, after setting all properties.
function current_iteration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_iteration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reset_timing.
function reset_timing_Callback(hObject, eventdata, handles)
% hObject    handle to reset_timing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.load_time,'String', '[3 3 3 3 3]');
set(handles.align_time,'String', '[40 40 40 40 40]');
set(handles.save_time,'String', '[56 56 56 56 56]');
set(handles.status_bar,'String', 'Timing estimates reset!');
drawnow;



function batch_Callback(hObject, eventdata, handles)
% hObject    handle to batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of batch as text
%        str2double(get(hObject,'String')) returns contents of batch as a double


% --- Executes during object creation, after setting all properties.
function batch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
