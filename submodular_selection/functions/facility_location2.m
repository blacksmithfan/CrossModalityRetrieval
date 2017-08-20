function [ selected_segment ] = facility_location2( X, X1, X2)
% Initialization: find the point that is closest to the central point
%
% dist_all=mean(X);
% [IDX, D] = knnsearch(X,dist_all);
% intial_point=X(IDX,:);
%
% selected_points=intial_point;
% selected_index=IDX;
% X(IDX,:)=[100 100 100];
%
% for i=1:9
%     [IDX, D] = knnsearch(X,selected_points);
%     IDX=IDX(1);
%     selected_points=[selected_points;X(IDX,:)];
%     selected_index=[selected_index;IDX];
%     X(IDX,:)=[100 100 100];
% end
delta=1;
selected_segment=[];

color_set={'m','c','r'};
point_size=110;

marginal_gain=zeros(size(X,1),1);
pre_total_dist=zeros(size(X,1),1);
for i=1:size(X,1)
    fprintf('Points %d\n',i)
    temp_X=X;
    temp_X(i,:)=[];
    [~,dist]=knnsearch(X(i,:),temp_X);
    marginal_gain(i)=1+sum(1./dist)-delta*(length(selected_segment)+1);
    dist=exp(-dist);
    pre_total_dist(i)=1+sum(dist)-delta*(length(selected_segment)+1);
end
[~,max_idx]=max(marginal_gain);
selected_segment=[selected_segment;max_idx];
previous_dist=pre_total_dist(max_idx);

%     marginal_gain(find(marginal_gain<50))=50;
scatter3(X(:,1),X(:,2),marginal_gain,'b','fill','o')
hold on
for num_seg=1:length(selected_segment)
    scatter3(X(selected_segment(num_seg),1),X(selected_segment(num_seg),2),...
        marginal_gain(selected_segment(num_seg)),point_size,color_set{num_seg},'o','linewidth',2)
    c = cellstr(['facility ',num2str(num_seg)]);
    dx = 0.3; dy = 0.3;dz=0.3; % displacement so the text does not overlay the data points
    text(X(selected_segment(num_seg),1)+dx, X(selected_segment(num_seg),2)+dy,...
        marginal_gain(selected_segment(num_seg))+dz, c);
end
scatter(X(:,1),X(:,2),20,'g','fill','o')
%     hold on
%     scatter(X(selected_segment,1),X(selected_segment,2),50,'k','x','linewidth',2)
az = -50;
el = 15;
view(az, el);
close all
scatter(X(:,1),X(:,2),50,'b','fill','o')
hold on
scatter(X(selected_segment,1),X(selected_segment,2),150,'r','x','linewidth',2)
AX=legend('Input data points','facility 1');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',10)

grid on
close all




for iter=1:2
    marginal_gain=zeros(size(X,1),1);
    pre_total_dist=zeros(size(X,1),1);
    parfor i=1:size(X,1)
        fprintf('Points %d\n',i)
        temp_X=X;
        temp_selected_set=[selected_segment;i];
        %             temp_X([selected_segment,i],:)=[];
        total_dist=0;
        for j=1:size(temp_X,1)
            [~,dist]=knnsearch(temp_X(j,:),X(temp_selected_set,:));
            dist=exp(-dist);
            total_dist=total_dist+max(dist);
        end
        pre_total_dist(i)=total_dist+length(selected_segment)-delta*(length(selected_segment)+1);
        marginal_gain(i)=total_dist+length(selected_segment)-previous_dist-delta*(length(selected_segment)+1);
    end
    [~,max_idx]=max(marginal_gain);
    selected_segment=[selected_segment;max_idx];
    previous_dist=pre_total_dist(max_idx);
    
    marginal_gain(find(marginal_gain<0))=0;
    scatter3(X(:,1),X(:,2),marginal_gain,'b','fill','o')
    hold on
    for num_seg=1:length(selected_segment)
        scatter3(X(selected_segment(num_seg),1),X(selected_segment(num_seg),2),...
            marginal_gain(selected_segment(num_seg)),point_size,color_set{num_seg},'o','linewidth',2)
        c = cellstr(['facility ',num2str(num_seg)]);
        switch num_seg
            case length(selected_segment)
                dx = 0.3; dy = 0.3;dz=0.3; % displacement so the text does not overlay the data points
            otherwise
                dx = -0.3; dy = -0.3;dz=-0.3;
        end
        text(X(selected_segment(num_seg),1)+dx, X(selected_segment(num_seg),2)+dy,...
            marginal_gain(selected_segment(num_seg))+dz, c);
    end
    scatter(X(:,1),X(:,2),20,'g','fill','o')
    %     hold on
    %     scatter(X(selected_segment,1),X(selected_segment,2),50,'k','x','linewidth',2)
    az = -50;
    el = 15;
    view(az, el);
    close all
    scatter(X(:,1),X(:,2),50,'b','fill','o')
    hold on
    for num_seg=1:length(selected_segment)
        scatter(X(selected_segment(num_seg),1),X(selected_segment(num_seg),2),150,...
            color_set{num_seg},'x','linewidth',2)
    end
    switch length(selected_segment)
        case 2
            AX=legend('Input data points','facility 1','facility 2');
        case 3
            AX=legend('Input data points','facility 1','facility 2','facility 3');
        otherwise
    end
    LEG = findobj(AX,'type','text');
    set(LEG,'FontSize',10)
    grid on
    close all
end
% use T-SNE to plot segments
selected_final=X(selected_segment,:);
class_idx=knnsearch(selected_final,X);
fianl_X1=X(find(class_idx==1),:);
fianl_X2=X(find(class_idx==2),:);
fianl_X3=X(find(class_idx==3),:);

scatter(fianl_X1(:,1),fianl_X1(:,2),50,'y','fill','o')
hold on
scatter(fianl_X2(:,1),fianl_X2(:,2),50,'r','fill','o')
scatter(fianl_X3(:,1),fianl_X3(:,2),50,'g','fill','o')
scatter(selected_final(:,1),selected_final(:,2),150,'k','x','linewidth',2)
AX=legend('group 1','group 2','group 3','facilities');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',10)
grid on
close all
end

