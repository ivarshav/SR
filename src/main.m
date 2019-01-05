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
    
    return


end

