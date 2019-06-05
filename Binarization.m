function Binarization(file_name, radius)
    I = imread(file_name);

    % open operation
    disk_kernel = Disk_kernel(radius);
    opening_img = imopen(I, disk_kernel);

    % save to file
    imwrite(opening_img, Create_file_name(file_name, "open"));
    
    % change to grayscale for JPG
    if Check_If_JPG(file_name)
        opening_img = rgb2gray(opening_img);
    end

    % binarization OTSU threshold
    level = graythresh(opening_img);
    binary_img = imbinarize(opening_img, level);

    % filling holes
    binary_img = uint8(255 * binary_img);
    filled = imfill(binary_img);

    % deleting border objects
    result_img = imclearborder(filled);

    % save to file
    imwrite(result_img, Create_file_name(file_name, "bin"))

    imshow(result_img);
end

