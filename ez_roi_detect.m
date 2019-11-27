function varargout = ez_roi_detect(varargin)
% EZ_ROI_DETECT MATLAB code for ez_roi_detect.fig
%      EZ_ROI_DETECT, by itself, creates a new EZ_ROI_DETECT or raises the existing
%      singleton*.
%
%      H = EZ_ROI_DETECT returns the handle to a new EZ_ROI_DETECT or the handle to
%      the existing singleton*.
%
%      EZ_ROI_DETECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EZ_ROI_DETECT.M with the given input arguments.
%
%      EZ_ROI_DETECT('Property','Value',...) creates a new EZ_ROI_DETECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ez_roi_detect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ez_roi_detect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ez_roi_detect

% Last Modified by GUIDE v2.5 12-Nov-2019 16:36:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ez_roi_detect_OpeningFcn, ...
    'gui_OutputFcn',  @ez_roi_detect_OutputFcn, ...
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


% --- Executes just before ez_roi_detect is made visible.
function ez_roi_detect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ez_roi_detect (see VARARGIN)

filepath = fileparts([mfilename('fullpath') '.m']);
settings_file = fullfile(filepath,'ez_settings.mat');
if isfile(settings_file)
    if ismember('autoroi',who('-file',settings_file))
        load(fullfile(filepath,'ez_settings.mat'),'autoroi')
        write_autoroi(handles,autoroi,2)
    end
end

% Choose default command line output for ez_roi_detect
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ez_roi_detect wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ez_roi_detect_OutputFcn(hObject, eventdata, handles)
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

autoroi = parse_autoroi(handles,2);

supported_files = {'*.tif; *.tiff; *.avi;',...
    'Supported Files (.tif, .tiff, .avi)';...
    '*.*','All Files'};

[add_file,add_filepath] = uigetfile(supported_files,'Choose file(s) to be processed.','MultiSelect','on');

if iscell(add_file)||ischar(add_file) %Checks to see if anything was selected
    
    %Checks to see if only one item was added
    if ~iscell(add_file); add_file = cellstr(add_file); end
    
    %Check for repeats, if not, add to list
    for i = 1:length(add_file)
        full_add_file = [add_filepath add_file{i}]; %update full names
        
        if sum(ismember(autoroi.to_process_list,full_add_file)) > 0%If repeats, warning_text update
            warning_text = ['File: ' add_file{i} ' is already on the list.'];
            msgbox(warning_text,'Warning');
        else
            autoroi.to_process_list = vertcat(autoroi.to_process_list,cellstr(full_add_file)); %Adds to list
            set(handles.to_process_list,'String',autoroi.to_process_list); %Refresh list
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

autoroi = parse_autoroi(handles,2);

%Get position of highlight
list_position = get(handles.to_process_list,'Value');

%Checks if anything is in the internal list
if isempty(autoroi.to_process_list)
    return
end

if list_position == size(autoroi.to_process_list,1) %Checks if in last position
    if list_position ~= 1
        set(handles.to_process_list,'Value',list_position-1); %moves highlight up one position
    end
end

%Update internal list
if size(autoroi.to_process_list,1) == 1
    autoroi.to_process_list = blanks(0);
else
    autoroi.to_process_list(list_position) = '';
end

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
list_position = get(handles.processed_list,'Value'); %Find location of highlight in list

%Get all file names
list_strings = get(handles.processed_list,'String');

%Checks if only one value is listed in list
if size(list_strings,1) == 1
    list_cell{1,1} = list_strings; %Converts single value reading to be in single cell
else
    list_cell = list_strings;
end

%Get selected file name
file_string = cellstr(list_cell{list_position});

%Open file in the default program
%system(file_string{1});

%Open file into workspace
assignin('base','loadfile',file_string{1})
evalin('base','load(loadfile)');
evalin('base','clear loadfile');


% --- Executes on button press in clear_button.
function clear_button_Callback(hObject, eventdata, handles)
% hObject    handle to clear_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%This button clears the list of processed files
set(handles.processed_list, 'String', blanks(0)); %Clear list
set(handles.processed_list, 'Value', 1); %Reset value of highlighter

% --- Executes on button press in run_button.
function run_button_Callback(hObject, eventdata, handles)
% hObject    handle to run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This runs the roi detection

autoroi = parse_autoroi(handles,2); %read GUI

%Move files to process highlight to first position
set(handles.processed_list,'Value',1);

%Find number of files to be run
file_num = size(get(handles.to_process_list,'String'),1);

for i = 1:file_num
    filename = autoroi.to_process_list{1};
    disp(['Starting ROI detection for ' filename]);
    [fpath,fname] = fileparts(filename);
    filename_roi = fullfile(fpath,[fname '_roi.mat']);
    
    Y = read_file(filename);
    
    if ~isa(Y,'single');    Y = single(Y);  end
    
    [d1,d2,T] = size(Y); %Extract dimensions of dataset
    d = d1*d2; %Calculate total number of pixels
    
    %===========================Set Parameters=================================
    K = str2double(autoroi.input_components); %Check number of components to be found
    tau = round(str2double(autoroi.input_kernel)/2); %Std of gaussian kernel (size of neuron)
    p = autoroi.menu_regression-1; %From "Autoregression" in GUI.
    
    if autoroi.menu_init==1 %Check "Initialization" in GUI
        init_method='greedy';
    elseif autoroi.menu_init==2
        init_method='sparse_NMF';
    end
    
    if autoroi.menu_search==1 %Check "Search Method" in GUI
        search_method='ellipse';
    elseif autoroi.menu_search==2
        search_method='dilate';
    end
    
    if autoroi.menu_deconvolution==1 %Check "Deconvolution Method" in GUI
        deconv_method='constrained_foopsi';
        method='cvx';
    elseif autoroi.menu_deconvolution==2
        deconv_method='constrained_foopsi';
        method='spgl1';
    elseif autoroi.menu_deconvolution==3
        deconv_method='MCEM_foopsi';
        method='cvx';
    elseif autoroi.menu_deconvolution==4
        deconv_method='MCEM_foopsi';
        method='spgl1';
    elseif autoroi.menu_deconvolution==5
        deconv_method='MCMC';
        method='cvx';
    end
    
    %--------------Set Default Values-------------------
    options = CNMFSetParms(...                                          %Check CNMFSetParms.m for more details
        'd1',d1,'d2',d2,...                                             %Dimensions of datasets
        'ssub',str2double(autoroi.input_space_down),...                 %Spatial downsampling
        'tsub',str2double(autoroi.input_time_down),...                  %Temporal downsampling
        'init_method',init_method,...                                   %Initialization method
        'search_method',search_method,...                               %Search locations when updating spatial components
        'dist',3,...                                                    %Expansion factor of ellipse
        'deconv_method',deconv_method,...                               %Activity deconvolution method
        'method',method,...                                             %Method for solving convex problems
        'temporal_iter',str2double(autoroi.input_time_iteration),...    %Number of block-coordinate descent steps
        'fudge_factor',str2double(autoroi.input_fudge),...              %Bias correction for autoregression coefficients
        'merge_thr',str2double(autoroi.input_merge_thresh),...          %Merging threshold
        'p',p,...                                                       %Order of AR dynamics
        'nb',2,...                                                      %Number of background components
        'min_SNR',3,...                                                 %Minimum SNR threshold
        'cnn_thr',0.2,...                                               %Threshold for CNN classifier
        'bas_nonneg',0);                                                %Allow a negative baseline
    
    [P,Y] = preprocess_data(Y,p,options); %Data pre-processing
    %=============================End Set Parameters========================
    
    %============================Extract Components=========================
    [Ain, Cin, bin, fin, center] = initialize_components(Y, K, tau, options, P); %Initilize components
    Cn =  correlation_image(Y);
    
    if autoroi.manual_refine
        [Ain,Cin,~] = manually_refine_components(Y,Ain,Cin,center,Cn,tau,options); %Launch manual refinement
    end
    
    %-------------Update spatial and temporal components-------------------
    Yr = reshape(Y,d,T);
    [A,b,Cin] = update_spatial_components(Yr,Cin,fin,[Ain,bin],P,options);
    P.p = 0;    %Turn off autoregression dynamics temporarily for speed
    [C,f,P,S,YrA] = update_temporal_components(Yr,A,b,Cin,fin,P,options);
    %-----------End update spatial and temporal components-----------------
    
    %---------------Classify and Select-------------
    if autoroi.use_classifier
        
        % classify components
        rval_space = classify_comp_corr(Y,A,C,b,f,options);
        ind_corr = rval_space > options.space_thresh;           % components that pass the correlation test
        % this test will keep processes
        
        % further classification with cnn_classifier
        try  % matlab 2017b or later is needed
            [ind_cnn,~] = cnn_classifier(A,[d1,d2],'cnn_model',options.cnn_thr);
        catch
            ind_cnn = true(size(A,2),1);                        % components that pass the CNN classifier
        end
        
        % event exceptionality
        
        fitness = compute_event_exceptionality(C+YrA,options.N_samples_exc,options.robust_std);
        ind_exc = (fitness < options.min_fitness);
        
        % select components
        
        keep = (ind_corr | ind_cnn) & ind_exc;
        
        % display kept and discarded components
        figure;
        subplot(121); montage(extract_patch(A(:,keep),[d1,d2],[30,30]),'DisplayRange',[0,0.15]);
        title('Kept Components');
        subplot(122); montage(extract_patch(A(:,~keep),[d1,d2],[30,30]),'DisplayRange',[0,0.15])
        title('Discarded Components');
        
        A = A(:,keep);
        C = C(keep,:);
    end
    
    %------------------------Merge found components------------------------
    [Am,Cm,~,~,Pm,~] = merge_components(Yr,A,b,C,f,P,S,options); %Merge similar components
    
    %---------------Update components again--------------------
    Pm.p = p; %Restore autoregression dynamics value
    [A2,b2,C2] = update_spatial_components(Yr,Cm,f,[Am,b],Pm,options); %Update spatial components
    [C2,f2,P2,S2,~] = update_temporal_components(Yr,A2,b2,C2,f,Pm,options); %Update temporal components
    
    %===============================Plotting================================
    
    [A_or,C_or,S_or,P_or] = order_ROIs(A2,C2,S2,P2); %Reorder ROIs
    
    % Calculate traces to be saved
    [F_raw,F_inferred] = construct_traces(Yr,A_or,C_or,b2,f2,options);
    S_deconv = S_or;
    
    %------------ROI Map Plotting---------------
    if autoroi.check_contours
        figure; plot_contours(A_or,Cn,options,1);
    end
    
    %-----------Display Contours----------------
    if autoroi.check_map
        plot_components_GUI(Yr,A_or,C_or,b2,f2,Cn,options); %Plot individual components
    end
    
    %------Save .mat file----
    filename_roi = [filename(1:end-4) '_roi.mat'];
    if isfile(filename_roi)
        msgbox(['File ' filename_roi ' already exist. Will improvise a different file name...'],'Warning')
        filename_roi = [filename(1:end-4) '_roi_' datestr(now,30) '.mat'];
    end
    save(filename_roi,'Cn','A_or','C_or','S_or','P_or','F_raw','F_inferred','S_deconv','options');
    
    %Update internal file list
    if size(autoroi.to_process_list,1) == 1
        autoroi.to_process_list = blanks(0);
    else
        autoroi.to_process_list(1) = '';
    end
    autoroi.processed_list = vertcat(autoroi.processed_list,cellstr(filename_roi));
    
    %Update files to process list
    set(handles.to_process_list,'String',autoroi.to_process_list);
    
    %Update processed Files list
    set(handles.processed_list,'String',autoroi.processed_list);
    drawnow %Updates GUI
end

function [F_raw,F_inferred] = construct_traces(Y,A,C,b,f,options)
Y = double(Y);
b = double(b);
C = double(C);
f = double(f);
nA = full(sqrt(sum(A.^2))');
[K,~] = size(C);
A = A/spdiags(nA,0,K,K);
C = bsxfun(@times,C,nA(:));
AY = mm_fun(A,Y);

Y_r = (AY- (A'*A)*C - full(A'*b)*f) + C;
[~,Df] = extract_DF_F(Y,A,C,[],options,AY);

F_raw = Y_r ./ Df;
F_inferred = C ./ Df;

% --- Executes on button press in help_button.
function help_button_Callback(hObject, eventdata, handles)
% hObject    handle to help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filepath = fileparts([mfilename('fullpath') '.m']);
system([filepath '/HELP.pdf']); %Load documentation


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


% --- Executes on button press in check_contours.
function check_contours_Callback(hObject, eventdata, handles)
% hObject    handle to check_contours (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_contours


function autoroi_save_settings(handles)
%Manually save settings from GUI

autoroi=parse_autoroi(handles,1); %reads GUI

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
load(full_filename,'autoroi');

%Check if valid save file
if exist('autoroi','var')~=1
    warning_text='The selected file is not a valid settings file.';
    msgbox(warning_text,'Warning');
end

write_autoroi(handles,autoroi,1)


function autoroi = parse_autoroi(handles,parse_mode)
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
autoroi.manual_refine=get(handles.manual_refine,'Value');

%Display Contours
autoroi.check_contours=get(handles.check_contours,'Value');

%Display Map
autoroi.check_map=get(handles.check_map,'Value');

%Display Component Centers
autoroi.use_classifier=get(handles.use_classifier,'Value');

%============Read Input Boxes===========
%Estimated Components
autoroi.input_components=get(handles.input_components,'String');

%Merge Threshold
autoroi.input_merge_thresh=get(handles.input_merge_thresh,'String');

%Component Width
autoroi.input_kernel=get(handles.input_kernel,'String');

%Fudge Factor
autoroi.input_fudge=get(handles.input_fudge,'String');

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
    autoroi.processed_list=get(handles.processed_list,'String');
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
set(handles.manual_refine,'Value',autoroi.manual_refine);

%Display Contours
set(handles.check_contours,'Value',autoroi.check_contours);

%Display Kept ROIs
set(handles.check_map,'Value',autoroi.check_map);

%Display Center
set(handles.use_classifier,'Value',autoroi.use_classifier);

%==========Read Input Boxes=============
%Estimated Components
set(handles.input_components,'String',autoroi.input_components);

%Merge Threshold
set(handles.input_merge_thresh,'String',autoroi.input_merge_thresh);

%Component Width
set(handles.input_kernel,'String',autoroi.input_kernel);

%Fudge Factor
set(handles.input_fudge,'String',autoroi.input_fudge);

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


% --- Executes on button press in check_mat.
function check_mat_Callback(hObject, eventdata, handles)
% hObject    handle to check_mat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_mat


% --- Executes on button press in use_classifier.
function use_classifier_Callback(hObject, eventdata, handles)
% hObject    handle to use_classifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_classifier


% --- Executes on button press in manual_refine.
function manual_refine_Callback(hObject, eventdata, handles)
% hObject    handle to manual_refine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manual_refine


% --- Executes on button press in check_map.
function check_map_Callback(hObject, eventdata, handles)
% hObject    handle to check_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_map


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Initialization"" methods provide an initial estimate of spatial and temporal components. ""Greedy"" is recommended for videos of neuronal somata. It relies heavily on spatial components and generally runs much faster; ""Sparse NMF"" is recommended for more complex structures, such as dendrites, dendritic spines, or axons.","Help",'replace')


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Search Method"" determines the spatial components (location) of ROIs. ""Ellipse"" assumes components have an ellipsoid shape, such as for neuronal somata; ""Dilate"" can be used with either ellipsoid or non-ellipsoid ROIs, but generally takes longer.","Help",'replace')


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Deconvolution"" determines the method for translating activity-induced changes in the fluorescence intensity of the indicator into approximate firing rates.  If you are imaging an organism that does not produce action potentials, set this to the fastest setting available. Noise-constrained deconvolution methods include ""SPGL1 - Constrained foopsi"" and ""CVX - Constrained foopsi."" Both are also available through https://github.com/epnev/constrained-foopsi. ""SPGL1 - Constrained foopsi"" works well even with medium-to-low signal-to-noise traces. ""CVX - Constrained foopsi"" requires CVX and is not available in the standalone version of EZcalcium. It is typically the fastest method of deconvolution when working with high signal-to-noise traces.  It is available at http://cvxr.com/cvx/doc/install.html. ""MCMC"" is a fully-Bayesian deconvolution method that is computationally-intensive and is recommended when higher precision is required. ""MCEM"" alternates between the listed ""Constrained foopsi"" deconvolution and ""MCMC"" to update time constants. It is significantly faster than ""MCMC"" alone and is generally recommended when deconvolving calcium signals from cell somata.","Help",'replace')


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Autoregression"" is used to estimate the calcium indicator kinetics. ""Rise and Decay"" estimates both the rise and decay kinetics of the calcium indicator and incorporates them when extracting fluorescence traces and deconvolving the signal.  Due to the difficulty in detecting fast rise times, using ""Rise and Decay"" may result in overfit data if the imaging was performed at low temporal resolution (<16 Hz).  ""Decay"" estimates just the decay kinetics of the calcium indicator and is the recommended setting for lower temporal resolution imaging.  ""No Dynamics"" will produce only raw traces and will not perform deconvolution.","Help",'replace')


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Estimated Components"" is the estimated maximum number of components in the field of view. This must be set to a minimum value of 1.  If you want to perform fully manual ROI selection, set ""Estimated Components"" to 1 and check the box to enable ""Manual Initial Refinement"".  When the manual refinement step starts, delete the initial automatically detected ROI.  If no components are determined to be similar enough to be merged, the most likely result is that the number set for ""Estimated Components"" is the number that will be initially detected.","Help",'replace')


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Component Width"" is the estimated width, in pixels, of your components.  If you have a simple ROI shape, such as a cell soma, you can use the width of the entire ROI as your component width.","Help",'replace')


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Merge Threshold"" is the threshold at which two components will be merged into a single ROI. Components that share a correlation coefficient above ""Merge Threshold"" will be merged into a single ROI.","Help",'replace')


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Fudge Factor"" is useful for estimating time constants of very noisy data, in particular those with low temporal resolution (slow frame rate). The value indicates a multiplicative bias correction for time constants of each ROI during deconvolution.  ""Fudge Factor"" should generally be set to 0.95-1. A value of 1 indicates that no bias correction will be performed.","Help",'replace')


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Spatial Downsampling"" will downsample the spatial resolution of a video by a factor set here.  The value entered should be a positive integer. A value of 1 means that no downsampling will be performed.  This is useful for rapidly troubleshooting the settings on videos with a very large field of view.","Help",'replace')


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Temporal Downsampling"" is similar to Spatial Downsampling, except it downsamples the temporal resolution.  This is useful for optimizing settings on very long, high frame rate (>15 Hz) videos.","Help",'replace')


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Temporal Iterations"" is the number of iterations that will be performed to calculate the temporal components of ROIs. This should be set to at least 2 when not rapidly testing other parameters.","Help",'replace')


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Manual Initial Refinement"" adds an additional step following initialization to manually add or remove ROIs.  ROIs can also be removed in the step ""ROI Refinement.""  To fully automate the process, it is recommended to optimize your settings to slightly overestimate the number of ROIs and then remove erroneous ROIs later. This step is included as an option for particularly troublesome files and for those who prefer semi-automated ROI selection.  Initial spatial components will be displayed in a new figure.  The center of estimates in ROIs is highlighted with a magenta circle, surrounded by the boundary of the ROI. To manually add an ROI, left click with the mouse where you want to add the center of an ROI.  The boundary of the ROI will be automatically computed and drawn. To manually remove an ROI, right click on any ROI center. Hit the enter key to continue ROI detection.","Help",'replace')


% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Display ROI Contours"" generates a map with all the ROI boundaries, each labeled with the same ROI number as was used in the data.","Help",'replace')


% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Use Neuron Classifier"" uses correlation test and a CNN-based neuron classifier to exclude non-neuron ROIs.","Help",'replace')


% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Display ROI Browser"" shows extracted raw fluorescence data, the inferred trace generated, and the ROI shape and location.","Help",'replace')


% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("The ""Save Settings"" button allows the user to save all settings under a specific name of your choosing. Settings are saved as .mat files. The ""Load Settings"" button allows one to load all saved settings in future sessions.","Help",'replace')


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

autoroi = parse_autoroi(handles,2);
filepath = fileparts([mfilename('fullpath') '.m']);
if isfile(fullfile(filepath,'ez_settings.mat'))
    save(fullfile(filepath,'ez_settings.mat'),'autoroi','-append')
else
    save(fullfile(filepath,'ez_settings.mat'),'autoroi')
end

% Hint: delete(hObject) closes the figure
delete(hObject);
