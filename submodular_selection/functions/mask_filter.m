function [ new_mask,new_D ] = mask_filter( masks,D )

remain_set=[];
for i=1:size(masks,3)
    area=sum(sum(masks(:,:,i)));
    
    percentage=area/(231*231);
    
    if percentage>0.5
        remain_set=[remain_set;i];
    end
end

new_mask=masks(:,:,remain_set);
for i=1:6
    new_D{i,1}=D{i,1}(:,remain_set);
end
end

