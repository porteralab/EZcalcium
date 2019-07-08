function ez_test_baseline(raw_traces,baselineframes,roiselect,max_pass)

converge_thresh=0.25; %amount of convergence difference allowed, expressed as a fraction
% load(fullFfile); %!!!!!!!!!!!!!!!!!!!!!!!! temporary testing
F=raw_traces; %!!!!!!!!!!!!!!!!!!!!!!!! temporary testing

transpose(roiselect);

% %Import new style data--------------- %!!!!!!!!!!!!!!!!!!!!!!!! temporary testing
% F=zeros(size(ROI_list,2),size(ROI_list(1,1).fmean,1));
% for i=1:size(ROI_list,2)
%     F(i,:)=(ROI_list(1,i).fmean);
% end
%F=F'; %transpose the matrix to get old format
%------------------------------------

if roiselect~=0 %use only the good ROIs
    F=F(:,roiselect);
end

Fsize=size(F);

%-----------Calculate Baseline F-----------------------------------------
basecalc=zeros(1,Fsize(1)-baselineframes+1);
Fbaseline=zeros(1,Fsize(2));
Fbaselinestd=zeros(1,Fsize(2));
min_base=nan(Fsize(1),Fsize(2)); %label for baseline
min_index=zeros(1,Fsize(2));
%nonzero_min=Fsize(1)-floor(zero_allowed/100*Fsize(1)); %calculates the min number of nonzero frames needed to be included

for j=1:Fsize(2)
    for i=1:Fsize(1)-baselineframes+1 %find 5 seconds of baseline. RECALC based on framerate
        basecalc(i)=nanstd(F(i:i+baselineframes-1,j)); %checks STD for all values       
    end
    [~,min_index(j)]=nanmin(basecalc); %calculate the position of lowest deviation for baseline
    Fbaseline(j)=nanmean(F(min_index(j):min_index(j)+baselineframes-1,j));
    Fbaselinestd(j)=nanstd(F(min_index(j):min_index(j)+baselineframes-1,j));
    min_base((min_index(j):min_index(j)+baselineframes-1),j)=1; %label for baseline
    disp(['Calculating initial baseline: ', (num2str(100*j/Fsize(2))), '%'])
end
%----------------End Calculate Baseline F--------------------------------


%--------------Calculate Z (dF) for each ROI-------------------------------
dF=zeros(Fsize(1),Fsize(2));
for i=1:Fsize(1)
    for j=1:Fsize(2)
        if F(i,j)==0
            dF(i,j)=0; %set to 0 if no data available
        else
            dF(i,j)=(F(i,j)-Fbaseline(j))/(Fbaselinestd(j));        
        end
    end
end

%----------End Calculate dF/F for each ROI-------------------------------

%--------------Calculate significance for each ROI-----------------------
sigdF=2;
sigframes=zeros(size(dF,1),size(dF,2));
activeframes=zeros(size(dF,1),size(dF,2));
sigframenum=2;
active_add=8;
active_subtract=4;
detected_active=nan(size(dF,1),size(dF,2));
detected_baseline=zeros(size(dF,1),size(dF,2))+1;

for j=1:size(dF,2) %check if activity is above threshold
    for i=1:size(dF,1)
        if dF(i,j)>sigdF
            sigframes(i,j)=1;
        end
    end
end


for j=1:size(dF,2) %check for 6+ consecutive significant frames
    for i=1:size(dF,1)
        
        sigcount=0;
        if sigframes(i,j)==1
            sigcount=sigcount+1;
            for k=1:sigframenum-1
                if ((i+k <= size(dF,1)) && (sigframes(i+k,j)==1))
                    sigcount=sigcount+1;
                end
            end
            if sigcount==sigframenum
                activeframes(i:i+sigframenum-1,j)=1;
            end
        end
    end
end

for j=1:size(dF,2) %mark frames before and after stimulus as red
    for i=1:size(dF,1)
        if activeframes(i,j)==1 && (i+active_add <= size(dF,1)) && (i-active_subtract > 0)
            detected_active(i-active_subtract:i+active_add,j)=1;
            detected_baseline(i-active_subtract:i+active_add,j)=nan;
        end
    end
end

dF_active=dF.*detected_active;
detected_original=detected_active;
dF_baseline=dF.*detected_baseline;
original_base=dF.*min_base;
dF_original=dF_active;
ez_multiplot(dF,'pass_0',1,'frames',10,1:size(dF_active,2),dF_active,original_base,nan,nan);
%find if nanmean is greater than thresh

%========================Iterate baseline calculation======================
dF_baseline_prior=dF_baseline;
for j=1:size(dF,2)
    for pass_num=1:max_pass
        sigframes=zeros(size(dF,1),size(dF,2));
        activeframes=zeros(size(dF,1),size(dF,2));
        display(['Pass: ' num2str(pass_num)])
        F_baseline=F.*detected_baseline;
        detected_active=nan(size(dF,1),size(dF,2));
        detected_baseline=zeros(size(dF,1),size(dF,2))+1;
        Fbaseline(j)=nanmean(F_baseline(:,j));
        Fbaselinestd(j)=nanstd(F_baseline(:,j));
        dF(:,j)=(F(:,j)-Fbaseline(j))/(Fbaselinestd(j)); %calculate new dF
        %check if activity is above threshold
        for i=1:size(dF,1)
            if dF(i,j)>sigdF
                sigframes(i,j)=1;
            end
        end
        %check for consecutive significant frames
        for i=1:size(dF,1)
            sigcount=0;
            if sigframes(i,j)==1
                sigcount=sigcount+1;
                for k=1:sigframenum-1
                    if ((i+k <= size(dF,1)) && (sigframes(i+k,j)==1))
                        sigcount=sigcount+1;
                    end
                end
                if sigcount==sigframenum
                    activeframes(i:i+sigframenum-1,j)=1;
                end
            end
        end
        %mark frames before and after stimulus as red
        for i=1:size(dF,1)
            if activeframes(i,j)==1 && (i+active_add <= size(dF,1)) && (i-active_subtract > 0)
                detected_active(i-active_subtract:i+active_add,j)=1;
                detected_baseline(i-active_subtract:i+active_add,j)=nan;
            end
        end
        
        %iteration of baseline calculation
        dF_active(:,j)=dF(:,j).*detected_active(:,j);
        dF_baseline(:,j)=dF(:,j).*detected_baseline(:,j);
        
        if abs(1-nanmean(dF_baseline(:,j))/nanmean(dF_baseline_prior(:,j)))<=converge_thresh
            %sum(isnan(detected_active(:,j)))+sum(isnan(detected_baseline(:,j))) %checksum of sorts
            break
        else
            dF_baseline_prior=dF_baseline;
        end

    end
    
    disp(['Iterating baseline calculation: ', (num2str(100*j/Fsize(2))), '%'])
end
%=====================End Iterate baseline calculation=====================

display('Baseline calculation complete!');



%ez_multiplot(dF,'pass_final',1,'frames',10,1:size(dF_active,2),dF_active,dF_baseline,original_base,nan);
ez_multiplot(dF,'pass_final',1,'frames',10,1:size(dF_active,2),dF_active,dF_baseline,nan,nan);
sum(sum(~isnan(dF_original)))
sum(sum(~isnan(dF_active)))





