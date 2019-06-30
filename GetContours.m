function contours = GetContours(image)
    [h] = contourc(double(image), 1);
%     [C, h] = imcontour(image, [1 1]);
    index = 0;
    i = 1;
    length = size(h, 2);
    indexes(1) = h(2, 1);
    
    contours(1) = ContourData([h(1, 2 : indexes(1) + 1); h(2, 2 : indexes(1) + 1)]);
    while index + indexes(i) + i < length
        index = index + indexes(i);
        i = i + 1;
        indexes(i) = h(2, index + i);
        
        contours(i) = ContourData([h(1, index + i + 1 : index + indexes(i) + i); h(2, index + i + 1 : index + indexes(i) + i)]);
    end
end
