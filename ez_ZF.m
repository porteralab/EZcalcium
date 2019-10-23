function [Z_mod,F_baseline_mean,F_baseline_std,baseline_start_frame]=ez_ZF(F,frames)
%Takes raw F or dF/F data, converts to modified Z-score
%
%-----Inputs------
%
% F is the matrix of either raw F data or dF/F data. Every row represents
%   an ROI and every column is the F or dF/F value of an ROI during a
%   single frame.
%
% frames is the number of consecutive, non-NAN frames that will make up the
%   baseline period. It is recommended to take at least 10 seconds worth of
%   frames, which depends on the imaging rate.
%
%-----Outputs-----
%
% Z_mod is the matrix of modified Z-scores. Every row represents
%   an ROI and every column is the Z_F value of an ROI during a single
%   frame.
%
% F_baseline_mean is the mean of the baseline for each ROI
%
% F_baseline_std is the standard deviation of the baseline for each ROI
%
% baseline_start_frame indicates the first frame of baseline for each ROI

[F_baseline_std,baseline_start_frame] = min(movstd(F,frames,0,2,'Endpoints','discard'),[],2);
F_baseline_mean = mean(F(:,baseline_start_frame:baseline_start_frame+frames-1),2);
Z_mod = (F - F_baseline_mean) ./ F_baseline_std;