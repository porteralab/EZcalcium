function varargout = ez_auto_roi(fullvidfile)

max_width=30;
min_pixels=12;
thresh_z=5;
thresh_frames=6;

%=====================Load Video=======================
display('Starting automatic ROI segmentation!');

vidinfo=imfinfo(fullvidfile); %Checks video file information
if vidinfo(1).FileSize>800000000 %Checks file size
    fprintf(2,'Warning!!! Files greater than 800MB should only be used with 64-bit MATLAB!') %this is a MATLAB problem.
    %Use a 64 bit version of MATLAB (designated with a 'b' at the end of
    %the version with a 64 bit co-*mputer on a 64 bit operating system to
    %handle files greater than 800MB. Matrix size limit is actually just over
    %1GB, but you need extra room for the purpose of motion correction.
end
num_frames=numel(vidinfo); %extracts number of frame information

vidheight=vidinfo(1).Height; %Sets height
vidwidth=vidinfo(1).Width; %Sets width
%vidpixels=vidheight*vidwidth; %Finds full video pixel number
videodata=NaN(vidheight,vidwidth,num_frames); %Makes NaN matrix for speed
parfor i = 1:num_frames %Loads every frame of the video
    videodata(:,:,i)=imread(fullvidfile,i,'info',vidinfo); %reads each frame and writes into greenchannel matrix
    if floor(i/100)==(i/100) %show only every 100 frames progress
        display(['Loading video: ' num2str((1-(i)/(num_frames))*100) '%']);
    end
end

display('Video loaded!'); 
%===================End Load Video========================

load('Z_F_data.mat')
%num_frames=800;
videodata=Z_F(:,:,1:num_frames);

%=================Find Background Pixels==================
roi_map=NaN(vidheight,vidwidth); %Create map of ROIs where value = ROI number. 
%    0 = background. NaN = has yet to be checked.

%Check if all pixels ever exceeds threshold (thresh_z) for thresh_dur consecutive seconds
%   If not, roi_map=0 (background)

       %==========Let's try filtering our Data!=========
       filter_videodata=NaN(size(videodata));
       for i=1:vidheight
           display(['Filtering video: ' num2str(i/vidheight*100,3) '%']);
           parfor j=1:vidwidth
               for frame=1:num_frames
                   if videodata(i,j,frame)>thresh_z %Quick check of average value above thresh
                       filter_videodata(i,j,frame)=thresh_z;
                   else
                       filter_videodata(i,j,frame)=0;
                   end
               end
           end
       end



for i=1:vidheight
    display(['Detecting background pixels: ' num2str(i/vidheight*100,3) '%']);
    parfor j=1:vidwidth
        for frame=1:num_frames-thresh_frames+1
            if sum(filter_videodata(i,j,frame:frame+thresh_frames-1))>=thresh_z*thresh_frames %Quick check of average value above thresh
                roi_map(i,j)=255;
                break
            else if frame==num_frames-thresh_frames+1
                    roi_map(i,j)=1;
                end
            end
        end
    end
end
       figure(1)
       image(roi_map)



       
       
       
%Start at first pixel 

%Check to make sure this pixel wasn't already used in the roi_map

roi_checklist=NaN(vidheight,vidwidth); %create a list of non-background pixels
for i=1:vidheight
    roi_check_count=1;
    for j=1:vidwidth
        if roi_map(i,j)==255
            roi_checklist(i,roi_check_count)=j;
            roi_check_count=roi_check_count+1;
        end
    end
end


alpha_value=0.001;
r_threshold=0.50;
p_test=NaN(vidheight,vidwidth);
good_pixels=NaN(vidheight,1);
parfor i=1:size(good_pixels,1);
    good_pixels(i)=sum(~isnan(roi_checklist(i,:)));
end

%Finds consecutive good pixels that are correlated
%========Spearman Version======

for i=1:vidheight %scans every horizontal scan line in parallel
    display(['Calculating horizontal correlations: ' num2str(i/vidheight*100,3) '%'])
    if good_pixels(i)>1 %checks to see if there are two or more pixels in a line
        [r_value,p_value]=corr(squeeze(filter_videodata(i,roi_checklist(i,1:good_pixels(i)),:))','type','Spearman');
        %[r_value,p_value]=corr(squeeze(videodata(i,roi_checklist(i,1:good_pixels(i)),:))','type','Kendall'); %Kendall may be better, but is too slow practically
        parfor j=1:good_pixels(i)-1 %checks only active pixels
            p_test(i,j)=(p_value(j,j+1)<alpha_value)*(r_value(j,j+1)>r_threshold); %must past both tests
        end
    else if good_pixels(i)==1 %checks to see if only one pixel is valid
            p_test(i,1)=0;%a single roi is generated for the row
        end
    end
end

% %========Pearson Version======
% 
% for i=1:vidheight %scans every horizontal scan line in parallel
%     display(['Calculating horizontal correlations: ' num2str(i/vidheight*100,3) '%'])
%     if good_pixels(i)>1 %checks to see if there are two or more pixels in a line
%         [~,p_value]=corrcoef(squeeze(videodata(i,roi_checklist(i,1:good_pixels(i)),:))');
%         for j=1:good_pixels(i)-1 %checks only active pixels
%             p_test(i,j)=p_value(j,j+1)<alpha_value;
%         end
%     else if good_pixels(i)==1 %checks to see if only one pixel is valid
%             p_test(i,j)=0;%a single roi is generated for the row
%         end
%     end
% end

%======Bootstrap version=======
% bootstraps=100;
% r_value=NaN(bootstraps,1);
% %Finds consecutive good pixels that are correlated
% for i=1:vidheight %scans every horizontal scan line in parallel
%     display(['Calculating horizontal correlations: ' num2str(i/vidheight*100,3) '%'])
%     if good_pixels(i)>1 %checks to see if there are two or more pixels in a line
%         %[~,p_value]=corrcoef(squeeze(videodata(i,roi_checklist(i,1:good_pixels(i)),:))');
%         for j=1:good_pixels(i)-1 %checks only active pixels
%             %p_test(i,j)=p_value(j,j+1)<alpha_value;
%             current_trace=squeeze(videodata(i,roi_checklist(i,j),:));             
%             parfor scramble=2:bootstraps
%             scramble_trace=squeeze(videodata(i,roi_checklist(i,j+1),randperm(num_frames)));
%             [rcorr,~]=corrcoef(current_trace,scramble_trace);
%             r_value(scramble)=rcorr(1,2);
%             end
%             [original_r,~]=corrcoef(current_trace,squeeze(videodata(i,roi_checklist(i,j+1),:)));
%             r_value(1)=original_r(1,2);
%             p_value=(1-find(sort(r_value)==original_r(1,2),1,'last')/bootstraps);
%             p_test(i,j)=p_value<alpha_value;
%         end
%     else if good_pixels(i)==1 %checks to see if only one pixel is valid
%             p_test(i,j)=0;%a single roi is generated for the row
%         end
%     end
% end




h_color_map=NaN(vidheight,vidwidth);
h_number_map=NaN(vidheight,vidwidth);

good_rois=zeros(vidheight,1);

%Organize pixels into horizontal ROIs
for i=1:vidheight
    roi_count=1;
    pixel_count=0;
    first_pixel=1;
    for j=1:good_pixels(i)
        if p_test(i,j)==1
            pixel_count=pixel_count+1; %Count pixels, continue roi
        else
            roi_color=randi(60);
            ROI.(['H_' num2str(i)]).(['ROI_' num2str(roi_count)]).Color=roi_color;
            ROI.(['H_' num2str(i)]).(['ROI_' num2str(roi_count)]).Pixels=roi_checklist(i,first_pixel:first_pixel+pixel_count);
            ROI.(['H_' num2str(i)]).(['ROI_' num2str(roi_count)]).Trace=squeeze(mean(videodata(i,roi_checklist(i,first_pixel:first_pixel+pixel_count),:),2));          
            h_color_map(i,roi_checklist(i,first_pixel:first_pixel+pixel_count))=roi_color;
            h_number_map(i,roi_checklist(i,first_pixel:first_pixel+pixel_count))=roi_count;
            good_rois(i)=good_rois(i)+1;
            roi_count=roi_count+1;
            pixel_count=0; %reset counter
            first_pixel=j+1;
        end 
    end
end
       figure(2) 
       image(h_color_map)

%             roi_color=[rand, rand, rand]; %Finds a random color
%             roi_color(randi(3,1))=1;

% %Find ROIs vertically
% for i=1:vidheight
%     for j=1:good_rois(i)
%         ROI.(['H_' num2str(i)]).(['ROI_' num2str(roi_count)]).Trace
%         
%     end
% end

%=========Vertical Test==========
v_roi_checklist=NaN(vidheight,vidwidth); %create a list of non-background pixels
for j=1:vidwidth
    roi_check_count=1;
    for i=1:vidheight
        if roi_map(i,j)==255
            v_roi_checklist(roi_check_count,j)=i;
            roi_check_count=roi_check_count+1;
        end
    end
end

v_p_test=NaN(vidheight,vidwidth);
v_good_pixels=NaN(vidwidth,1);
parfor i=1:size(v_good_pixels,1);
    v_good_pixels(i)=sum(~isnan(v_roi_checklist(:,i)));
end

for i=1:vidwidth %scans every horizontal scan line in parallel
    display(['Calculating vertical correlations: ' num2str(i/vidwidth*100,3) '%'])
    if v_good_pixels(i)>1 %checks to see if there are two or more pixels in a line
        [r_value,v_p_value]=corr(squeeze(filter_videodata(v_roi_checklist(1:v_good_pixels(i),i),i,:))','type','Spearman');
        for j=1:v_good_pixels(i)-1 %checks only active pixels
            v_p_test(j,i)=v_p_value(j,j+1)<alpha_value*(r_value(j,j+1)>r_threshold);
        end
    else if v_good_pixels(i)==1 %checks to see if only one pixel is valid
            v_p_test(j,i)=0;%a single roi is generated for the row
        end
    end
end

v_color_map=NaN(vidheight,vidwidth);
v_number_map=NaN(vidheight,vidwidth);
v_good_rois=zeros(vidwidth,1);

%Organize pixels into vertical ROIs
for i=1:vidwidth
    roi_count=1;
    pixel_count=0;
    first_pixel=1;
    for j=1:v_good_pixels(i)
        if v_p_test(j,i)==1
            pixel_count=pixel_count+1; %Count pixels, continue roi
        else
            roi_color=randi(60);
            ROI.(['V_' num2str(i)]).(['ROI_' num2str(roi_count)]).Color=roi_color;
            ROI.(['V_' num2str(i)]).(['ROI_' num2str(roi_count)]).Pixels=v_roi_checklist(first_pixel:first_pixel+pixel_count,i);
            ROI.(['V_' num2str(i)]).(['ROI_' num2str(roi_count)]).Trace=squeeze(mean(videodata(v_roi_checklist(first_pixel:first_pixel+pixel_count,i),i,:),2));          
            v_color_map(v_roi_checklist(first_pixel:first_pixel+pixel_count,i),i)=roi_color;
            v_number_map(v_roi_checklist(first_pixel:first_pixel+pixel_count,i),i)=roi_count;
            v_good_rois(i)=v_good_rois(i)+1;
            roi_count=roi_count+1;
            pixel_count=0; %reset counter
            first_pixel=j+1;
        end 
    end
end
       figure(3) 
       image(v_color_map)

           roi_colors=randi(64,[vidheight,vidwidth]);
           double_color_map=NaN(vidheight,vidwidth);
           double_number_map=NaN(vidheight,vidwidth);
           roi_count=vidwidth+vidheight;
           
           new_h_number_map=h_number_map;
           new_v_number_map=v_number_map;
           
      for i=1:vidheight
          previous_roi=0;
          for j=1:vidwidth
              if ~isnan(new_h_number_map(i,j))
                  if new_h_number_map(i,j)==previous_roi
                      double_number_map(i,j)=roi_count;
                      double_color_map(i,j)=roi_colors(roi_count);
                                
                      for v=1:vidheight %This basically needs to be infinitely recursive. Change plan.
                          if ~isnan(new_v_number_map(v,j))
                              if new_v_number_map(v,j)==v_number_map(i,j)
                                  double_number_map(v,j)=roi_count;
                                  double_color_map(v,j)=roi_colors(roi_count);
                                  new_v_number_map(v,j)=NaN;
                                  new_h_number_map(v,j)=NaN;
                              end
                          end
                      end
                      
                  else
                      previous_roi=new_h_number_map(i,j);
                      roi_count=roi_count+1;
                  end
                  %double_color_map(i,j)=roi_colors(h_number_map(i,j),v_number_map(i,j));
              end
          end
      end
       figure(4)
       image(double_color_map)
       
      

%Check all neighbors neighbor (i+max_width,j+max_width)
%   Compare horizontally-adjacent pixel (due to laser scanning direction), not original pixel
%ez_auto_roi('Z_F.tif')


1;
 
 %Randomly maximizes one RGB value for better visualization against background

 