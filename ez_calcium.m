function varargout = ez_calcium(varargin)
% EZ_CALCIUM M-file for ez_calcium.fig
%      EZ_CALCIUM, by itself, creates a new EZ_CALCIUM or raises the existing
%      singleton*.
%
%      H = EZ_CALCIUM returns the handle to a new EZ_CALCIUM or the handle to
%      the existing singleton*.
%
%      EZ_CALCIUM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EZ_CALCIUM.M with the given input arguments.
%
%      EZ_CALCIUM('Property','Value',...) creates a new EZ_CALCIUM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ez_calcium_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ez_calcium_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ez_calcium

% Last Modified by GUIDE v2.5 08-Jul-2019 14:49:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ez_calcium_OpeningFcn, ...
                   'gui_OutputFcn',  @ez_calcium_OutputFcn, ...
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


% --- Executes just before ez_calcium is made visible.
function ez_calcium_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ez_calcium (see VARARGIN)

% Choose default command line output for ez_calcium
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ez_calcium wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ez_calcium_OutputFcn(hObject, eventdata, handles) 
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
[chan1file,chan1filepath]=uigetfile('*.tif','Select main channel data');
fullchan1file=[chan1filepath chan1file];
set(hObject,'String',fullchan1file);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[chan2file,chan2filepath]=uigetfile('*.tif','Select reference channel data');
fullchan2file=[chan2filepath chan2file];
set(hObject,'String',fullchan2file);

function block_Callback(hObject, eventdata, handles)
% hObject    handle to block (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of block as text
%        str2double(get(hObject,'String')) returns contents of block as a double


% --- Executes during object creation, after setting all properties.
function block_CreateFcn(hObject, eventdata, handles)
% hObject    handle to block (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function refframe_Callback(hObject, eventdata, handles)
% hObject    handle to refframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of refframe as text
%        str2double(get(hObject,'String')) returns contents of refframe as a double


% --- Executes during object creation, after setting all properties.
function refframe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to refframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadFdatabutton.
function loadFdatabutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadFdatabutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[datafile,datafilepath]=uigetfile('*.mat','Select fluorescence data');
fulldatafile=[datafilepath datafile];
set(hObject,'String',fulldatafile);

% --- Executes on button press in rundatapreview.
function rundatapreview_Callback(hObject, eventdata, handles)
% hObject    handle to rundatapreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%----------Simple parse---------------------
fulldatafile=(get(handles.loadFdatabutton,'String')); %file name of chan 1 data
%-----------End simple parse----------------
load(fulldatafile);

for MOVIE = 1 %:initial.numberofmovies
    cellnumber=size(ROI_list,2); 
    figcount=1; %needed for pdf
    clear figHandles %needed for pdf
    for page = 1:ceil (cellnumber/10)
        figure((MOVIE*10) + page)
        figHandles(figcount)=gcf; %needed for pdf
        figcount=figcount+1; %needed for pdf
        plot_place=0;
        subplot(10,1,1);
        axis([0 size(ROI_list(1,1).fmean,1) 0 1.2]);
        axis off;
        for b = ((page-1)*10)+1:((page-1)*10)+10
            if (b<=cellnumber)
                plot_place = plot_place+1;
                subplot (11,1,plot_place+1); %subplot(10,1,plot_place);
                hline = plot(ROI_list(1,b).fmean(:,1,MOVIE)); %changed from deltaf_matrix to F(9/11/12) to dF(11/27/12)
                set(gca,'YTick',[]);
                set(gca,'YColor',[1,1,1],'FontName','Helvetica');
                roiname=ROI_list(1,b).name;
                ylabel (roiname(4:end),'Color',[0,0,0]); %added by Lauren on 9/11/12
                axis tight;
                box off;
                if(plot_place==10||b==cellnumber)
                    set(hline,'Color',[0,0,0]);
                    hxlabel = xlabel('Frame');
                    set(hxlabel,'FontName','Helvetica');
                else
                    set(hline,'Color',[0,0,0]);
                    set(gca,'XTick', []);
                    set(gca,'XColor',[1,1,1]);
                end
            end
        end
        set(gcf,'Color',[1,1,1]);
    end
    %---needed for pdf---
    hackslash=strfind(fulldatafile,filesep);
    nameString=[fulldatafile(hackslash(end)+1:end-4) '_raw'];
    dirString=fulldatafile(1:hackslash(end));
    ez_multiPagePDF(figHandles, nameString, dirString)
    close(figHandles)
    disp(['PDF created: ' fulldatafile(1:end-4) '_raw.pdf']);
    open([fulldatafile(1:end-4) '_raw.pdf']);
end

% --- Executes on button press in roiselectbutton.
function roiselectbutton_Callback(hObject, eventdata, handles)
% hObject    handle to roiselectbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%------------Autoload Feature---------------
autoloadstatus=(get(handles.autoloadbox,'Value'));
if autoloadstatus==1 %Autoloads if box checked
    %Sets file of F Data Preview by adding ending that would be added in ROI selection
    fulldatafile=(get(handles.loadcalciumbutton,'String'));
    datahandle=[fulldatafile(1:end-4) '_data' '.mat'];
  
    set(handles.loadFdatabutton,'String',datahandle);
end

%------------End Autoload Feature------------
fullvidfile=(get(handles.loadcalciumbutton,'String'));
info = imfinfo(fullvidfile);
num_frames = numel(info);
imheight=info(1).Height; %Sets height
imwidth=info(1).Width; %Sets width
im=zeros(imheight,imwidth,num_frames);
autoROIsave=get(handles.autosavebox,'Value');
for i=1:num_frames
    im(:,:,i)=imread(fullvidfile,i,'info',info);
    if floor(i/100)==(i/100) %show only every 100 frames progress
        display(['Loading video: ' num2str((i)/(num_frames)*100) '%']);
    end
end
display('Video loaded!');
savename=[fullvidfile(1:end-4) '_data' '.mat'];
ez_roigui(im,savename,autoROIsave)


% --- Executes on button press in loadcalciumbutton.
function loadcalciumbutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadcalciumbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[datafile,datafilepath]=uigetfile('*.tif','Select video');
fulldatafile=[datafilepath datafile];
set(hObject,'String',fulldatafile);

% --- Executes on button press in motcorhelp.
function motcorhelp_Callback(hObject, eventdata, handles)
% hObject    handle to motcorhelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ez_motcorhelp;


% --- Executes on button press in restartbutton.
function restartbutton_Callback(hObject, eventdata, handles)
% hObject    handle to restartbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all
clear all
ez_calcium;


% --- Executes on button press in autoloadbox.
function autoloadbox_Callback(hObject, eventdata, handles)
% hObject    handle to autoloadbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoloadbox


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%----------Simple parse---------------------
correctiontype=(get(handles.radiobutton2,'Value')); %finds value of radio button (1 channel or not one channel)
referenceframe=str2double(get(handles.refframe,'String'));
blocksize=str2double(get(handles.block,'String'));
fullvidfile=(get(handles.pushbutton1,'String')); %file name of chan 1 data
fullvidfile1=(get(handles.pushbutton1,'String')); %file name of chan 1 data
fullvidfile2=(get(handles.pushbutton2,'String')); %file name of chan 2 data
%-----------End simple parse----------------

%------------Autoload Feature---------------
autoloadstatus=(get(handles.autoloadbox,'Value'));

if autoloadstatus==1 %Autoloads if box checked
    
    %Sets file of ROI Selection by adding ending that would be added in motion correction
    if correctiontype==1
        roihandle=[fullvidfile(1:end-4) '_ezmcor1' '.tif'];
    else
        roihandle=[fullvidfile1(1:end-4) '_ezmcor2_ch1' '.tif'];
    end
    
    set(handles.loadcalciumbutton,'String',roihandle);
    
end
%------------End Autoload Feature------------

if correctiontype==1
    %1 channel correction
    %ez_motion_correct_1channel_1step(fullvidfile,referenceframe,blocksize);
    
    
    ez_motion_correct_1channel(fullvidfile,referenceframe,blocksize);
   
else
    %2 channel correction
    
    ez_motion_correct_2channel_1step_fast(fullvidfile1,fullvidfile2,referenceframe,blocksize);
    
end


% --- Executes on button press in autosavebox.
function autosavebox_Callback(hObject, eventdata, handles)
% hObject    handle to autosavebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autosavebox
