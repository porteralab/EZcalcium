function varargout = ez_noise_reduction(varargin)
% EZ_NOISE_REDUCTION MATLAB code for ez_noise_reduction.fig
%      EZ_NOISE_REDUCTION, by itself, creates a new EZ_NOISE_REDUCTION or raises the existing
%      singleton*.
%
%      H = EZ_NOISE_REDUCTION returns the handle to a new EZ_NOISE_REDUCTION or the handle to
%      the existing singleton*.
%
%      EZ_NOISE_REDUCTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EZ_NOISE_REDUCTION.M with the given input arguments.
%
%      EZ_NOISE_REDUCTION('Property','Value',...) creates a new EZ_NOISE_REDUCTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ez_noise_reduction_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ez_noise_reduction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ez_noise_reduction

% Last Modified by GUIDE v2.5 08-Jul-2019 15:01:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ez_noise_reduction_OpeningFcn, ...
                   'gui_OutputFcn',  @ez_noise_reduction_OutputFcn, ...
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


% --- Executes just before ez_noise_reduction is made visible.
function ez_noise_reduction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ez_noise_reduction (see VARARGIN)

% Choose default command line output for ez_noise_reduction
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ez_noise_reduction wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ez_noise_reduction_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushload.
function pushload_Callback(hObject, eventdata, handles)
% hObject    handle to pushload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,filepath]=uigetfile('*.tif','Please select your video file!');
fullfile=[filepath file];
set(hObject,'String',fullfile);

% --- Executes on button press in pushgo.
function pushgo_Callback(hObject, eventdata, handles)
% hObject    handle to pushgo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%=====================Data Parse=======================
fullvidfile=(get(handles.pushload,'String')); %file name of chan 1 data
baselineframes=str2double(get(handles.baselineframes,'String'));
%=====================End Data Parse=======================


%=====================Load Video=======================
display('Starting subthreshold noise reduction!');

vidinfo=imfinfo(fullvidfile); %Checks video file information
if vidinfo(1).FileSize>800000000 %Checks file size
    fprintf(2,'Warning!!! Files greater than 800MB should only be used with 64-bit MATLAB!') %this is a MATLAB problem.
    %Use a 64 bit version of MATLAB (designated with a 'b' at the end of
    %the version with a 64 bit computer on a 64 bit operating system to
    %handle files greater than 800MB. Matrix size limit is actually just over
    %1GB, but you need extra room for the purpose of motion correction.
end
num_frames=numel(vidinfo); %extracts number of frame information

nonzero_min=floor(0.05*num_frames);
quant=0.10;

vidheight=vidinfo(1).Height; %Sets height
vidwidth=vidinfo(1).Width; %Sets width
%vidpixels=vidwidth*vidheight; %Number of pixels per field
videodata=NaN(vidheight,vidwidth,num_frames); %Makes zero matrix for speed
parfor i = 1:num_frames %Loads every frame of the video
    videodata(:,:,i)=imread(fullvidfile,i,'info',vidinfo); %reads each frame and writes into greenchannel matrix
    if floor(i/100)==(i/100) %show only every 100 frames progress
        display(['Loading video: ' num2str((1-(i)/(num_frames))*100) '%']);
    end
end

display('Video loaded!');
%===================End Load Video========================


%==================calculate baseline fluorescence=================
tic

%         %----Serial Computing---
% display('Calculating baseline fluorescence values: 0%');
%         basecalc=NaN(1,num_frames-baselineframes+1);
%         fbaseline=NaN(vidheight,vidwidth);
%         fbaselinestd=NaN(vidheight,vidwidth);
%         mindex=NaN(vidheight,vidwidth);
        

% for i=1:vidheight  
%     for j=1:vidwidth
%         for k=1:num_frames-baselineframes+1 %find 5 seconds of baseline. recalc based on framerate
%             basecalc(k)=std(videodata(i,j,k:k+baselineframes-1)); %checks std for all values
%         end
%         [~,mindex(i,j)]=min(basecalc); %calculate the position of lowest deviation for baseline
%         fbaseline(i,j)=mean(videodata(i,j,mindex(i,j):mindex(i,j)+baselineframes-1));
%         fbaselinestd(i,j)=std(videodata(i,j,mindex(i,j):mindex(i,j)+baselineframes-1));
%     end
%     calctoc=toc;
%     display(['Calculating baseline fluorescence values: ' num2str((i)/(vidheight)*100) '%']);
%     display(['Estimated time remaining: ' num2str((calctoc*(vidheight)/(i)-calctoc)/60) ' minutes']);
% end
 
        %----- Vectorized Computing-----
        
        display('Calculating baseline fluorescence values: 0%');
        basecalc=NaN(vidheight,vidwidth,num_frames-baselineframes+1);
        %         fbaseline=NaN(vidheight,vidwidth);
        %         fbaselinestd=NaN(vidheight,vidwidth);
        %         mindex=NaN(vidheight,vidwidth);
        
        progress=0;
        progresswait=10;
       
        
        for k=1:num_frames-baselineframes+1 %find 10 seconds of baseline. recalc based on framerate
            
%             if size(find(videodata(:,:,k:k+baselineframes-1)),1)<baselineframes %Checks that all frames are nonzero
%             basecalc(:,:,k)=NaN;
%             else
            basecalc(:,:,k)=std(videodata(:,:,k:k+baselineframes-1),0,3); %checks std for all values
%             end
            %Progress every 10 pixels
            progress=progress+1;
            if progress>=progresswait
                calctoc=toc;
                display(['Calculating baseline fluorescence values: ' num2str((k)/(num_frames-baselineframes+1)*100) '%']);
                display(['Estimated time remaining: ' num2str((calctoc*(num_frames-baselineframes+1)/(k)-calctoc)/60) ' minutes']);
                progress=0;
            end
        end
        
         
        
        
        [~,mindex]=nanmin(basecalc,[],3); %calculate the position of lowest deviation for baseline
%         quantindex=round(quant*(num_frames-1)+1); %quantile version
%         quantcalc=sort(basecalc,3); %quantile version
%         
%         mindex=NaN(vidheight,vidwidth);
        
%         for i=1:vidheight
%             parfor j=1:vidwidth
%                 mindex(i,j)=find(basecalc(i,j,:)==quantcalc(i,j,quantindex),1); %quantile version
%             end
%         end
        
        %clear basecalc
        fbaseline=mean(videodata(:,:,mindex:mindex+baselineframes-1),3);
        fbaselinestd=std(videodata(:,:,mindex:mindex+baselineframes-1),0,3);
        
        
        
        %================end calculate baseline Fluorescence=================
        
        
        %=================Calculate Z_F==================================
        
        Z_F=NaN(vidheight,vidwidth,num_frames);
        parfor i=1:vidheight
            for j=1:vidwidth
                if fbaselinestd(i,j)>0
                    Z_F(i,j,:)=(videodata(i,j,:)-fbaseline(i,j))/fbaselinestd(i,j);
                end
%                 %Checks to see if number of non-zero frames exceeds threshold
%                 if size(find(Z_F(i,j,:)==min(Z_F(i,j,:))),1)>nonzero_min
%                     Z_F(i,j,:)=0;
%                     
%                     %Checks to see if pixels are blown out
%                 else if size(find(Z_F(i,j,:)==max(Z_F(i,j,:))),1)>nonzero_min
%                         Z_F(i,j,:)=0;
%                     end
%                 end
                
            end
        end
        
        clear videodata
        %Save Z_F data
        save('Z_F_data','Z_F','-v7.3');
        
        Z_F_scale=Z_F/quantile(quantile(quantile(Z_F(isfinite(Z_F)),.999),1),1);
        %Z_F_scale=Z_F/nanmax(nanmax(nanmax(Z_F(isfinite(Z_F)))));
        %Write Video
        for imagedex = 1:num_frames
            if imagedex==1 %for the first picture, overwrite. Then, append. This is a temporary file.
                imwrite(Z_F_scale(:,:,imagedex),'Z_F.tif','tiff','Compression','none','WriteMode','overwrite');
            else %appends the rest of the images to the file in order
                imwrite(Z_F_scale(:,:,imagedex),'Z_F.tif','tiff','Compression','none','WriteMode','append');
            end
        end
        clear Z_F_scale
        
        
        display('Done with Z_F!')
        
        toc


%Find average tiff file (mean of Z stack) for first pass
% greenchannelmean=mean(videodata,3); %calculates mean along the 3rd dimension
% 
% 
% 
% 
% imwrite(greenchannelmeanscale,[fullvidfile(1:end-4) '_quiet' '.tif'],'tiff','Compression','lzw') %writes tiff with no compression



function baselineframes_Callback(hObject, eventdata, handles)
% hObject    handle to baselineframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baselineframes as text
%        str2double(get(hObject,'String')) returns contents of baselineframes as a double


% --- Executes during object creation, after setting all properties.
function baselineframes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baselineframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
