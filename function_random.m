function [ T2I_map,I2T_map ] = function_random( Rd_dimension )
% addpath C:\Codes\CrossModalityAutoencoder\utilities\UCSD_code
% addpath C:\Codes\PublicCodes\PCA

% load ./data/image_data.mat
% load ./data/Text_data.mat

% load best_partition.mat

load ./data/DeepNet.mat
% clear Target
label=label_img;

label=double(label);
image_fea=double(image_fea) ;
text_fea=double(text_fea);

test_num=1260;

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

Target=zeros(length(train_label),Rd_dimension);
for c=1:length(unique(train_label))
    idx=find(train_label==c);
    randfev = rand(1,Rd_dimension);
    %randfev=[eigvector_I(:,c)'];
    Target(idx,:)=repmat(randfev,[length(idx), 1]);
end



% pool = parpool

network_layer=10;

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

% [ Precision_T2I,Recall_T2I ] = PR_curve( new_test_data_text',test_label,new_train_data_img',train_label); 
% 
% [ Precision_I2T,Recall_I2T ] = PR_curve( new_test_data_img',test_label,new_train_data_text',train_label);


opt.metric='NC';
opt.rm=0;

[Q_t2i,C_t2i,info_t2i] = retrieval_pascal(new_test_data_text',test_label,new_train_data_img',train_label,opt);
[Q_i2t,C_i2t,info_i2t] = retrieval_pascal(new_test_data_img',test_label,new_train_data_text',train_label,opt);

T2I_map=info_t2i.mAP;
I2T_map=info_i2t.mAP;

fprintf('mAP for TextQueryOnImageDB: %.4f\n', info_t2i.mAP);
fprintf('mAP for ImageQueryOnTextDB: %.4f\n', info_i2t.mAP);
% plot(info_t2i.ap_11pt)
name_I2T=['./Results/PR_curves/DeepNetrandom_PRcurve_I2T',num2str(Rd_dimension),'.mat'];
name_T2I=['./Results/PR_curves/DeepNetrandom_PRcurve_T2I',num2str(Rd_dimension),'.mat'];
curve=info_i2t.ap_11pt;
save(name_I2T,'curve')
curve=info_t2i.ap_11pt;
save(name_T2I,'curve')

name_top_points_I2T=['./Results/Top_retrieved_points/DeepNetrandom_points_I2T',num2str(Rd_dimension),'.mat'];
name_top_points_T2I=['./Results/Top_retrieved_points/DeepNetrandom_points_T2I',num2str(Rd_dimension),'.mat'];
points=info_i2t.Precision_at_k;
save(name_top_points_I2T,'points');
points=info_t2i.Precision_at_k;
save(name_top_points_T2I,'points');


end

