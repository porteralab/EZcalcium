function ez_multiplot(raw_traces,plots_per_page,filename,frame_length,x_units,x_tick_number,y_units,y_tick_number,roi_numbers,active_traces,baseline,threshold,stimulus)
%activity is a matrix of things to be plotted
%plots_per_page is the number of plots per page (1-10, usually)
%framerate is the frame rate in Hz for time labeling. Default is 1.
%append is a string for appending to end of plot for making pdfs
%tick_number is number of ticks
%stimulus is a vector of time when stimulus is presented. If not present, does not plot
%baseline is like stim, but baseline
%threshold is like stim, but the threshold for activity
%can enter nan if don't want baseline, threshold, or stimulus to be used

%=================Error Check======================
if ~ischar(filename)
    error('Error: variable "filename" must be a string!')
end

if length(filename)>=4 %adds .pdf to end of filename if not there already
    if ~strcmp(filename(end-3:end),'.pdf')
        filename=[filename '.pdf'];
    end
else
    filename=[filename '.pdf'];
end

if plots_per_page<1
    error('Error: variable "plots_per_page" must be at least 1!')
end
if floor(plots_per_page)~=plots_per_page
    error('Error: variable "plots_per_page" must be a whole number!')
end

%checks for optional inputs
if ~exist('baseline','var')
    baseline=nan;
end
if ~exist('roi_numbers','var')
    roi_numbers=1:size(raw_traces,2);
end
if ~exist('threshold','var')
    threshold=nan;
end
if ~exist('stimulus','var')
    stimulus=nan;
end
if ~exist('frame_length','var')
    frame_length=1;
end
if ~exist('active_traces','var')
    active_traces=nan;
end

%checks if a unit of time is entered
if exist('units','var')
    x_units=['(' x_units ')'];
else
    x_units=[];
end
%================End Error Check===================

cellnumber=size(raw_traces,2);
figcount=1; %needed for pdf
clear figHandles %needed for pdf
for page = 1:ceil (cellnumber/plots_per_page)
    figure (10 + page)
    figHandles(figcount)=gcf; %needed for pdf
    figcount=figcount+1; %needed for pdf
    plot_place=0;
    subplot(plots_per_page,1,1);
    axis([0 size(raw_traces,1) 0 1.2]);
    axis off;
    for b = ((page-1)*plots_per_page)+1:((page-1)*plots_per_page)+plots_per_page %position of the subplot
        if (b<=cellnumber)
            plot_place = plot_place+1;
            subplot (plots_per_page+1,1,plot_place+1); 
            
            %-----------------Plot stimulus bars------------------
            if nansum(nansum(~isnan(stimulus)))>0
                plot(stimulus(:,b),'Color',[.9,.9,.9],'LineWidth',75);
            end
            
            %-----------------Plot raw traces---------------------
            hold on;
            hline = plot (raw_traces (:,b));
            set(hline,'Color','black');
            
            %-----------------Plot active traces------------------
            if nansum(nansum(~isnan(active_traces)))>0
                plot(active_traces(:,b),'Color','red'); %spikes above threshold
            end
            
            %-----------------Plot baseline------------------------
            if nansum(nansum(~isnan(baseline)))>0
                plot(baseline(:,b),'Color','blue'); %baseline
            end
            
            %-----------------Plot threshold-------------------------
            if nansum(nansum(~isnan(threshold)))>0
                plot(threshold(:,b),'Color','green'); %Cutoff line
            end
            
            %-----------Finish plotting, labels, etc.----------------
            hold off;
            
            set(gca,'YColor',[0,0,0],'FontName','Helvetica');
            ylabel(int2str(roi_numbers(b)),'Color',[0,0,.5]);
            axis tight;
            box off;
            if(plot_place==plots_per_page||b==cellnumber)
                %set(gca,'YTick',0:max(raw_traces(:,b))/y_tick_number:max(raw_traces(:,b)));
                set(gca,'YTickMode','auto');
                set(gca,'YLimMode','auto');
                %set(gca,'YTickLabel',y_units)
                
                %set(gca,'XTick', 0:size(raw_traces,1)/10:size(raw_traces,1));
                set(gca,'XTick', round(0:size(raw_traces,1)/x_tick_number:size(raw_traces,1)));
                timelabel=round(0:(size(raw_traces,1)*frame_length/x_tick_number):size(raw_traces,1)*frame_length);
                set(gca,'XTickLabel',timelabel);
                hxlabel = xlabel(['time (sec)' x_units]); %x_units doesn't seem to work
                set(hxlabel,'FontName','Helvetica');
            else
                %only label bottom-most plot
                set(gca,'XTick', []);
                set(gca,'XColor',[1,1,1]);
            end
        end
    end
    set(gcf,'Color',[1,1,1]);
end


%--------------Generate PDF-------------
find_forward_slash=strfind(filename,filesep); %finds forward slash in filenames

if isempty(find_forward_slash) %determines whether or not a directory was listed as part of the filename
    nameString=filename(1:end-4);
    dirString=pwd; %use current directory if no valid directory listed
    filename=[pwd filesep filename];
else
    nameString=[filename(find_forward_slash(end)+1:end-4)];
    %nameString=[filename(find_forward_slash(end)+1:end-4) '_' filename];
    dirString=filename(1:find_forward_slash(end));
end

%ez_multiPagePDF(figHandles, nameString, dirString)

print(figHandles,nameString,'-dpdf')


close(figHandles)
disp(['PDF created: ' filename]);
open(filename);
