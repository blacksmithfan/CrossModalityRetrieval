clear;clc;

image_path='select_1_feature';

file='Z:\Fan_Zhu\data\PASCAL_dataset\attribute_data\apascal_train.txt';

N_ATTS = 64;


fileID = fopen (file,'r');

% tline = fgetl(fileID);
% while ischar(tline)
%     temp=strread(tline);
%     tline = fgetl(fileID);
tline = textscan(fileID, ['%s %s' repmat(' %f',1,N_ATTS + 4)],'CollectOutput',1);
% end
fclose(fileID);

image_fea=zeros(length(tline{1,1}),4096);
label_img=zeros(length(tline{1,1}),1);


categories={'aeroplane','bicycle','bird','boat','bottle','bus','car','cat','chair','cow','diningtable',...
    'dog','horse','motorbike','person','pottedplant','sheep','sofa','train','tvmonitor'};

num=1;
for i=1:length(tline{1,1})
    fprintf('Num: %d\n',num)
    image_category=tline{1,1}{i,2};
    image_name=tline{1,1}{i,1};
    CNN_fea_path=[image_path,'\',image_name,'.features'];
    
    if exist(char(CNN_fea_path))
        feature=textread(char(CNN_fea_path));
        image_fea(num,:)=feature(2,1:4096);
        
        cmp_vector=strcmp(categories,image_category);
        label_img(num)=find(cmp_vector==1);
        num=num+1;
    end
end

save('image_data_select_1.mat','image_fea','label_img')