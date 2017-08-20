clear;clc;
addpath ./functions
addpath(genpath('./sfo'))
addpath subtightplot
segment_path='Z:\Fan_Zhu\data\PASCAL_dataset\sorted_data\CPMC_segments';

segment_dir=dir([segment_path,'\*.mat']);

save_path='visual_1';

for i=1:length(segment_dir)
    try
        fprintf('Loading file %s\n',segment_dir(i,1).name)
        if ~exist([save_path,'/',segment_dir(i,1).name(1:end-4),'.jpg'])
            load(fullfile(segment_path,segment_dir(i,1).name))
            
            
            %     for j=1:size(masks,3)
            %         subtightplot(5,5,j,0.01,0.01,0.0001)
            %         I=double(I);
            %         masks=double(masks);
            %         image=zeros(size(I));
            %         for c=1:3
            %             image(:,:,c)=I(:,:,c).*masks(:,:,j);
            %         end
            %         imshow(uint8(image))
            %     end
            % abandon masks that have less than 50% coverages
            %     [masks,D] = mask_filter(masks,D);
            
            salient_region=new_facility_location_selection(masks,D);
            
            I=double(I);
                    salient_image=zeros(size(I));
                    
                    salient_image(:,:,1)=255.*masks(:,:,salient_region);
                    salient_image(:,:,2)=230.*masks(:,:,salient_region);
                    salient_image(:,:,3)=0.*masks(:,:,salient_region);
%             [ salient_image,BB ] = visualize( I,masks(:,:,salient_region) );
%             imshow(uint8(salient_image))
            imwrite(uint8(salient_image),[save_path,'/',segment_dir(i,1).name(1:end-4),'.jpg'])
        end
    catch
    end
end

