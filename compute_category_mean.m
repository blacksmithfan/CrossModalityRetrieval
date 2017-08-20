function [ mean_vector ] = compute_category_mean( data, label )

category=unique(label);

mean_vector=zeros(length(category),size(data,2));
for i=1:length(category)
    category_ind=find(label==category(i));
    category_data=data(category_ind,:);
    mean_vector(i,:)=mean(category_data,1);
end


end

