clear;clc;
addpath C:\Codes\CrossModalityAutoencoder\utilities\UCSD_code
addpath C:\Codes\PublicCodes\PCA
addpath C:\Codes\CrossModalityAutoencoder\utilities\3rd-party\liblinear\windows

Rd_dimension=16;

load ./data/Saliencyfinetune.mat
% clear Target

label=double(label_img);
image_fea=double(image_fea) ;
text_fea=double(text_fea);

% test_num=1260;

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
% plot(U(:,1),V(:,1),'.')


train_data_img=train_data_img*A;
test_data_img=test_data_img*A;
train_data_text=train_data_text*B;
test_data_text=test_data_text*B;
% train_data_img=train_data_img';
% test_data_img=test_data_img';

% % find 0 rows
% temp_sum=sum(train_data_text,2);
% zero_idx=find(temp_sum==0);
% 
% train_data_text(zero_idx,:)=[];
% train_data_img(zero_idx,:)=[];
% train_label(zero_idx)=[];
% %---------------------------------

[ mean_vector ] = compute_category_mean( [train_data_img;train_data_text], [train_label;train_label] );

% Target_temp=data_scaling(mean_vector);
Target_temp=mean_vector;
Target_temp=Target_temp(:,1:Rd_dimension);
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
% Target=abs(Target);
% pool = parpool

network_layer=20;

net_text = feedforwardnet(network_layer);
net_text.divideFcn = '';
net_text.trainParam.epochs = 1000;
net_text.trainParam.goal = 1e-5;
net_text.performParam.regularization = 0.5;

[net_text,tr_text] = train(net_text,train_data_text',Target','useGPU','yes','showResources','yes');

new_test_data_text = net_text(test_data_text','useGPU','yes','showResources','yes');
new_train_data_text = net_text(train_data_text','useGPU','yes','showResources','yes');


net_img = feedforwardnet(network_layer);
net_img.divideFcn = '';
net_img.trainParam.epochs = 100;
net_img.trainParam.goal = 1e-5;
net_img.performParam.regularization = 0.1;

[net_img,tr_img] = train(net_img,train_data_img',Target','useGPU','yes','showResources','yes');

new_train_data_img = net_img(train_data_img','useGPU','yes','showResources','yes');

new_test_data_img = net_img(test_data_img','useGPU','yes','showResources','yes');

% [ Precision_T2I,Recall_T2I ] = PR_curve( new_test_data_text',test_label,new_train_data_img',train_label); 
% 
% [ Precision_I2T,Recall_I2T ] = PR_curve( new_test_data_img',test_label,new_train_data_text',train_label);

new_test_data_text=data_scaling(new_test_data_text);
new_test_data_img=data_scaling(new_test_data_img);
new_train_data_img=data_scaling(new_train_data_img);
new_train_data_text=data_scaling(new_train_data_text);

opt.metric='NC';
opt.rm=0;

[Q_t2i,C_t2i,info_t2i] = retrieval_pascal(new_test_data_text',test_label,new_train_data_img',train_label,opt);
[Q_i2t,C_i2t,info_i2t] = retrieval_pascal(new_test_data_img',test_label,new_train_data_text',train_label,opt);

T2I_map=info_t2i.mAP;
I2T_map=info_i2t.mAP;

fprintf('mAP for TextQueryOnImageDB: %.4f\n', info_t2i.mAP);
fprintf('mAP for ImageQueryOnTextDB: %.4f\n', info_i2t.mAP);
% plot(info_t2i.ap_11pt)
name_I2T=['./Results/PR_curves/CCA_finetune_PRcurve_I2T',num2str(Rd_dimension),'.mat'];
name_T2I=['./Results/PR_curves/CCA_finetune_PRcurve_T2I',num2str(Rd_dimension),'.mat'];
curve=info_i2t.ap_11pt;
save(name_I2T,'curve')
curve=info_t2i.ap_11pt;
save(name_T2I,'curve')

name_top_points_I2T=['./Results/Top_retrieved_points/CCA_finetune_points_I2T',num2str(Rd_dimension),'.mat'];
name_top_points_T2I=['./Results/Top_retrieved_points/CCA_finetune_points_T2I',num2str(Rd_dimension),'.mat'];
points=info_i2t.Precision_at_k;
save(name_top_points_I2T,'points');
points=info_t2i.Precision_at_k;
save(name_top_points_T2I,'points');