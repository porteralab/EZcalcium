function [pixel_list,nuc_list,boundary_inner,boundary_outer,boundary_list]=donut_roi(map,center,cell_radius,expand_factor,plot_flag)

%% DONUT_ROI.m  Select donut shaped ROI around a selected point
%    
%% Input Arguments
%   'map': NxM reference image, can be intensity average or maximum projection
%   'center': 1x2 vector [row, col] containing the coordinate of the ROI center     
%   'cell_radius': rough estimate of the expected radius of the cell (in pixel)
%   'expand_factor': 1x2 vector [frow,fcol], a factor that corrects for unequal
%                    physical pixel size of the image. 
%           example: If the physical pixel size in the row dimension is 2x the
%                    physical pixel size in the col dimension, use [2,1]
%                    for expand_factor. If the physical pixel size is equal
%                    in both dimension use [1,1] or []
%
%   'plot_flag': set plot_flag=1 to generate a panel of detail figures   
%
%% Output Arguments
%   'pixel_list': [Nx1] vector containing the index of cytoplasm pixels
%   'nuc_list':   [Nx1] vector containing the index of nucleus pixels
%
%
%   Created 01/20/2011,       by Tsai-Wen Chen, 
%   Last modified 01/21/2011, by Tsai-Wen Chen
%
full_radius=round(1.3*cell_radius);
thick_inner=cell_radius*0.4;
thick_outter=cell_radius*0.1;
search_range=cell_radius*0.3; %maximally allowed cell thickness in pixel
ntheta=90;
nsample=50;
t=(1:ntheta)/ntheta*2*pi;

if ~exist('expand_factor')  || isempty(expand_factor)
    expand_factor=[1,1];
end

if ~exist('plot_flag')
    plot_flag=1;
end

map_org=map;
ss_org=size(map);

ss=ss_org.*expand_factor;
map=imresize(map,ss);
map=double(map);


x=round(center(2))*expand_factor(2);
y=round(center(1))*expand_factor(1);


lprofile=zeros(nsample,ntheta);
lprofile_mod=zeros(nsample,ntheta);

rin=zeros(1,ntheta);

for i=1:ntheta
    f=improfile(map,[x,x+full_radius*cos(t(i))],[y,y+full_radius*sin(t(i))],nsample,'bilinear')';    
    lprofile(:,i)=f;%-[zeros(1,nsample/3),(1:(nsample*2/3))/nsample*max(f)/2];
    
    rin(i)=find_para(f);        
    lprofile_mod(:,i)=f;
    lprofile_mod(1:rin(i),i)=0;
    lprofile_mod((rin(i)+round(search_range/full_radius*nsample)):end,i)=0;
end

path=find_path(lprofile_mod);
rin=path-round(thick_inner/full_radius*nsample);
rout=path+round(thick_outter/full_radius*nsample);




%% determine pixels
% trep=[t-2*pi,t,t+2*pi];
% rin_rep=repmat(rin,1,3);
% rout_rep=repmat(rout,1,3);
roimap=zeros(ss);
for xx=-full_radius:full_radius
    for yy=-full_radius:full_radius
        
        theta=angle(xx+yy*sqrt(-1));
        if theta<=0;
            theta=theta+2*pi;
        end
        rr=sqrt(xx^2+yy^2)/full_radius*nsample;
%         rin_int=interp1(t,rin,theta);
%         rout_int=interp1(t,rout,theta);
        tind=ceil(theta/(2*pi)*ntheta);
        rin_int=rin(tind);
        rout_int=rout(tind);

        indx=xx+x;
        indy=yy+y;
        if (indx>0) && (indy>0) && indx<=(ss(2))  && indy<=(ss(1))
            if rr<rin_int
                roimap(indy,indx)=1;
            elseif (rr>=rin_int)  && (rr<rout_int)
                roimap(indy,indx)=2;
            end
        end
    end
end

roimap_org=imresize(roimap,ss_org,'nearest');

pixel_list=find(roimap_org(:)==2);
nuc_list=find(roimap_org(:)==1);

boundary_inner=zeros(2,ntheta);
boundary_outer=zeros(2,ntheta);
boundary_inner(1,:)=(x+(rin/nsample*full_radius).*cos(t))/expand_factor(2);
boundary_inner(2,:)=(y+(rin/nsample*full_radius).*sin(t))/expand_factor(1);

boundary_outer(1,:)=(x+(rout/nsample*full_radius).*cos(t))/expand_factor(2);
boundary_outer(2,:)=(y+(rout/nsample*full_radius).*sin(t))/expand_factor(1);
        
roimap_org(nuc_list)=0;
boundary=bwperim(roimap_org,4);
boundary_list=find(boundary(:));


if plot_flag==1
    plot_detail;
end



    function plot_detail        
        figure;subplot(1,3,1);imagesc([0,360],[0,full_radius],lprofile);hold on;
        for k=1:ntheta
            plot(k/ntheta*360,path(k)/nsample*full_radius,'.k');
            plot(k/ntheta*360,rin(k)/nsample*full_radius,'.r');
            plot(k/ntheta*360,rout(k)/nsample*full_radius,'.w');
        end
        axis square;
        subplot(1,3,2);imagesc(map);hold on;axis image;
        xi=x+(path/nsample*full_radius).*cos(t);
        yi=y+(path/nsample*full_radius).*sin(t);
        plot(xi,yi,'.k');
        
        
        xi=x+(rin/nsample*full_radius).*cos(t);
        yi=y+(rin/nsample*full_radius).*sin(t);
        plot(xi,yi,'.r');
        
        xi=x+(rout/nsample*full_radius).*cos(t);
        yi=y+(rout/nsample*full_radius).*sin(t);
        plot(xi,yi,'.w');
        
        xlim([x-full_radius*2,x+full_radius*2]);
        ylim([y-full_radius*2,y+full_radius*2]);
        
        subplot(1,3,3);imagesc(roimap);hold on;axis image;
        xi=x+(rin/nsample*full_radius).*cos(t);
        yi=y+(rin/nsample*full_radius).*sin(t);
        plot([xi,xi(1)],[yi,yi(1)],'w');
        
        xi=x+(rout/nsample*full_radius).*cos(t);
        yi=y+(rout/nsample*full_radius).*sin(t);
        plot([xi,xi(1)],[yi,yi(1)],'w');
        
        xlim([x-full_radius*2,x+full_radius*2]);
        ylim([y-full_radius*2,y+full_radius*2]);
        
    end

end

function rin=find_para(f)
    [globalmax,globalind]=max(f);
    threshold=(globalmax-f(1))/2+mean(f(1:5));


    localmax=(f(2:end-1)>f(1:end-2))&(f(2:end-1)>f(3:end))&(f(2:end-1)>threshold);
    ind=find(localmax)+1;


    rpeak=min(ind);
    if isempty(ind)
        rpeak=globalind;
    end
    ind=find(f(1:rpeak)>threshold);
    rin=min(ind);

    if isempty(rin)
        rin=ceil(rpeak/2);
    end

end
    
function path=find_path(lprofile)
    pointer=zeros(size(lprofile));
    value=zeros(size(lprofile));
    value(:,1)=lprofile(:,1);
    for i=2:size(lprofile,2)
        for j=3:(size(lprofile,1)-2)
            [M,ind]=max(value((j-1):(j+1),i-1));
            value(j,i)=M+lprofile(j,i);
            pointer(j,i)=j+ind-2;
        end
    end

    %%second traverse to minimize boundary effect
    pointer=zeros(size(lprofile));
    value(:,1)=value(:,end);
    for i=2:size(lprofile,2)
        for j=3:(size(lprofile,1)-2)
            [M,ind]=max(value((j-1):(j+1),i-1));
            value(j,i)=M+lprofile(j,i);
            pointer(j,i)=j+ind-2;
        end
    end
    
    path=zeros(1,size(lprofile,2));
    [M,ind]=max(value(:,end));
    path(end)=ind;
    
    for j=(size(lprofile,2)):-1:2
    path(j-1)=pointer(path(j),j);
    end
end

