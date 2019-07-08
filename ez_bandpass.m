function [filter_video] = ez_bandpass(video, cutoff_low,cutoff_high,confidence, save_row,name_rows,compression,rate)
%Bandpass filter for videos

%Video is a video matrix

%confidence = percent confidence of low pass filter

%-------Detect video-wide artifacts-------


%XXXXXXX------Collapse video for row-based detection of noise------XXX
    mean_rows=mean(video,2);
    %Save video file, count as 20% of progress

    if save_row==1
        imwrite(mean_rows(:,:,1),name_rows,'tiff','Compression',compression,'WriteMode','overwrite');
        for imagedex = 2:size(video,3); %start at frame two and append to first image
            imwrite(mean_rows(:,:,imagedex),name_rows,'tiff','Compression',compression,'WriteMode','append');
        end
    end
    




%b_vector=zeros(size(video,3))+1;
% b_vector=1;


L=size(video,3);
Fs=rate;
T=1/Fs;
t=(0:L-1)*T;
cutoff_low_position=round(cutoff_low*L/Fs);
cutoff_high_position=round(cutoff_high*L/Fs);

mean_rows=squeeze(mean_rows);

% Y=zeros(size(mean_rows,1));
% P2=zeros(size(mean_rows,1));
f = Fs*(0:(L/2))/L;
P1=zeros(size(mean_rows,1),size(f,2));
Y=(fft(mean_rows,L,2));
fft_peaks=zeros(size(Y,1),1);

for i=1:size(Y,1)
    P2 = abs(Y(i,:)/L);
    P1(i,:) = P2(1:L/2+1);
    P1(i,2:end-1) = 2*P1(i,2:end-1);
    %Find max P for given values of f
    [~,fft_peaks(i)]=max(P1(i,(cutoff_low_position:cutoff_high_position)));
end

%Plot mean FFT for all rows
figure
gcf;
plot(f,mean(P1,1))
title('Mean Single-Sided Amplitude Spectrum of X(t) - Before')
xlabel('f (Hz)')
ylabel('|P1(f)|')

fft_peaks=fft_peaks+cutoff_low_position-1;

stop_low_hz=round(quantile(fft_peaks,(1-confidence)/2));
stop_high_hz=round(quantile(fft_peaks,1-(1-confidence)/2));

filter_cutoff=[f(stop_low_hz) f(stop_high_hz)]; %extract frequency

%normalize frequency
filter_cutoff_norm=filter_cutoff/(Fs/2);



%-----Auto-detect cut-off for filter------


% for i=1:size(video,1)
%     for j=1:size(video,2)
%         fft_video(i,j,:)=fftfilt(b_vector,video(i,j,:));
%     end
% end

%Find max in freq domain
%peaks=zeros(size(video,1),size(video,2));
% 
% 
% peaks=fft(video(256,:,:),2100,3); %2100=video length, choose middle row for horizontal filter
% 
% [~,peaks]=max(peaks(:,:,2:end),[],3); %skip the first, very low freq noise
% 
% % for i=1:size(video,1)
% %     parfor j=1:size(video,2)
% %         [~,peaks(i,j)]=max(fft(video(i,j,:)));
% %     end
% % end
% 
% %Find Cut-off confidence (95%, for example)
% peaks=sort(peaks,'ascend');
% 
% %Find limit for filter
% filter_cutoff=quantile(peaks,1-confidence); %Gets a low value to filter below

%Design low-pass filter
%[b_filt,a_filt]=butter(3,filter_cutoff_norm(1),'low');
%[b_filt,a_filt]=butter(3,[.55/(Fs/2) .99/(Fs/2)],'stop');
[b_filt,a_filt]=butter(5,.6087/(Fs/2),'low');
%Apply filter
for i=1:size(video,1)
    parfor j=1:size(video,2)
        filter_video(i,j,:)=filtfilt(b_filt,a_filt,video(i,j,:));
    end
end


%===================Plot filtered video FFT=========================
L=size(filter_video,3);
Fs=rate;
T=1/Fs;
t=(0:L-1)*T;
cutoff_low_position=round(cutoff_low*L/Fs);
cutoff_high_position=round(cutoff_high*L/Fs);

mean_rows=mean(filter_video,2);
mean_rows=squeeze(mean_rows);

% Y=zeros(size(mean_rows,1));
% P2=zeros(size(mean_rows,1));
f = Fs*(0:(L/2))/L;
P1=zeros(size(mean_rows,1),size(f,2));
Y=(fft(mean_rows,L,2));
fft_peaks=zeros(size(Y,1),1);

for i=1:size(Y,1)
    P2 = abs(Y(i,:)/L);
    P1(i,:) = P2(1:L/2+1);
    P1(i,2:end-1) = 2*P1(i,2:end-1);
    %Find max P for given values of f
    [~,fft_peaks(i)]=max(P1(i,(cutoff_low_position:cutoff_high_position)));
end

%Plot mean FFT for all rows
figure
gcf;
plot(f,mean(P1,1))
title('Mean Single-Sided Amplitude Spectrum of X(t) - Filtered')
xlabel('f (Hz)')
ylabel('|P1(f)|')
%==================================================================

%normalize values before saving
scale_video_black=min(min(min(filter_video)));
filter_video=filter_video-scale_video_black;

scale_video_max=max(max(max(filter_video)));
filter_video=filter_video/scale_video_max;

imwrite(filter_video(:,:,1),name_rows,'tiff','Compression',compression,'WriteMode','overwrite');
for imagedex = 2:size(video,3); %start at frame two and append to first image
    imwrite(filter_video(:,:,imagedex),name_rows,'tiff','Compression',compression,'WriteMode','append');
end  





end 

