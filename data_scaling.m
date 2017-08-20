function [ data ] = data_scaling( data )

for i=1:size(data,1)
    data(i,:)=(data(i,:)-min(data(i,:)))...
        ./(max(data(i,:))-min(data(i,:)));
end

end

