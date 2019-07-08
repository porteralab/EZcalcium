function ez_roi_refine_process(F)
%ADD saturated max?
%ADD Check for stable baseline?


sig_frames_num=6; %Number of consecutive frames above the Z value threshold
sig_z=3; %Significant values of Z
baselineframes=80; %number of frames in baseline
zero_allowed=1; %Percent of frames allowed to have a value of 0 in the data, which may indicate a microscope issue



% plot spatial components and temporal traces against filtered background
% Y:        raw data    
% A:        spatial footprints (Am seems good?)
% C:        temporal components
% b:        spatial background
% f:        temporal background
% Cn:       background image (default: mean image)
% options:  options structure


%axes2 Main screen
%axes3 ROI blowup
%axes4 dF/F
%axes5 deconvolved traces



% %reshape
% image(reshape(A(:,1)/max(A(:,1))*255,d1,d2));


%[~,Df] = extract_DF_F(Y,[A,b],[C;f],[],size(A,2)+1);


%open view_components %has all the good plotting stuff in it



%-----------Calculate Baseline F-----------------------------------------
baseline_calc=zeros(1,size(F,1)-baselineframes+1);
F_baseline=zeros(1,size(F,2));
F_baseline_std=zeros(1,size(F,2));
baseline_frames=nan(size(F,1),size(F,2)); 
% magenta_frames=zeros(size(F,1),size(F,2));
min_index=zeros(1,size(F,2));
nonzero_min=size(F,1)-floor(zero_allowed/100*size(F,1)); %calculates the min number of nonzero frames needed to be included



 

for j=1:size(F,2)
    for i=1:size(F,1)-baselineframes+1 %find 5 seconds of baseline. RECALC based on framerate
        baseline_calc(i)=std(F(i:i+baselineframes-1,j)); %checks STD for all values 
    end
    [~,min_index(j)]=min(baseline_calc); %calculate the position of lowest deviation for baseline

   %min_index(j)=find(base_calc==quantcalc(quantindex),1); %quantile version
    
    F_baseline(j)=mean(F(min_index(j):min_index(j)+baselineframes-1,j));
    F_baseline_std(j)=std(F(min_index(j):min_index(j)+baselineframes-1,j));
    baseline_frames((min_index(j):min_index(j)+baselineframes-1),j)=1;
    disp(['Calculating Initial Baseline: ', (num2str(100*j/size(F,2))), '%'])
end




%------------------Iterate Baseline Detection------------------------------




%--------------Calculate Z (dF) for each ROI-------------------------------
Z_F=zeros(size(F));
for i=1:size(F,1)
    for j=1:size(F,2)
        if F(i,j)==0
            Z_F(i,j)=0; %set to 0 if no data available
        else
            Z_F(i,j)=(F(i,j)-F_baseline(j))/(F_baseline_std(j));
        end
    end
end
 
%----------End Calculate dF/F for each ROI-------------------------------

%--------------Calculate significance for each ROI-----------------------

sig_frames=zeros(size(Z_F,1),size(Z_F,2));
active_frames=zeros(size(Z_F,1),size(Z_F,2)); 
highlight_frames=zeros(size(Z_F,1),size(Z_F,2));
active_ROI=zeros(1,size(Z_F,2));



for j=1:size(Z_F,2) %check if activity is above threshold     
    for i=1:size(Z_F,1)
        if Z_F(i,j)>sigdF
            sig_frames(i,j)=1;
        end
    end
end


for j=1:size(Z_F,2) %check for 6+ consecutive significant frames
    for i=1:size(Z_F,1)
        
        sig_count=0;
        if sig_frames(i,j)==1
            sig_count=sig_count+1;
            for k=1:sig_frames_num-1
                if ((i+k <= size(Z_F,1)) && (sig_frames(i+k,j)==1))
                    sig_count=sig_count+1;
                end
            end
            if sig_count==sig_frames_num
                active_frames(i:i+sig_frames_num-1,j)=1;
            end
        end
    end
end

for j=1:size(Z_F,2) %mark frames before and after stimulus as red
    for i=1:size(Z_F,1)
        if active_frames(i,j)==1 && (i+8 <= size(Z_F,1)) && (i-3 > 0)
            highlight_frames(i-3:i+8,j)=1;
        end
    end
end
sum_active=sum(active_frames,1);
for j=1:size(Z_F,2) %check if ROI has active frames
    if sum_active(j)>=1;
        active_ROI(1,j)=1;
    end
    %Checks to see if number of non-zero frames exceeds threshold
    if size(find(Z_F(:,j)),1)<nonzero_min
        active_ROI(1,j)=0;
    end
end


% calculates the percentage  of cells above threshold vs time
% active_percent_line=sum(sig_frames,2)/size(Z_F,2)*100;
% active_percent_sigline=sum(active_frames,2)/size(Z_F,2)*100;
% active_percent_redline=sum(highlight_frames,2)/size(Z_F,2)*100;

active_ROI_number=zeros(1,sum(active_ROI));
ROIcount=0; %Create a matrix of active ROI numbers
for j=1:size(Z_F,2)
    if active_ROI(1,j)==1
        ROIcount=ROIcount+1;
        active_ROI_number(1,ROIcount)=j;
    end
end

activeROIdF=zeros(size(Z_F,1),size(active_ROI_number,2)); %Remove inactive ROIs
for j=1:size(active_ROI_number,2)
    for i=1:size(Z_F,1)
        activeROIdF(i,j)=Z_F(i,active_ROI_number(j));
    end
end

activeredframes=zeros(size(highlight_frames,1),size(active_ROI_number,2)); %Remove inactive redframes
for j=1:size(active_ROI_number,2)
    for i=1:size(highlight_frames,1)
        activeredframes(i,j)=highlight_frames(i,active_ROI_number(j));
    end
end

tick_plot=zeros(size(activeredframes,2),floor(size(activeredframes,1)/tick_bin));
bar_plot=zeros(size(tick_plot));

for i=1:size(activeredframes,2)
    for j=1:floor(size(activeredframes,1)/tick_bin)
        start_j=(j-1)*tick_bin+1;
        if sum(activeredframes(start_j:start_j+tick_bin-1,i))<tick_thresh
            tick_plot(i,j)=255;
        else
            bar_plot(i,j)=1;
        end
    end
end














