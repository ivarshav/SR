function [ kernel ] = main( path )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    orig = imread(path);
    orig = double(orig);
    kernel = fspecial('gaussian', [5 5], 4); % symmetric 2d gaussian kernel, 5*5
    
%   Creates synthetic image
    gray_image = orig(:,:,2);  % orig(:,:,2); % takes the 'g' layer from rgb 
    orig_filtered = imfilter(orig, kernel, 'conv');
    gray_filtered = orig_filtered(:,:,2); 
    filtered_small = gray_filtered(1:2:end,1:2:end);
    
    synthetic_image = [gray_image,[filtered_small;filtered_small]];
    
%     gray_image = rgb2gray(orig);  % orig(:,:,2); % takes the 'g' layer from rgb 
%     orig_filtered = imfilter(gray_image, kernel, 'conv');
%     orig_small = orig_filtered(1:2:end,1:2:end);
%     synthetic_image = [gray_image,[orig_small;orig_small]];
    
    high = double(synthetic_image);
    
    k = zeros(size(kernel),'like',kernel);
    PATCH_SIZE = 5;
    counter = 1;

%     assert (low(:,1:size(orig_small,2)) == orig_small);
%     assert (low(:,1:size(orig_small,2)) == high(end-size(orig_small,1)+1:end, end-size(orig_small,2)+1:end));

    while sum(sum(abs(abs(kernel) - abs(k)))) > 0.1 && counter < 11
        tic;
        % Use the new kernel
        if k ~= 0
            kernel = k;
        end
        filtered = imfilter(high, kernel, 'conv'); % 'same' is default
        low = filtered(1:2:end,1:2:end); % takes every second patch
        
        if counter == 1
            low = low(:, 1:45);
            high = high(1:46,93:137);
        end

        low_patches = double(im2col(low, [5 5], 'sliding')');
        high_patches = double(im2col(high, [5 5], 'sliding')');
        mid =  ceil(size(high_patches, 2) / 2);

%       Find nearest neighbors between high and low.
        [idx, D] = knnsearch(low_patches, high_patches, 'K', 9, 'Distance', 'minkowski', 'P', 2);

        [i,j] = ind2sub(size(low)-4,idx(:,1));
        high_i = 2*i-1;
        high_j = 2*j-1;
        h_idx = sub2ind(size(high) - 4,high_i,high_j);
        high_from_low_patches = high_patches(h_idx,:);

%         assert (pinv(high)*high == eye(size(high,2),'like',high));
        index_D = find(D(:,1) < 20);
        high_patches_best = high_patches(index_D,:);
        high_from_low_patches_best = high_from_low_patches(index_D,:); 

        % update kernel
        k = pinv(high_from_low_patches_best)*high_patches_best(:,mid);
        k = reshape(k,[5,5]);
        k = k / sum(k(:));
        disp('kernel:');
        disp(kernel);
        disp('new kernel:');
        disp(k);
        fprintf('Just finished iteration #%d\n', counter);
        disp(sum(sum(abs(abs(kernel) - abs(k)))));
        counter = counter + 1;
        toc;
    end 
    return
end