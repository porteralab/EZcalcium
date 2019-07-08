function [progress]=ez_roi_autoselect_process(fullvidfile,autoroi,handles,progress)

%Based on code by Patrick Mineault



%Current File Progress: handles.file_progress
%Overall progress: handles.overall_progress
%Estimated time: handles.time_remaining


%=============Parse inputs================

%Read compression
if autoroi.compression==1
    compression='none';
elseif autoroi.compression==2
    compression='lzw';
elseif autoroi.compression==3
    compression='packbits';
elseif autoroi.compression==4
    compression='deflate';
end


set(handles.status_bar, 'String', 'Checking Video');
progress.current_file=1;
set(handles.file_progress, 'String',[num2str(progress.current_file) '%']);
drawnow;

videoinfo=imfinfo(fullvidfile); %Checks video file information
if videoinfo(1).FileSize>800000000 %Checks file size
    fprintf(2,'Warning!!! Files greater than 800MB should only be used with 64-bit MATLAB!') %this is a MATLAB problem.
    %Use a 64 bit version of MATLAB (designated with a 'b' at the end of
    %the version with a 64 bit computer on a 64 bit operating system to
    %handle files greater than 800MB. Matrix size limit is actually just over
    %1GB, but you need extra room for the purpose of motion correction.
end
num_frames=numel(videoinfo); %extracts number of frame information

videoheight=videoinfo(1).Height; %Sets height
videowidth=videoinfo(1).Width; %Sets width
videochannel=zeros(videoheight,videowidth,num_frames); %Makes zero matrix for speed

set(handles.status_bar, 'String', 'Loading Video');
drawnow;

parfor i = 1:num_frames %Loads every frame of the video
    videochannel(:,:,i)=imread(fullvidfile,i,'info',videoinfo); %reads each frame and writes into videochannel matrix
    if floor(i/100)==(i/100) %show only every 100 frames progress    
        set(handles.status_bar, 'String', ['Loading video: ' num2str(round(10*(100*(1-i/num_frames)))/10) '%']);
        current_prog=round(10*(1+9*(1-i/num_frames)))/10;
        autoroi_update_overall(handles,progress,current_prog);
        set(handles.file_progress, 'String', [num2str(current_prog) '%']);
        drawnow; %update GUI
    end
end
set(handles.status_bar, 'String', 'Video loaded!');
drawnow; %update GUI
current_prog=10; %set current progress to 10
set(handles.file_progress, 'String', [num2str(current_prog) '%']);
autoroi_update_overall(handles,progress,current_prog);




if autoroi.frames_box==1
   autoroi.frames_start=1;
   autoroi.frames_end=num_frames;
end

if autoroi.template_style==1
    mc_template=mean(videochannel(:,:,autoroi.frames_start:autoroi.frames_end),3); %uses max projection
elseif autoroi.template_style==2
    mc_template=median(videochannel(:,:,autoroi.frames_start:autoroi.frames_end),3); %uses max projection
elseif autoroi.template_style==3
    mc_template=max(videochannel(:,:,autoroi.frames_start:autoroi.frames_end),[],3); %uses max projection
elseif autoroi.template_style==4
    %------Find brightest frame---------
    frame_brightness=squeeze(sum(sum(videochannel(:,:,autoroi.frames_start:autoroi.frames_end),2),1));
    brightest_frame=find(frame_brightness==median(frame_brightness),1,'first'); %median frame
    brightest_frame=find(frame_brightness==max(frame_brightness),1,'first');
    mc_template=videochannel(:,:,brightest_frame);
end


template_scale=mc_template/scalefactor; %scales so that the max value in the mean image is equal to white (1)
%videochannelmeanscale=videochannelmean/scalefactor_template; %scales so that the max value in the mean image is equal to white (1)




%Save template
if autoroi.template==1 
    imwrite(template_scale,[fullvidfile(1:end-4) '_template' '.tif'],'tiff','Compression',compression)
end


%---------First Pass--------------
T=mc_template; %template image
firstId=zeros(videoheight,videowidth,num_frames);
firstIdscale=firstId;

set(handles.status_bar, 'String', 'Aligning Images');
drawnow; %update GUI
%Parallel image alignment, count as 60% of progress, 70% if no BG sub
parfor imagedex = 1:num_frames %For every frame of the video
    if floor(imagedex/10)==(imagedex/10) %show only every 10 frames progress
        display(['Progress: ' num2str(round(10*(1-imagedex/num_frames)*100)/10) '%']);
        current_prog=round(10*(10+BG+(70-BG)*(1-imagedex/num_frames)))/10;
        set(handles.file_progress, 'String', [num2str(current_prog) '%']);
        autoroi_update_overall(handles,progress,current_prog);
    end
    
    I=videochannel(:,:,imagedex); %loads one frame at a time
    %[firstId,firstdpx(imagedex,:),firstdpy(imagedex,:)]=doLucasKanade(T,I); %runs the motion correction code
    [firstId(:,:,imagedex),~,~]=doLucasKanade(T,I,Nbasis); %runs the motion correction code
    firstIdscale(:,:,imagedex)=firstId(:,:,imagedex)/scalefactor;
    
end
%toc


%Save max projection
if autoroi.max==1 
    imwrite(max(firstIdscale,[],3),[fullvidfile(1:end-4) '_max' '.tif'],'tiff','Compression',compression)
end

%Save video file, count as 20% of progress
set(handles.status_bar, 'String', 'Saving Corrected Video');
        drawnow; %update GUI
        progress.newfile=[fullvidfile(1:end-4) '_mcor' '.tif'];
imwrite(firstIdscale(:,:,1),progress.newfile,'tiff','Compression',compression,'WriteMode','overwrite');
for imagedex = 2:num_frames %start at frame two and append to first image
    if floor(imagedex/10)==(imagedex/10) %show only every 10 frames progress
        current_prog=round(10*(80+20*(imagedex/num_frames)))/10;
        autoroi_update_overall(handles,progress,current_prog);
        set(handles.status_bar, 'String','Saving Video');
        set(handles.file_progress, 'String', [num2str(current_prog) '%']);
        drawnow; %update GUI
    end
    imwrite(firstIdscale(:,:,imagedex),progress.newfile,'tiff','Compression',compression,'WriteMode','append');
end

%Save .mat file (workspace)
if autoroi.workspace==1 
    save([fullvidfile(1:end-4) '_autoroi_mat'])
end

set(handles.status_bar, 'String', 'Correction Complete!');
        drawnow; %update GUI

%toc
end



function autoroi_update_overall(handles,progress,current_prog)

file_num=progress.current_file;
total_files=progress.to_process_size;

overall=current_prog/100/total_files+(file_num-1)/total_files;
overall_round=round(10*overall*100)/10;
set(handles.overall_progress, 'String', [num2str(overall_round) '%']);

elapsed_time=toc(progress.tic); %time passed in sec

timepoint=elapsed_time/overall-elapsed_time; %time remaining in sec

if timepoint>3600 %display time in hours
    set(handles.time_remaining, 'String', [num2str(round(10*timepoint/3600)/10) ' hr']);
else if timepoint>60 %display time in minutes 
        set(handles.time_remaining, 'String', [num2str(round(10*timepoint/60)/10) ' min']);
    else %display time in seconds
        set(handles.time_remaining, 'String', [num2str(round(10*timepoint)/10) ' sec']);
    end
end

drawnow;

end
