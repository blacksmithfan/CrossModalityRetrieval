clear;clc;
addpath C:\Codes\CrossModalityAutoencoder\utilities\UCSD_code
addpath C:\Codes\PublicCodes\PCA

% load ./data/image_data.mat
% load ./data/Text_data.mat

% load best_partition.mat

load ./data/SaliencyNet.mat
% clear Target
label=label_img;

label=double(label);
image_fea=double(image_fea) ;
text_fea=double(text_fea);

test_num=1260;
Rd_dimension=16;

rand_ind=randperm(length(label));
label=label(rand_ind);
image_fea=image_fea(rand_ind,:);
text_fea=text_fea(rand_ind,:);

test_data_img=image_fea(1:test_num,:);
train_data_img=image_fea(test_num+1:end,:);

test_data_text=text_fea(1:test_num,:);
train_data_text=text_fea(test_num+1:end,:);

test_label=label(1:test_num);
train_label=label(test_num+1:end);

[A B r U V] = canoncorr(train_data_img,train_data_text);

% [A B r U V] = canoncorr(train_data_img,train_data_text);
% plot(U(:,1),V(:,1),'.')
% 
% train_data_img=train_data_img';
% test_data_img=test_data_img';

options.ReducedDim = Rd_dimension;


[eigvector,eigvalue,meanData,new_data] = PCA(train_data_img,options);
train_data_img = train_data_img*eigvector;
test_data_img = test_data_img*eigvector;

train_data_img=abs(train_data_img);
test_data_img=abs(test_data_img);


[eigvector,eigvalue,meanData,new_data] = PCA(train_data_text,options);
test_data_text = test_data_text*eigvector;
train_data_text = train_data_text*eigvector;

test_data_text=abs(test_data_text);
train_data_text=abs(train_data_text);

[ mean_vector ] = compute_category_mean( [train_data_img;train_data_text], [train_label;train_label] );

Target_temp=mean_vector;
% Target_temp=data_scaling(Target_temp);

% Target_temp=[];
% for i=1:size(eigvector,1)
%     if sum(eigvector(i,:))>0
%         Target_temp=[Target_temp;eigvector(i,:)];
%     end
%     if size(Target_temp,1)>19
%         break
%     end
% end

% Target_temp=data_scaling(Target_temp);
% 
Target=zeros(length(train_label),Rd_dimension);
for c=1:length(unique(train_label))
    idx=find(train_label==c);
    randfev = Target_temp(c,:);
    %randfev=[eigvector_I(:,c)'];
    Target(idx,:)=repmat(randfev,[length(idx), 1]);
end

% pool = parpool

network_layer=20;

net_text = feedforwardnet(network_layer);
net_text.divideFcn = '';
net_text.trainParam.epochs = 300;
net_text.trainParam.goal = 1e-5;
net_text.performParam.regularization = 0.5;

[net_text,tr_text] = train(net_text,train_data_text',Target','useGPU','yes','showResources','yes');

new_test_data_text = net_text(test_data_text','useGPU','yes','showResources','yes');
new_train_data_text = net_text(train_data_text','useGPU','yes','showResources','yes');


net_img = feedforwardnet(network_layer);
net_img.divideFcn = '';
net_img.trainParam.epochs = 300;
net_img.trainParam.goal = 1e-5;
net_img.performParam.regularization = 0.5;

[net_img,tr_img] = train(net_img,train_data_img',Target','useGPU','yes','showResources','yes');

new_train_data_img = net_img(train_data_img','useGPU','yes','showResources','yes');

new_test_data_img = net_img(test_data_img','useGPU','yes','showResources','yes');


% simii = new_test_data_text' * new_train_data_img;

simii = new_test_data_img' * new_train_data_img;
simti = new_test_data_text' * new_train_data_img;
% simti = new_test_data_text' * Target';
% simit = new_test_data_img' * Target';
simit = new_test_data_img' * new_train_data_text;
simtt = new_test_data_text' * new_train_data_text;
%
%
% [Precision_T2I,map(1, 2),Recall_T2I] = mAP_2(simii',train_label,test_label);


% map(1, 1) = mAP_2(simii',train_label,test_label);
% [Precision_T2I,map(1, 2),Recall_T2I] = mAP_2(simti',train_label,test_label);
% [Precision_I2T,map(1, 3),Recall_I2T] = mAP_2(simit',train_label,test_label);
% map(1, 4) = mAP_2(simtt',train_label,test_label);

% plot(Recall_T2I,Precision_T2I)


opt.metric='NC';
opt.rm=0;

[Q_t2i,C_t2i,info_t2i] = retrieval_pascal(new_test_data_text',test_label,new_train_data_img',train_label,opt);
[Q_i2t,C_i2t,info_i2t] = retrieval_pascal(new_test_data_img',test_label,new_train_data_text',train_label,opt);


fprintf('mAP for TextQueryOnImageDB: %.4f\n', info_t2i.mAP);
fprintf('mAP for ImageQueryOnTextDB: %.4f\n', info_i2t.mAP);
% plot(info_t2i.ap_11pt)
name_I2T=['./Results/PR_curves/PCA_PRcurve_I2T',num2str(Rd_dimension),'.mat'];
name_T2I=['./Results/PR_curves/PCA_PRcurve_T2I',num2str(Rd_dimension),'.mat'];
curve=info_i2t.ap_11pt;
save(name_I2T,'curve')
curve=info_t2i.ap_11pt;
save(name_T2I,'curve')

name_top_points_I2T=['./Results/Top_retrieved_points/PCA_points_I2T',num2str(Rd_dimension),'.mat'];
name_top_points_T2I=['./Results/Top_retrieved_points/PCA_points_T2I',num2str(Rd_dimension),'.mat'];
points=info_i2t.Precision_at_k;
save(name_top_points_I2T,'points');
points=info_t2i.Precision_at_k;
save(name_top_points_T2I,'points');