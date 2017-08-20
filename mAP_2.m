function [pre,map,rec] = mAP_2(sim_x,L_tr,L_te)
%sim_x(i,j) denote the sim bewteen query j and database i
tn = size(sim_x,2);
APx = zeros(tn,1);
R = length(L_tr);
% R=50;
C=zeros(tn,1);
precision2=[];

class_num=zeros(length(unique(L_tr)),1);
class_type=unique(L_tr);
for j=1:length(class_num)
    class_num(j)=length(find(L_tr==class_type(j)));
end

[row col] = size(L_tr);
if min(row,col) == 1
    for i = 1 : tn
        label = L_te(i);
        [~,inxx] = sort(sim_x(:,i),'descend');
        ranked_L_tr=L_tr(inxx);
        C(i)=length(find(ranked_L_tr(1:R)==label));
    end
end

Precision_points=zeros(tn,max(C));
Av_Precision=zeros(tn,1);

%L_tr = [L_tr;L_tr];
[row col] = size(L_tr);
if min(row,col) == 1
    for i = 1 : tn
        
        
        
        Px = zeros(R,1);
        deltax = zeros(R,1);
        label = L_te(i);
        [tempx,inxx] = sort(sim_x(:,i),'descend');
        
        ranked_L_tr=L_tr(inxx);
        
        
        Lx = length(find(L_tr(inxx(1:R)) == label));
        yes = 0;
        p1 = [];
        r1 =[];
        for r = 1 : R
            Lrx = length(find(L_tr(inxx(1:r)) == label));
            if label == L_tr(inxx(r))
                deltax(r) = 1;
                yes = yes +1;
            end
            Px(r) = Lrx/r;
            p1 = [p1 yes/r];
            r1 = [r1 yes/C(i)];
        end
        
        if C(i)>0
            G_sum=cumsum(deltax);
            Recall_points=zeros(1,C(i));
            for rec=1:C(i)
                Recall_points(rec)=find((G_sum==rec),1);
            end;
            Precision_points(i,1:C(i))=G_sum(Recall_points)'./Recall_points;
            Av_Precision(i)=mean(Precision_points(i,1:C(i)));
        end
        if Lx ~=0
            APx(i) = sum(Px.*deltax)/Lx;
        end
        precision2(i,:) = p1;
        recall(i,:) = r1;
    end
    map = mean(APx);
    Mean_Av_Precision=mean(Av_Precision);
    Precision=calcAvgPerf_1(Precision_points, C, tn);
    
    pre = sum(precision2,1)/size(precision2,1);
    rec = sum(recall,1)/size(recall,1);

end


end

function [Precision]=calcAvgPerf_1(P_points,C, size)

CUTOFF=2;
SAMPLE=20;
mean=zeros(1,SAMPLE);

for j = 1:SAMPLE
    valid = 0;
    for i = 1:size
        % only consider classes of a valid size and only average over real interpolated results this means avoid classes between precision 1 and 1/(classsize-1)
        %         if (C(i) < CUTOFF || C(i) < SAMPLE/j)
        %             continue;
        %         end
        [tmp] = interpolatePerf(P_points(i,:), C(i), j/SAMPLE); %
        mean(1,j)=mean(1,j)+tmp;
        valid=valid+1;
    end
    if (valid > 0)
        mean(1,j)=mean(1,j)/valid;
    end
end
Precision=mean;

end


function [total] = grps2total(query,grps)

m = size(grps,2);
% total = [];

for i=1:m
    if strcmp(query,grps(i).name)
        total = grps(i).number;
        break
    end
end

end
