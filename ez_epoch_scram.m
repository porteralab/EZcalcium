function [scram_traces]=ez_epoch_scram(trace,scrambles,threshold_value,threshold_frames,before_frames,after_frames)
%This function performs the scrambling of traces in terms of epochs
%
%-----------Inputs------------
%trace is the column vector of the trace to be scrambled.
%scrambles is the number of scrambles to be performed.
%threshold_value is the value of which a trace must meet or pass in order to be
%   considered significant (e.g. 3 for Z-score-based traces).
%threshold_frames is the number of frames which a trace must meet or pass in order
%   to be considered significant.
%before_frames is the number of frames to add before the initial passing of
%   threshold, in order to find the true start of the epoch (3 of GCaMP6 8hz)
%after_frames is the number of frames to add after the final passing of threshold (8 for GCaMP6 8hz)
%
%-----------Outputs-----------
%scram_traces is the output matrix of scrambled traces


%----------------Input Error Check---------------------
%Runs a series of checks to ensure all inputs are properly formatted.

%Checks if trace is column vector.
if size(trace,2)>1
    error('Variable "trace" must be a column vector!')
end

%Checks if all single-value inputs are, indeed, single-value.
if length(scrambles)>1
    error('Variable "scrambles" must have a single value!')
end
if length(threshold_frames)>1
    error('Variable "threshold_frames" must have a single value!')
end
if length(before_frames)>1
    error('Variable "before_frames" must have a single value!')
end
if length(after_frames)>1
    error('Variable "after_frames" must have a single value!')
end
if length(threshold_value)>1
    error('Variable "threshold_value" must have a single value!')
end

%Checks if threshold_frames and scrambles are whole numbers greater than 0.
if threshold_frames-floor(threshold_frames)~=0
    error('Variable "threshold_frames" must be a whole number!')
end
if threshold_frames<=0
    error('Variable "threshold_frames" must be greater than 0!')
end
if scrambles-floor(scrambles)~=0
    error('Variable "scrambles" must be a whole number!')
end
if scrambles<=0
    error('Variable "scrambles" must be greater than 0!')
end

%Check if before_frames and after_frames are non-negative whole numbers.
if before_frames-floor(before_frames)~=0
    error('Variable "before_frames" must be a whole number!')
end
if before_frames<0
    error('Variable "before_frames" must be non-negative!')
end
if after_frames-floor(after_frames)~=0
    error('Variable "after_frames" must be a whole number!')
end
if after_frames<0
    error('Variable "after_frames" must be non-negative!')
end
%-------------End Input Error Check--------------------


%------------------Epoch Detection---------------------
%Detect epochs based on criteria that a trace must surpass a given threshold and
%remain above threshold for a given number of frames

sig_frames=zeros(size(trace)); %trace of frames above threshold
active_frames=sig_frames; %trace of frames above threshold for period longer than threshold frames
epoch_frames=sig_frames; %final trace with epochs as 1, baseline as 0.

%check if activity is above threshold
for i=1:size(trace,1)
    if trace(i)>=threshold_value
        sig_frames(i)=1;
    end
end

%check for consecutive significant frames
for i=1:size(trace,1)
    sigcount=0;
    if sig_frames(i)==1
        sigcount=sigcount+1;
        for k=1:threshold_frames-1
            if ((i+k <= size(trace,1)) && (sig_frames(i+k)==1))
                sigcount=sigcount+1;
            end
        end
        if sigcount==threshold_frames
            active_frames(i:i+threshold_frames-1)=1;
        end
    end
end

%mark frames before and after stimulus as part of epoch
for i=1:size(trace,1)
    if active_frames(i)==1 && (i+after_frames <= size(trace,1)) && (i-before_frames > 0)
        epoch_frames(i-before_frames:i+after_frames)=1;
    end
end

%---------------End Epoch Detection--------------------


%------------------Epoch Counting----------------------
%Find when epochs start and end.
%Place into epoch matrix, with first digit being start position and second
%digit being end position.

epoch_frame_count=0; %counter for frame being checked
epoch_count=1; %number of epochs counter
epoch_start_end=[0 0]; %initialize the matrix where epoch ends will be recorded
whilecheck=1;
%Locate start and end of epochs.
while epoch_frame_count<length(epoch_frames)
    whilecheck=whilecheck+1;
    if whilecheck>length(epoch_frames)
    error('Epoch Counting while loop has looped too many times!')
    end
    epoch_start=find(epoch_frames((epoch_frame_count+1):end)==1,1,'first')+epoch_frame_count; %find start of epoch
    if epoch_start>0
        epoch_start_end(epoch_count,1)=epoch_start; %set start value
        epoch_frame_count=epoch_start+1; %may result in early termination if epoch is 1 frame long in final frame
        epoch_end=find(epoch_frames((epoch_frame_count):end)==0,1,'first')+epoch_frame_count-2; %find end of epoch
        if epoch_end>0
            epoch_start_end(epoch_count,2)=epoch_end; %set end of epoch
            epoch_frame_count=(epoch_end); %set frame counter to end of epoch
        else
            %set end of epoch equal to the end of the trace
            epoch_start_end(epoch_count,2)=length(epoch_frames);
            epoch_frame_count=length(epoch_frames);
        end
        epoch_count=epoch_count+1;%increment number of epochs counter
    else
        break
    end
end 

%Check if any epochs detected and epochs are complete.
if epoch_start_end(1,1)==0
    %No epochs detected. That's OK, it'll just be boring.
%     disp('Warning: no epochs were detected in one or more traces.')
%     disp('Scrambled matrices are entirely composed of background.')
else
    %Trim off last epoch if incomplete, as in the case of a 1 frame epoch in the final frame.
    %Should only occur when threshold_frames=1.
    if epoch_start_end(end,2)==0
        epoch_start_end=epoch_start_end(1:end-1,:);
    end
end
%---------------End Epoch Counting---------------------


%----------------Baseline Extraction-------------------
%Extract and concatenate all baseline data to generate a single trace of all baseline data with epochs removed.

if epoch_start_end(1,1)>0 %Checks if trace has any epochs
    %Calculate first set of baseline data
    if epoch_start_end(1,1)==1 %different conditions if epoch starts on first frame
        if epoch_start_end(1,2)==epoch_start_end(end,2) %check if final epoch
            if epoch_start_end(1,2)==length(trace)%check if epoch ends on the last frame
                error('The trace you selected consists entirely of one epoch and no baseline! Please check your thresholds!')
            else
                baseline_concat=trace(epoch_start_end(1,2)+1:length(trace)); %first epoch is final epoch
            end
        else %Epoch starts on first frame, but is not final epoch.
            %baseline_concat=trace(epoch_start_end(1,2)+1:epoch_start_end(2,2)-1);
            baseline_concat=[];
        end
    else %First epoch doesn't start on first frame
        baseline_concat=trace(1:epoch_start_end(1,1)-1);
    end
    
    %Concatenate additional baseline data
    if epoch_start_end(1,2)<epoch_start_end(end,2) %check if first epoch is final epoch
        for i=2:size(epoch_start_end,1) %concatenates baselines, except last epoch
            baseline_concat=[baseline_concat; trace(epoch_start_end(i-1,2)+1:epoch_start_end(i,1)-1)];
        end
    end
    
    %Concatenate final baseline data, if baseline continues past final epoch, if final epoch doesn't start on first frame
    if epoch_start_end(end,1)>1
        if epoch_start_end(end,2)<length(trace) %check if epoch is final epoch and does not end on last frame
            baseline_concat=[baseline_concat; trace(epoch_start_end(end,2)+1:end)];
        end
    end
    

    
else %case where trace has no epochs, no concatenation needed
    baseline_concat=trace;
end
%-------------End Baseline Extraction------------------


%----------------Baseline Shuffling--------------------
%Scramble background traces

baseline_scram=zeros(length(baseline_concat),scrambles);
baseline_concat_par=baseline_concat; %optimizing for parallelization 
parfor i=1:scrambles
    baseline_scram(:,i)=baseline_concat_par(randperm(numel(baseline_concat)));
end
%-------------End Baseline Shuffling-------------------


%-------------Epoch and Baseline Insertion-------------
%Alternate inserting epochs and baseline into final output matrix

if epoch_start_end(1,1)>0 %check if there are any epochs to be inserted
    scram_traces=nan(length(trace),scrambles); %initialize scrambled trace matrix to NaN
    for i=1:scrambles %repeat for all scrambles
        epoch_location=sort(randperm(length(baseline_concat)+1,size(epoch_start_end,1))); %determine location of epochs
        epoch_order=randperm(size(epoch_start_end,1));
        epoch_sizes=0; %records length of previous epochs in order to set locations relative to each other
        base_count=1;
        for j=1:length(epoch_order) %insert epochs based on relative position
            %inserts baseline before first epoch
            epoch_start=epoch_start_end(epoch_order(j),1); %start of epoch
            if j==1
                    scram_traces(1:epoch_location(j)-1,i)=baseline_scram(base_count:epoch_location(j)-1,i);
                    base_count=epoch_location(j);
            end
            epoch_end=epoch_start_end(epoch_order(j),2); %end of epoch
            epoch_length=epoch_end-epoch_start+1; %length of epoch
            %inserts epoch
            epoch_insert=epoch_location(j)+epoch_sizes; %find insertion point of epoch
            epoch_terminate=epoch_location(j)+epoch_sizes+epoch_length-1; %find termination point of epoch
            scram_traces(epoch_insert:epoch_terminate,i)=trace(epoch_start_end(epoch_order(j),1):epoch_start_end(epoch_order(j),2));
            %adds current epoch to total sizes
            epoch_sizes=epoch_sizes+epoch_length;
            %inserts baseline after epoch if epoch does not end at last frame
            if epoch_terminate<length(trace)
                base_start=epoch_terminate+1; %start of baseline in scram_traces matrix
                if j<length(epoch_order) %inserts between epochs
                    base_end=epoch_location(j+1)+epoch_sizes-1; %end of baseline
                    base_length=base_end-base_start+1; %length of baseline
                    scram_traces(base_start:base_end,i)=baseline_scram(base_count:base_count+base_length-1,i);
                    base_count=base_count+base_length; %count of baseline thus far extracted from baseline_scram matrix
                else
                    %insert baseline from end of epoch to end of trace
                    scram_traces(base_start:end,i)=baseline_scram(base_count:end,i);
                    %scram tracse is correct length, base_count is wrong
                end 
            end
        end
    end
else
    scram_traces=baseline_scram; %no epochs, only baseline
end
%-----------End Epoch and Baseline Insertion-----------
clear baseline_scram

