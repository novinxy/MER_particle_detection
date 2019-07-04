function result_img = Watershed(file_name, log, open_radius, sharpen_radius, thresh, sigma, gradient_threshold, gaussian_sigma, guassian_filter)
    I = imread(file_name);

    % open operation
    disk_kernel = Disk_kernel(open_radius);
    opening_img = imopen(I, disk_kernel);

    if log == true
        CreateDictionary(file_name);
        imwrite(opening_img, Create_file_name(file_name, "open"));
    end

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
        if isa(opening_img, 'uint8')
            edge_img = uint8(255 * edge_img);
        else
            edge_img = uint16(65535 * edge_img);
        end

        if log == true
            imwrite(edge_img, Create_file_name(file_name, "edge"));
        end

        % add edge to sharpened img
        added_img = sharpened_img + edge_img;
        if log == true
            imwrite(added_img, Create_file_name(file_name, "add"));
        end

        % gradient filtering
        [gmag, gdir] = imgradient(added_img);
        gradient_img = gmag > gradient_threshold;
        if log == true
            imwrite(gradient_img, Create_file_name(file_name, "gradient"));
        end

    % FIRST PARALLEL 
    % END

    % SECOND PARALLEL 
    % START

        % binarization OTSU threshold
        level = graythresh(sharpened_img);
        binary_img = imbinarize(sharpened_img, level);
        if log == true
            imwrite(binary_img, Create_file_name(file_name, "bin"));
        end

        % filling holes
        if isa(opening_img, 'uint8')
            binary_img = uint8(255 * binary_img);
        else
            binary_img = uint16(65535 * binary_img);
        end

        filled = imfill(binary_img);
        if log == true
            imwrite(filled, Create_file_name(file_name, "fill"));
        end

        % distance transform
        distance_img = bwdist(~filled);

        % gaussian filtering
        gaussian_img = imgaussfilt(distance_img, gaussian_sigma, 'FilterSize', guassian_filter);
        if log == true
            imwrite(gaussian_img, Create_file_name(file_name, "gaussian"));
        end

        % Finding markers(MS)/ extended maxima detection
        img = imextendedmax(gaussian_img, 0.001);
        if log == true
            imwrite(img, Create_file_name(file_name, "MAX"));
        end

    % SECOND PARALLEL 
    % END

    % adding two together
    combined_img = img + gradient_img;

    % watershed
    water_img = watershed(combined_img);
    if isa(opening_img, 'uint8')
        water_img = uint8(255 * water_img);
    else
        water_img = uint16(65535 * water_img);
    end

    % binarization OTSU threshold
    level = graythresh(water_img);
    binary_img = imbinarize(water_img, level);

    % deleting border objects
    result_img = imclearborder(binary_img);

    % cleaning garbage
    disk_kernel = Disk_kernel(7);
    result_img = imopen(result_img, disk_kernel);

    if isa(opening_img, 'uint8')
        result_img = uint8(255 * result_img);
    else
        result_img = uint16(65535 * result_img);
    end
    result_img = imfill(result_img);

    if log == true
        imwrite(result_img, Create_file_name(file_name, "result"));
    end

end

