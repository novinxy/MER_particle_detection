function result_img = Canny(file_name, log, radius, thresh, sigma)
    I = imread(file_name);

    % open operation
    disk_kernel = Disk_kernel(radius);
    opening_img = imopen(I, disk_kernel);

    % save to file
    if log == true
        imwrite(opening_img, Create_file_name(file_name, "open"));
    end

    % change to grayscale for JPG
    if Check_If_JPG(file_name)
        opening_img = rgb2gray(opening_img);
    end
        
    % canny detection
    edge_img = edge(opening_img,'canny', thresh, sigma);
    
    % thinning edges
    edge_img = bwmorph(edge_img,'thin',Inf);

    % save to file
    if log == true
        imwrite(edge_img, Create_file_name(file_name, "edge"));
    end
    
    % filling image
    edge_img = uint8(255 * edge_img);
    filled_img = imfill(edge_img);
    
    % open operation
    square_kernel = strel('square', 2);
    result_img = imopen(filled_img, square_kernel);

    % save to file
    if log == true
        imwrite(result_img, Create_file_name(file_name, "result"))
    end

end