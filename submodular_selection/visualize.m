function [ masked_image,BB ] = visualize( image,mask )
close all

if size(mask,3)==1
    alpha=0.3;
    new_mask=mask.*100;
    I=image;
    masked_image=zeros(size(I));
    for ii=1:size(I,1)
        for jj=1:size(I,2)
            %                 if new_mask(ii,jj,3)==142
            %                     new_mask(ii,jj,3)=0;
            %                 end
            masked_image(ii,jj,1)=(1-alpha).*I(ii,jj,1)+alpha.*new_mask(ii,jj);
            masked_image(ii,jj,2)=(1-alpha).*I(ii,jj,2)+alpha.*new_mask(ii,jj)*5;
            masked_image(ii,jj,3)=(1-alpha).*I(ii,jj,3)+alpha.*new_mask(ii,jj)*5;
            
        end
    end
else
    I=image;
    accumulated_mask=zeros(size(mask,1),size(mask,2));
    for k=1:size(mask,3)
        accumulated_mask=accumulated_mask+mask(:,:,k);
    end
    
    accumulated_mask(accumulated_mask<2)=0;
    myfilter = fspecial('gaussian',[50 50],28.2);
    accumulated_mask = imfilter(accumulated_mask, myfilter, 'replicate');
    h = figure;
    imagesc(accumulated_mask)
    set(gca,'Units','normalized','Position',[0 0 1 1]);
    set(gcf, 'Units', 'pixels','position', [200, 200, size(accumulated_mask,2), size(accumulated_mask,1)]);
    axis off
    f = getframe(gcf);
    BB=f.cdata;
        
    alpha=0.5;
    accumulated_mask=BB;
    %     accumulated_mask=double(accumulated_mask);
    %     accumulated_temp=double(accumulated_temp);
    %     for cc=1:3
    %         accumulated_mask(:,:,cc)=accumulated_mask(:,:,cc).*accumulated_temp;
    %     end
    masked_image=zeros(size(I));
    for ii=1:size(image,1)
        for jj=1:size(image,2)
            if accumulated_mask(ii,jj,1)==53 
                accumulated_mask(ii,jj,1)=0;
            end
            if accumulated_mask(ii,jj,2)==42 
                accumulated_mask(ii,jj,2)=0;
            end
            if accumulated_mask(ii,jj,3)==134 
                accumulated_mask(ii,jj,3)=0;
            end
            %             if accumulated_mask(ii,jj,3)==142 || accumulated_mask(ii,jj,3)==143
            %                 accumulated_mask(ii,jj,3)=0;
            %             end
            masked_image(ii,jj,1)=(1-alpha).*image(ii,jj,1)+alpha.*accumulated_mask(ii,jj,1);
            masked_image(ii,jj,2)=(1-alpha).*image(ii,jj,2)+alpha.*accumulated_mask(ii,jj,2);
            masked_image(ii,jj,3)=(1-alpha).*image(ii,jj,3)+alpha.*accumulated_mask(ii,jj,3);
        end
    end
    
end


end

