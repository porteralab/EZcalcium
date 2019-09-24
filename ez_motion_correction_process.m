function [progress,motcor]=ez_motion_correction_process(fullvidfile,motcor,handles,progress)


%Based on code by Patrick Mineault
test=tic;
%Current File Progress: handles.file_progress
%Overall progress: handles.overall_progress
%Estimated time: handles.time_remaining


%=============Parse inputs================

%Read compression
if motcor.compression==1
    compression='none';
elseif motcor.compression==2
    compression='lzw';
elseif motcor.compression==3
    compression='packbits';
elseif motcor.compression==4
    compression='deflate';
end

%Read output
if motcor.output==1
    bits=16;
elseif motcor.output==2
    bits=8;
elseif motcor.output==3
    bits=1;
elseif motcor.output==4
    bits=2;
end

%Read block size
Nbasis=str2double(motcor.block_size);
%animation_position=1; %initialize

%Initilize timing
load_time_relative=(motcor.load_time_relative);
align_time_relative=(motcor.align_time_relative);
save_time_relative=(motcor.save_time_relative);



%tic


%============Iterative Motion Correction================================

iterations=floor(str2double(motcor.iterations)); %whole numbers only
if iterations<1 %minimum 1 pass
    iterations=1;
end

%===========================Check filetype================================
extension_index=strfind(fullvidfile,'.');
extension=fullvidfile(extension_index(end)+1:end);
vidfile_name=fullvidfile(1:extension_index-1);

set(handles.overall_progress, 'String','0%');
% progress.current_file=progress.current_file+1;
for iteration=1:iterations
    load_tic=tic; %Mark start of load timing
    
    set(handles.status_bar, 'String', 'Checking Video');
    set(handles.file_progress, 'String','0%');
    set(handles.current_iteration, 'String', num2str(iteration));
    drawnow;
    
    %Find mean times
    load_time=mean(load_time_relative);
    align_time=mean(align_time_relative);
    save_time=mean(save_time_relative);
    
    if iteration >1 %update file name
        if bits==1
            fullvidfile=[vidfile_name '_mcor' num2str(iteration-1) '.mat'];
            extension='mat';
        elseif bits==2
            fullvidfile=[vidfile_name '_mcor' num2str(iteration-1) '.avi'];
            extension='avi';
        else
            fullvidfile=[vidfile_name '_mcor' num2str(iteration-1) '.tif'];
            extension='tif';
        end
        
    end
    
    if motcor.template_style>=6 %Low RAM version of the code
        
        %Check for file compatibility (must be TIFF for loading and saving
        %in a stepwise manner!)
        if bits==1
            set(handles.status_bar, 'String', 'Incompatible Output');
            drawnow;
            warning_text='Only loading and saving TIFF files are compatible with the low RAM version of motion correction';
            ez_warning_small(warning_text);
            return
        elseif bits==2
            set(handles.status_bar, 'String', 'Incompatible Output');
            drawnow;
            warning_text='Only loading and saving TIFF files are compatible with the low RAM version of motion correction';
            ez_warning_small(warning_text);
            return
        end
        
        if strcmpi(extension,'tif') || strcmpi(extension,'tiff')
            set(handles.status_bar, 'String', 'Loading Video');
            drawnow;
        else
            set(handles.status_bar, 'String', 'Incompatible Input');
            drawnow;
            warning_text='Only loading and saving TIFF files are compatible with the low RAM version of motion correction';
            ez_warning_small(warning_text);
            return
        end
        
        batch_size=str2double(motcor.batch);
        if batch_size<100
            set(handles.status_bar, 'String', 'Batch Size Small');
            drawnow;
            warning_text='Low RAM Batch Size must be at least 100 frames';
            ez_warning_small(warning_text);
            return
        end
        
        
        vid_info=imfinfo(fullvidfile); %Checks video file information
        
        %num_frames=numel(vid_info); %extracts number of frame information
        vid_height=vid_info(1).Height; %Sets height
        vid_width=vid_info(1).Width; %Sets width
        
        
        %Calculate number of batches of 100 frames to perform
        num_frames=numel(vid_info); %Find number of frames
        
        
        if num_frames==1 %Checks for read errors
            set(handles.status_bar, 'String', 'Reading error');
            drawnow;
            warning_text='Only 1 frame was detected. Either the incorrect video or a very large compressed TIFF file was chosen. TIFF files >4GB must be uncompressed.';
            ez_warning_small(warning_text);
            return
        end
        if num_frames<2*batch_size
            set(handles.status_bar, 'String', 'Reading error');
            drawnow;
            warning_text='Low RAM mode requires at least twice as many frames in your video as the chosen batch size';
            ez_warning_small(warning_text);
            return
        end
        
        batch_total=ceil(num_frames/batch_size); %find number of batches of batch_size frames
        final_batch_size=num_frames-batch_total*batch_size+batch_size; %Find the number of frames in the final batch
        
        if motcor.template_style==6 %Low RAM Mean Frame
            if motcor.frames_box==1 %If Use All Frames box is checked
                frames_start=1; %Start template at the first frame
                frames_end=num_frames; %End template at the final frame
            else
                frames_start=(motcor.frames_start); %Template start
                frames_end=(motcor.frames_end); %Template end
            end
            
            template_num_frames=frames_end-frames_start+1; %Calculate number of frames in the template
            
            if template_num_frames<batch_size*2
                image_data=zeros(vid_height,vid_width,template_num_frames); %Initialize data matrix
                parfor i = 1:template_num_frames %Loads every frame of the video
                    image_data(:,:,i)=imread(fullvidfile,i+frames_start-1,'info',vid_info); %Read the frame
                end
                template=(mean(image_data,3)); %Calculate template
                max_projection=(max(image_data,[],3));
                min_projection=(min(image_data,[],3));
                % clear image_data
                
                
            else %more than twice the batch size
                
                template_batch_total=ceil(template_num_frames/batch_size); %find number of batches of batch_size frames
                final_template_batch_size=template_num_frames-template_batch_total*batch_size+batch_size; %size of final batch
                image_data=zeros(vid_height,vid_width,batch_size); %initialize frame holding matrix for batch video info
                
                template_mean_frames=zeros(vid_height,vid_width,template_batch_total); %Initialize mean frames for each batch
                template_max_frames=template_mean_frames;
                template_min_frames=template_mean_frames;
                
                
                for template_batch = 1:template_batch_total-1
                    parfor i = 1:batch_size %Loads every frame of the video
                        image_data(:,:,i)=imread(fullvidfile,(template_batch-1)*batch_size+i+frames_start-1,'info',vid_info); %Read the frame
                    end
                    template_mean_frames(:,:,template_batch)=mean(image_data,3); %Take the mean of the batch, store it
                    template_min_frames(:,:,template_batch)=min(image_data,[],3);
                    template_max_frames(:,:,template_batch)=max(image_data,[],3);
                end
                
                template_batch=template_batch_total; %For final frame of the template
                image_data=zeros(vid_height,vid_width,final_template_batch_size);
                parfor i = 1:final_template_batch_size %Loads every frame of the video
                    image_data(:,:,i)=imread(fullvidfile,(template_batch-1)*final_template_batch_size+i+frames_start-1,'info',vid_info); %Read the frame
                end
                template_mean_frames(:,:,template_batch)=mean(image_data,3); %Take the mean of the final batch, store it
                
                %Calculate the mean template, clear unneeded data
                template=(mean(template_mean_frames,3)); %mean image
                max_projection=max(template_max_frames,[],3);
                min_projection=min(template_min_frames,[],3);
                
                %                 clear image_data
                %                 clear template_mean_frames
                %                 clear template_min_frames
                %                 clear template_max_frames
            end
            
            %Scale template output
            
            scaleblack=min(min(template));
            template_scale=template-scaleblack;
            scalefactor=max(max(max_projection));
            scaleblack_template=min(min(min_projection));
            template_scale=template_scale-scaleblack_template;
            template_scale=template_scale/double(scalefactor);
            
            clear max_projection
            clear min_projection
            
            %Save template
            if motcor.template==1
                if bits==16
                    imwrite(im2uint16(template_scale),[vidfile_name '_template' '.tif'],'tiff','Compression',compression)
                else
                    imwrite(im2uint8(template_scale),[vidfile_name '_template' '.tif'],'tiff','Compression',compression)
                end
            end
            
            
            load_toc=toc(load_tic); %end of load timing
            align_tic=tic; %start of alignment timing
            
            %==================Image Alignment!=================
            
            set(handles.status_bar, 'String', 'Aligning Images');
            drawnow; %update GUI
            
            
            %--------Start GPU processing--------
            %image_data=gpuArray(zeros(vid_height,vid_width,batch_size));
            image_data=(zeros(vid_height,vid_width,batch_size));
            %             template=gpuArray(template);
            %             Nbasis=gpuArray(Nbasis);
            %             scalefactor=gpuArray(scalefactor);
            %image_data=zeros(vid_height,vid_width,batch_size);
            
            
            if motcor.max==1
                %max_project_calc=gpuArray(zeros(vid_height,vid_width,batch_total));
                max_project_calc=(zeros(vid_height,vid_width,batch_total));
            end
            
            %Set Tiff writing options
            options.overwrite=true; %Overwrite existing files of same name
            options.message=false; %Don't display messages
            options.append=false; %Don't append to file for first frame
            options.big=true; %Save as large tiff file
            
            if motcor.compression==1
                options.compress='no'; %Don't compress if none selected
            else
                options.compress='lzw'; %Change all lossless compression options to LZW
            end
            
            for batch = 1:batch_total-1
                %Load every Frame in batch
                
                parfor i = 1:batch_size %Loads every frame of the video
                    image_data(:,:,i)=imread(fullvidfile,i+(batch-1)*batch_size,'info',vid_info); %Read the frame
                end
                
                %Align batch
                %========Call GPU Alignment=========
                
                
                %                 image_data = arrayfun( @doLucasKanade, ...
                %                     template, image_data, Nbasis);
                
                parfor imagedex = 1:batch_size %For every frame of the video
                    I=(image_data(:,:,imagedex)); %loads one frame at a time
                    [image_data(:,:,imagedex),~,~]=doLucasKanade(template,I,Nbasis); %runs the motion correction code
                    image_data(:,:,imagedex)=image_data(:,:,imagedex)/scalefactor;
                end
                
                
                
                %Find max of batch
                if motcor.max==1
                    max_project_calc(:,:,batch)=max(image_data,[],3);
                end
                
                %Update Progress
                %current_prog=load_time+round(align_time*(1+(align_time-1)*(1-batch/(batch_total-1))))/align_time;
                current_prog=load_time+round(align_time*(1+(align_time-1)*(batch/(batch_total-1))))/align_time;
                current_prog=round(current_prog*10)/10;
                motcor_update_overall(handles,progress,current_prog,iteration,iterations);
                set(handles.file_progress, 'String', [num2str(current_prog) '%']);
                drawnow; %update GUI
                
                %Background subtracted version
                if motcor.background_subtract==2 %Minimum pixel background subtraction
                    if batch==1
                        image_datamin=min(image_data,[],3); %finds min of all pixels in the first batch, to be applied to all batches
                    end
                    parfor i = 1:batch_size %Loads every frame of the video
                        image_data(:,:,i)=image_data(:,:,i)-image_datamin; %reads each frame and writes into image_data matrix
                    end
                end
                
                %End GPU Processing
                %image_data=gather(image_data);
                
                
                %Save batch
                if batch==1
                    if iteration==1
                        progress.newfile=[vidfile_name '_mcor1' '.tif'];
                    else
                        progress.newfile=[vidfile_name '_mcor' num2str(iteration) '.tif'];
                    end
                    
                    %Write first frame, set up new file
                    if bits==16
                        %imwrite(im2uint16(image_data(:,:,1)),progress.newfile,'tiff','Compression',compression,'WriteMode','overwrite');
                        saveastiff(im2uint16(image_data(:,:,1)), progress.newfile, options);
                    elseif bits==8
                        %imwrite(im2uint8(image_data(:,:,1)),progress.newfile,'tiff','Compression',compression,'WriteMode','overwrite');
                        saveastiff(im2uint8(image_data(:,:,1)), progress.newfile, options);
                    end
                    
                    %Start appending images
                    options.overwrite = false;
                    options.append = true;
                    
                    for imagedex = 2:batch_size %start at frame two and append to first image
                        if bits==16
                            %imwrite(im2uint16(image_data(:,:,imagedex)),progress.newfile,'tiff','Compression',compression,'WriteMode','append');
                            saveastiff(im2uint16(image_data(:,:,imagedex)), progress.newfile, options);
                        elseif bits==8
                            %imwrite(im2uint8(image_data(:,:,imagedex)),progress.newfile,'tiff','Compression',compression,'WriteMode','append');
                            saveastiff(im2uint8(image_data(:,:,imagedex)), progress.newfile, options);
                        end
                    end
                else %For all batches after the first
                    for imagedex = 1:batch_size %Append all frames to first batch
                        if bits==16
                            %imwrite(im2uint16(image_data(:,:,imagedex)),progress.newfile,'tiff','Compression',compression,'WriteMode','append');
                            saveastiff(im2uint16(image_data(:,:,imagedex)), progress.newfile, options);
                        elseif bits==8
                            %imwrite(im2uint8(image_data(:,:,imagedex)),progress.newfile,'tiff','Compression',compression,'WriteMode','append');
                            saveastiff(im2uint8(image_data(:,:,imagedex)), progress.newfile, options);
                        end
                    end
                end
            end
            
            align_toc=toc(align_tic); %end of alignment timing
            save_tic=tic; %start of saving timing
            
            %Final Batch
            image_data=zeros(vid_height,vid_width,final_batch_size);
            %Load every frame in final batch
            for i = 1:final_batch_size %Loads every frame of the video
                image_data(:,:,i)=imread(fullvidfile,i+(batch-1)*final_batch_size,'info',vid_info); %Read the frame
            end
            
            %             mex=tic;
            %             CompileMexFiles %compile Mex files
            %             toc(mex)
            
            %Align batch
            parfor imagedex = 1:final_batch_size %For every frame of the video
                I=image_data(:,:,imagedex); %loads one frame at a time
                [image_data(:,:,imagedex),~,~]=doLucasKanade(template,I,Nbasis); %runs the motion correction code
                image_data(:,:,imagedex)=image_data(:,:,imagedex)/scalefactor;
            end
            
            %Background subtracted version
            if motcor.background_subtract==2 %Minimum pixel background subtraction
                parfor i = 1:final_batch_size %Loads every frame of the video
                    image_data(:,:,i)=image_data(:,:,i)-image_datamin; %reads each frame and writes into image_data matrix
                end
            end
            
            %Find max of last batch
            if motcor.max==1
                max_project_calc(:,:,batch_total)=max(image_data,[],3);
            end
            
            %Update Progress
            %current_prog=load_time+round(save_time*(1+(save_time-1)*(1-batch/(batch_total-1))))/save_time;
            current_prog=load_time+align_time+round(save_time*(1-final_batch_size/batch_size));
            current_prog=round(current_prog*10)/10;
            motcor_update_overall(handles,progress,current_prog,iteration,iterations);
            set(handles.file_progress, 'String', [num2str(current_prog) '%']);
            drawnow; %update GUI
            
            %Save Max Projection
            if motcor.max==1
                if bits==16
                    imwrite(im2uint16(max(max_project_calc,[],3)),[vidfile_name '_max' '.tif'],'tiff','Compression',compression)
                else
                    imwrite(im2uint8(max(max_project_calc,[],3)),[vidfile_name '_max' '.tif'],'tiff','Compression',compression)
                end
            end
            
            %Save batch
            for imagedex = 1:final_batch_size %Append all frames to first batch
                if bits==16
                    %imwrite(im2uint16(image_data(:,:,imagedex)),progress.newfile,'tiff','Compression',compression,'WriteMode','append');
                    saveastiff(im2uint16(image_data(:,:,imagedex)), progress.newfile, options);
                elseif bits==8
                    %imwrite(im2uint8(image_data(:,:,imagedex)),progress.newfile,'tiff','Compression',compression,'WriteMode','append');
                    saveastiff(im2uint8(image_data(:,:,imagedex)), progress.newfile, options);
                end
            end
            
            
            %65536 frame length limit
            
            %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            
        elseif motcor.template_style==7 %Low RAM Previous Frame
            
            
            
            
            
            
        end
        %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        
    else %Regular RAM versions of the motion correction
        set(handles.status_bar, 'String', 'Loading Video');
        drawnow;
        %======================Tif/Tiff=========================
        if strcmpi(extension,'tif') || strcmpi(extension,'tiff')
            
            vid_info=imfinfo(fullvidfile); %Checks video file information
            
            %num_frames=numel(vid_info); %extracts number of frame information
            vid_height=vid_info(1).Height; %Sets height
            vid_width=vid_info(1).Width; %Sets width
            
            %=========Checks for compression=================
            if strcmp(vid_info(1).Compression,'Uncompressed') %Loads uncompressed videos
                image_data=loadtiff(fullvidfile);
                num_frames=size(image_data,3);
            else %Loads Compressed videos
                num_frames=numel(vid_info);
                image_data=zeros(vid_height,vid_width,num_frames); %Makes zero matrix for speed
                parfor i = 1:num_frames %Loads every frame of the video
                    image_data(:,:,i)=imread(fullvidfile,i,'info',vid_info); %reads each frame and writes into image_data matrix
                    if floor(i/100)==(i/100) %show only every 100 frames progress
                        
                        current_prog=round(load_time*(1+(load_time-1)*(1-i/num_frames)))/load_time;
                        current_prog=round(current_prog*10)/10;
                        motcor_update_overall(handles,progress,current_prog,iteration,iterations);
                        set(handles.file_progress, 'String', [num2str(current_prog) '%']);
                        drawnow; %update GUI
                    end
                end
            end
            
            %Checks for read errors
            if num_frames==1
                warning_text='Only 1 frame was detected. Either the incorrect video or a very large compressed TIFF file was chosen. TIFF files >4GB must be uncompressed.';
                ez_warning_small(warning_text);
            end
            
            
            
            
            %=====================Mat file==========================
        elseif strcmpi(extension,'mat')
            %This automatically detects and loads the largest variable in the workspace
            %load(fullvidfile);
            %Find data matrix
            
            %get data from the mat file
            matObj=matfile(fullvidfile);
            check_mat=whos(matObj);
            workspace_length=size(check_mat,1); %number of variables in workspace
            variable_sizes=zeros(workspace_length,1); %initialize
            for i=1:workspace_length
                variable_sizes(i)=check_mat(i,1).bytes; %check size of variables
            end
            [~,largest_variable]=max(variable_sizes); %find largest variable
            largest_variable_name=check_mat(largest_variable,1).name; %name of largest variable
            image_data=load(fullvidfile,largest_variable_name); %loads largest variable
            image_data=image_data.(largest_variable_name); %convert structure to matrix
            
            %====================AVI file===========================
        elseif strcmpi(extension,'avi')
            videoObj = VideoReader(fullvidfile);
            num_frames = ceil(videoObj.FrameRate*videoObj.Duration);
            frame_rate= videoObj.FrameRate;
            vid_height=videoObj.Height; %Sets height
            vid_width=videoObj.Width;
            
            image_data=zeros(vid_height,vid_width,num_frames); %Makes zero matrix for speed
            for i = 1:num_frames %Loads every frame of the video
                videoObj.CurrentTime=(i-1)/frame_rate;
                image_data(:,:,i)=readFrame(videoObj); %reads each frame and writes into image_data matrix
                if floor(i/100)==(i/100) %show only every 100 frames progress
                    
                    current_prog=round(load_time*(i/num_frames));
                    current_prog=round(current_prog*10)/10;
                    motcor_update_overall(handles,progress,current_prog,iteration,iterations);
                    set(handles.file_progress, 'String', [num2str(current_prog) '%']);
                    drawnow; %update GUI
                end
            end
            
            
        else
            warning_text=['The selected file ' fullvidfile ' is not a supported file type.'];
            ez_warning_small(warning_text);
            return
            
        end
        %=======================End Check Filetype================================
        
        set(handles.status_bar, 'String', 'Video loaded!');
        drawnow; %update GUI
        image_data=im2double(image_data); %convert to double
        vid_height=size(image_data,1); %Sets height
        vid_width=size(image_data,2);
        num_frames=size(image_data,3);
        
        
        
        
        
        if motcor.frames_box==1
            frames_start=1;
            frames_end=num_frames;
        else
            frames_start=(motcor.frames_start);
            frames_end=(motcor.frames_end);
        end
        
        
        if motcor.template_style==1
            mc_template=mean(image_data(:,:,frames_start:frames_end),3); %uses max projection
        elseif motcor.template_style==2
            mc_template=median(image_data(:,:,frames_start:frames_end),3); %uses max projection
        elseif motcor.template_style==3
            mc_template=max(image_data(:,:,frames_start:frames_end),[],3); %uses max projection
        elseif motcor.template_style==4
            %------Find brightest frame---------
            frame_brightness=squeeze(sum(sum(image_data(:,:,frames_start:frames_end),2),1));
            %brightest_frame=find(frame_brightness==median(frame_brightness),1,'first'); %median frame
            brightest_frame=find(frame_brightness==max(frame_brightness),1,'first');
            mc_template=image_data(:,:,brightest_frame);
        elseif motcor.template_style==5
            mc_template=image_data(:,:,frames_start);
        end
        
        
        
        set(handles.status_bar, 'String', 'Generating Template');
        drawnow; %update GUI
        
        
        scaleblack=min(min(min(image_data)));
        image_data=image_data-scaleblack;
        scalefactor=max(max(max(image_data)));
        
        scaleblack_template=min(min(min(mc_template)));
        mc_template=mc_template-scaleblack_template;
        
        template_scale=mc_template/double(scalefactor); %scales so that the max value in the mean image is equal to white (1)
        
        %Save template
        if motcor.template==1
            if bits==16
                imwrite(im2uint16(template_scale),[vidfile_name '_template' '.tif'],'tiff','Compression',compression)
            else
                imwrite(im2uint8(template_scale),[vidfile_name '_template' '.tif'],'tiff','Compression',compression)
            end
        end
        
        
        load_toc=toc(load_tic); %end of load timing
        align_tic=tic; %start of alignment timing
        
        %---------First Pass--------------
        T=mc_template; %template image
        
        set(handles.status_bar, 'String', 'Aligning Images');
        drawnow; %update GUI
        
        
        if motcor.template_style==5 %for serial alignment of images
            for imagedex = 1:num_frames
                if floor(imagedex/10)==(imagedex/10) %show only every 10 frames progress
                    current_prog=load_time+round(align_time-(align_time*(1+(align_time-1)*(1-imagedex/num_frames)))/align_time);
                    current_prog=round(current_prog*10)/10;
                    motcor_update_overall(handles,progress,current_prog,iteration,iterations);
                    set(handles.file_progress, 'String', [num2str(current_prog) '%']);
                    drawnow; %update GUI
                end
                if imagedex>1
                    T=image_data(:,:,imagedex-1);
                end
                I=image_data(:,:,imagedex); %loads one frame at a time
                [image_data(:,:,imagedex),~,~]=doLucasKanade(T,I,Nbasis); %runs the motion correction code
                image_data(:,:,imagedex)=image_data(:,:,imagedex)/scalefactor;
            end
        else %for parallel image alignment
            parfor imagedex = 1:num_frames %For every frame of the video
                if floor(imagedex/10)==(imagedex/10) %show only every 10 frames progress
                    current_prog=load_time+round(align_time*(1+(align_time-1)*(1-imagedex/num_frames)))/align_time;
                    current_prog=round(current_prog*10)/10;
                    motcor_update_overall(handles,progress,current_prog,iteration,iterations);
                    set(handles.file_progress, 'String', [num2str(current_prog) '%']);
                    drawnow; %update GUI
                end
                
                I=image_data(:,:,imagedex); %loads one frame at a time
                %[firstId,firstdpx(imagedex,:),firstdpy(imagedex,:)]=doLucasKanade(T,I); %runs the motion correction code
                [image_data(:,:,imagedex),~,~]=doLucasKanade(T,I,Nbasis); %runs the motion correction code
                image_data(:,:,imagedex)=image_data(:,:,imagedex)/scalefactor;
                
            end
        end
        %toc
        
        %---Background subtracted version----
        if motcor.background_subtract==2 %Minimum pixel background subtraction
            image_datamin=min(image_data,[],3); %finds min of all pixels
            parfor i = 1:num_frames %Loads every frame of the video
                image_data(:,:,i)=image_data(:,:,i)-image_datamin; %reads each frame and writes into image_data matrix
                if floor(i/100)==(i/100) %show only every 100 frames progress
                    set(handles.status_bar, 'String',['Removing BG: ' num2str(round(10*(1-(i)/(num_frames))*100)/10) '%']);
                    drawnow;
                end
            end
        end
        
        align_toc=toc(align_tic); %end of alignment timing
        save_tic=tic; %start of saving timing
        
        %Save max projection
        if motcor.max==1
            if bits==16
                imwrite(im2uint16(max(image_data,[],3)),[vidfile_name '_max' '.tif'],'tiff','Compression',compression)
            else
                imwrite(im2uint8(max(image_data,[],3)),[vidfile_name '_max' '.tif'],'tiff','Compression',compression)
            end
        end
        
        %Save video file
        set(handles.status_bar, 'String', 'Saving Corrected Video');
        drawnow; %update GUI
        
        if iteration==1
            progress.newfile=[vidfile_name '_mcor1' '.tif'];
        else
            progress.newfile=[vidfile_name '_mcor' num2str(iteration) '.tif'];
        end
        
        if bits==16
            imwrite(im2uint16(image_data(:,:,1)),progress.newfile,'tiff','Compression',compression,'WriteMode','overwrite');
        elseif bits==8
            imwrite(im2uint8(image_data(:,:,1)),progress.newfile,'tiff','Compression',compression,'WriteMode','overwrite');
        elseif bits==1 %Saves data as .mat file
            progress.newfile=[progress.newfile(1:end-4) '.mat'];
            save(progress.newfile,'image_data')
        elseif bits==2
            progress.newfile=[progress.newfile(1:end-4) '.avi'];
            writeObj=VideoWriter(progress.newfile,'Grayscale AVI');
            open(writeObj);
            writeVideo(writeObj,image_data);
            close(writeObj);
        end
        
        
        for imagedex = 2:num_frames %start at frame two and append to first image
            if floor(imagedex/10)==(imagedex/10) %show only every 10 frames progress
                current_prog=load_time+align_time+round(save_time-(save_time*(1+(save_time-1)*(1-imagedex/num_frames)))/save_time); %calculate video
                current_prog=round(current_prog*10)/10; %rounds to one decimal place
                motcor_update_overall(handles,progress,current_prog,iteration,iterations);
                set(handles.file_progress, 'String', [num2str(current_prog) '%']);
                drawnow; %update GUI
            end
            if bits==16
                imwrite(im2uint16(image_data(:,:,imagedex)),progress.newfile,'tiff','Compression',compression,'WriteMode','append');
            elseif bits==8
                imwrite(im2uint8(image_data(:,:,imagedex)),progress.newfile,'tiff','Compression',compression,'WriteMode','append');
            end
        end
        
        
    end %End for splitting low and regular RAM versions
    
    current_prog=100; %rounds to one decimal place
    motcor_update_overall(handles,progress,current_prog,iteration,iterations);
    set(handles.file_progress, 'String', [num2str(current_prog) '%']);
    drawnow; %update GUI
    %--------Delete previous iteration--------
    %previous iteration
    
    if bits==1
        previous_iteration=[vidfile_name '_mcor' num2str(iteration-1) '.mat'];
    elseif bits==2
        previous_iteration=[vidfile_name '_mcor' num2str(iteration-1) '.avi'];
    else
        previous_iteration=[vidfile_name '_mcor' num2str(iteration-1) '.tif'];
    end
    
    
    if iteration>1
        delete(previous_iteration);
    end
    
    %------End Delete previous iteration--------
    
    %Finish timing
    save_toc=toc(save_tic); %end of alignment timing
    total_toc=save_toc+align_toc+load_toc; %find total time elapsed
    
    %Find relative values
    load_time_relative(end+1)=round(100*load_toc/total_toc);
    if load_time_relative(end)<1
        load_time_relative(end)=1;
    end
    align_time_relative(end+1)=round(100*align_toc/total_toc);
    if align_time_relative(end)<1
        align_time_relative(end)=1;
    end
    save_time_relative(end+1)=(100-load_time_relative(end)-align_time_relative(end)); %to ensure all numbers add to 100
    
    %Remove oldest value from timing matrices
    load_time_relative=load_time_relative(2:end);
    align_time_relative=align_time_relative(2:end);
    save_time_relative=save_time_relative(2:end);
    
    %Update Timing GUI
    set(handles.load_time,'String',mat2str(load_time_relative));
    set(handles.align_time,'String',mat2str(align_time_relative));
    set(handles.save_time,'String',mat2str(save_time_relative));
    drawnow; %update GUI
    
    
    %==========End Iterative Motion Correction================================
    
end
toc(test)
set(handles.status_bar, 'String', 'Correction Complete!');
drawnow; %update GUI

end


%-----Below are the functions by Patrick Mineault. These do not need to be
%modified, but are instead called by the main function.-------------------

function [Id,dpx,dpy] = doLucasKanade(T,I,Nbasis,dpx,dpy) %dont need dpx, dpy
warning('off','fastBSpline:nomex');
%Nbasis = 16; %un-hard-coded this 8/26/14 DC
niter = 25;
damping = 1;
deltacorr = .0005;

lambda = .0001*median(T(:))^2;
%Use a non-iterative algo to get the initial displacement

if nargin < 4
    [dpx,dpy] = doBlockAlignment(I,T,Nbasis);
    dpx = [dpx(1);(dpx(1:end-1)+dpx(2:end))/2;dpx(end)];
    dpy = [dpy(1);(dpy(1:end-1)+dpy(2:end))/2;dpy(end)];
end
%dpx = zeros(Nbasis+1,1);
%dpy = zeros(Nbasis+1,1);

%linear b-splines
knots = linspace(1,size(T,1),Nbasis+1);
knots = [knots(1)-(knots(2)-knots(1)),knots,knots(end)+(knots(end)-knots(end-1))];
spl = fastBSpline(knots,knots(1:end-2)); %available on MATLAB file exchange

%spl.usemex = true; %Add mex acceleration. Need to compile mex beforehand
B = spl.getBasis((1:size(T,1))');

%Find optimal image warp via Lucas Kanade

Tnorm = T(:)-mean(T(:));
Tnorm = Tnorm/sqrt(sum(Tnorm.^2));
B = full(B);
c0 = mycorr(I(:),Tnorm(:));

%theI = gpuArray(eye(Nbasis+1)*lambda); %GPU Proccessing
theI = (eye(Nbasis+1)*lambda);

Bi = B(:,1:end-1).*B(:,2:end);
allBs = [B.^2,Bi];

[xi,yi] = meshgrid(1:size(T,2),1:size(T,1));

bl = quantile(I(:),.01);

for ii = 1:niter
    
    %Displaced template
    Dx = repmat((B*dpx),1,size(T,2));
    Dy = repmat((B*dpy),1,size(T,2));
    
    Id = interp2(I,xi+Dx,yi+Dy,'linear');
    
    Id(isnan(Id)) = bl;
    
    c = mycorr(Id(:),Tnorm(:));
    
    if c - c0 < deltacorr && ii > 1
        break;
    end
    
    c0 = c;
    
    %gradient of template
    dTx = (Id(:,[1,3:end,end])-Id(:,[1,1:end-2,end]))/2;
    dTy = (Id([1,3:end,end],:)-Id([1,1:end-2,end],:))/2;
    
    del = T(:) - Id(:);
    
    %special trick for g (easy)
    gx = B'*sum(reshape(del,size(dTx)).*dTx,2);
    gy = B'*sum(reshape(del,size(dTx)).*dTy,2);
    
    %special trick for H - harder%
    Hx = constructH(allBs'*sum(dTx.^2,2),size(B,2))+theI;
    Hy = constructH(allBs'*sum(dTy.^2,2),size(B,2))+theI;
    
    
    %Fast method
    %         dTx_s = reshape(bsxfun(@times,reshape(B,size(B,1),1,size(B,2)),dTx),[numel(dTx),size(B,2)]);
    %         dTy_s = reshape(bsxfun(@times,reshape(B,size(B,1),1,size(B,2)),dTy),[numel(dTx),size(B,2)]);
    %
    %         Hx = (doMult(dTx_s) + theI);
    %         Hy = (doMult(dTy_s) + theI);
    
    
    dpx_ = Hx\gx;
    dpy_ = Hy\gy;
    
    dpx = dpx + damping*dpx_;
    dpy = dpy + damping*dpy_;
end
end

function thec = mycorr(A,B)
A = A(:) - mean(A(:));
A = A / sqrt(sum(A.^2));
thec = A'*B;
end

function H2 = constructH(Hd,ns)
H2d1 = Hd(1:ns)';
H2d2 = [Hd(ns+1:end);0]';
H2d3 = [0;Hd(ns+1:end)]';

H2 = spdiags([H2d2;H2d1;H2d3]',-1:1,ns,ns);
end

function [dpx,dpy] = doBlockAlignment(T,I,nblocks)
% dpx = gpuArray(zeros(nblocks,1));
% dpy = gpuArray(zeros(nblocks,1));
dpx = (zeros(nblocks,1));
dpy = (zeros(nblocks,1));

dr = 10;
blocksize = size(T,1)/nblocks;

[xi,yi] = meshgrid(1:size(T,2),1:blocksize);
thecen = ([size(T,2)/2+1,floor(blocksize/2+1)]);
%thecen = gpuArray([size(T,2)/2+1,floor(blocksize/2+1)]);
mask = (xi-thecen(1)).^2+(yi-thecen(2)).^2< dr^2;

for ii = 1:nblocks
    dy = (ii-1)*size(T,1)/nblocks;
    rg = (1:size(T,1)/nblocks) + floor(dy); %added rounding 8/26/14 DC
    %rg = (1:size(T,1)/nblocks) + dy;
    %     T_ = gpuArray(T(rg,:));
    %     I_ = gpuArray(I(rg,:));
    T_ = T(rg,:);
    I_ = I(rg,:);
    T_ = bsxfun(@minus,T_,mean(T_,1));
    I_ = bsxfun(@minus,I_,mean(I_,1));
    dx = fftshift(ifft2(fft2(T_).*conj(fft2(I_))));
    theM = dx.*mask;
    
    [yy,xx] = find(theM == max(theM(:)),1,'last'); %changed to find only first match
    %     xx=gpuArray(xx);
    %     yy=gpuArray(yy);
    
    %[yy,xx] = find(theM == max(theM(:)));
    %     xx_mat=gather(xx);
    %     yy_mat=gather(yy);
    dpx(ii) = (xx-thecen(1));
    dpy(ii) = (yy-thecen(2));
    %     dpx(ii) = (xx_mat-thecen(1));
    %     dpy(ii) = (yy_mat-thecen(2));
end
end

function motcor_update_overall(handles,progress,current_prog,iteration,iterations)

file_num=progress.current_file;
total_files=progress.to_process_size;


overall=(current_prog/iterations+100*(iteration-1)/iterations)/100/total_files+(file_num-1)/total_files;

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
