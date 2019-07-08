function ez_motion_correct_2channel(fullvidfile1,fullvidfile2,referenceframe,blocksize)
%varargout = ez_motion_correct_1channel(fullvidfile,referenceframe,blocksize)
%Based on code by Patrick Mineault
%blocksize=2;
%referenceframe=2; %refers to 2 frames prior for reference
%Import tiff into matrix

display('Starting two channel motion correction!');
Nbasis=blocksize;

greeninfo=imfinfo(fullvidfile1); %Checks video file information
redinfo=imfinfo(fullvidfile2); %Checks video file information
if greeninfo(1).FileSize>800000000 %Checks file size
    fprintf(2,'Warning!!! Files greater than 800MB should only be used with 64-bit MATLAB!') %this is a MATLAB problem.
    %Use a 64 bit version of MATLAB (designated with a 'b' at the end of
    %the version with a 64 bit computer on a 64 bit operating system to
    %handle files greater than 800MB. Matrix size limit is actually just over
    %1GB, but you need extra room for the purpose of motion correction.
end
num_frames=numel(greeninfo); %extracts number of frame information

greenheight=greeninfo(1).Height; %Sets height
greenwidth=greeninfo(1).Width; %Sets width
greenchannel=zeros(greenheight,greenwidth,num_frames); %Makes zero matrix for speed
redchannel=zeros(greenheight,greenwidth,num_frames);
parfor i = 1:num_frames %Loads every frame of the video
    greenchannel(:,:,i)=imread(fullvidfile1,i,'info',greeninfo); %reads each frame and writes into greenchannel matrix
    if floor(i/100)==(i/100) %show only every 100 frames progress
        display(['Loading channel 1: ' num2str((1-(i)/(num_frames))*100) '%']);
    end
end
display('Channel 1 loaded!')
parfor i = 1:num_frames %Loads every frame of the video
    redchannel(:,:,i)=imread(fullvidfile2,i,'info',redinfo); %reads each frame and writes into greenchannel matrix
    if floor(i/100)==(i/100) %show only every 100 frames progress
        display(['Loading channel 2: ' num2str((1-(i)/(num_frames))*100) '%']);
    end
end
display('Channel 2 loaded!')
%Find average tiff file (mean of Z stack) for first pass

redscaleblack=min(min(min(redchannel)));
redchannel=redchannel-redscaleblack;
redscalefactor=max(max(max(redchannel)));

redchannelmean=redchannel(:,:,1); %just use the first frame


redchannelmeanscale=redchannelmean/redscalefactor; 
redchannelmean=mean(redchannel,3); %calculates mean along the 3rd dimension
%redchannelmeanscale=redchannelmean/max(max(redchannelmean)); %scales so that the max value in the mean image is equal to white (1)
imwrite(redchannelmeanscale,[fullvidfile2(1:end-4) '_redmean' '.tif'],'tiff','Compression','none') %writes tiff with no compression
%greenchannelmean=mean(greenchannel,3); %calculates mean along the 3rd dimension
%greenchannelmeanscale=greenchannelmean/max(max(greenchannelmean)); %scales so that the max value in the mean image is equal to white (1)

scaleblack=min(min(min(greenchannel)));
greenchannel=greenchannel-scaleblack;
scalefactor=max(max(max(greenchannel)));

greenchannelmean=greenchannel(:,:,1); %just use the first frame


greenchannelmeanscale=greenchannelmean/scalefactor; 
imwrite(greenchannelmeanscale,[fullvidfile1(1:end-4) '_greenmean' '.tif'],'tiff','Compression','none') %writes tiff with no compression

%Run through this code twice, second pass refering to an earlier frame

%---------First Pass--------------
T=redchannelmean; %template image
firstId=zeros(greenheight,greenwidth,num_frames);
firstIGd=firstId;
secondId=zeros(greenheight,greenwidth,num_frames);
secondIGd=zeros(greenheight,greenwidth,num_frames);
firstIdscale=firstId;
firstIGdscale=firstId;
secondIdscale=firstId;
secondIGdscale=firstId;

for imagedex = 1:num_frames %For every frame of the video
    if floor(imagedex/10)==(imagedex/10) %show only every 10 frames progress
    display(['Progress: ' num2str((imagedex)/(num_frames*2)*100) '%']);
    end
    I=redchannel(:,:,imagedex); %loads one frame at a time
    IG=greenchannel(:,:,imagedex); %makes a green channel one, too
    %[firstId,firstdpx(imagedex,:),firstdpy(imagedex,:)]=doLucasKanade(T,I); %runs the motion correction code
    [firstId(:,:,imagedex),firstIGd(:,:,imagedex),~,~]=doLucasKanade2(T,I,Nbasis,IG); %runs the motion correction code
    firstIdscale(:,:,imagedex)=firstId(:,:,imagedex)/max(max(redchannelmean));
    firstIGdscale(:,:,imagedex)=firstIGd(:,:,imagedex)/max(max(greenchannelmean));
    if imagedex==1 %for the first picture, overwrite. Then, append. This is a temporary file.
        imwrite(firstIdscale(:,:,imagedex),'motcorrtemp.tif','tiff','Compression','none','WriteMode','overwrite');
        imwrite(firstIGdscale(:,:,imagedex),'motcorrtempG.tif','tiff','Compression','none','WriteMode','overwrite');
    else %appends the rest of the images to the file in order
        imwrite(firstIdscale(:,:,imagedex),'motcorrtemp.tif','tiff','Compression','none','WriteMode','append');
        imwrite(firstIGdscale(:,:,imagedex),'motcorrtempG.tif','tiff','Compression','none','WriteMode','append');
    end
end

%----------Second Pass-----------
for imagedex = 1:num_frames %For every frame of the video
    if floor(imagedex/10)==(imagedex/10) %show only every 10 frames progress
        display(['Progress: ' num2str((imagedex+num_frames)/(num_frames*2)*100) '%']);
   end  
    I=firstIdscale(:,:,imagedex); %loads one frame at a time
    IG=firstIGdscale(:,:,imagedex);
    
    if imagedex>referenceframe
        T=secondIdscale(:,:,imagedex-referenceframe); %checks several frames prior as a template
    else
        T=firstIdscale(:,:,imagedex); %uses self as reference for initial frames
    end
    %[firstId,firstdpx(imagedex,:),firstdpy(imagedex,:)]=doLucasKanade(T,I); %runs the motion correction code
    [secondId(:,:,imagedex),secondIGd(:,:,imagedex),~,~]=doLucasKanade2(T,I,Nbasis,IG); %runs the motion correction code
    %[secondId(:,:,imagedex),~,~]=doLucasKanade(T,I,Nbasis); %runs the motion correction code
    %secondIdscale(:,:,imagedex)=secondId(:,:,imagedex)/max(max(greenchannelmean));
    secondIdscale(:,:,imagedex)=secondId(:,:,imagedex);
    secondIGdscale(:,:,imagedex)=secondIGd(:,:,imagedex);
    if imagedex==1 %for the first picture, overwrite. Then, append.
        imwrite(secondIdscale(:,:,imagedex),[fullvidfile2(1:end-4) '_ezmcor2_ch2' '.tif'],'tiff','Compression','none','WriteMode','overwrite');
        imwrite(secondIGdscale(:,:,imagedex),[fullvidfile1(1:end-4) '_ezmcor2_ch1' '.tif'],'tiff','Compression','none','WriteMode','overwrite');
    else %appends the rest of the images to the file in order
        imwrite(secondIdscale(:,:,imagedex),[fullvidfile2(1:end-4) '_ezmcor2_ch2' '.tif'],'tiff','Compression','none','WriteMode','append');
        imwrite(secondIGdscale(:,:,imagedex),[fullvidfile1(1:end-4) '_ezmcor2_ch1' '.tif'],'tiff','Compression','none','WriteMode','append');
    end
end
delete('motcorrtemp.tif');
delete('motcorrtempG.tif');
display('Two channel motion correction complete!');




end

%-----Below are the functions by Patrick Mineault. These do not need to be
%modified, but are instead called by the main function.-------------------

function [Id,IGd,dpx,dpy] = doLucasKanade2(T,I,Nbasis,IG,dpx,dpy) %dont need dpx, dpy
    warning('off','fastBSpline:nomex'); 
    %Nbasis = 16; %un-hard-coded this 8/26/14 DC
    niter = 25;
    damping = 1;
    deltacorr = .0005;
 
    lambda = .0001*median(T(:))^2;
    %Use a non-iterative algo to get the initial displacement
 
    if nargin < 5
        [dpx,dpy] = doBlockAlignment(I,T,Nbasis);
        dpx = [dpx(1);(dpx(1:end-1)+dpx(2:end))/2;dpx(end)];
        dpy = [dpy(1);(dpy(1:end-1)+dpy(2:end))/2;dpy(end)];
    end
    %dpx = zeros(Nbasis+1,1);
    %dpy = zeros(Nbasis+1,1);
 
    %linear b-splines
    knots = linspace(1,size(T,1),Nbasis+1);
    knots = [knots(1)-(knots(2)-knots(1)),knots,knots(end)+(knots(end)-knots(end-1))];
    spl = fastBSpline(knots,knots(1:end-2)); %available on MATLAB file exchange
    B = spl.getBasis((1:size(T,1))');
 
    %Find optimal image warp via Lucas Kanade
 
    Tnorm = T(:)-mean(T(:));
    Tnorm = Tnorm/sqrt(sum(Tnorm.^2));
    B = full(B);
    c0 = mycorr(I(:),Tnorm(:));
    c20 = mycorr(IG(:),Tnorm(:));
 
    %theI = gpuArray(eye(Nbasis+1)*lambda);
    theI = (eye(Nbasis+1)*lambda);
 
    Bi = B(:,1:end-1).*B(:,2:end);
    allBs = [B.^2,Bi];
 
    [xi,yi] = meshgrid(1:size(T,2),1:size(T,1));
 
    bl = quantile(I(:),.01);
    bl2 = quantile(IG(:),.01);
 
    for ii = 1:niter
 
        %Displaced template
        Dx = repmat((B*dpx),1,size(T,2));
        Dy = repmat((B*dpy),1,size(T,2));
 
        Id = interp2(I,xi+Dx,yi+Dy,'linear');
        IGd = interp2(IG,xi+Dx,yi+Dy,'linear'); %Editted by DC for 2 channels

        Id(isnan(Id)) = bl;
        IGd(isnan(IGd)) = bl2;
        c = mycorr(Id(:),Tnorm(:));
 
        if c - c0 < deltacorr && ii > 1
            break;
        end
 
        c0 = c;
        
        
        %C2 verion
        c2 = mycorr(IGd(:),Tnorm(:));
        
        if c2 - c20 < deltacorr && ii > 1
            break;
        end
        
        c20 = c2;
        
        
        
 
        %gradient of template
        dTx = (Id(:,[1,3:end,end])-Id(:,[1,1:end-2,end]))/2;
        dTy = (Id([1,3:end,end],:)-Id([1,1:end-2,end],:))/2;
 
        del = T(:) - Id(:);
 
        %special trick for g (easy)
        gx = B'*sum(reshape(del,size(dTx)).*dTx,2);
        gy = B'*sum(reshape(del,size(dTx)).*dTy,2);
 
        %special trick for H - harder
        Hx = constructH(allBs'*sum(dTx.^2,2),size(B,2))+theI;
        Hy = constructH(allBs'*sum(dTy.^2,2),size(B,2))+theI;
 
        %{
        %Compare with fast method
        dTx_s = reshape(bsxfun(@times,reshape(B,size(B,1),1,size(B,2)),dTx),[numel(dTx),size(B,2)]);
        dTy_s = reshape(bsxfun(@times,reshape(B,size(B,1),1,size(B,2)),dTy),[numel(dTx),size(B,2)]);
 
        Hx = (doMult(dTx_s) + theI);
        Hy = (doMult(dTy_s) + theI);
        %}
 
        dpx_ = Hx\gx;
        dpy_ = Hy\gy;
 
        dpx = dpx + damping*dpx_;
        dpy = dpy + damping*dpy_;
    end
end
 
function thec = mycorr(A,B)
    A = A(:) - mean(A(:));
    A = A / sqrt(sum(A.^2));
    thec = A'*B;
end
 
function H2 = constructH(Hd,ns)
    H2d1 = Hd(1:ns)';
    H2d2 = [Hd(ns+1:end);0]';
    H2d3 = [0;Hd(ns+1:end)]';
 
    H2 = spdiags([H2d2;H2d1;H2d3]',-1:1,ns,ns);
end
 
function [dpx,dpy] = doBlockAlignment(T,I,nblocks)
    dpx = zeros(nblocks,1);
    dpy = zeros(nblocks,1);
 
    dr = 10;
    blocksize = size(T,1)/nblocks;
 
    [xi,yi] = meshgrid(1:size(T,2),1:blocksize);
    thecen = [size(T,2)/2+1,floor(blocksize/2+1)];
    mask = (xi-thecen(1)).^2+(yi-thecen(2)).^2< dr^2;
 
    for ii = 1:nblocks
        dy = (ii-1)*size(T,1)/nblocks;
        rg = (1:size(T,1)/nblocks) + floor(dy); %added rounding 8/26/14 DC
        %rg = (1:size(T,1)/nblocks) + dy;
        T_ = T(rg,:);
        I_ = I(rg,:);
        T_ = bsxfun(@minus,T_,mean(T_,1));
        I_ = bsxfun(@minus,I_,mean(I_,1));
        dx = fftshift(ifft2(fft2(T_).*conj(fft2(I_))));
        theM = dx.*mask;
 
        [yy,xx] = find(theM == max(theM(:)));
 
        dpx(ii) = (xx-thecen(1));
        dpy(ii) = (yy-thecen(2));
    end
end

