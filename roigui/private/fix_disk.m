function pixel_list=fix_disk(ss,center_pos,cell_radius,expand_ratio)
ss_org=ss;
ss=ss.*expand_ratio;
center_pos=center_pos.*expand_ratio;
full_radius=round(cell_radius*1.2);

rout=cell_radius;

roimap=zeros(ss);

for II=-full_radius:full_radius
    for JJ=-full_radius:full_radius
        indi=II+center_pos(1);
        indj=JJ+center_pos(2);
        rr=sqrt(II^2+JJ^2);
        if (indi>0) && (indj>0) && indi<=(ss(1))  && indj<=(ss(2))
            if (rr<rout)
                roimap(indi,indj)=1;
            end
        end
    end
end
roimap=imresize(roimap,ss_org,'nearest');
pixel_list=find(roimap);
