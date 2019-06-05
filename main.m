clear CannyT

function CannyT(radius, lower, upper, sigma)
    I = imread('1M129869918EFF0338P2953M2M1.JPG');

    disk_kernel = Disk_kernel(radius);
    opening_img = imopen(I, disk_kernel);
    % save to file and show in figure
    open_file_name = "open.JPG";
    imwrite(opening_img, open_file_name);
    % figure('Name', open_file_name)
    imshow(opening_img)
    gray_img = rgb2gray(opening_img);
    cleaned_img2 = make(gray_img, [lower, upper], sigma);
    imshow(cleaned_img2);
end
% I = imread('1M129869918EFF0338P2953M2M1.JPG');
% 
% disk_kernel = Disk_kernel(12);
% opening_img = imopen(I, disk_kernel);
% % save to file and show in figure
% open_file_name = "open.JPG";
% imwrite(opening_img, open_file_name);
% % figure('Name', open_file_name)
% imshow(opening_img)
% gray_img= rgb2gray(opening_img);
% 
% % get minimum value
% % result_name = '1M129869918EFF0338P2953M2M1_result.JPG';
% % image2 = imread(result_name);
% % level2 = multithresh(image2);
% % seg_I2 = imquantize(image2,level2);
% % 
% % 
% % min = 50000;
% % 
% % best_low = 0;
% % best_high = 0;
% % best_sigma = 0;
% % 
% % 
% % max_num_results = 100;
% % results = zeros(max_num_results, 4);
% % result_counter = 0;
% 
% % for lowIt = 0.:0.01:0.1
% %     for highI = 0.01:0.01:0.1
% %         for sigmaI = 0.1:0.1:10
% % 
% %             if lowIt >= highI
% %                 continue
% %             end       
% % 
% %             cleaned_img = make(gray_img, [lowIt, highI], sigmaI);
% %             level = multithresh(cleaned_img, 1);
% %             seg_I = imquantize(cleaned_img, level);
% %             
% %             result = abs(double(seg_I2) - double(seg_I));                    
% %             possible_min = sum(sum(result));
% % 
% %             if possible_min < min
% %                 result_counter = result_counter + 1;
% %                 results(result_counter, 1) = possible_min;
% %                 results(result_counter, 2) = lowIt;
% %                 results(result_counter, 3) = highI;
% %                 results(result_counter, 4) = sigmaI;
% %                 disp(possible_min);
% %                 min = possible_min;
% %                 best_high = highI;
% %                 best_low = lowIt;
% %                 best_sigma = sigmaI;
% %             end
% %         end
% %     end
% % end
% 
% % disp(best_sigma)
% 
% % disp(result)
% % imwrite(cleaned_img, 'result.jpg');
% % imshow(result)
% 
% cleaned_img2 = make(gray_img, [0.01, 0.02], 5.2);
% imshow(cleaned_img2);
% % imwrite(cleaned_img2, 'name.JPG');


function img = make(iimage, thresh, ssigma)
    canny6_img = edge(iimage,'canny', thresh, ssigma);
    
    canny6_img = bwmorph(canny6_img,'thin',Inf);
    
    canny6_file_name = "canny6.JPG";
    imwrite(canny6_img, canny6_file_name);
    
    canny6_img = imread(canny6_file_name);
    filled_canny6_img = imfill(canny6_img);
    % imwrite(filled_canny6_img, "filled" + canny6_file_name);
    
    % figure('Name', canny6_file_name)
    % imshow(filled_canny6_img);
    
    disk_kernel = strel('square', 2);
    img = imopen(filled_canny6_img, disk_kernel);
end