function [hz_matrix,bin_frame_duration] = ez_spikes_to_hz(spike_matrix,frames_per_bin,frame_duration)
%ez_spikes_to_hz converts a series of deconvoluted spike timing to
%   a trace of binned activity in Hz.
%INPUTS
%   spike_matrix is a matrix of spiking data extracted from fluorescent
%       imaging. These must be positive real numbers, but need not be
%       whole numbers. Each value of the matrix is the number of spikes
%       during a single frame of imaging from a single ROI. Each ROI should
%       be placed in columns, with rows representing frames.
%   frames_per_bin is a variable equal to the number of frames to put 
%       into a bin. This must be a whole number equal to or greater than 1.
%       For no further binning, set this to 1.
%   frame_duration is the real-time length of a frame in seconds. This must
%       be a real number greater than 0.
%
%OUTPUTS
%   hz_trace is a matrix of binned time with firing frequency in terms of
%       Hz.
%   bin_frame_duration is the duration of binned output frames, in seconds.


%=============Check for common errors=============

%Check if matrix may be formatted incorrectly
if size(spike_matrix,2)>size(spike_matrix,1)
    warning('The number of columns in the matrix spike_matrix exceeds the number of rows. This is unlikely to happen in properly-formatted matrices. You may need to transpose your matrix.')
end

%Checks inputs formatting
if floor(frames_per_bin)~=frames_per_bin
    error('Please input frames_per_bin as a whole number greater than 0.')
end
if frames_per_bin<1
    error('Please input frames_per_bin as a whole number greater than 0.')
end
if frame_duration<=0
    error('Please input frame_duration as a real number greater than 0.')
end


%=============Bin spikes=============

roi_num=size(spike_matrix,2); %number of ROIs (columns)
frame_num=size(spike_matrix,1); %number of frames (rows)
bin_num=ceil(frame_num/frames_per_bin); %calculate number of output bins (rows)

bin_matrix=zeros(bin_num,size(spike_matrix,2)); %initialize zero matrix

if frames_per_bin>1 %skips if no binning
    parfor i=1:bin_num
        for j=1:roi_num
            if i==bin_num %special case for final bin if incomplete
                bin_matrix(i,j)=mean(spike_matrix((i-1)*frames_per_bin+1:end,j));
            else
                bin_matrix(i,j)=mean(spike_matrix((i-1)*frames_per_bin+1:i*frames_per_bin,j));
            end
        end
    end
else
    bin_matrix=spike_matrix;
end


%=============Convert spikes/bin to Hz=============

bin_frame_duration=frame_duration*frames_per_bin; %output duration of binned output frames

hz_matrix=bin_matrix/frame_duration;


end

