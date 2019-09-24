function [Z_F,F_baseline_mean,F_baseline_std,baseline_start_frame]=ez_ZF(F,frames)
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
% baseline_start_frame indicates the first frame of baseline for each ROI

[F_baseline_std,baseline_start_frame] = min(movstd(F,frames,'Endpoints','discard'));
F_baseline_mean = mean(F(baseline_start_frame:baseline_start_frame+frames-1,:),1);
Z_F = (F - F_baseline_mean) ./ F_baseline_std;