clear;clc;
Rd_dimension=64;


addpath C:\Codes\CrossModalityAutoencoder\utilities\UCSD_code
addpath C:\Codes\PublicCodes\PCA
addpath C:\Codes\CrossModalityAutoencoder\utilities\3rd-party\liblinear\windows

load ./data/SaliencyNet.mat

label=double(label_img);
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



[I.tr, T.tr, Mi,Mt,test] = cca3(train_data_img,train_data_text,test_data_img,test_data_text);

COMPS=min(Rd_dimension,size(I.tr,2));

new_train_data_text=T.tr(:,1:COMPS);
new_train_data_img=I.tr(:,1:COMPS);
new_test_data_img=test.Xcca(:,1:COMPS);
new_test_data_text=test.Ycca(:,1:COMPS);

fprintf('CCA done!\n')

opt.metric='NC';
opt.rm=0;

[~,~,info_t2i] = retrieval_pascal(new_test_data_text,test_label,new_train_data_img,train_label,opt);
[~,~,info_i2t] = retrieval_pascal(new_test_data_img,test_label,new_train_data_text,train_label,opt);

T2I_map=info_t2i.mAP;
I2T_map=info_i2t.mAP;

fprintf('mAP for TextQueryOnImageDB: %.4f\n', info_t2i.mAP);
fprintf('mAP for ImageQueryOnTextDB: %.4f\n', info_i2t.mAP);
% plot(info_t2i.ap_11pt)
name_I2T=['./Results/PR_curves/SM_PRcurve_I2T',num2str(Rd_dimension),'.mat'];
name_T2I=['./Results/PR_curves/SM_PRcurve_T2I',num2str(Rd_dimension),'.mat'];
curve=info_i2t.ap_11pt;
save(name_I2T,'curve')
curve=info_t2i.ap_11pt;
save(name_T2I,'curve')

name_top_points_I2T=['./Results/Top_retrieved_points/SM_points_I2T',num2str(Rd_dimension),'.mat'];
name_top_points_T2I=['./Results/Top_retrieved_points/SM_points_T2I',num2str(Rd_dimension),'.mat'];
points=info_i2t.Precision_at_k;
save(name_top_points_I2T,'points');
points=info_t2i.Precision_at_k;
save(name_top_points_T2I,'points');