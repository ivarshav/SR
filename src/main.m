function [ kernel ] = main( path )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    orig = imread(path);
    gray_image = rgb2gray(orig);  % orig(:,:,2); % takes the 'g' layer from rgb 
    kernel = fspecial('gaussian', [5 5], 4); % symmetric 2d gaussian kernel, 5*5
    orig_filtered = imfilter(gray_image, kernel, 'conv');
    orig_small = orig_filtered(1:2:end,1:2:end);
    synthetic_image = [gray_image,[orig_small;orig_small]];
    high = double(synthetic_image);
    
    k = zeros(size(kernel),'like',kernel);
    while sum(sum(abs(abs(kernel) - abs(k)))) > 0.1
        tic;
        % Use the new kernel
        if k ~= 0
            kernel = k;
        end
        filtered = imfilter(high, kernel, 'conv'); % 'same' is default
        low = filtered(1:2:end,1:2:end); % takes every second patch

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
        % update kernel
        k = pinv(high_from_low_patches)*high_patches(:,mid);
        k = reshape(k,[5,5]);
        k = k / sum(k(:));
        disp('new kernel:');
        disp(k);
        disp('kernel:');
        disp(kernel);
        fprintf('Just finished iteration #%d\n', counter);
        counter = counter + 1;
        toc;
    end      
    return


end

