function Watershed(file_name, open_radius, sharpen_radius, thresh, sigma)
    I = imread(file_name);

    % open operation
    disk_kernel = Disk_kernel(open_radius);
    opening_img = imopen(I, disk_kernel);

    % save to file
    imwrite(opening_img, Create_file_name(file_name, "open"));

    % change to grayscale for JPG
    if Check_If_JPG(file_name)
        opening_img = rgb2gray(opening_img);
    end
        

    figure
    imshow(opening_img);
    % sharpening image
    sharpened_img = imsharpen(opening_img, "Radius", sharpen_radius);

    figure
    imshow(sharpened_img);

    % canny detection
    edge_img = edge(sharpened_img,'canny', thresh, sigma);
    figure
    imshow(edge_img);
    edge_img = uint8(255 * edge_img);

    enhanced_img = sharpened_img + edge_img;
    img = imgaussfilt(enhanced_img, [1, 1], 'FilterSize', 1);

    figure
    imshow(img);

    % canny detection
    % thresh = [lower, upper];
    % edge_img = edge(opening_img,'canny', thresh, sigma);
    
    % % thinning edges
    % edge_img = bwmorph(edge_img,'thin',Inf);

    % % save to file
    % imwrite(edge_img, Create_file_name(file_name, "edge"));
    
    % % filling image
    % edge_img = uint8(255 * edge_img);
    % filled_img = imfill(edge_img);
    
    % % open operation
    % square_kernel = strel('square', 2);
    % result_img = imopen(filled_img, square_kernel);

    % % save to file
    % imwrite(result_img, Create_file_name(file_name, "result"))

    % imshow(result_img);
end

