clear;clc;
load merced_data;

V_sigma = 1:size(merced_data.sigma,1); 


% Mutual information: F_mi(A) = H(V\A) - H(V\A | A)
F_mi = sfo_fn_mi(merced_data.sigma,V_sigma);

disp('We will now explore the lazy greedy algorithm');
disp(' ');
k = 15;
disp('Example: Experimental Design. Want to predict pH values on Lake Merced');
disp(sprintf('We greedily pick %d sensor locations for maximizing mutual information',k));
F = F_mi; V = V_sigma;
disp('[A,scores,evals] = sfo_greedy_lazy(F,V,k);');

[A,scores,evals] = sfo_greedy_lazy(F,V,k);
A
nevals = length(V):-1:(length(V)-k+1);
disp(sprintf('Lazy evaluations: %d, naive evaluations: %d, savings: %f%%',sum(evals),sum(nevals),100*(1-sum(evals)/sum(nevals))));
disp(' ')

if do_plot
    figure
    plot(merced_data.coords(:,1),merced_data.coords(:,2),'k.'); hold on
    plot(merced_data.coords(A,1),merced_data.coords(A,2),'bs','markerfacecolor','blue');
    xlabel('Horizontal location along transect'); ylabel('Vertical location (depth)'); title('Chosen sensing locations (blue squares)');
    pause
end

disp('Let''s now compute online bounds.  These are data dependent bounds');
disp('that can be computed after running the greedy algorithm (and are often');
disp('tighter than the (1-1/e) "offline" bound).');
bound = sfo_maxbound(F,V,A,k);
disp(sprintf('Greedy score F(A) = %f; \nNemhauser (1-1/e) bound: %f; \nOnline bound: %f',scores(end),scores(end)/(1-1/exp(1)),bound));
pause

if do_plot
    disp('will now plot the greedy scores');
    figure
    plot(0:k,[0 scores]); xlabel('Number of elements'); ylabel('submodular utility');
    pause
end