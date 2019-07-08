function [Z_F,F_baseline_mean,F_baseline_std,baseline_frames,baseline_start_frame]=ez_ZF(F,frames)
%Takes raw F or dF/F data, converts to modified Z_F score
%
%-----Inputs------
%
% F is the matrix of either raw F data or dF/F data. Every column represents
%   an ROI and every row is the F or dF/F value of an ROI during a single frame
%
% frames is the number of consecutive, non-NAN frames that will make up the
%   baseline period (recommended: at least 10 seconds worth of frames, depends on imaging rate)
%
%-----Outputs-----
%
% Z_F is the matrix of modified Z-scores. Every column represents
%   an ROI and every row is the Z_F value of an ROI during a single frame
%
% F_baseline_mean is the mean of the baseline for each ROI
%
% F_baseline_std is the standard deviation of the baseline for each ROI
%
% baseline_frames, formerly called 'blueline' in older scripts, is a matrix
%   of binary values where baseline frames=1, non-baseline frames=0
%
% baseline_start_frame indicates the first frame of baseline for each ROI


%-----------Calculate Baseline-----------------------------------------
F_size=size(F); %dimensions of the F matrix
baseline_calc=zeros(1,F_size(1)-frames+1); %used for calculating baseline
F_baseline_mean=zeros(1,F_size(2)); %Mean of the baseline
F_baseline_std=zeros(1,F_size(2)); %Standard deviation of the baseline
baseline_frames=zeros(F_size(1),F_size(2)); %formerly blueline, baseline frames=1, non-baseline=0
baseline_start_frame=zeros(1,F_size(2)); %the first frame of baseline
F_calc=F; %A copy of the F matrix used to mark frames to ignore in calculations

%Remove extreme values (saturated, desaturated) from baseline calculation
F_min=min(F); %finds min value of each ROI (desaturated removal)
F_max=max(F); %finds max of each ROI (saturated removal)

for i=1:F_size(1)
    for j=1:F_size(2)
        if F_calc(i,j)==F_min(j) || F_calc(i,j)==F_max(j) %Detects values at the min or max
            F_calc(i,j)=nan; %Changes to NAN
        end
    end
end

%Calculate standard deviations of potential baselines
for j=1:F_size(2)
    for i=1:F_size(1)-frames+1
        if sum(isnan(F_calc(i:i+frames-1,j)))~=0 %If NAN are present, set to NaN
            baseline_calc(i)=nan;
        else %If no NAN are present
            baseline_calc(i)=std(F(i:i+frames-1,j)); %Find STD for all values
        end
    end
    
    [~,baseline_start_frame(j)]=min(baseline_calc); %calculate the position of lowest deviation for baseline
    
    %     quant_index=round(quant*(Fsize(1)-1)+1); %quantile version
    %     quant_calc=sort(baseline_calc); %quantile version
    %     min_index(j)=find(baseline_calc==quant_calc(quant_index),1); %quantile version
    
    F_baseline_mean(j)=mean(F(baseline_start_frame(j):baseline_start_frame(j)+frames-1,j)); %calculate mean
    F_baseline_std(j)=std(F(baseline_start_frame(j):baseline_start_frame(j)+frames-1,j)); %calculate standard deviation
    baseline_frames((baseline_start_frame(j):baseline_start_frame(j)+frames-1),j)=1; %mark baseline frames
    disp(['Calculating Minimum Baseline: ', (num2str(100*j/F_size(2))), '%']) %progress display
end
%----------------End Calculate Baseline--------------------------------

%--------------Calculate Z_F for each ROI------------------------------
Z_F=zeros(F_size(1),F_size(2));
for i=1:F_size(1)
    for j=1:F_size(2)
        if F(i,j)==0
            Z_F(i,j)=0; %set to 0 if no data available
        else
            Z_F(i,j)=(F(i,j)-F_baseline_mean(j))/(F_baseline_std(j)); %Convert F or dF/F to Z_F
        end
    end
end
%----------End Calculate Z_F for each ROI-------------------------------