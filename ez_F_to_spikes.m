function [spikes,hz]= ez_F_to_spikes(raw_data,data_type,name)
%Set data_type to 'list' in order to import an ROI_list as raw data. Otherwise, set to any other string. 
%
%Y-scales are currently way off. Potentially, modified Z-score data may be the best to import as
%   it is a bit more normalized.
%
%Set name to whatever string you want to name the output PDFs
%

frames_per_bin=1; %Number of frames to insert into each time bin
frame_duration=.128; %Length of a single frame, in seconds.

%Import ROI_list data---------------
if strcmp(data_type,'list')==1
    F=zeros(size(raw_data,2),size(raw_data(1,1).fmean,1));
    parfor i=1:size(raw_data,2)
        F(i,:)=(raw_data(1,i).fmean);
    end
else
    F=raw_data'; %transpose the matrix to get compatible format
end
%------------------------------------

%Configure options in format readable by constrained_foopsi
options = CNMFSetParms('method','cvx','fudge_factor',0.98); 

%Initialize spike matrix
spikes=zeros(size(F));

%Run deconvolution
disp('Starting deconvolution!')
parfor i=1:size(F,1)
    [~,~,~,~,~,spikes(i,:)] = constrained_foopsi(F(i,:),[],[],[],[],options);
    disp(['Percent complete: ' num2str(100-i/size(F,1)*100) '%'])
end

spikes=spikes'; %Convert output matrix spikes to compatible format

%Transform spike timing into binned frequency
hz=ez_spikes_to_hz(spikes,frames_per_bin,frame_duration);

%Spiking graph
spike_filename=[name '_spikes.pdf'];
ez_multiplot(spikes,10,spike_filename,frame_duration,'(sec)',8,'dF/F',2);

%Firing rate graph. Not really different from spiking if you don't bin.
hz_filename=[name '_Hz.pdf'];
ez_multiplot(hz,10,hz_filename,frame_duration,'(sec)',8,'Hz',2);

