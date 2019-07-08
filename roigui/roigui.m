function roigui(im,ROI_list,pixel_dimension)
%   
%   im :  input images, organized to 3-D (x by y by t) matrix
%   ROI_list:  optional, input to re-use previously selected ROI
% 
%   Created 01/20/2008,       by Tsai-Wen Chen, 
%   Last modified 7/22/2013 , by Tsai-Wen Chen
%

currFrame=1;
ss=size(im);
if ss(3)>400
    max_ind=400;
else
    max_ind=ss(3);
end
isplaying=0;
colormap_string={'gray','jet','hot'};

hdispfig=-1;
hdispimage=-1;
hdispseed=-1;
hdispROI=-1;
% hdispRec=-1;
hdispCircle=-1;
hROIDetail=-1;

seed_location.row=[];
seed_location.col=[];
ROIcount=1;
if nargin==1
    ROI_list=[];
else
    if ~isempty(ROI_list)
        ROI_list=measure_ROI(im,ROI_list);
        ROIcount=length(ROI_list)+1;
    end
end

if ~exist('pixel_dimension')
    pixel_dimension=[1,1];
end
roi_map=zeros(ss(1:2));   % 1 when pixel belong to a ROI, 0 otherwise


%% ROI selection parameter
cell_radius=10;
para.region_size=round(cell_radius*1.8);
para.cell_radius=cell_radius;
para.min_pixelno=10;
para.r_threshold=0.8;
para.npca=2;   %number of pca components for residule

%% setup display structure
d.name='Average';

d.data=mean(im,3);
d.playsize=1;
d.DataRange=[min(d.data(:)),max(d.data(:))];
% d.DataRange=dataRange;
d.DispRange=[prctile(d.data(:),1),prctile(d.data(:),99.8)];
d.colormap=1;
dispstruct=d;


d.name='Raw Images';
d.data=im;
d.playsize=size(im,3);
max_im=max(im,[],3);
min_im=min(im,[],3);
firstim=max_im;
d.DataRange=[min(min_im(:)),max(max_im(:))];
% dataRange=[min(im(:)),max(im(:))];
% d.DataRange=dataRange;
d.DispRange=[prctile(firstim(:),0.0),prctile(firstim(:),98)];
d.colormap=1;
dispstruct(end+1)=d;


d.name='MaxProj';
d.data=[];
d.playsize=1;
d.DataRange=[];
d.DispRange=[];
d.colormap=1;
dispstruct(end+1)=d;

%% Block Structure
% ncondition=16;
% ntrial=5;
% frame_per_trial=32;
% base_ind=9:16;
% resp_ind=17:32;
% smooth=[1,3];

%%
% 
ncondition=8;
ntrial=5;
frame_per_trial=120;
base_ind=31:60;
resp_ind=61:120;
smooth=[1,3];

% ncondition=8;
% ntrial=10;
% nslice=12;
% frame_per_trial=40;
% base_ind=1:10;
% resp_ind=11:30;


% ncondition=8;
% ntrial=5;
% frame_per_trial=80;
% base_ind=1:20;
% resp_ind=21:40;
% smooth=[1,3];


% ncondition=8;
% ntrial=5;
% frame_per_trial=30;
% base_ind=[(1:6),(22:30)];
% resp_ind=7:21;
% smooth=[1,3];
% ncondition=4;
% ntrial=3;
% frame_per_trial=16;
% base_ind=1:8;
% resp_ind=9:16;
% smooth=[1,3];


% base_ind=1:8;
% resp_ind=9:16;


%% setup GUI

hctrlfig=figure('position',[900,100,500,550],'Resize','off','MenuBar','none','color',[1,1,1]*0.85,'DeleteFcn',@ctrlfigDelCallback);

% Create the button group.
h = uibuttongroup('Units','pixel','Position',[350 380 130 160],'visible','on');
hgroup1 = uibuttongroup('Units','pixel','Position',[0 79 130 80],'parent',h);
hgroup2 = uibuttongroup('Units','pixel','Position',[0 0 130 80],'parent',h);
uicontrol('Style','Radio','String','Ring','pos',[10 40 100 30],'parent',hgroup1,'HandleVisibility','off');
uicontrol('Style','Radio','String','Disk','pos',[10 10 100 30],'parent',hgroup1,'HandleVisibility','off');
uicontrol('Style','Radio','String','Auto Border','pos',[10 40 100 30],'parent',hgroup2,'HandleVisibility','off');
uicontrol('Style','Radio','String','Circle Border','pos',[10 10 100 30],'parent',hgroup2,'HandleVisibility','off');

% set(hgroup1,'SelectedObject',2);  % No selection

%hctrlfig=figure('position',[900,200,350,550],'DeleteFcn',@ctrlfigDelCallback);
uicontrol(hctrlfig,'Tag','ListROI','Style','listbox','Units','pixel','position',[25,15,75,200],'Max',2,'Callback',@ListROICallback,'KeyPressFcn', @keyPressFcn);
uicontrol(hctrlfig,'Tag','EdROIinfo','Style','edit','Units','pixel','position',[110,15,140,200],'Max',2,'HorizontalAlignment','left');
uicontrol(hctrlfig,'Tag','BnPlotSel','Style','pushbutton','Units','pixel','position',[260,190,70,25],'String','PlotSel','Callback',@BnPlotSelCallback);
uicontrol(hctrlfig,'Tag','BnExport','Style','pushbutton','Units','pixel','position',[260,160,70,25],'String','Export','Callback',@BnExportCallback);
% uicontrol(hctrlfig,'Tag','BnSort','Style','pushbutton','Units','pixel','position',[260,130,70,25],'String','Sort','Callback',@BnSortCallback);
% uicontrol(hctrlfig,'Tag','BnDetail','Style','togglebutton','Units','pixel','position',[260,100,70,25],'String','Detail','Callback',@BnDetailCallback);
uicontrol(hctrlfig,'Tag','BnOption','Style','pushbutton','Units','pixel','position',[260,130,70,25],'String','Option','Callback',@BnOptionCallback);
axes('Tag','ax1','units','pixel','position',[25,245,300,150],'Parent',hctrlfig,'NextPlot','add');       %template trace                      

% uicontrol(hctrlfig,'Tag','BnDF_F','Style','pushbutton','Units','pixel','position',[25,410,80,40],'String','DF_Fmap','Callback',@BnDF_FCallback);
% uicontrol(hctrlfig,'Tag','BnAutoROI','Style','pushbutton','Units','pixel','position',[135,410,80,40],'String','Auto ROI','Callback',@BnAutoROICallback);
% uicontrol(hctrlfig,'Tag','BnAutoROI','Style','pushbutton','Units','pixel','position',[245,410,80,40],'String','Auto ROI','Callback',@BnAutoROICallback,'Enable','off');

uicontrol(hctrlfig,'Tag','SlFrame','Style','slider','Units','pixel','position',[25,521,200,18],'Max',ss(3),'Min',1,'Value',currFrame,'SliderStep',[1/(ss(3)-1),0.1]);%,'Callback',@SlFrameCallback);
uicontrol(hctrlfig,'Tag','BnPlay','Style','pushbutton','Units','pixel','position',[230,520,40,20],'String','Play','Callback',@BnPlayCallback);
uicontrol(hctrlfig,'Tag','EdFrame','Style','edit','Units','pixel','position',[275,520,50,20],'String',num2str(currFrame),'Callback',@EdFrameCallback);

uicontrol(hctrlfig,'Tag','SlMax','Style','slider','Units','pixel','position',[200,486,70,16]);%,'Callback',@SlMaxCallback);
uicontrol(hctrlfig,'Tag','EdMax','Style','edit','Units','pixel','position',[275,486,50,18],'String','20000','Callback',@EdMaxCallback);
uicontrol(hctrlfig,'Tag','SlMin','Style','slider','Units','pixel','position',[200,465,70,16]);%,'Callback',@SlMinCallback);
uicontrol(hctrlfig,'Tag','EdMin','Style','edit','Units','pixel','position',[275,465,50,18],'String','20000','Callback',@EdMinCallback);
uicontrol(hctrlfig,'Tag','PopupDisplay','Style','popupmenu','Units','pixel','position',[25,479,100,25],'String','Raw Images','Callback',@PopupDisplayCallback);
uicontrol(hctrlfig,'Tag','PopupColormap','Style','popupmenu','Units','pixel','position',[130,479,60,25],'String',colormap_string,'Callback',@PopupColormapCallback);
uicontrol(hctrlfig,'Tag','CkROI','Style','checkbox','Units','pixel','position',[25,460,50,13],'String','ROI','Value',1,'Callback',@CkROICallback);
% uicontrol(hctrlfig,'Tag','CkSeed','Style','checkbox','Units','pixel','position',[78,460,50,13],'String','Seed','Value',1,'Callback',@CkSeedCallback);


hobjs=guihandles(hctrlfig);
hROIsignal=plot(hobjs.ax1,1:ss(3),zeros(ss(3),1));
%hPixSignal=plot(hobjs.ax1,1:ss(3),zeros(ss(3),1),'r','LineWidth',0.1);

CreateNewDispWnd();
set(hobjs.PopupDisplay,'String',{dispstruct.name});
PopupDisplayCallback();
drawROI();


if  usejava('awt') % java enabled -> use it to update while dragging
    l1=handle.listener(hobjs.SlFrame,'ActionEvent',@SlFrameCallback);
    l2=handle.listener(hobjs.SlMax,'ActionEvent',@SlMaxCallback);
    l3=handle.listener(hobjs.SlMin,'ActionEvent',@SlMinCallback);
end


    function ListROICallback(varargin)
        drawROI();
    end


    function BnPlotSelCallback(varargin)
        sel_ind=get(hobjs.ListROI,'Value');
        
        fmean=[ROI_list(sel_ind).fmean];
        multiplot(1:size(fmean,1),fmean,{ROI_list(sel_ind).name});
        
     
        
%         nROI=size(fmean,2);
% %        fmean=reshape(fmean,frame_per_trial,[]);
%         df_f=rawf2df_f(fmean,base_ind);
% %         df_f=reshape(df_f,frame_per_trial*ncondition,ntrial,nROI);
%         
%                
%         figure;
%         hold on;
%         
%         fs=15;
%         
%         stim_start=(min(resp_ind)-0.5)/fs;
%         stim_duration=(length(resp_ind))/fs;
%         for i=1:ncondition
%             rectangle('Position',[stim_start,min(df_f(:)),stim_duration,max(df_f(:))-min(df_f(:))],'FaceColor',[1,1,1]*0.9,'LineStyle','none');
%             stim_start=stim_start+frame_per_trial/fs;
%         end
%         timebase=(1:frame_per_trial*ncondition)/fs;
%         plot(timebase,df_f(:,:,1),'color',[1,1,1]*0.5);
%         plot(timebase,mean(df_f(:,:,1),2),'color','r');
%         plot([0,max(timebase)],[0,0],'k')
%         xlim([0,max(timebase)]);
      

    end

    function BnExportCallback(varargin)
        assignin('base','ROI_list',ROI_list);
    end

    function BnSortCallback(varargin)
    end

    function BnDetailCallback(varargin)
        
%         if get(hobjs.BnDetail,'Value')==0
%             if ishandle(hROIDetail)
%                 close(hROIDetail);
%                 hROIDetail=-1;
%             end
%         else
%             drawROI();
%         end
    end

    function BnOptionCallback(varargin)
        prompt = {'Enter expected radius of the cell (in pixel):','Enter minimal pixel number:'};
        dlg_title = 'Input ROI selection parameters';
        num_lines = 1;
        def = {num2str(cell_radius),num2str(para.min_pixelno)};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        if ~isempty(answer)
            cell_radius=str2double(answer(1));
            para.region_size=ceil(cell_radius*1.8);
            para.cell_radius=cell_radius;
            %para.region_size=str2double(answer(1));
            para.min_pixelno=str2double(answer(2));
        end
       
    end



    function BnPlayCallback(varargin)
        if isplaying==0    
            isplaying=1;
            set(hobjs.BnPlay,'String','Stop');
            while isplaying
                
                currFrame=currFrame+1;
                if currFrame>ss(3)
                    currFrame=1;
                    isplaying=0;
                end
                set(hobjs.EdFrame,'String',num2str(currFrame));
                set(hobjs.SlFrame,'Value',currFrame);
                UpdateDisplay(); 
            end
            set(hobjs.EdFrame,'String',num2str(currFrame));
            set(hobjs.SlFrame,'Value',currFrame);
            set(hobjs.BnPlay,'String','Play');
            UpdateDisplay();
        else
            isplaying=0;
            set(hobjs.BnPlay,'String','Play');
        end       
    end

%     function BnNPMapCallback(varargin)        
%         im_npmap=np_map(im(:,:,1:max_ind));
%         d.name='NP_Map';
%         d.canplay=0;
%         d.DataRange=[min(im_npmap(:)),max(im_npmap(:))];
%         d.DispRange=[myprctile(im_npmap,1),myprctile(im_npmap,97)];
%         d.colormap=1;  %'gray'
%         dispstruct(3)=d;
%         set(hobjs.PopupDisplay,'String',{dispstruct.name},'Value',3);
%         set(hobjs.BnGetSeed,'Enable','on');
%         PopupDisplayCallback();
%     end

    function BnDF_FCallback(varargin)   
        
        prompt = {'ncondition:','ntrial:','frame_per_trial:'};
        dlg_title = 'Input';
        num_lines = 1;
        def = {'16','5','32'};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        ncondition=str2num(answer{1});
        ntrial=str2num(answer{2});
        frame_per_trial=str2num(answer{3});
        
        base_ind=1:(frame_per_trial/2);
        
        conmaps=df_f_condition(im,ncondition,ntrial,frame_per_trial,base_ind,resp_ind,smooth);    
        d.name='df_f';
        d.data=max(conmaps,[],3);
        d.playsize=1;
        d.DataRange=[-1,7];
        d.DispRange=[0,1];
        d.colormap=1;  %'gray'
        dispstruct(end+1)=d;
        set(hobjs.PopupDisplay,'String',{dispstruct.name},'Value',4);
%         set(hobjs.BnGetSeed,'Enable','on');
        PopupDisplayCallback();
    end


    function BnGetSeedCallback(varargin)

    end

    function BnAutoROICallback(varargin)
        nROI=length(ROI_list);
        
        if nROI==0
            h = msgbox('Select one or a few isolated cells as template');
            return;
        end
            
        
        block=zeros(2*cell_radius+1,2*cell_radius+1,nROI);
        meanmap=dispstruct(2).data;
        
        meanmap_exp=imresize(meanmap,size(meanmap).*pixel_dimension);
        
        for i=1:nROI
            v=round(ROI_list(i).centerPos).*pixel_dimension;
            block(:,:,i)=meanmap_exp(v(1)+(-cell_radius:cell_radius),v(2)+(-cell_radius:cell_radius));
        end
        template=mean(block,3);
        template=template+fliplr(template);
        template=template+flipud(template);
        [row,col]=define_seed_location(meanmap_exp,template,cell_radius);
        
        row=row/pixel_dimension(1);
        col=col/pixel_dimension(2);
        
        for i=1:length(row)
            ButtonDownCallback(round([row(i),col(i)]));
        end
    end

    function SlFrameCallback(varargin)
        currFrame=round(get(hobjs.SlFrame,'Value'));
        set(hobjs.EdFrame,'String',num2str(currFrame));
        UpdateDisplay();
    end

    function SlMaxCallback(varargin)
        value=get(hobjs.SlMax,'Value');
        ind=get(hobjs.PopupDisplay,'Value');
        DispRange=dispstruct(ind).DispRange;
        DispRange(2)=value;
        if DispRange(2)<=DispRange(1)
            DispRange(2)=DispRange(1)+1;
        end
        set(hobjs.SlMax,'Value',DispRange(2));
        set(hobjs.EdMax,'String',num2str(DispRange(2)));
        dispstruct(ind).DispRange=DispRange;
        UpdateDisplay();     
    end

    function SlMinCallback(varargin)        
        value=get(hobjs.SlMin,'Value');
        ind=get(hobjs.PopupDisplay,'Value');
        DispRange=dispstruct(ind).DispRange;
        DispRange(1)=value;
        if DispRange(2)<=DispRange(1)
            DispRange(1)=DispRange(2)-1;
        end
        %set(hobjs.SlMin,'Value',DispRange(1));
        set(hobjs.EdMin,'String',num2str(DispRange(1)));
        dispstruct(ind).DispRange=DispRange;
        UpdateDisplay();     
    end


    function PopupDisplayCallback(varargin)
        ind=get(hobjs.PopupDisplay,'Value');
        if dispstruct(ind).playsize>1
            set(hobjs.SlFrame,'Enable','on');
            set(hobjs.BnPlay,'Enable','on');
            set(hobjs.EdFrame,'Enable','on');
        else
            isplaying=0;
            set(hobjs.SlFrame,'Enable','off');
            set(hobjs.BnPlay,'Enable','off');
            set(hobjs.EdFrame,'Enable','off');
        end
        
        
        switch dispstruct(ind).name
            case 'MaxProj'
                if isempty(dispstruct(ind).data)
                    dispstruct(ind).data=max(im,[],3);      
                    dispstruct(ind).DataRange=[min(dispstruct(ind).data(:)),max(dispstruct(ind).data(:))];
                    dispstruct(ind).DispRange=[prctile(dispstruct(ind).data(:),1),prctile(dispstruct(ind).data(:),99.8)];
                end
        end
                
        dispinfo=dispstruct(ind);
        set(hobjs.EdMax,'String',num2str(dispinfo.DispRange(2)));
        set(hobjs.EdMin,'String',num2str(dispinfo.DispRange(1)));       
        set(hobjs.SlMax,'Max',dispinfo.DataRange(2),'Min',dispinfo.DataRange(1),'Value',dispinfo.DispRange(2));
        set(hobjs.SlMin,'Max',dispinfo.DataRange(2),'Min',dispinfo.DataRange(1),'Value',dispinfo.DispRange(1));
        set(hobjs.PopupColormap,'Value',dispinfo.colormap);
        UpdateDisplay();
    end

    function PopupColormapCallback(varargin)
        ind_cmap=get(hobjs.PopupColormap,'Value');        
        ind=get(hobjs.PopupDisplay,'Value');
        dispstruct(ind).colormap=ind_cmap;
        UpdateDisplay();
    end

    function CkSeedCallback(varargin)
        if get(hobjs.CkSeed,'Value')
            set(hdispseed,'Visible','on');
        else
            set(hdispseed,'Visible','off');
        end
    end

    function CkROICallback(varargin)
        if get(hobjs.CkROI,'Value')
            set(hdispROI,'Visible','on');
        else
            set(hdispROI,'Visible','off');
        end
    end


    function MouseMotionFcn(varargin)
        pt=get(get(hdispimage,'parent'),'currentPoint');
        figure(hdispfig);
        I=round(pt(1,2));
        J=round(pt(1,1));
        if I>0 && I<ss(1) && J>0 && J<ss(2)
            pixsignal=squeeze(im(I,J,:));
          %  set(hPixSignal,'YData',pixsignal);
            
            currData=get(hdispimage,'CData');
            val=currData(I,J);
            set(hdispfig,'Name',['(',num2str(I),',',num2str(J),')=',num2str(val)]);
            
            r=para.region_size;
            Imin=I-r/pixel_dimension(1);
            Jmin=J-r/pixel_dimension(2);
            Imin=(Imin>0)*(Imin-1)+1;
            Jmin=(Jmin>0)*(Jmin-1)+1;
            if (Imin+2*r/pixel_dimension(1))>ss(1)
                Imin=ss(1)-2*r/pixel_dimension(1);
            end
            if (Jmin+2*r/pixel_dimension(2))>ss(2)
                Jmin=ss(2)-2*r/pixel_dimension(2);
            end

%             [J-cell_radius,I-cell_radius,2*cell_radius+1,2*cell_radius+1]
%             set(hdispRec,'Position',[Jmin,Imin,(2*r+1)/pixel_dimension(2),(2*r+1)/pixel_dimension(1)],'visible','on');
            set(hdispCircle,'Position',[J-cell_radius/pixel_dimension(2),I-cell_radius/pixel_dimension(1),(2*cell_radius+1)/pixel_dimension(2),(2*cell_radius+1)/pixel_dimension(1)],'visible','on','Curvature',[1,1]);
         else
%             set(hdispRec,'visible','off');
        end
    end

    function ButtonDownCallback(varargin)
        if nargin>1
            pt = round(get(gca,'CurrentPoint'));
            currPos(1)=round(pt(1,2));
            currPos(2)=round(pt(1,1));
        else
            currPos=varargin{1};
        end
        
        if currPos(1)>ss(1) || currPos(1)<0 || currPos(2)>ss(2) || currPos(2)<0
            return;
        end
        
        ind=sub2ind(ss(1:2),currPos(1),currPos(2));
        sel_ind=get(hobjs.ListROI,'Value');
        seltype=get(gcf,'SelectionType');
        
        
        if strcmp(seltype,'alt')  % click right button
            
            sig=im(currPos(1)+(-1:1),currPos(2)+(-1:1),:);
            sig=mean(reshape(sig,9,[]));
            figure;
            plot(squeeze(sig));
            return;
        end
        
        
        %test if the clicked pixel belong to any ROI
        flag=0;
        for i=1:length(ROI_list)            
            if sum(ROI_list(i).fill_list==ind)>0
                if strcmp(seltype,'normal')
                    sel_ind=i;
                elseif strcmp(seltype,'extend')
                    sel_ind=[sel_ind,i];
                end
                flag=1;
            end            
        end
        
        %clicked pixel does not belong to any ROI  
        if flag==0     
            if strcmp(seltype,'normal')
%                 

                 switch get(get(hgroup2,'SelectedObject'),'String');
                     case 'Circle Border'                         
                         switch get(get(hgroup1,'SelectedObject'),'String');
                             case 'Disk'
                                 pixel_list=fix_disk(ss(1:2),currPos,cell_radius,pixel_dimension);
                                 ROI.pixel_list=pixel_list;
                                 ROI=measure_ROI(im,ROI);  
                                 
                             case 'Ring'
                                 pixel_list=fix_ring(ss(1:2),currPos,cell_radius,pixel_dimension);
                                 ROI.pixel_list=pixel_list;
                                 ROI=measure_ROI(im,ROI);    
                         end
                         
                     case 'Auto Border'                         
                         ind=get(hobjs.PopupDisplay,'Value');
                         if ind==2
                             ind=1;  %if select on raw data, then use meanmap
                         end
                         dispinfo=dispstruct(ind);
                         
                         switch get(get(hgroup1,'SelectedObject'),'String');
                             
                             case 'Disk'   
                                 [pixel_list,boundary,boundary_list]=disk_roi(dispinfo.data,currPos,cell_radius,pixel_dimension,0);
                                 ROI.pixel_list=pixel_list;
                                 ROI=measure_ROI(im,ROI); 
%                                  ROI=round_roi(dispinfo.data,currPos,cell_radius);
%                                  if ~isempty(ROI)                                     
%                                      ROI=measure_ROI(im,ROI);
%                                  end
                             case 'Ring'                                 
                                 %% Auto Border Ring
                                 [pixel_list,nuc_list,boundary_inner,boundary_outer,boundary_list]=donut_roi(dispinfo.data,currPos,cell_radius,pixel_dimension,0);
                                 ROI.pixel_list=pixel_list;
                                 ROI=measure_ROI(im,ROI);                                                                  
                         end                         
                 end
                
            elseif strcmp(seltype,'extend')                
%                 ROI=define_roi(im,currPos,para);   
%                 ROI=measure_ROI(im,ROI);
            end
            %[pixel_list,boundary_list,trace]=cube_roi(data,ss,currPos);
            %define a new cell
            if ~isempty(ROI)
                ROI.name=['ROI',num2str(ROIcount)];
                ROI_list=[ROI_list,ROI];
                ROIcount=ROIcount+1;        
                set(hobjs.ListROI,'String',{ROI_list.name});
                sel_ind=length(ROI_list);
            else
                sel_ind=[];
            end
        end              
        set(hobjs.ListROI,'Value',sel_ind);  
        drawROI();
    end

    function UpdateDisplay()
        ind=get(hobjs.PopupDisplay,'Value');
        dispinfo=dispstruct(ind);
        
        if ~ishandle(hdispfig)
            CreateNewDispWnd();
        end
        
        if currFrame>dispinfo.playsize
            currFrame=1;
            
        end
        set(hdispimage,'cdata',dispinfo.data(:,:,currFrame));
            
        set(hdispfig,'Colormap',eval(colormap_string{dispinfo.colormap}));
        set(get(hdispimage,'parent'),'clim',dispinfo.DispRange);
        drawnow();
    end
        
    function keyPressFcn(src,event)
        switch event.Key
            case 'delete'
                sel_ind=get(hobjs.ListROI,'Value');                
                %delete from cell_list
                ROI_list(sel_ind)=[];
                set(hobjs.ListROI,'Value',[]);
                drawROI();
                
            case 'c'
                sel_ind=get(hobjs.ListROI,'Value'); 
                ref=ROI_list(sel_ind(1)).fmean;

                rg_map(im,ref);

        end
    end

    function WindowScrollWheelFcn(src,event)
        
       if event.VerticalScrollCount>0
          if cell_radius>3
             cell_radius=cell_radius-1; 
          end
       else
           disp('bigger') 
           if cell_radius<100
               cell_radius=cell_radius+1;
           end
       end
            MouseMotionFcn();
    end

    function CreateNewDispWnd()
        hdispfig=figure('position',[50,100,600,600],'DeleteFcn',@dispfigDelCallback,'colormap',gray,'WindowButtonMotionFcn',@MouseMotionFcn,'WindowButtonDownFcn',@ButtonDownCallback,'KeyPressFcn', @keyPressFcn,'WindowScrollWheelFcn',@WindowScrollWheelFcn);
        hdispimage=imagesc(im(:,:,1));
        daspect([pixel_dimension,1]);
        hold on;
        if isempty(seed_location.col)
            hdispseed=plot(get(hdispimage,'parent'),1,1,'r+','MarkerSize',6,'Visible','off');
        else
            hdispseed=plot(get(hdispimage,'parent'),seed_location.col,seed_location.row,'r+','MarkerSize',6,'Visible','off');
            if get(hobjs.CkSeed,'Value')==1
                set(hdispseed,'Visible','on');
            end
        end
        %hdispROI=image(zeros([ss(1:2),3]),'AlphaData',zeros([ss(1:2)]),'Visible','off','parent',hax);
        hdispRec=rectangle('Position',[0,0,para.region_size*2+1,para.region_size*2+1],'Visible','off','EdgeColor','r','LineStyle','--');
        hdispCircle=rectangle('Position',[0,0,cell_radius*2+1,cell_radius*2+1],'Visible','off');
        hdispROI=image(zeros([ss(1:2),3]),'AlphaData',zeros([ss(1:2)]),'Visible','off');
          %hdispRec=rectangle('Position',[0,0,para.region_size*2+1,para.region_size*2+1],'Visible','off','EdgeColor','r','LineStyle','--','parent',hax);
    end

    function drawROI()

        if ~isempty(ROI_list)
            str={ROI_list.name};
            set(hobjs.ListROI,'String',str);
        else
            set(hobjs.ListROI,'Value',[]);
        end
        
        
        
        roi_display=zeros([prod(ss(1:2)),3]);
        alpha=zeros(prod(ss(1:2)),1);       
        roi_map=zeros(ss(1:2));
        
        sel_ind=get(hobjs.ListROI,'Value');
        for i=1:length(ROI_list)
            hue=(sin(2*pi*ROI_list(i).centerPos(1)/30)*sin(2*pi*ROI_list(i).centerPos(2)/30)+1)/2;
            %rgb=hsv2rgb([hue,1,1]);
            rgb=[0.5,1,0.5];
            if sum(sel_ind==i)>0
                roi_display(ROI_list(i).pixel_list,1)=rgb(1);
                roi_display(ROI_list(i).pixel_list,2)=rgb(2);
                roi_display(ROI_list(i).pixel_list,3)=rgb(3);
                alpha(ROI_list(i).pixel_list)=1;        
            else
                roi_display(ROI_list(i).pixel_list,1)=1;
                roi_display(ROI_list(i).pixel_list,2)=0;
                roi_display(ROI_list(i).pixel_list,3)=0;
                alpha(ROI_list(i).pixel_list)=1;
                
%                 roi_display(ROI_list(i).boundary_list,1)=1;
%                 roi_display(ROI_list(i).boundary_list,2)=0;
%                 roi_display(ROI_list(i).boundary_list,3)=0;
%                 alpha(ROI_list(i).boundary_list)=1;
            end
            roi_map(ROI_list(i).pixel_list)=1;
            %alpha(ROI_list(i).pixel_list)=0.5;
        end
        alpha=reshape(alpha,ss(1:2));

        roi_display=reshape(roi_display,[ss(1:2),3]);
        set(hdispROI,'CData',roi_display,'AlphaData',alpha);
        if ~isempty(sel_ind)
            set(hROIsignal,'YData',ROI_list(sel_ind(1)).fmean);
            
%             if get(hobjs.BnDetail,'Value')==1
%                 [ROI,hROIDetail]=define_roi(im,ROI_list(sel_ind(1)).seedPos,para,hROIDetail);              
%             end
        else
            set(hROIsignal,'YData',zeros(ss(3),1));
        end   
        
        if get(hobjs.CkROI,'Value')
            set(hdispROI,'Visible','on');
        else
            set(hdispROI,'Visible','off');
        end
        
        if length(sel_ind)>0
            ROI=ROI_list(sel_ind(1));

            pixelno=length(ROI.pixel_list);
            boundaryno=length(ROI.boundary_list);
            text={['Pixelno = ',num2str(length(ROI.pixel_list))];
                ['SeedPos = (',num2str(ROI.seedPos(1)),',',num2str(ROI.seedPos(2)),')'];
                ['fmean   = ',num2str(round(mean(ROI.fmean)))];
%                 ['SNRmean = ',num2str(mean(ROI.SNR),2)];
%                 ['SNRmin  = ',num2str(min(ROI.SNR),2)];
%                 ['SNRmax  = ',num2str(max(ROI.SNR),2)];
                ['Boundary =',num2str(length(ROI.boundary_list))];
                ['roundness=',num2str(4*pi*pixelno/(boundaryno^2),2)];
                };
            set(hobjs.EdROIinfo,'string',text);
        end
        drawnow();
    end

    function ctrlfigDelCallback(varargin)
        if ishandle(hdispfig)
            close(hdispfig);
        end
    end

    function dispfigDelCallback(varargin)
        hdispfig=-1;
    end
end




        
function out_list=measure_ROI(im,in_list)
    nROI=length(in_list);
    ss=size(im);
    out_list=[];
    for i=1:nROI
        tempROI.pixel_list=in_list(i).pixel_list;
        ROImap=false(ss(1:2));
        ROImap(in_list(i).pixel_list)=1;
        
        if isfield(in_list(i),'boundary_list')&& (~isempty(in_list(i).boundary_list))
            tempROI.boundary_list=in_list(i).boundary_list;
        else
            tempROI.boundary_list=find(bwperim(ROImap,4));
        end
        
        
        [I1,J1]=ind2sub(ss,tempROI.pixel_list);
        tempROI.centerPos=[mean(I1),mean(J1)];
        
        
        if isfield(in_list(i),'seedPos')&& (~isempty(in_list(i).seedPos))
            tempROI.seedPos=in_list(i).seedPos;
        else
            tempROI.seedPos=tempROI.centerPos;
        end
        
        if isfield(in_list(i),'name')&& (~isempty(in_list(i).name))
            tempROI.name=in_list(i).name;
        else
            tempROI.name='ROI';
        end
        

        ROImap_fill=imfill(ROImap,'holes');
        
        
        
        im=reshape(im,[],ss(3));
        tempROI.fmean=mean(im(tempROI.pixel_list,:))';
        
        tempROI.fill_list=find(ROImap_fill);
        tempROI.fmean_fill=mean(im(tempROI.fill_list,:))';

        im=reshape(im,ss);
        out_list=[out_list,tempROI];
        

    end
    
end