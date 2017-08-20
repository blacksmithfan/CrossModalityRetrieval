clear;clc;

image_path='E:\Codes\Z_temp_folder\saliencyNet_finetune\';

file='Z:\Fan_Zhu\data\PASCAL_dataset\attribute_data\apascal_train.txt';
file_1='Z:\Fan_Zhu\data\PASCAL_dataset\attribute_data\apascal_test.txt';

N_ATTS = 64;


fileID = fopen (file,'r');

% tline = fgetl(fileID);
% while ischar(tline)
%     temp=strread(tline);
%     tline = fgetl(fileID);
tline = textscan(fileID, ['%s %s' repmat(' %f',1,N_ATTS + 4)],'CollectOutput',1);
% end
fclose(fileID);

fileID1 = fopen (file_1,'r');

% tline = fgetl(fileID);
% while ischar(tline)
%     temp=strread(tline);
%     tline = fgetl(fileID);
tline_1 = textscan(fileID1, ['%s %s' repmat(' %f',1,N_ATTS + 4)],'CollectOutput',1);
% end
fclose(fileID1);

% image_fea=zeros(length(tline{1,1})+length(tline_1{1,1}),4096);
% label_img=zeros(length(tline{1,1})+length(tline_1{1,1}),1);


categories={'aeroplane','bicycle','bird','boat','bottle','bus','car','cat','chair','cow','diningtable',...
    'dog','horse','motorbike','person','pottedplant','sheep','sofa','train','tvmonitor'};

image_fea=[];label_img=[];label_text=[];text_fea=[];
for i=1:length(tline{1,1})
    image_category=tline{1,1}{i,2};
    image_name=tline{1,1}{i,1};
    CNN_fea_path=[image_path,image_name(1:end-4),'.mat'];
    if exist(CNN_fea_path)
        category_id=tline{1,1}{i,2};
        cmp_vector=strcmp(categories,category_id);
        label_text=[label_text;find(cmp_vector==1)];
        text_fea=[text_fea;tline{1,2}(i,5:end)];
        
        load(CNN_fea_path);
        fea = squeeze(fea{1,1});
        fea=max(fea');
        image_fea=[image_fea;fea];
        
        cmp_vector=strcmp(categories,image_category);
        label_img=[label_img;find(cmp_vector==1)];
    end
end

for i=1:length(tline_1{1,1})
    image_category=tline_1{1,1}{i,2};
    image_name=tline_1{1,1}{i,1};
    CNN_fea_path=[image_path,image_name(1:end-4),'.mat'];
    if exist(CNN_fea_path)
        category_id=tline_1{1,1}{i,2};
        cmp_vector=strcmp(categories,category_id);
        label_text=[label_text;find(cmp_vector==1)];
        text_fea=[text_fea;tline_1{1,2}(i,5:end)];
        
        load(CNN_fea_path);
        fea = squeeze(fea{1,1});
        fea=max(fea');
        image_fea=[image_fea;fea];
        
        cmp_vector=strcmp(categories,image_category);
        label_img=[label_img;find(cmp_vector==1)];
    end
end

save('Saliencyfinetune.mat','image_fea','label_img','label_text','text_fea')