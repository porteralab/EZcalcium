function [population_activity,population_Rho,population_P,population_Coupling]=ez_pop_coupling(activity_data,shuffles,bin)
%This function finds population coupling (Okun, et al, Nature 2015)
%
%=============Inputs============
%activity_data is a matrix of column vectors of activity simultaneously
%   recorded from a population of neurons. These data should be first transformed
%   to 1s (active) and 0s (not active) to normalize across cells.
%shuffles is the number of random shuffles to perform.
%bin is the length of the time bin (in frames) to translate data into. This
%   should be ~1 second of time.
%
%=============Outputs============
%population_activity is the activity trace of the entire population.

%
%population_Rho is the set of Rho values calculated for each neuron vs the population.
%
%population_P is the set of P values(against a null hypothesis Rho=0) for each neuron vs the population.

rng('shuffle'); %sets random seed based on clock value



%-------------Bin into 1 second time bins------------
for i=1:ceil(size(activity_data,1)/bin)
    if i<ceil(size(activity_data,1)/bin)
        bin_data(i,:)=ceil(mean(activity_data((i-1)*bin+1:i*bin,:))); %if one frame is active in a bin, counts entire bin as active
    else %special exemption for final bin, accounting for when it isn't a complete bin length
        bin_data(i,:)=ceil(mean(activity_data((i-1)*bin+1:end,:))); %goes until end instead of full bin size
    end
end
%----------------------------------------------------


population_activity=sum(bin_data,2); %Finds the population activity
population_Rho=zeros(1,size(bin_data,2)); %Initialize Rho matrix
population_P=zeros(1,size(bin_data,2)); %Initialize P matrix
shuffle_Rho=zeros(shuffles,size(bin_data,2));
%activity_shuffle=zeros(shuffles,size(activity_data,2));
shufflecount=1;

for deals=1:shuffles%calculates normalization factor to account for different ROI numbers and activity levels
    if shufflecount==10
        display(['Calculating Population Coupling: ' num2str(100*deals/shuffles) '%'])
        shufflecount=1;
    else
        shufflecount=shufflecount+1;
    end
    
    %old shuffling
%     for j=1:size(activity_data,1);
%         %activity_shuffle(j,:)=activity_data(j,randperm(size(activity_data,2)));
%     end

    %==========Epoch-preserving raster shuffling===========

    %---------------Create random matrices---------------
    %Create initial randomized checklist of 1s in entire matrix to ensure full shuffling
    data_checklist=(find(bin_data)); %initial checklist
    if isempty(data_checklist)==1 %checks to see if any activity at all is detected
        error('WARNING! No activity was detected in the input activity_data!');
    end
    data_checklist=data_checklist(randperm(length(data_checklist)));
    activity_shuffle=bin_data; %initialize matrix to be shuffled
    for i=1:length(data_checklist)
        if activity_shuffle(data_checklist(i))==1 %checks if value matches initial
            
            %Find a random 0 in the same row as a 1 from the checklist
            data_column=ceil(data_checklist(i)/size(activity_shuffle,1));  %find row of index
            data_row=data_checklist(i)-(data_column-1)*(size(activity_shuffle,1)); %find column of index
            zero_list=find(activity_shuffle(data_row,:)==0);
            
            if isempty(zero_list)==0 %checks to see if there is a 0 in the row at all
                zero_list=zero_list(randperm(length(zero_list)));
                
                %Find a row with a 1 in the same column as the 0. If none exist, check again until exhausted.
                zero_count=1; %count which position checking
                if zero_count<=length(zero_list)
                    one_list=find(activity_shuffle(:,zero_list(zero_count))==1);
                    one_list=one_list(randperm(length(one_list)));
                    one_count=1;
                    if isempty(one_list)==1
                        zero_count=zero_count+1; %steps through to next column to see if a 1 is present
                    else
                        if activity_shuffle(one_list(one_count),data_column)==0 %check if 0 is in the final position
                            %Swap timing of bins
                            activity_shuffle(data_row,data_column)=0;
                            activity_shuffle(data_row,zero_list(zero_count))=1;
                            activity_shuffle(one_list(one_count),zero_list(zero_count))=0;
                            activity_shuffle(one_list(one_count),data_column)=1;
                        else
                            %check next row in list
                            one_count=one_count+1;
                        end
                        
                    end %end isempty(one_list) check
                    
                end %end zero_count loop
            end %end zero in row check
        end %end bin_data change check
    end
    
    for i=1:size(bin_data,2) %Find Pearson correlations between each neuron and the population
        
        %[population_Rho(i),population_P(i)]=corr(population_activity,bin_data(:,i));
        %[shuffle_Rho(deals,i),~]=corr(population_activity,activity_shuffle);
        [shuffle_Rho(deals,i),~]=corr(population_activity,activity_shuffle(:,i));
        
    end
end

parfor i=1:size(bin_data,2) %Find Pearson correlations between each neuron and the population
    [population_Rho(i),population_P(i)]=corr(population_activity,bin_data(:,i));
end

population_Coupling=population_Rho/nanmean(nanmean(shuffle_Rho,1));
%population_Coupling=population_Rho/nanmedian(nanmedian(shuffle_Rho,1));
%population_Coupling=population_Rho-nanmedian(shuffle_Rho,1);

