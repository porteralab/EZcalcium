F=zeros(size(ROI_list,2),size(ROI_list(1,1).fmean,1));
for i=1:size(ROI_list,2)
    F(i,:)=(ROI_list(1,i).fmean);
end
F=F'; %transpose the matrix to get old format