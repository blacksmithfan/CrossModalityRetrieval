function salient_region= new_facility_location_selection(masks,D)

do_plot=0;
k = 1;


concatenated_D=cat(1,D{1,1},D{3,1},D{3,1},D{4,1},D{5,1},D{6,1});
X=concatenated_D';


V_sigma=1:size(X,1);


P_dist=pdist2(X,X);

P_dist=P_dist./norm(P_dist);
for i=1:length(P_dist)
    P_dist(i,i)=1;
end

% P_dist

F_mi = sfo_fn_mi(P_dist,V_sigma);

F = F_mi; V = V_sigma;

[A,scores,evals] = saliency_greedy_lazy(F,V,k);


salient_region=A;

% nevals = length(V):-1:(length(V)-k+1);
% disp(sprintf('Lazy evaluations: %d, naive evaluations: %d, savings: %f%%',sum(evals),sum(nevals),100*(1-sum(evals)/sum(nevals))));
% disp(' ')
% 
% 
% disp('Let''s now compute online bounds.  These are data dependent bounds');
% disp('that can be computed after running the greedy algorithm (and are often');
% disp('tighter than the (1-1/e) "offline" bound).');
% bound = sfo_maxbound(F,V,A,k);
% disp(sprintf('Greedy score F(A) = %f; \nNemhauser (1-1/e) bound: %f; \nOnline bound: %f',scores(end),scores(end)/(1-1/exp(1)),bound));


if do_plot
    disp('will now plot the greedy scores');
    figure
    plot(0:k,[0 scores]); xlabel('Number of elements'); ylabel('submodular utility');
end


end

