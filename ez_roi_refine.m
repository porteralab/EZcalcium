function varargout = ez_roi_refine(varargin)
% EZ_ROI_REFINE MATLAB code for ez_roi_refine.fig
%      EZ_ROI_REFINE, by itself, creates a new EZ_ROI_REFINE or raises the existing
%      singleton*.
%
%      H = EZ_ROI_REFINE returns the handle to a new EZ_ROI_REFINE or the handle to
%      the existing singleton*.
%
%      EZ_ROI_REFINE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EZ_ROI_REFINE.M with the given input arguments.
%
%      EZ_ROI_REFINE('Property','Value',...) creates a new EZ_ROI_REFINE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ez_roi_refine_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ez_roi_refine_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ez_roi_refine

% Last Modified by GUIDE v2.5 30-Jul-2019 11:45:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ez_roi_refine_OpeningFcn, ...
    'gui_OutputFcn',  @ez_roi_refine_OutputFcn, ...
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


% --- Executes just before ez_roi_refine is made visible.
function ez_roi_refine_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ez_roi_refine (see VARARGIN)

% Choose default command line output for ez_roi_refine
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ez_roi_refine wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ez_roi_refine_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

refine_roi=parse_refine_roi(handles); %read GUI

%=========Re-calculate data from load button===================
%------Calculate Baseline Stability - First vs Last-------
frames=size(handles.ROI.F_raw,2); %calculate number of frames in data
roi_number=size(handles.ROI.F_raw,1);

%User input sliding window number of frames for detecting baseline ====
baseline_window=str2double(get(handles.input_baseline_window,'string'));
%calculate Z_mod
handles.ROI.Z_mod=ez_ZF(handles.ROI.F_raw,baseline_window);
%First Frame End
first_frame_start=1;
first_frame_end=floor(str2double(get(handles.input_baseline_stability_percent,'string'))/100*frames);
%Last Frame Start
last_frame_start=frames-first_frame_end+1;
last_frame_end=frames;
%Calculate First Baseline
[~,first_baseline,~,~]=ez_ZF(handles.ROI.Z_mod(:,first_frame_start:first_frame_end),baseline_window);
%Calculate Last Baseline
[~,last_baseline,~,~]=ez_ZF(handles.ROI.Z_mod(:,last_frame_start:last_frame_end),baseline_window);
%Calculate Stability (difference in Z score of baselines)
handles.ROI.Baseline_stability=abs(first_baseline-last_baseline);

%--------Calculate Significant Activity-----------
activity_value=str2double(get(handles.input_dF_activity_value,'string')); %get values from GUI
activity_frames=str2double(get(handles.input_dF_activity_frames,'string')); %get values from GUI

significant_frames = handles.ROI.Z_mod > activity_value;
handles.ROI.active_ROI = max(movsum(significant_frames,activity_frames,2,'Endpoints','discard'),[],2) == activity_frames;

%=====End Re-calculate data from load button===================

for ROI=1:size(handles.ROI.F_raw,1)
    borderline_count=0;
    set(handles.ROI_list,'Value',ROI); %reset selection bar to first ROI
    drawnow; %Update GUI
    
    guidata(hObject,handles) %Update handles data
    view_ROI_function(hObject, eventdata, handles) %Load ROI
    
    %Check for whether or not ROI is active
    if handles.ROI.active_ROI(ROI)==0
        borderline_count=9999999;
    end
    
    if get(handles.ROI_baseline_stability,'BackgroundColor')==[0.6350, 0.0780, 0.1840] %Check for red backgrounds
        borderline_count=9999999;%Mark for exclusion
    elseif get(handles.ROI_baseline_stability,'BackgroundColor')==[1 1 0] %Check for yellow backgrounds
        borderline_count=borderline_count+1;
    end
    
    if get(handles.ROI_roundness,'BackgroundColor')==[0.6350, 0.0780, 0.1840] %Check for red backgrounds
        borderline_count=9999999;%Mark for exclusion
    elseif get(handles.ROI_roundness,'BackgroundColor')==[1 1 0] %Check for yellow backgrounds
        borderline_count=borderline_count+1;
    end
    
    if get(handles.ROI_oblongness,'BackgroundColor')==[0.6350, 0.0780, 0.1840] %Check for red backgrounds
        borderline_count=9999999;%Mark for exclusion
    elseif get(handles.ROI_oblongness,'BackgroundColor')==[1 1 0] %Check for yellow backgrounds
        borderline_count=borderline_count+1;
    end
    
    if get(handles.ROI_width,'BackgroundColor')==[0.6350, 0.0780, 0.1840] %Check for red backgrounds
        borderline_count=9999999;%Mark for exclusion
    elseif get(handles.ROI_width,'BackgroundColor')==[1 1 0] %Check for yellow backgrounds
        borderline_count=borderline_count+1;
    end
    
    if get(handles.ROI_area,'BackgroundColor')==[0.6350, 0.0780, 0.1840] %Check for red backgrounds
        borderline_count=9999999;%Mark for exclusion
    elseif get(handles.ROI_area,'BackgroundColor')==[1 1 0] %Check for yellow backgrounds
        borderline_count=borderline_count+1;
    end
    
    if get(handles.ROI_skewness_dF,'BackgroundColor')==[0.6350, 0.0780, 0.1840] %Check for red backgrounds
        borderline_count=9999999; %Mark for exclusion
    elseif get(handles.ROI_skewness_dF,'BackgroundColor')==[1 1 0] %Check for yellow backgrounds
        borderline_count=borderline_count+1;
    end
    
    if get(handles.ROI_skewness_deconvolved,'BackgroundColor')==[0.6350, 0.0780, 0.1840] %Check for red backgrounds
        borderline_count=9999999;%Mark for exclusion
    elseif get(handles.ROI_skewness_deconvolved,'BackgroundColor')==[1 1 0] %Check for yellow backgrounds
        borderline_count=borderline_count+1;
    end
    
    if get(handles.ROI_kurtosis_dF,'BackgroundColor')==[0.6350, 0.0780, 0.1840] %Check for red backgrounds
        borderline_count=9999999; %Mark for exclusion
    elseif get(handles.ROI_kurtosis_dF,'BackgroundColor')==[1 1 0] %Check for yellow backgrounds
        borderline_count=borderline_count+1;
    end
    
    if get(handles.ROI_kurtosis_deconvolved,'BackgroundColor')==[0.6350, 0.0780, 0.1840] %Check for red backgrounds
        borderline_count=9999999;%Mark for exclusion
    elseif get(handles.ROI_kurtosis_deconvolved,'BackgroundColor')==[1 1 0] %Check for yellow backgrounds
        borderline_count=borderline_count+1;
    end
    
    if get(handles.ROI_saturated_frames,'BackgroundColor')==[0.6350, 0.0780, 0.1840] %Check for red backgrounds
        borderline_count=9999999;%Mark for exclusion
    elseif get(handles.ROI_saturated_frames,'BackgroundColor')==[1 1 0] %Check for yellow backgrounds
        borderline_count=borderline_count+1;
    end
    
    
    %Mark Borderline, Exclude, or Include
    if borderline_count==0 %No borderline, no exclusions
        include_ROI_Callback(hObject, eventdata, handles) %include ROI
    elseif borderline_count <= str2double(get(handles.input_borderline_allowance,'string'))
        %mark as borderline
        ROI_new_string=string(get(handles.ROI_list,'String'));
        ROI_new_string(ROI,1)=[num2str(ROI) ' B'];
        set(handles.ROI_list,'String',ROI_new_string);
    else
        exclude_ROI_Callback(hObject, eventdata, handles) %exclude ROI
    end
    
    drawnow;
    guidata(hObject,handles) %Update handles data
    view_ROI_function(hObject, eventdata, handles) %Load ROI
    
    
end %End the ROI loop

%Autosave new data
% save(handles.full_filepath);



% --- Executes on button press in help.
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
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
refine_roi_load_settings(handles)


% --- Executes on button press in save_settings_button.
function save_settings_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_settings_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%This function saves the settings for future use as a csv
refine_roi_save_settings(handles)


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

% --- Executes on button press in load_ROI.
function load_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to load_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[add_file,add_filepath]=uigetfile('*.mat','Choose _roi.mat file to be processed.','MultiSelect','off');

if iscell(add_file)||ischar(add_file) %Checks to see if anything was selected
    
    %Load Data
    handles.full_filepath=[add_filepath add_file]; %Concatenate file path and name
    handles.ROI=load(handles.full_filepath); %Creates a new handle, ROI, and loads file data into it
    guidata( hObject, handles); %Saves new handle so that it can be passed within the GUI
    
    if  isfield(handles.ROI,'F_raw') %check to make sure data are compatible and raw data available
        roi_number=size(handles.ROI.F_raw,1); %Find longest length of data
    else
        warning_text='The selected file is not a compatible data file. Compatible data files should end with _roi.mat';
        ez_warning_small(warning_text);
        return
    end
    
    if ~isfield(handles.ROI,'ROI_names') %Check if names are already generated
        handles.ROI.ROI_names=1:roi_number; %populate the list of default ROI names
        set(handles.ROI_list,'String',handles.ROI.ROI_names); %Update the ROI list
        drawnow
        handles.ROI.ROI_names=cellstr(get(handles.ROI_list,'String')); %Get the list back, convert to cell array of character vectors
        handles.ROI.ROI_names=char(pad(handles.ROI.ROI_names,7)); %Add blank characters to the end, convert back to character array
        set(handles.ROI_list,'String',handles.ROI.ROI_names); %Update ROI names
    end
    
    set(handles.ROI_list,'Value',1); %reset selection bar to 1
    
    set(handles.ROI_list,'String',handles.ROI.ROI_names); %Update the ROI list
    
    drawnow
    
    % pre-processing loaded data for displaying images
    nA = full(sqrt(sum(handles.ROI.A_or.^2))');
    [K,~] = size(handles.ROI.C_or);
    handles.ROI.A_or = handles.ROI.A_or/spdiags(nA,0,K,K);
    
    map_size = size(handles.ROI.Cn);
    handles.ROI.sx = min([handles.ROI.options.sx,floor(map_size(1)/2),floor(map_size(2)/2)]);
    handles.ROI.int_x = zeros(roi_number,2*handles.ROI.sx);
    handles.ROI.int_y = zeros(roi_number,2*handles.ROI.sx);
    handles.ROI.cm = com(handles.ROI.A_or,map_size(1),map_size(2));
    
    %------Calculate Baseline Stability - First vs Last-------
    frames = size(handles.ROI.F_raw,2); %calculate number of frames in data
    
    %Use 40 frame sliding window for detecting baseline ====ADD BASELINE
    %User input sliding window number of frames for detecting baseline ====ADD BASELINE
    baseline_window = str2double(get(handles.input_baseline_window,'string'));
    %calculate Z_mod
    handles.ROI.Z_mod = ez_ZF(handles.ROI.F_raw,baseline_window);
    %First Frame End
    first_frame_start = 1;
    first_frame_end = floor(str2double(get(handles.input_baseline_stability_percent,'string'))/100*frames);
    %Last Frame Start
    last_frame_start = frames-first_frame_end+1;
    last_frame_end = frames;
    %Calculate First Baseline
    [~,first_baseline,~,~] = ez_ZF(handles.ROI.Z_mod(:,first_frame_start:first_frame_end),baseline_window);
    %Calculate Last Baseline
    [~,last_baseline,~,~] = ez_ZF(handles.ROI.Z_mod(:,last_frame_start:last_frame_end),baseline_window);
    %Calculate Stability (difference in Z score of baselines)
    handles.ROI.Baseline_stability = abs(first_baseline-last_baseline);
    
    %--------Calculate Significant Activity-----------
    activity_value = str2double(get(handles.input_dF_activity_value,'string')); %get values from GUI
    activity_frames = str2double(get(handles.input_dF_activity_frames,'string')); %get values from GUI
    
    significant_frames = handles.ROI.Z_mod > activity_value;
    handles.ROI.active_ROI = max(movsum(significant_frames,activity_frames,2,'Endpoints','discard'),[],2) == activity_frames;
    
    %Calculated Saturated Frames
    saturated_frames_value = max(handles.ROI.F_raw,[],1); %find maximum value in trace
    handles.ROI.Saturated_frames = zeros(1,roi_number); %initialize
    for i = 1:roi_number
        handles.ROI.Saturated_frames(i) = numel(find(handles.ROI.F_raw(i,:)==saturated_frames_value(i)));
        if handles.ROI.Saturated_frames(i) == 1 %If only one frame is at max value, assume it is not saturated
            handles.ROI.Saturated_frames(i) = 0;
        end
    end
    
    %Binarize image, extract stats
    map_size=size(handles.ROI.Cn);
    handles.ROI.Area=zeros(size(handles.ROI.ROI_names,2),1);
    handles.ROI.MajorAxis=zeros(size(handles.ROI.ROI_names,2),1);
    handles.ROI.MinorAxis=zeros(size(handles.ROI.ROI_names,2),1);
    handles.ROI.Perimeter=zeros(size(handles.ROI.ROI_names,2),1);
    handles.ROI.Roundness=zeros(size(handles.ROI.ROI_names,2),1);
    handles.ROI.Width=zeros(size(handles.ROI.ROI_names,2),1);
    handles.ROI.Oblong=zeros(size(handles.ROI.ROI_names,2),1);
    for ROI=1:roi_number
        %Binarize images
        single_ROI=full(reshape(handles.ROI.A_or(:,ROI),map_size(1),map_size(2)));
        single_ROI=imbinarize(single_ROI,0);
        %Calculate image stats
        image_stats=regionprops(single_ROI,'Area','Perimeter','MajorAxisLength','MinorAxisLength'); %find image stats
        %Extract stats
        handles.ROI.Area(ROI)=image_stats.Area; %Area of ROI
        handles.ROI.MajorAxis(ROI)=image_stats.MajorAxisLength; %Major axis of ellipse
        handles.ROI.MinorAxis(ROI)=image_stats.MinorAxisLength; %Minor axis of ellipse
        handles.ROI.Perimeter(ROI)=image_stats.Perimeter; %Perimeter
        handles.ROI.Roundness(ROI)=(handles.ROI.Perimeter(ROI).^ 2)./(4 * pi * handles.ROI.Area(ROI)); %Roundness
        handles.ROI.Width(ROI)=mean([handles.ROI.MajorAxis(ROI) handles.ROI.MinorAxis(ROI)],2); %ROI mean width
        handles.ROI.Oblong(ROI)=handles.ROI.MajorAxis(ROI)/handles.ROI.MinorAxis(ROI);
    end
    
    %Calculate Kurtosis
    handles.ROI.Kurtosis_raw=kurtosis(handles.ROI.F_raw'); %raw data kurtosis
    handles.ROI.Kurtosis_deconv=kurtosis(handles.ROI.S_deconv');
    %Calculate Skewness
    handles.ROI.Skewness_raw=skewness(handles.ROI.F_raw'); %raw data kurtosis
    handles.ROI.Skewness_deconv=skewness(handles.ROI.S_deconv');
    
    drawnow %update GUI
    
    guidata(hObject,handles) %Update handles data
    
    %ADD A BUNCH OF DISPLAYS FOR NEW DATA FIELDS
    view_ROI_function(hObject, eventdata, handles) %Automatically load first ROI
    
end

% --- Executes on selection change in ROI_list.
function ROI_list_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
view_ROI_function(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns ROI_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ROI_list



% --- Executes during object creation, after setting all properties.
function ROI_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in include_ROI.
function include_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to include_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROI_number=get(handles.ROI_list,'Value'); %Get the number of the selected ROI
ROI_new_string=string(get(handles.ROI_list,'String'));
ROI_new_string(ROI_number,:)=num2str(ROI_number);
set(handles.ROI_list,'String',ROI_new_string);

view_ROI_function(hObject, eventdata, handles);



% --- Executes on button press in view_ROI.
function view_ROI_function(hObject, eventdata, handles)
% hObject    handle to view_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ROI_number=get(handles.ROI_list,'Value'); %Get the number of the selected ROI

%Display Isolated ROI
axes(handles.isolated_ROI); %Select whole field axes

%Display raw dF/F trace (if exists)
axes(handles.ROI_dF_trace);
% plot(handles.ROI.F_raw(ROI_number,:))
plot(handles.ROI.Z_mod(ROI_number,:))
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
set(gca,'box','off')

hold on %Add active trace threshold
if get(handles.input_dF_activity_style,'Value')==1
    threshold_line=zeros(1,size(handles.ROI.Z_mod,2))+str2num(get(handles.input_dF_activity_value,'String'));
    plot(threshold_line);
end

hold off

%Display fitted trace (if exists)
axes(handles.ROI_fitted_trace);
plot(handles.ROI.F_inferred(ROI_number,:))
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
set(gca,'box','off')

%Display deconvolved trace (if exists)
axes(handles.ROI_deconvolved_trace);
plot(handles.ROI.S_deconv(ROI_number,:))
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
set(gca,'box','off')

%Display Big Map
map_size = size(handles.ROI.Cn);
axes(handles.whole_field)
imagesc(handles.ROI.Cn);hold on
single_ROI = full(reshape(handles.ROI.A_or(:,ROI_number),map_size(1),map_size(2)));
single_ROI = medfilt2(single_ROI,[3,3]);
single_ROI = single_ROI(:);
[temp,ind] = sort(single_ROI(:).^2,'ascend');
temp =  cumsum(temp);
ff = find(temp > (1-0.95)*temp(end),1,'first');
if ~isempty(ff)
    [~,ww] = contour(reshape(single_ROI,map_size(1),map_size(2)),[0,0]+single_ROI(ind(ff)),'LineColor','k');
    ww.LineWidth = 2;
end
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
set(gca,'box','off')
hold off

%Display Isolated ROI
axes(handles.isolated_ROI);
single_ROI=reshape(handles.ROI.A_or(:,ROI_number),map_size(1),map_size(2));
i = ROI_number;
int_x = handles.ROI.int_x;
int_y = handles.ROI.int_y;
sx = handles.ROI.sx;
cm = handles.ROI.cm;
d1 = map_size(1);
d2 = map_size(2);

int_x(i,:) = round(cm(i,1)) + (-(sx-1):sx);
if int_x(i,1)<1
    int_x(i,:) = int_x(i,:) + 1 - int_x(i,1);
end
if int_x(i,end)>d1
    int_x(i,:) = int_x(i,:) - (int_x(i,end)-d1);
end
int_y(i,:) = round(cm(i,2)) + (-(sx-1):sx);
if int_y(i,1)<1
    int_y(i,:) = int_y(i,:) + 1 - int_y(i,1);
end
if int_y(i,end)>d2
    int_y(i,:) = int_y(i,:) - (int_y(i,end)-d2);
end
single_ROI = single_ROI(int_x(i,:),int_y(i,:));
imagesc(int_x(i,:),int_y(i,:),single_ROI);

set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
set(gca,'box','off')

%Read if included or excluded, update exclusion list
ROI_name=get(handles.ROI_list,'String'); %ADD 3 SPACES TO END OF STRING
% XXXXXXXXXXXXXXXXXX RESUME HERE =================


if contains(ROI_name(ROI_number,1),'X') %Checks if marked excluded
    set(handles.exclusion_status,'String',['ROI ' num2str(ROI_number) ' - Excluded'])
    set(handles.exclusion_status,'ForegroundColor','white')
    set(handles.exclusion_status,'BackgroundColor',[0.6350, 0.0780, 0.1840])
elseif contains(ROI_name(ROI_number,1),'B')  %Checks if marked borderline
    set(handles.exclusion_status,'String',['ROI ' num2str(ROI_number) ' - Borderline'])
    set(handles.exclusion_status,'ForegroundColor','black')
    set(handles.exclusion_status,'BackgroundColor','yellow')
else
    set(handles.exclusion_status,'String',['ROI ' num2str(ROI_number) ' - Included'])
    set(handles.exclusion_status,'ForegroundColor','black')
    set(handles.exclusion_status,'BackgroundColor','white')
end
%Coloring scheme isn't working for some reason. Fix this bug later


%Display values of ROIs
set(handles.ROI_baseline_stability,'String',num2str(round(handles.ROI.Baseline_stability(ROI_number),3)));
set(handles.ROI_roundness,'String',num2str(round(handles.ROI.Roundness(ROI_number),3)));
set(handles.ROI_oblongness,'String',num2str(round(handles.ROI.Oblong(ROI_number),3)));
set(handles.ROI_width,'String',num2str(round(handles.ROI.Width(ROI_number),3)));
set(handles.ROI_area,'String',num2str(round(handles.ROI.Area(ROI_number),3)));
set(handles.ROI_skewness_dF,'String',num2str(round(handles.ROI.Skewness_raw(ROI_number),3)));
set(handles.ROI_skewness_deconvolved,'String',num2str(round(handles.ROI.Skewness_deconv(ROI_number),3)));
set(handles.ROI_kurtosis_dF,'String',num2str(round(handles.ROI.Kurtosis_raw(ROI_number),3)));
set(handles.ROI_kurtosis_deconvolved,'String',num2str(round(handles.ROI.Kurtosis_deconv(ROI_number),3)));
set(handles.ROI_saturated_frames,'String',num2str(round(handles.ROI.Saturated_frames(ROI_number),3)));


%=========Display exclusion status==============

%Grab all exclusion values
input_activity_style=(get(handles.input_dF_activity_style,'Value'));
input_activity_value=str2double(get(handles.input_dF_activity_value,'String'));
input_activity_frames=str2double(get(handles.input_dF_activity_frames,'String'));
input_baseline_stability=str2double(get(handles.input_baseline_stability,'String'));
input_baseline_stability_percent=str2double(get(handles.input_baseline_stability_percent,'String'));
input_baseline_window=str2double(get(handles.input_baseline_window,'String'));
input_roundness=str2double(get(handles.input_roundness,'String'));
input_oblongness=str2double(get(handles.input_oblongness,'String'));
input_area_min=str2double(get(handles.input_area_min,'String'));
input_area_max=str2double(get(handles.input_area_max,'String'));
input_width_min=str2double(get(handles.input_width_min,'String'));
input_width_max=str2double(get(handles.input_width_max,'String'));
input_skewness_min=str2double(get(handles.input_skewness_min,'String'));
input_skewness_max=str2double(get(handles.input_skewness_max,'String'));
input_skewness_kurtosis_style=get(handles.input_skewness_kurtosis_style,'Value');
input_kurtosis_min=str2double(get(handles.input_kurtosis_min,'String'));
input_kurtosis_max=str2double(get(handles.input_kurtosis_max,'String'));

%Convert sat value to frames if not frames already
input_sat_style=get(handles.input_sat_value,'Value'); % 1 = percent, 2 = frames

if input_sat_style==2
    input_sat_value=str2double(get(handles.input_sat_value,'String'));
else
    input_sat_value=floor(str2double(get(handles.input_sat_value,'String'))/100*size(handles.ROI.C_or,2)); %Convert to number of frames
end


%Calculate Borderline Values
borderline_style=get(handles.input_borderline_style,'Value'); %1 = percentage, 2 = stdev, 3 = MAD

if borderline_style==1 %percentage
    border_percent=str2double(get(handles.input_borderline_value,'String'))/100;
    
    border_activity_value=input_activity_value*(1-border_percent); %Treat as a minimum
    border_baseline_stability=input_baseline_stability*(1+border_percent); %Treat as a maximum
    border_roundness=input_roundness*(1-border_percent); %Treat as a minimum
    border_oblongness=input_oblongness*(1+border_percent); %Treated as a maximum
    border_area_min=input_area_min*(1-border_percent);
    border_area_max=input_area_max*(1+border_percent);
    border_width_min=input_width_min*(1-border_percent);
    border_width_max=input_width_max*(1+border_percent);
    border_skewness_min=input_skewness_min*(1-border_percent);
    border_skewness_max=input_skewness_max*(1+border_percent);
    border_kurtosis_min=input_kurtosis_min*(1-border_percent);
    border_kurtosis_max=input_kurtosis_max*(1+border_percent);
    border_sat_value=input_sat_value*(1+border_percent);
    
elseif borderline_style==2 %stdev
    border_std=str2double(get(handles.input_borderline_value,'String'));
    
    border_activity_value=input_activity_value; %MAD and STD can't be applied here
    border_baseline_stability=input_baseline_stability; %MAD and STD can't be applied here
    border_roundness=mean(handles.ROI.Roundness)-border_std*std(handles.ROI.Roundness); %Treat as a minimum
    border_oblongness=mean(handles.ROI.Oblong)+border_std*std(handles.ROI.Oblong);  %Treated as a maximum
    border_area_min=mean(handles.ROI.Area)-border_std*std(handles.ROI.Area);
    border_area_max=mean(handles.ROI.Area)+border_std*std(handles.ROI.Area);
    border_width_min=mean(handles.ROI.Width)-border_std*std(handles.ROI.Width);
    border_width_max=mean(handles.ROI.Width)+border_std*std(handles.ROI.Width);
    border_sat_value=mean(handles.ROI.Saturated_frames)-border_std*std(handles.ROI.Saturated_frames);
    
    if input_skewness_kurtosis_style==1 %Deconvolved
        border_skewness_min=mean(handles.ROI.Skewness_deconv)-border_std*std(handles.ROI.Skewness_deconv);
        border_skewness_max=mean(handles.ROI.Skewness_deconv)+border_std*std(handles.ROI.Skewness_deconv);
        border_kurtosis_min=mean(handles.ROI.Kurtosis_deconv)-border_std*std(handles.ROI.Kurtosis_deconv);
        border_kurtosis_max=mean(handles.ROI.Kurtosis_deconv)+border_std*std(handles.ROI.Kurtosis_deconv);
    else %Raw
        border_skewness_min=mean(handles.ROI.Skewness_raw)-border_std*std(handles.ROI.Skewness_raw);
        border_skewness_max=mean(handles.ROI.Skewness_raw)+border_std*std(handles.ROI.Skewness_raw);
        border_kurtosis_min=mean(handles.ROI.Kurtosis_raw)-border_std*std(handles.ROI.Kurtosis_raw);
        border_kurtosis_max=mean(handles.ROI.Kurtosis_raw)+border_std*std(handles.ROI.Kurtosis_raw);
    end
    
elseif borderline_style==3 %MAD
    border_mad=str2double(get(handles.input_borderline_value,'String'));
    
    border_activity_value=input_activity_value; %MAD and STD can't be applied here
    border_baseline_stability=input_baseline_stability; %MAD and STD can't be applied here
    border_roundness=mean(handles.ROI.Roundness)-border_mad*mad(handles.ROI.Roundness,1); %Treat as a minimum
    border_oblongness=mean(handles.ROI.Oblong)+border_mad*mad(handles.ROI.Oblong,1);  %Treated as a maximum
    border_area_min=mean(handles.ROI.Area)-border_mad*mad(handles.ROI.Area,1);
    border_area_max=mean(handles.ROI.Area)+border_mad*mad(handles.ROI.Area,1);
    border_width_min=mean(handles.ROI.Width)-border_mad*mad(handles.ROI.Width,1);
    border_width_max=mean(handles.ROI.Width)+border_mad*mad(handles.ROI.Width,1);
    border_sat_value=mean(handles.ROI.Saturated_frames)-border_mad*mad(handles.ROI.Saturated_frames,1);
    
    if input_skewness_kurtosis_style==1 %Deconvolved
        border_skewness_min=mean(handles.ROI.Skewness_deconv)-border_mad*mad(handles.ROI.Skewness_deconv,1);
        border_skewness_max=mean(handles.ROI.Skewness_deconv)+border_mad*mad(handles.ROI.Skewness_deconv,1);
        border_kurtosis_min=mean(handles.ROI.Kurtosis_deconv)-border_mad*mad(handles.ROI.Kurtosis_deconv,1);
        border_kurtosis_max=mean(handles.ROI.Kurtosis_deconv)+border_mad*mad(handles.ROI.Kurtosis_deconv,1);
    else %Raw
        border_skewness_min=mean(handles.ROI.Skewness_raw)-border_mad*mad(handles.ROI.Skewness_raw,1);
        border_skewness_max=mean(handles.ROI.Skewness_raw)+border_mad*mad(handles.ROI.Skewness_raw,1);
        border_kurtosis_min=mean(handles.ROI.Kurtosis_raw)-border_mad*mad(handles.ROI.Kurtosis_raw,1);
        border_kurtosis_max=mean(handles.ROI.Kurtosis_raw)+border_mad*mad(handles.ROI.Kurtosis_raw,1);
    end
    
end

%Mark if things are exclusionary

if handles.ROI.Baseline_stability(ROI_number)<=input_baseline_stability
    set(handles.ROI_baseline_stability,'BackgroundColor','white');
    set(handles.ROI_baseline_stability,'ForegroundColor','black');
elseif handles.ROI.Baseline_stability(ROI_number)<=border_baseline_stability
    set(handles.ROI_baseline_stability,'BackgroundColor','yellow');
    set(handles.ROI_baseline_stability,'ForegroundColor','black');
else
    set(handles.ROI_baseline_stability,'BackgroundColor',[0.6350, 0.0780, 0.1840]);
    set(handles.ROI_baseline_stability,'ForegroundColor','white');
end

if handles.ROI.Roundness(ROI_number)<=input_roundness
    set(handles.ROI_roundness,'BackgroundColor','white');
    set(handles.ROI_roundness,'ForegroundColor','black');
elseif handles.ROI.Roundness(ROI_number)<=border_roundness
    set(handles.ROI_roundness,'BackgroundColor','yellow');
    set(handles.ROI_roundness,'ForegroundColor','black');
else
    set(handles.ROI_roundness,'BackgroundColor',[0.6350, 0.0780, 0.1840]);
    set(handles.ROI_roundness,'ForegroundColor','white');
end

if handles.ROI.Oblong(ROI_number)<=input_oblongness
    set(handles.ROI_oblongness,'BackgroundColor','white');
    set(handles.ROI_oblongness,'ForegroundColor','black');
elseif handles.ROI.Oblong(ROI_number)<=border_oblongness
    set(handles.ROI_oblongness,'BackgroundColor','yellow');
    set(handles.ROI_oblongness,'ForegroundColor','black');
else
    set(handles.ROI_oblongness,'BackgroundColor',[0.6350, 0.0780, 0.1840]);
    set(handles.ROI_oblongness,'ForegroundColor','white');
end

if handles.ROI.Saturated_frames(ROI_number)<=input_sat_value
    set(handles.ROI_saturated_frames,'BackgroundColor','white');
    set(handles.ROI_saturated_frames,'ForegroundColor','black');
elseif handles.ROI.Saturated_frames(ROI_number)<=border_sat_value
    set(handles.ROI_saturated_frames,'BackgroundColor','yellow');
    set(handles.ROI_saturated_frames,'ForegroundColor','black');
else
    set(handles.ROI_saturated_frames,'BackgroundColor',[0.6350, 0.0780, 0.1840]);
    set(handles.ROI_saturated_frames,'ForegroundColor','white');
end

if handles.ROI.Width(ROI_number)>=input_width_min && handles.ROI.Width(ROI_number)<=input_width_max
    set(handles.ROI_width,'BackgroundColor','white');
    set(handles.ROI_width,'ForegroundColor','black');
elseif handles.ROI.Width(ROI_number)>=border_width_min && handles.ROI.Width(ROI_number)<=border_width_max
    set(handles.ROI_width,'BackgroundColor','yellow');
    set(handles.ROI_width,'ForegroundColor','black');
else
    set(handles.ROI_width,'BackgroundColor',[0.6350, 0.0780, 0.1840]);
    set(handles.ROI_width,'ForegroundColor','white');
end

if handles.ROI.Area(ROI_number)>=input_area_min && handles.ROI.Area(ROI_number)<=input_area_max
    set(handles.ROI_area,'BackgroundColor','white');
    set(handles.ROI_area,'ForegroundColor','black');
elseif handles.ROI.Area(ROI_number)>=border_area_min && handles.ROI.Area(ROI_number)<=border_area_max
    set(handles.ROI_area,'BackgroundColor','yellow');
    set(handles.ROI_area,'ForegroundColor','black');
else
    set(handles.ROI_area,'BackgroundColor',[0.6350, 0.0780, 0.1840]);
    set(handles.ROI_area,'ForegroundColor','white');
end

if input_skewness_kurtosis_style==1 %Deconvolved
    set(handles.ROI_skewness_dF,'BackgroundColor','white');
    set(handles.ROI_skewness_dF,'ForegroundColor','black');
    set(handles.ROI_kurtosis_dF,'BackgroundColor','white');
    set(handles.ROI_kurtosis_dF,'ForegroundColor','black');
    
    if handles.ROI.Skewness_deconv(ROI_number)>=input_skewness_min && handles.ROI.Skewness_deconv(ROI_number)<=input_skewness_max
        set(handles.ROI_skewness_deconvolved,'BackgroundColor','white');
        set(handles.ROI_skewness_deconvolved,'ForegroundColor','black');
    elseif handles.ROI.Skewness_deconv(ROI_number)>=border_skewness_min && handles.ROI.Skewness_deconv(ROI_number)<=border_skewness_max
        set(handles.ROI_skewness_deconvolved,'BackgroundColor','yellow');
        set(handles.ROI_skewness_deconvolved,'ForegroundColor','black');
    else
        set(handles.ROI_skewness_deconvolved,'BackgroundColor',[0.6350, 0.0780, 0.1840]);
        set(handles.ROI_skewness_deconvolved,'ForegroundColor','white');
    end
    
    if handles.ROI.Kurtosis_deconv(ROI_number)>=input_kurtosis_min && handles.ROI.Kurtosis_deconv(ROI_number)<=input_kurtosis_max
        set(handles.ROI_kurtosis_deconvolved,'BackgroundColor','white');
        set(handles.ROI_kurtosis_deconvolved,'ForegroundColor','black');
    elseif handles.ROI.Kurtosis_deconv(ROI_number)>=border_kurtosis_min && handles.ROI.Kurtosis_deconv(ROI_number)<=border_kurtosis_max
        set(handles.ROI_kurtosis_deconvolved,'BackgroundColor','yellow');
        set(handles.ROI_kurtosis_deconvolved,'ForegroundColor','black');
    else
        set(handles.ROI_kurtosis_deconvolved,'BackgroundColor',[0.6350, 0.0780, 0.1840]);
        set(handles.ROI_kurtosis_deconvolved,'ForegroundColor','white');
    end
    
    
else %Raw
    set(handles.ROI_skewness_deconvolved,'BackgroundColor','white');
    set(handles.ROI_skewness_deconvolved,'ForegroundColor','black');
    set(handles.ROI_kurtosis_deconvolved,'BackgroundColor','white');
    set(handles.ROI_kurtosis_deconvolved,'ForegroundColor','black');
    
    
    if handles.ROI.Skewness_raw(ROI_number)>=input_skewness_min && handles.ROI.Skewness_raw(ROI_number)<=input_skewness_max
        set(handles.ROI_skewness_dF,'BackgroundColor','white');
        set(handles.ROI_skewness_dF,'ForegroundColor','black');
    elseif handles.ROI.Skewness_raw(ROI_number)>=border_skewness_min && handles.ROI.Skewness_raw(ROI_number)<=border_skewness_max
        set(handles.ROI_skewness_dF,'BackgroundColor','yellow');
        set(handles.ROI_skewness_dF,'ForegroundColor','black');
    else
        set(handles.ROI_skewness_dF,'BackgroundColor',[0.6350, 0.0780, 0.1840]);
        set(handles.ROI_skewness_dF,'ForegroundColor','white');
    end
    
    if handles.ROI.Kurtosis_raw(ROI_number)>=input_kurtosis_min && handles.ROI.Kurtosis_raw(ROI_number)<=input_kurtosis_max
        set(handles.ROI_kurtosis_dF,'BackgroundColor','white');
        set(handles.ROI_kurtosis_dF,'ForegroundColor','black');
    elseif handles.ROI.Kurtosis_raw(ROI_number)>=border_kurtosis_min && handles.ROI.Kurtosis_raw(ROI_number)<=border_kurtosis_max
        set(handles.ROI_kurtosis_dF,'BackgroundColor','yellow');
        set(handles.ROI_kurtosis_dF,'ForegroundColor','black');
    else
        set(handles.ROI_kurtosis_dF,'BackgroundColor',[0.6350, 0.0780, 0.1840]);
        set(handles.ROI_kurtosis_dF,'ForegroundColor','white');
    end
    
    
    
    
end




guidata(hObject,handles) %Update handles data
drawnow;



% --- Executes on button press in next_ROI.
function next_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to next_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list_position=get(handles.ROI_list,'Value'); %Finds the position of the highlight
list_length=length(get(handles.ROI_list,'String')); %Finds the length of the list
if list_position == list_length %Checks to see if end of the list
    new_position=1; %Start back at the start
else
    new_position=list_position+1; %Move to the next position
end
set(handles.ROI_list,'Value',new_position); %Change position of highlight
drawnow %update GUI

view_ROI_function(hObject, eventdata, handles) %Run as if the View ROI button were pressed



% --- Executes on button press in previous_ROI.
function previous_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to previous_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

list_position=get(handles.ROI_list,'Value'); %Finds the position of the highlight
list_length=length(get(handles.ROI_list,'String')); %Finds the length of the list
if list_position == 1 %Checks to see if at the start of the list
    new_position=list_length; %Move to the end of the list
else
    new_position=list_position-1; %Move to the previous position
end
set(handles.ROI_list,'Value',new_position); %Change position of highlight
drawnow %update GUI

view_ROI_function(hObject, eventdata, handles) %Run as if the View ROI button were pressed


% --- Executes on selection change in input_dF_activity_style.
function input_dF_activity_style_Callback(hObject, eventdata, handles)
% hObject    handle to input_dF_activity_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns input_dF_activity_style contents as cell array
%        contents{get(hObject,'Value')} returns selected item from input_dF_activity_style


% --- Executes during object creation, after setting all properties.
function input_dF_activity_style_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_dF_activity_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_dF_activity_value_Callback(hObject, eventdata, handles)
% hObject    handle to input_dF_activity_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_dF_activity_value as text
%        str2double(get(hObject,'String')) returns contents of input_dF_activity_value as a double


% --- Executes during object creation, after setting all properties.
function input_dF_activity_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_dF_activity_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function input_dF_activity_frames_Callback(hObject, eventdata, handles)
% hObject    handle to input_dF_activity_frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_dF_activity_frames as text
%        str2double(get(hObject,'String')) returns contents of input_dF_activity_frames as a double


% --- Executes during object creation, after setting all properties.
function input_dF_activity_frames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_dF_activity_frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in export.
function export_Callback(hObject, eventdata, handles)
% hObject    handle to export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Check export options
csv_save=get(handles.box_csv,'value');
mat_save=get(handles.box_mat,'value');
xlsx_save=get(handles.box_xlsx,'value');

ROI_list=get(handles.ROI_list,'String');
%=====Select only the ROIs that have not been excluded=====
handles.ROI.included_ROIs=[];
for i=1:size(ROI_list,1)
    if ~contains(ROI_list(i,:),'X')
        handles.ROI.included_ROIs(end+1)=i;
    end
end

F=handles.ROI.F_raw(handles.ROI.included_ROIs,:)'; %For legacy Portera Lab compatibility. Feel free to comment this out.
F_inferred_refined=handles.ROI.F_inferred(handles.ROI.included_ROIs,:); %Fitted data
F_raw_refined=handles.ROI.F_raw(handles.ROI.included_ROIs,:); %Raw data
S_deconv_refined=handles.ROI.S_deconv(handles.ROI.included_ROIs,:); %Deconvolved data
Z_mod_refined=handles.ROI.Z_mod(handles.ROI.included_ROIs,:); %Z-score data

%CSV Export
if csv_save
    refined_filename=[handles.full_filepath(1:end-4) '_refined_raw.csv'];
    csvwrite(refined_filename,F_raw_refined);
    refined_filename=[handles.full_filepath(1:end-4) '_refined_fit.csv'];
    csvwrite(refined_filename,F_inferred_refined);
    refined_filename=[handles.full_filepath(1:end-4) '_refined_decon.csv'];
    csvwrite(refined_filename,S_deconv_refined);
    refined_filename=[handles.full_filepath(1:end-4) '_refined_Zmod.csv'];
    csvwrite(refined_filename,Z_mod_refined);
    % refined_filename=[handles.full_filepath(1:end-4) '_refined_centers.csv'];
    % csvwrite(refined_filename,ROI_centers);
end

%MAT Export
if mat_save
    refined_filename=[handles.full_filepath(1:end-4) '_refined.mat'];
    save(refined_filename,'F_inferred_refined','F_raw_refined','S_deconv_refined','F','Z_mod_refined');
end

%XLSX Export
if xlsx_save
    refined_filename=[handles.full_filepath(1:end-4) '_refined.xlsx'];
    xlswrite(refined_filename,F_raw_refined,'Raw');
    xlswrite(refined_filename,F_inferred_refined,'Fit');
    xlswrite(refined_filename,S_deconv_refined,'Deconvolved');
    xlswrite(refined_filename,Z_mod_refined,'Z_mod');
    % xlswrite(refined_filename,ROI_centers,'Centers');
end

% save(handles.full_filepath);



function input_roundness_Callback(hObject, eventdata, handles)
% hObject    handle to input_roundness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_roundness as text
%        str2double(get(hObject,'String')) returns contents of input_roundness as a double


% --- Executes during object creation, after setting all properties.
function input_roundness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_roundness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function input_baseline_stability_Callback(hObject, eventdata, handles)
% hObject    handle to input_baseline_stability (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_baseline_stability as text
%        str2double(get(hObject,'String')) returns contents of input_baseline_stability as a double


% --- Executes during object creation, after setting all properties.
function input_baseline_stability_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_baseline_stability (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_oblongness_Callback(hObject, eventdata, handles)
% hObject    handle to input_oblongness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_oblongness as text
%        str2double(get(hObject,'String')) returns contents of input_oblongness as a double


% --- Executes during object creation, after setting all properties.
function input_oblongness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_oblongness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ROI_roundness_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_roundness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_roundness as text
%        str2double(get(hObject,'String')) returns contents of ROI_roundness as a double


% --- Executes during object creation, after setting all properties.
function ROI_roundness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_roundness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_width_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_width as text
%        str2double(get(hObject,'String')) returns contents of ROI_width as a double


% --- Executes during object creation, after setting all properties.
function ROI_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_baseline_stability_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_baseline_stability (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_baseline_stability as text
%        str2double(get(hObject,'String')) returns contents of ROI_baseline_stability as a double


% --- Executes during object creation, after setting all properties.
function ROI_baseline_stability_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_baseline_stability (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_oblongness_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_oblongness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_oblongness as text
%        str2double(get(hObject,'String')) returns contents of ROI_oblongness as a double


% --- Executes during object creation, after setting all properties.
function ROI_oblongness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_oblongness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function exclusion_status_Callback(hObject, eventdata, handles)
% hObject    handle to exclusion_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exclusion_status as text
%        str2double(get(hObject,'String')) returns contents of exclusion_status as a double


% --- Executes during object creation, after setting all properties.
function exclusion_status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exclusion_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_baseline_stability_percent_Callback(hObject, eventdata, handles)
% hObject    handle to input_baseline_stability_percent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_baseline_stability_percent as text
%        str2double(get(hObject,'String')) returns contents of input_baseline_stability_percent as a double


% --- Executes during object creation, after setting all properties.
function input_baseline_stability_percent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_baseline_stability_percent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function input_baseline_window_Callback(hObject, eventdata, handles)
% hObject    handle to input_baseline_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_baseline_window as text
%        str2double(get(hObject,'String')) returns contents of input_baseline_window as a double


% --- Executes during object creation, after setting all properties.
function input_baseline_window_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_baseline_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function input_area_max_Callback(hObject, eventdata, handles)
% hObject    handle to input_area_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_area_max as text
%        str2double(get(hObject,'String')) returns contents of input_area_max as a double


% --- Executes during object creation, after setting all properties.
function input_area_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_area_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function input_area_min_Callback(hObject, eventdata, handles)
% hObject    handle to input_area_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_area_min as text
%        str2double(get(hObject,'String')) returns contents of input_area_min as a double


% --- Executes during object creation, after setting all properties.
function input_area_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_area_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_area_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_area as text
%        str2double(get(hObject,'String')) returns contents of ROI_area as a double


% --- Executes during object creation, after setting all properties.
function ROI_area_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ROI_kurtosis_dF_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_kurtosis_dF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_kurtosis_dF as text
%        str2double(get(hObject,'String')) returns contents of ROI_kurtosis_dF as a double


% --- Executes during object creation, after setting all properties.
function ROI_kurtosis_dF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_kurtosis_dF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_skewness_deconvolved_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_skewness_deconvolved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_skewness_deconvolved as text
%        str2double(get(hObject,'String')) returns contents of ROI_skewness_deconvolved as a double


% --- Executes during object creation, after setting all properties.
function ROI_skewness_deconvolved_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_skewness_deconvolved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_kurtosis_deconvolved_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_kurtosis_deconvolved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_kurtosis_deconvolved as text
%        str2double(get(hObject,'String')) returns contents of ROI_kurtosis_deconvolved as a double


% --- Executes during object creation, after setting all properties.
function ROI_kurtosis_deconvolved_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_kurtosis_deconvolved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_skewness_dF_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_skewness_dF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_skewness_dF as text
%        str2double(get(hObject,'String')) returns contents of ROI_skewness_dF as a double


% --- Executes during object creation, after setting all properties.
function ROI_skewness_dF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_skewness_dF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in input_skewness_kurtosis_style.
function input_skewness_kurtosis_style_Callback(hObject, eventdata, handles)
% hObject    handle to input_skewness_kurtosis_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns input_skewness_kurtosis_style contents as cell array
%        contents{get(hObject,'Value')} returns selected item from input_skewness_kurtosis_style


% --- Executes during object creation, after setting all properties.
function input_skewness_kurtosis_style_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_skewness_kurtosis_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_borderline_value_Callback(hObject, eventdata, handles)
% hObject    handle to input_borderline_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_borderline_value as text
%        str2double(get(hObject,'String')) returns contents of input_borderline_value as a double


% --- Executes during object creation, after setting all properties.
function input_borderline_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_borderline_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_width_max_Callback(hObject, eventdata, handles)
% hObject    handle to input_width_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_width_max as text
%        str2double(get(hObject,'String')) returns contents of input_width_max as a double


% --- Executes during object creation, after setting all properties.
function input_width_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_width_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_width_min_Callback(hObject, eventdata, handles)
% hObject    handle to input_width_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_width_min as text
%        str2double(get(hObject,'String')) returns contents of input_width_min as a double


% --- Executes during object creation, after setting all properties.
function input_width_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_width_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_skewness_max_Callback(hObject, eventdata, handles)
% hObject    handle to input_skewness_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_skewness_max as text
%        str2double(get(hObject,'String')) returns contents of input_skewness_max as a double


% --- Executes during object creation, after setting all properties.
function input_skewness_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_skewness_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_kurtosis_max_Callback(hObject, eventdata, handles)
% hObject    handle to input_kurtosis_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_kurtosis_max as text
%        str2double(get(hObject,'String')) returns contents of input_kurtosis_max as a double


% --- Executes during object creation, after setting all properties.
function input_kurtosis_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_kurtosis_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_skewness_min_Callback(hObject, eventdata, handles)
% hObject    handle to input_skewness_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_skewness_min as text
%        str2double(get(hObject,'String')) returns contents of input_skewness_min as a double


% --- Executes during object creation, after setting all properties.
function input_skewness_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_skewness_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_kurtosis_min_Callback(hObject, eventdata, handles)
% hObject    handle to input_kurtosis_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_kurtosis_min as text
%        str2double(get(hObject,'String')) returns contents of input_kurtosis_min as a double


% --- Executes during object creation, after setting all properties.
function input_kurtosis_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_kurtosis_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_borderline_allowance_Callback(hObject, eventdata, handles)
% hObject    handle to input_borderline_allowance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_borderline_allowance as text
%        str2double(get(hObject,'String')) returns contents of input_borderline_allowance as a double


% --- Executes during object creation, after setting all properties.
function input_borderline_allowance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_borderline_allowance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in exclude_ROI.
function exclude_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to exclude_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROI_number=get(handles.ROI_list,'Value'); %Get the number of the selected ROI
ROI_new_string=string(get(handles.ROI_list,'String'));


ROI_new_string(ROI_number,1)=[num2str(ROI_number) ' X'];
set(handles.ROI_list,'String',ROI_new_string);

view_ROI_function(hObject, eventdata, handles);

% --- Executes on selection change in input_borderline_style.
function input_borderline_style_Callback(hObject, eventdata, handles)
% hObject    handle to input_borderline_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns input_borderline_style contents as cell array
%        contents{get(hObject,'Value')} returns selected item from input_borderline_style


% --- Executes during object creation, after setting all properties.
function input_borderline_style_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_borderline_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_settings_button.
function load_settings_Callback(hObject, eventdata, handles)
% hObject    handle to load_settings_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_settings_button.
function save_settings_Callback(hObject, eventdata, handles)
% hObject    handle to save_settings_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA).

% --- Executes on button press in box_csv.
function box_csv_Callback(hObject, eventdata, handles)
% hObject    handle to box_csv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of box_csv


% --- Executes on button press in box_mat.
function box_mat_Callback(hObject, eventdata, handles)
% hObject    handle to box_mat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of box_mat


% --- Executes on button press in box_xlsx.
function box_xlsx_Callback(hObject, eventdata, handles)
% hObject    handle to box_xlsx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of box_xlsx




function refine_roi_save_settings(handles)
%Manually save settings from GUI

[refine_roi]=parse_refine_roi(handles); %reads GUI

%Open save box
[filename,filepath] = uiputfile('*.mat');

%Check if anything was selected
if filename==0
    return
end

%Concatenate file name
full_filename=[filepath filename];

%Write to .mat file
save(full_filename,'refine_roi');


function refine_roi_load_settings(handles)
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
if exist('refine_roi','var')~=1
    warning_text='The selected file is not a valid settings file.';
    ez_warning_small(warning_text);
    return
end

write_refine_roi(handles,refine_roi)


function [refine_roi]=parse_refine_roi(handles)
%Reads GUI, stores data into refine_roi variable

%==============Read Menus==============
%dF/F Activity
refine_roi.input_dF_activity_style=get(handles.input_dF_activity_style,'Value');

%Borderline Style
refine_roi.input_borderline_style=get(handles.input_borderline_style,'Value');

%Saturation Frames Style
refine_roi.input_sat_style=get(handles.input_sat_style,'Value');

%Skewness Kurtosis Style
refine_roi.input_skewness_kurtosis_style=get(handles.input_skewness_kurtosis_style,'Value');

%============Read Check Boxes===========
%Export CSV
refine_roi.box_csv=get(handles.box_csv,'Value');

%Export MAT
refine_roi.box_mat=get(handles.box_mat,'Value');

%Export XLSX
refine_roi.box_xlsx=get(handles.box_xlsx,'Value');

%============Read Input Boxes===========
%dF_activity_value
refine_roi.input_dF_activity_value=get(handles.input_dF_activity_value,'String');

%dF activity frames
refine_roi.input_dF_activity_frames=get(handles.input_dF_activity_frames,'String');

%Baseline stability
refine_roi.input_baseline_stability=get(handles.input_baseline_stability,'String');

%Baseline stability percent
refine_roi.input_baseline_stability_percent=get(handles.input_baseline_stability_percent,'String');

%Baseline window
refine_roi.input_baseline_window=get(handles.input_baseline_window,'string');

%Roundness
refine_roi.input_roundness=get(handles.input_roundness,'String');

%Oblongness
refine_roi.input_oblongness=get(handles.input_oblongness,'String');

%Borderline Value
refine_roi.input_borderline_value=get(handles.input_borderline_value,'String');

%Borderline Allowance
refine_roi.input_borderline_allowance=get(handles.input_borderline_allowance,'String');

%Saturated Value
refine_roi.input_sat_value=get(handles.input_sat_value,'String');

%Area Min
refine_roi.input_area_min=get(handles.input_area_min,'String');

%Area Max
refine_roi.input_area_max=get(handles.input_area_max,'String');

%Width Min
refine_roi.input_width_min=get(handles.input_width_min,'String');

%Width Max
refine_roi.input_width_max=get(handles.input_width_max,'String');

%Skewness Min
refine_roi.input_skewness_min=get(handles.input_skewness_min,'String');

%Skewness Max
refine_roi.input_skewness_max=get(handles.input_skewness_max,'String');

%Kurtosis Min
refine_roi.input_kurtosis_min=get(handles.input_kurtosis_min,'String');

%Kurtosis Max
refine_roi.input_kurtosis_max=get(handles.input_kurtosis_max,'String');



function write_refine_roi(handles,refine_roi)
%This function writes to the GUI

%Writes to GUI, loading data from refine_roi variable

%==============Write Menus==============
%dF/F Activity
set(handles.input_dF_activity_style,'Value',refine_roi.input_dF_activity_style);

%Borderline Style
set(handles.input_borderline_style,'Value',refine_roi.input_borderline_style);

%Saturation Frames Style
set(handles.input_sat_style,'Value',refine_roi.input_sat_style);

%Skewness Kurtosis Style
set(handles.input_skewness_kurtosis_style,'Value',refine_roi.input_skewness_kurtosis_style);

%============Write Check Boxes===========
%Export CSV
set(handles.box_csv,'Value',refine_roi.box_csv);

%Export MAT
set(handles.box_mat,'Value',refine_roi.box_mat);

%Export XLSX
set(handles.box_xlsx,'Value',refine_roi.box_xlsx);

%============Write Input Boxes===========
%dF_activity_value
set(handles.input_dF_activity_value,'String',refine_roi.input_dF_activity_value);

%dF activity frames
set(handles.input_dF_activity_frames,'String',refine_roi.input_dF_activity_frames);

%Baseline stability
set(handles.input_baseline_stability,'String',refine_roi.input_baseline_stability);

%Baseline stability percent
set(handles.input_baseline_stability_percent,'String',refine_roi.input_baseline_stability_percent);

%Baseline window
set(handles.input_baseline_window,'String',refine_roi.input_baseline_window);

%Roundness
set(handles.input_roundness,'String',refine_roi.input_roundness);

%Oblongness
set(handles.input_oblongness,'String',refine_roi.input_oblongness);

%Borderline Value
set(handles.input_borderline_value,'String',refine_roi.input_borderline_value);

%Borderline Style
set(handles.input_borderline_style,'Value',refine_roi.input_borderline_style);

%Borderline Allowance
set(handles.input_borderline_allowance,'String',refine_roi.input_borderline_allowance);

%Saturated Value
set(handles.input_sat_value,'String',refine_roi.input_sat_value);

%Area Min
set(handles.input_area_min,'String',refine_roi.input_area_min);

%Area Max
set(handles.input_area_max,'String',refine_roi.input_area_max);

%Width Min
set(handles.input_width_min,'String',refine_roi.input_width_min);

%Width Max
set(handles.input_width_max,'String',refine_roi.input_width_max);

%Skewness Min
set(handles.input_skewness_min,'String',refine_roi.input_skewness_min);

%Skewness Max
set(handles.input_skewness_max,'String',refine_roi.input_skewness_max);

%Kurtosis Min
set(handles.input_kurtosis_min,'String',refine_roi.input_kurtosis_min);

%Kurtosis Max
set(handles.input_kurtosis_max,'String',refine_roi.input_kurtosis_max);





function input_sat_value_Callback(hObject, eventdata, handles)
% hObject    handle to input_sat_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_sat_value as text
%        str2double(get(hObject,'String')) returns contents of input_sat_value as a double


% --- Executes during object creation, after setting all properties.
function input_sat_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_sat_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in input_sat_style.
function input_sat_style_Callback(hObject, eventdata, handles)
% hObject    handle to input_sat_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns input_sat_style contents as cell array
%        contents{get(hObject,'Value')} returns selected item from input_sat_style


% --- Executes during object creation, after setting all properties.
function input_sat_style_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_sat_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_saturated_frames_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_saturated_frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_saturated_frames as text
%        str2double(get(hObject,'String')) returns contents of ROI_saturated_frames as a double


% --- Executes during object creation, after setting all properties.
function ROI_saturated_frames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_saturated_frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""dF/F Activity"" is used to only include ROIs that surpass a chosen activity threshold for a given number of consecutive frames. This threshold can be set in the ""Value"" box in units of dF/F, and the chosen number of consecutive frames can be set in the ""Frames"" box.","Help",'replace')


% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Baseline Stability"" is used to check if an ROI has a stable baseline throughout the imaging session by comparing the baseline at the beginning of recording with the baseline at the end. ""Baseline location"" determines the percentage of the data from the beginning and end of the recording that will be considered when determining the baseline activity level; for example, if this is set to 25%, the first 25% and the last 25% of the total frames will be used to determine the baseline values. EZcalcium will find the minimum value within these frames and use the surrounding frames to calculate a mean baseline value. ""Window"" determines the number of frames to be averaged to find this baseline value. ""dF/F Baseline Stability"" represents the absolute value of the difference between the baseline values from the beginning and end of the data. ","Help",'replace')


% --- Executes on button press in pushbutton30.
function pushbutton30_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Roundness"" measures how similar an ROI is to a circle. This is useful when looking exclusively for neuron somata or other round ROIs.","Help",'replace')


% --- Executes on button press in pushbutton31.
function pushbutton31_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Oblongness"" is a measure of the ellipsoid shape of an ROI. It is calculated by dividing the length of the major axis of the ellipse by the length of the minor axis. This is useful in excluding overly oblong ROIs that are not likely to be neurons.","Help",'replace')


% --- Executes on button press in pushbutton32.
function pushbutton32_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Borderline"" can be set to allow an ROI to have criteria slightly outside of the desired range. If a criterion is outside the desired range but within the allotted borderline percentage, it will not automatically exlude the ROI. Instead, the ROI will be labeled with a ""B,"" the criterion will turn yellow, and if the number of criteria that are considered ""Borderline"" is less than or equal to the number in ""Borderline Allowance,"" the ROI will be included. The parameter can also be input in terms of Standard Deviation or Mean Average Deviation.","Help",'replace')


% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Borderline Allowance"" is the number of criteria per ROI that are allowed to deviate from the set exclusion criteria as long as they are within the borderline percentage. In other words, if an ROI has a number of criteria within the borderline range equal to or less than the ""Borderline Allowance,"" the ROI will be included.","Help",'replace')


% --- Executes on button press in pushbutton34.
function pushbutton34_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Saturated Frames"" can be used to set a maximum number of frames in which the ROI can be fully saturated. This can also be input in terms of the percentage of total frames.","Help",'replace')


% --- Executes on button press in pushbutton35.
function pushbutton35_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Area"" allows the user to select the minimum and maximum area of an included ROI. This is useful for excluding ROIs that are too small or too large.","Help",'replace')


% --- Executes on button press in pushbutton36.
function pushbutton36_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Width"" measures the mean width of an ROI and allows you to select a minimum and maximum value for this parameter.","Help",'replace')


% --- Executes on button press in pushbutton37.
function pushbutton37_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Skewness"" is used to describe the skewness of the probability distribution of either the dF/F data or the deconvolved data for an ROI.","Help",'replace')


% --- Executes on button press in pushbutton38.
function pushbutton38_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Kurtosis"" is used to describe the probability distribution of either the dF/F data or the deconvolved data for an ROI. It measures the likelihood of finding outliers in a distribution. For example, a cell with large, fast, and frequent spikes in calcium levels will have a higher kurtosis value than cells with a more moderate distribution of slow activity.","Help",'replace')


% --- Executes on button press in pushbutton39.
function pushbutton39_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("""Skewness & Kurtosis Data"" is used to select whether the dF/F or deconvolved data will be used as the basis of the exclusion criteria for these two parameters.","Help",'replace')


% --- Executes on button press in pushbutton40.
function pushbutton40_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("The ""Save Settings"" button allows the user to save all settings under a specific name of your choosing. Settings are saved as .mat files. The ""Load Settings"" button allows one to load all saved settings in future sessions.","Help",'replace')


% --- Executes on button press in pushbutton41.
function pushbutton41_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("The ""Include ROI"" and ""Exclude ROI"" buttons allow the user to manually include or exclude an ROI regardless of the parameters set under ""Automated Exclusion.""","Help",'replace')


% --- Executes on button press in pushbutton42.
function pushbutton42_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox("The ""Automated Exclusion"" section allows the user to set thresholds for a variety of criteria in order to ensure the validity of each ROI. If an ROI is outside of the set threshold for a criterion, it will be automatically excluded upon clicking ""Run Refinement.""","Help",'replace')

