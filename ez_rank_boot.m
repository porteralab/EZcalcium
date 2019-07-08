function [pvalue] = ez_rank_boot(deals,data1,data2,rank)
%Performs a difference of means test using bootstrap statistics.

%deals = number of trials
%data1 = first set of data (column vector)
%data2 = second set of data (column vector)
%rank 1 = rank-based, 0 = non-ranked. Use ranks for low n (<20).


%Find boostrap confidence interval
CIdist=zeros(deals,1); %generate blank distribution
parfor deal = 1:deals
    CIboot1=randsample(data1,length(data1),true); %resample 1
    CIboot2=randsample(data2,length(data2),true); %resample 2
    CIdist(deal)=mean(CIboot1)-mean(CIboot2); %find difference of means
end
CIdist=sort(CIdist);

%Display 95% confidence interval
CIlow=CIdist(floor(deals*0.025));
CIhigh=CIdist(floor(deals*0.975));
disp(['95% confidence interval: ' num2str(CIlow) ' to ' num2str(CIhigh)]);



datapool=sort([data1; data2]);%pool and sort data

%Convert to ranks
if rank==1
    %convert data1
    parfor i=1:length(data1)
        data1(i)=find(datapool==data1(i));
    end
    %convert data2
    parfor i=1:length(data2)
        data2(i)=find(datapool==data2(i));
    end
    datapool=sort([data1; data2]);
end

%find difference of means
meandif=mean(data1)-mean(data2);

%Find boostrap distribution
bootdist=zeros(deals,1); %generate blank distribution
parfor deal = 1:deals
    boot1=randsample(datapool,length(data1),true); %resample 1
    boot2=randsample(datapool,length(data2),true); %resample 2
    bootdist(deal)=mean(boot1)-mean(boot2); %find difference of means
end

%find p value
pdist=sort([bootdist; meandif]);
pvalue=(find(pdist==meandif,1)-1)/deals;
if pvalue>0.5
    pvalue=1-pvalue;
end



    
    
    
    
    
    
    
    
    
    