function [ precision_all,recall_all ] = PR_curve( query,query_label,database,database_label )

recall_all=zeros(length(query_label),length(database_label));
precision_all=zeros(length(query_label),length(database_label));

D = pdist2(query,database);

    
parfor i=1:length(query_label)
    
    
    [~,idx]=sort(D(i,:),'ascend');
    sort_list=database_label(idx);
    gt_list=ones(length(database_label),1).*query_label(i);
    
    recall_list_temp=sort_list-gt_list;
    recall_list=zeros(length(database_label),1);
    recall_list(find(recall_list_temp==0))=1;
    
    
    recall=zeros(length(database_label),1);
    precision=zeros(length(database_label),1);
    for j=1:length(database_label)
        recall(j)=sum(recall_list(1:j))/sum(recall_list);
        precision(j)=sum(recall_list(1:j))/j;
    end
    recall_all(i,:)=recall;
    precision_all(i,:)=precision;
    
end

recall_all=mean(recall_all);
precision_all=mean(precision_all);



end

