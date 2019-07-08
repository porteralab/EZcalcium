function multiplot(timebase,wavelist,name,stimulus)
col=ceil(size(wavelist,2)/10);
row=ceil(size(wavelist,2)/col);
scale=2;
figure;


for i=1:col
    subplot(1,col,i);
    hold on;
    ytick=[];
    name_label=[];
    
    
    if nargin>3
    	stim_image=ones(100,1)*stimulus;
        image([1,max(timebase)],[-0.5*scale,scale*(row-0.5)],stim_image,'CDataMapping','scaled');
        set(gca,'Clim',[0,5]);cmap=gray;colormap(flipud(cmap));
    end
    
    
    
    for j=1:row
        if ((i-1)*row+j) <= size(wavelist,2)
            wave=wavelist(:,(i-1)*row+j);
            if length(wave)>10
                mm=mean(wave(1:10));
            else
                mm=mean(wave);
            end        
            df_f=(wave-mm)/mm;
            plot(timebase,df_f+scale*(j-1));

            ytick(j)=scale*(j-1);
            name_label{j}=name{(i-1)*row+j};
        end
    end
    xlim([0,max(timebase)+1]);
    ylim([-1*scale,scale*row]);
    set(gca,'YTick',ytick);
    set(gca,'YTickLabel',name_label);
    

    
    plot(max(timebase)*0.85*[1,1],[-0.6,-0.1]*scale,'k','LineWidth',5);
    text(max(timebase)*0.9,-0.35*scale,[num2str(scale*0.5*100),'%']);
    %set(gca,'XTick',[]);
end



    
% for i=1:size(wavelist,1)
%     plot(wavelist(i,:)+1.1*M*(i-1));
%     %plot(1:size(wavelist,2),1.1*M*(i-1),'k-');
%     yticklabel(i)={num2str(i)};
%     ytick(i)=1.1*M*(i-1);
% end
% ylim([-0.1*M,1.1*M*(i)]);
% set(gca,'YTick',ytick);
% set(gca,'YTickLabel',name);
% set(gca,'XTick',[]);