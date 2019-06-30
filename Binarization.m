function [result_img, thresh_level] = Binarization(file_name, log, radius, thresh_level)
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

    % binarization OTSU threshold
    if nargin < 4
        thresh_level = graythresh(opening_img);
    end
    binary_img = imbinarize(opening_img, thresh_level);

    % filling holes
    binary_img = uint8(255 * binary_img);
    filled = imfill(binary_img);

    % deleting border objects
    result_img = imclearborder(filled);

    % save to file
    if log == true
        imwrite(result_img, Create_file_name(file_name, "bin"))
    end

end

