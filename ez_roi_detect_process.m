function [progress]=ez_roi_detect_process(fullvidfile,autoroi,handles,progress)

%------------------------------Load video----------------------------------
set(handles.status_bar, 'String', 'Loading Video'); %Update status bar
drawnow; %Update GUI
addpath(genpath('utilities')); %Make sure CaImAn "utilities" folder is set in paths
extension_index=strfind(fullvidfile,'.'); %Find periods in file name
extension=fullvidfile(extension_index(end)+1:end); %Find the location of the last period in the file name
vidfile_name=fullvidfile(1:extension_index-1); %Extract video file name without extension

if strcmpi(extension,'tif') || strcmpi(extension,'tiff')
    %----------------Read tiff file--------------
    vid_info=imfinfo(fullvidfile); %Checks video file information
    vid_height=vid_info(1).Height; %Sets height
    vid_width=vid_info(1).Width; %Sets width
    
    %     %Convert certain types of Tiff files to be compatible
    %     if isfield(vid_info,'StripOffsets') %Check if formatted correctly
    %         if isa(vid_info(1).StripOffsets,'double') %check if a double
    %             set(handles.status_bar, 'String', 'Converting Tiff'); %Update status bar
    %             drawnow; %Update GUI
    %             for i=1:length(vid_info)
    %                 vid_info(i).StripOffsets=sum(vid_info(i).StripOffsets);
    %             end
    %         end
    %         if isa(vid_info(1).StripByteCounts,'double') %check if a double
    %             for i=1:length(vid_info)
    %                 vid_info(i).StripByteCounts=sum(vid_info(i).StripByteCounts);
    %             end
    %         end
    %     end
    
    %Checks for compression
    if strcmp(vid_info(1).Compression,'Uncompressed') %Loads uncompressed videos
        Y=loadtiff(fullvidfile); %Read uncompressed Tiff
        num_frames=size(Y,3); %Extract number of frames
        if autoroi.frames_box==1 %Check if all frames being read
            start_frame=1; %Start at frame 1
            end_frame=num_frames; %Detect number of frames
        else
            start_frame=str2double(autoroi.frames_start); %Read start frame from GUI
            end_frame=str2double(autoroi.frames_end); %Read end frame from GUI
        end
        Y=Y(:,:,start_frame:end_frame); %Trim matrix to desired size
        
    else %Loads Compressed videos
        if autoroi.frames_box==1 %Check if all frames being read
            start_frame=1; %Start at frame 1
            num_frames=numel(vid_info); %Detect number of frames
            frames_to_read=num_frames; %Set frames to read to all frames
        else
            start_frame=str2double(autoroi.frames_start); %Set start frame based on GUI
            frames_to_read=str2double(autoroi.frames_end)-str2double(autoroi.frames_start)+1; %Calculate number of frames to read
            num_frames=frames_to_read; %Set number of frames to number of frames read
        end
        Y=zeros(vid_height,vid_width,frames_to_read); %Makes zero matrix for speed
        parfor i = 1:frames_to_read %Loads every frame of the video
            Y(:,:,i)=imread(fullvidfile,i+start_frame-1,'info',vid_info); %Read frames in video
        end
    end
    
    %Checks for read errors
    if num_frames==1 %Only 1 frame was read, which is probably an error
        warning_text='Only 1 frame was detected. Either the incorrect video or a very large compressed TIFF file was chosen. TIFF files >4GB must be uncompressed.'; %Generate warning text
        ez_warning_small(warning_text); %Load warning GUI
    end
    
    %---------------------Mat file-------------------------
elseif strcmpi(extension,'mat')
    matObj=matfile(fullvidfile); %Initialize matfile object
    check_mat=whos(matObj); %Check mat file information
    workspace_length=size(check_mat,1); %Number of variables in workspace
    variable_sizes=zeros(workspace_length,1); %Initialize matrix of variable sizes (in bytes)
    for i=1:workspace_length %Go through all variables in workspace
        variable_sizes(i)=check_mat(i,1).bytes; %Check size of variables
    end
    [~,largest_variable]=max(variable_sizes); %Find largest variable
    largest_variable_name=check_mat(largest_variable,1).name; %Name of largest variable
    Y=load(fullvidfile,largest_variable_name); %Loads largest variable
    Y=Y.(largest_variable_name); %Convert structure to matrix
    if autoroi.frames_box==1 %Check if all frames being read
        start_frame=1; %Start at frame 1
        end_frame=size(Y,3); %End at last frame
    else
        start_frame=str2double(autoroi.frames_start); %Set start frame from GUI
        end_frame=str2double(autoroi.frames_end); %Set end frame from GUI
    end
    Y=Y(:,:,start_frame:end_frame); %Trim matrix to desired size
    
    %-------------------AVI File-----------------------
elseif strcmpi(extension,'avi')
    videoObj = VideoReader(fullvidfile); %Initialize video object
    vid_height=videoObj.Height; %Sets height
    vid_width=videoObj.Width; %Sets width
    frame_rate= videoObj.FrameRate; %Sets frame rate
    num_frames = ceil(videoObj.FrameRate*videoObj.Duration); %Calculate number of frames
    if autoroi.frames_box==1 %check if all frames being read
        start_frame=1; %Start at frame one
        frames_to_read=num_frames; %Read until the last frame
    else
        start_frame=str2double(autoroi.frames_start); %Set start frame from GUI
        frames_to_read=str2double(autoroi.frames_end)-str2double(autoroi.frames_start)+1; %Calculate number of frames to read based on GUI
    end
    Y=zeros(vid_height,vid_width,frames_to_read); %Makes zero matrix for speed
    for i = 1:frames_to_read %Loads every frame of the video
        videoObj.CurrentTime=(start_frame+i-2)/frame_rate; %Step forward one frame at a time
        Y(:,:,i)=readFrame(videoObj); %Read the frame
    end
    %--------------------Unsupported File Type--------------------
else
    warning_text=['The selected file ' fullvidfile ' is not a supported file type.']; %Generate warning text
    ez_warning_small(warning_text); %Load warning GUI
    return
end

if ~isa(Y,'single');    Y = single(Y);  end %Convert to single if not already

%Add a round of Scaling early
%         original_max=max(max(max(Y)));
%         original_min=min(min(min(Y)));
%         Y=(Y-original_min);
%         new_max=max(max(max(Y)));
%         Y=Y*original_max/new_max;

%Try BG Subtraction Early

% BG_min=min(Y,[],3);
% Y=Y-BG_min;

[d1,d2,T] = size(Y); %Extract dimensions of dataset
d = d1*d2; %Calculate total number of pixels
%===========================End Load Video=================================

%===========================Set Parameters=================================
set(handles.status_bar, 'String', 'Initializing parameters'); %Update status bar
drawnow; %Update GUI
K = str2double(autoroi.input_components); %Check number of components to be found
tau = round(str2double(autoroi.input_kernel)/2); %Std of gaussian kernel (size of neuron)
p = autoroi.menu_regression-1; %From "Autoregression" in GUI. Order of autoregressive system (p = 0 no dynamics, p=1 just decay, p = 2, both rise and decay)

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
    deconv_method='MCMC';
    method='spgl1';
    spatial_method='regularized';
elseif autoroi.menu_deconvolution==2
    deconv_method='constrained_foopsi';
    method='spgl1';
    spatial_method='regularized';
elseif autoroi.menu_deconvolution==3
    deconv_method='MCEM_foopsi';
    method='spgl1';
    spatial_method='regularized';
elseif autoroi.menu_deconvolution==4
    deconv_method='constrained_foopsi';
    method='cvx';
    spatial_method='constrained';
elseif autoroi.menu_deconvolution==5
    deconv_method='MCEM_foopsi';
    method='cvx';
    spatial_method='constrained';
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
    'spatial_method',spatial_method,...                             %Constrained vs regularized
    'p',p,...                                                       %Order of AR dynamics
    'nb',2,...                                                      %Number of background components
    'min_SNR',3,...                                                 %Minimum SNR threshold
    'cnn_thr',0.2,...                                               %Threshold for CNN classifier
    'bas_nonneg',0);                                                %Allow a negative baseline
%     'eta',weight_time,...                                           %Relative weight of temporal components
%     'beta',weight_space,...                                         %Relative weight of spatial components


%options.method2=method;    %Set method for foopsi %Is this still used?
[P,Y] = preprocess_data(Y,p,options); %Data pre-processing
%=============================End Set Parameters========================

%============================Extract Components=========================
set(handles.status_bar, 'String', 'Init. spatial components'); %Update status bar
drawnow; %Update GUI
[Ain, Cin, bin, fin, center] = initialize_components(Y, K, tau, options, P); %Initilize components
Cn =  correlation_image(Y); %max(Y,[],3); %std(Y,[],3); %image statistic (only for display purposes)

%-----End initialization of spatial components using greedyROI and HALS---
if autoroi.refine_components==1 %Check if "Manual Initial Refinement" is selected in the GUI
    [Ain,Cin,~] = manually_refine_components(Y,Ain,Cin,center,Cn,tau,options); %Launch manual refinement
end

%-------------Update spatial and temporal components-------------------

set(handles.status_bar, 'String', 'Updating components');
drawnow; %Update GUI
Yr = reshape(Y,d,T);
[A,b,Cin] = update_spatial_components(Yr,Cin,fin,[Ain,bin],P,options);
P.p = 0;    %Turn off autoregression dynamics temporarily for speed
[C,f,P,S,YrA] = update_temporal_components(Yr,A,b,Cin,fin,P,options);
%-----------End update spatial and temporal components-----------------

%---------------Classify and Select-------------
if autoroi.use_classifier==1
    set(handles.status_bar, 'String', 'Classifying');
    drawnow; %Update GUI
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
set(handles.status_bar, 'String', 'Merging found components'); %Update status bar
drawnow; %Update GUI
[Am,Cm,K_m,merged_ROIs,Pm,~] = merge_components(Yr,A,b,C,f,P,S,options); %Merge similar components

%------------Generate merging example-------------
if and(autoroi.check_merge, ~isempty(merged_ROIs)) %Check if "Display Merging Example" is selected in GUI and that at least two components were merged
    i = 1; %Take the first merged ROI for an example
    ln = length(merged_ROIs{i}); %Check size necessary for figure
    figure; %Open new figure
    set(gcf,'Position',[300,300,(ln+2)*300,300]); %Set figure size
    for j = 1:ln %For all the components that were merged
        subplot(1,ln+2,j); imagesc(reshape(A(:,merged_ROIs{i}(j)),d1,d2)); %Plot individual components
        title(sprintf('Component %i',j),'fontsize',16,'fontweight','bold'); axis equal; axis tight; %Label components
    end
    subplot(1,ln+2,ln+1); imagesc(reshape(Am(:,K_m-length(merged_ROIs)+i),d1,d2)); %Plot merged component
    title('Merged Component','fontsize',16,'fontweight','bold');axis equal; axis tight; %Label merged component
    subplot(1,ln+2,ln+2); %Show temporal component in subplot
    plot(1:T,(diag(max(C(merged_ROIs{i},:),[],2))\C(merged_ROIs{i},:))'); %Plot temporal component
    hold all; plot(1:T,Cm(K_m-length(merged_ROIs)+i,:)/max(Cm(K_m-length(merged_ROIs)+i,:)),'--k') %Plot temporal component
    title('Temporal Components','fontsize',16,'fontweight','bold') %Label temporal component
    drawnow; %Update figure
end

%---------------Update components again--------------------
Pm.p=p; %Restore autoregression dynamics value
[A2,b2,C2] = update_spatial_components(Yr,Cm,f,[Am,b],Pm,options); %Update spatial components
[C2,f2,P2,S2,~] = update_temporal_components(Yr,A2,b2,C2,f,Pm,options); %Update temporal components

%===============================Plotting================================
set(handles.status_bar, 'String', 'Plotting components'); %Update status bar
drawnow; %Update GUI

[A_or,C_or,S_or,P_or] = order_ROIs(A2,C2,S2,P2); %Reorder ROIs

% Calculate traces to be saved
[F_raw,F_inferred] = construct_traces(Yr,A_or,C_or,b2,f2,options);

%------------ROI Map Plotting---------------
figure; %Open a new figure
plot_contours(A_or,Cn,options,1); %Run calculations for plotting an ROI map. One is automatically opened, but can be closed so that the matrix Coor is still generated.
if autoroi.check_map==1 %Check if "Display ROI Map" has been selected in the GUI
    if get(handles.check_pdf,'Value')==1 %Check if "Save PDFs" has been selected in the GUI
        fig=gcf; %Target the current figure
        set(fig,'Position',[680 558 900 1200]) %Set the size of the figure to be exported
        print(fig,[vidfile_name '_map.pdf'],'-bestfit','-dpdf') %Export the figure to PDF
        if autoroi.open_pdf==1 %Check if "Open PDFs" has been selected in the GUI
            winopen([vidfile_name '_map.pdf']) %Open the newly-created PDF
        end
        close(fig) %Close the figure window
    end
else %If no ROI maps are desired
    fig=gcf; %Target the current figure
    close(fig) %Close the figure window
end

%-----------Display Contours----------------
if autoroi.check_contours==1 %Check if "Display Contours" has been selected in the GUI
    plot_components_GUI(Yr,A_or,C_or,b2,f2,Cn,options); %Plot individual components
end

%-------------PDF Generation---------------
open_pdf=get(handles.open_pdf,'Value'); %Check if "Open PDFs" has been selected in the GUI, to be passed to plotting functions
if get(handles.check_pdf,'Value')==1 %Check if "Save PDFs" has been selected in the GUI
    dF_filename=[vidfile_name '_dF']; %dF/F plots name
    ez_multiplot(F_inferred',10,dF_filename,1,'Frame',1,'dF/F',1,open_pdf); %Generate and save dF/F plots
    if p>0 %Only export rate if using dynamics
        spike_filename=[vidfile_name '_rate']; %Firing rate plots name
        ez_multiplot(S_or',10,spike_filename,1,'Frame',1,'Rate',1,open_pdf); %Generate and save firing rate plots
    end
end
%===========================End plotting================================

%=============================Save data=================================
set(handles.status_bar, 'String', 'Saving data'); %Update status bar
drawnow; %Update GUI

%------Save .mat file (workspace)----
progress.newfile=[vidfile_name '_roi' '.mat']; %.mat file name passed back to GUI
save([vidfile_name '_roi'],'A_or','C_or','S_or','P_or','Cn','F_raw','F_inferred','options','autoroi');

%-----------Save .csv files---------
if autoroi.check_csv==1 %Check if "Export to .csv" is selected in GUI
    csvwrite([vidfile_name '_roi_dF'],full(F_inferred')); %Write dF/F csv
    if p > 0 %Only export rate if using dynamics
        csvwrite([vidfile_name '_roi_rate'],full(S_or')); %Write rate csv
    end
    csvwrite([vidfile_name '_roi_raw'],F_raw'); %Write raw F data csv
end
set(handles.status_bar, 'String', 'ROI Detection Complete!'); %Update status bar
drawnow; %Update GUI
%=========================End save data==================================
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
end
