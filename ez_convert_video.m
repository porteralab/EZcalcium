%Converts Zemelman cell videos into a single matrix, and then a video
%=========Inputs========
filename='mouse6depth200red';
compression='lzw';
%======End Inputs=======

green=red;
disp('Starting conversion!')

% green = video in 1xframe num cell
disp('Reading image dimensions!')
num_frames=length(green);
x_size=size(green{1},2);
y_size=size(green{1},1);

%Convert cell to a standard image
disp('Converting cell to a matrix!')
video_matrix=zeros(y_size,x_size,num_frames);

parfor i=1:num_frames
   video_matrix(:,:,i)=green{i};
end

disp('Scaling image!')
scaleblack=min(min(min(video_matrix)));
video_matrix=video_matrix-scaleblack;
scalefactor=max(max(max(video_matrix)));

disp('Writing video!')
imwrite(video_matrix(:,:,1)/scalefactor,[filename '.tif'],'tiff','Compression',compression,'WriteMode','overwrite');
drawnow; %update GUI
for imagedex = 2:num_frames %start at frame two and append to first image
    imwrite(video_matrix(:,:,imagedex)/scalefactor,[filename '.tif'],'tiff','Compression',compression,'WriteMode','append');
end

disp('Done! That was fun; we should do it again!')








