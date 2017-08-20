clear;clc;
close all
colors ={'b','g','c','k','m','r','k','c','k','g','b','c','m','y'};
markers={'s','o','v','o','o','s','d','v','v','p','hexagram','s','o','v'};

type_set='T2I';
dim_set='64';

path='PR_curves';
mat_dir=dir('PR_curves\*.mat');
num=1;
for i=1:length(mat_dir)
    dim=mat_dir(i,1).name(end-5:end-4);
    type=mat_dir(i,1).name(end-8:end-6);
    if strcmp(dim_set,dim) && strcmp(type_set,type)
        fprintf('%s\n',mat_dir(i,1).name)
        load(fullfile(path,mat_dir(i,1).name))
        plot(curve,'LineWidth',2,'color',colors{num},'marker',markers{num},...
            'MarkerFaceColor',colors{num},'MarkerEdgeColor',colors{num},'MarkerSize',1);
        clear curve
        hold on
        num=num+1;
    end
end

switch type_set
    case 'I2T'
        title(['Image to Text retrieval PR-curves, dimension=',dim_set])
    case 'T2I'
        title(['Text to Image retrieval PR-curves, dimension=',dim_set])
end
hleg1=legend('SaliencyNet-CCA','DeepNet-CCA','SaliencyNet-PCA','DeepNet-random','DeepNet-PCA','SaliencyNet-random')
set(hleg1,'FontSize',6);


grid on
xlabel('Recall'),ylabel('Precision')