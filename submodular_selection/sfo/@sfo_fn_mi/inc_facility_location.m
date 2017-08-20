function newScore = inc_facility_location(F,A,el)

F = init(F,A);


if sum(A==el)>0
    newScore = get(F,'current_val');
    return;
else
    A=[A,el];
end



distance_matrix=F.sigma;



weight=0;
for i=1:length(F.sigma)
%     marginal_gain=zeros(length(A),1);
%     for j=1:length(A)
%         marginal_gain(j)=distance_matrix(i,A(1:length(A)));
%     end
    weight_temp=min(distance_matrix(i,A(1:length(A))));
    weight=weight+exp(-weight_temp);
end

newScore = get(F,'current_val')+weight;
