function [signal_corr,signal_delay,signal_percentile]=ez_signal_significance(stimulus_trace,signal_traces,maxlagframes,scrambles)
%Why, hello there! This script was written by Daniel Cantu originally to correlate whisker stimuli with fluorescent traces
%    obtained with 2-photon imaging of GCaMP6S in the mouse barrel cortex. This is a flexible script and should be adaptable to 
%    comparing stimuli with various types of recorded output signals.
%
%The general function of this script is to take a set of fluorescent signals and a single stimulus vector to which they were
%    all subjected. Then, for each individual trace, it compares the trace to the stimulus and attempts to find the delay time
%    between the stimulus and the recorded signal. The signal and stimulus traces are then aligned and the correlation between them
%    is found. Then, this is repeated a number of times set by the user using many randomly-scrambled sets of data (1000+, generally).
%    The correlation of the actual signal vs the array of scrambled signals are compared and the percentile rank of the actual
%    amongst the scrambled is found. It's pretty cool.
%
%-----------Inputs------------
%stimulus_trace is a column vector of the stimulus where 0 is no stimulus and 1 is a stimulus.
%signal_traces is a matrix of the traces of your signal, which can be dF/F, Z-scores, raw F, etc.
%    The format of this is that your individual traces are each in column vectors.
%maxlagframes is the maximum number of frames your signal can lag behind the stimulus. This should definitely not be greater than
%    the period between repeated presentations of a stimulus.
%scrambles is the number of scrambles to perform and compare. 1,000 is generally a good number, but 10,000 works if you have time to spare
%    and you happen to have a rather long signal and would, thus, like to try a large number of combinations.
%
%-----------Outputs-----------
%signal_corr is the correlation (R) of your signals to the stimulus in a matrix.
%    These correlation numbers are bound to be low if you're comparing a square-pulse stimulus to long-tailed
%    traces such as those produces by GCaMPs. What matters more is the comparison to scrambled data.
%signal_delay are the delay times of your individual signals relative to the presentation of a stimulus in frames.
%    If you get a mix of positive and negative values, you can use the absolute value to determine the magnitude of
%    the delay. If presenting multiple stimuli that are spread apart, you should get a consistent sign in cells that
%    are considered to be actually responsive. If you are analyzing delays, don't forget to exclude cells that aren't
%    significantly correlated to the stimulus (relative to scrambles).
%signal_percentile is the percentile rankings of your signal traces relative to the scrambled traces.
%    Commonly accepted cut-offs for percentile are typically top 5% or 1% (0.05 or 0.01).
%    This is non-parametric and does not assume normality. Yay!
%    Since all traces are being compared internally to scrambled versions of themselves, differences in levels 
%    of fluorescent calcium indicator between ROIs don't impact results. Woohoo! :)

%matrix initialization
signal_delay=zeros(1,size(signal_traces,2));
signal_corr=zeros(1,size(signal_traces,2)); 
signal_percentile=zeros(1,size(signal_traces,2));

for ROI=1:size(signal_traces,2) %Goes through each ROI's trace individually
[Xa,Ya,signal_delay(ROI)]=alignsignals(stimulus_trace,signal_traces(:,ROI),maxlagframes); %Aligns signal and stimulus, finds delay time
R=corrcoef(Xa(1:size(signal_traces,1)),Ya(1:size(signal_traces,1))); %finds correlation of aligned traces
signal_corr(ROI)=R(2,1); %due to the output of the corrcoef function, you have to select which number you want
scram_corrs=zeros(1,scrambles+1); %resets scramble correlations to zeros, leaves a space at the end for comparing your trace
original_signal=signal_traces(:,ROI); %pulled out here to cut computation time

for scram=1:scrambles %does all the scrambles
    scram_signal=original_signal(randperm(numel(original_signal))); %computes the scrambled data
    [Xa,Ya,~]=alignsignals(stimulus_trace,scram_signal,maxlagframes); %aligns by same parameters as original data
    R=corrcoef(Xa(1:size(signal_traces,1)),Ya(1:size(signal_traces,1))); %correlation of the scrambles are stored
    scram_corrs(scram)=R(2,1);
end

scram_corrs(scrambles+1)=signal_corr(ROI); %throws your ROI of interest's correlation into the list and then finds its rank
signal_percentile(ROI)=find(sort(scram_corrs,'descend')==signal_corr(ROI),1,'first')/size(scram_corrs,2); %percentile is calculated
%    lower value for signal_percentile are more significant.
disp(['Percent complete: ' num2str(ROI/size(signal_traces,2)*100)]);
end






