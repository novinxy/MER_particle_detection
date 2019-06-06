function Watershed(file_name, open_radius, sharpen_radius, thresh, sigma, gradient_threshold, gaussian_sigma, guassian_filter)
    I = imread(file_name);

    % open operation
    disk_kernel = Disk_kernel(open_radius);
    opening_img = imopen(I, disk_kernel);

    imwrite(opening_img, Create_file_name(file_name, "open"));

    % change to grayscale for JPG
    if Check_If_JPG(file_name)
        opening_img = rgb2gray(opening_img);
    end
        
    % sharpening image
    sharpened_img = imsharpen(opening_img, "Radius", sharpen_radius);

    % FIRST PARALLEL 
    % START

        % canny detection
        edge_img = edge(sharpened_img,'canny', thresh, sigma);
        edge_img = uint8(255 * edge_img);

        imwrite(edge_img, Create_file_name(file_name, "edge"));

        % add edge to sharpened img
        added_img = sharpened_img + edge_img;
        imwrite(added_img, Create_file_name(file_name, "add"));

        % gradient filtering
        [gmag, gdir] = imgradient(added_img);
        gradient_img = gmag > gradient_threshold;
        imwrite(gradient_img, Create_file_name(file_name, "gradient"));

    % FIRST PARALLEL 
    % END

    % SECOND PARALLEL 
    % START

        % binarization OTSU threshold
        level = graythresh(sharpened_img);
        binary_img = imbinarize(sharpened_img, level);
        imwrite(binary_img, Create_file_name(file_name, "bin"));

        % filling holes
        binary_img = uint8(255 * binary_img);
        filled = imfill(binary_img);
        imwrite(filled, Create_file_name(file_name, "fill"));

        % distance transform
        distance_img = bwdist(~filled);

        % gaussian filtering
        gaussian_img = imgaussfilt(distance_img, gaussian_sigma, 'FilterSize', guassian_filter);
        imwrite(gaussian_img, Create_file_name(file_name, "gaussian"));

        % Finding markers(MS)/ extended maxima detection
        img = imextendedmax(gaussian_img, 0.001);
        imwrite(img, Create_file_name(file_name, "MAX"));

    % SECOND PARALLEL 
    % END

    % adding two together
    combined_img = img + gradient_img;

    % watershed
    water_img = watershed(combined_img);
    water_img = uint8(255 * water_img); % from logical to values

    % binarization OTSU threshold
    level = graythresh(water_img);
    binary_img = imbinarize(water_img, level);

    % deleting border objects
    result_img = imclearborder(binary_img);
    imwrite(result_img, Create_file_name(file_name, "result"));

    figure
    imshow(result_img);

end

