function [result] = Check_If_JPG(file_name)
    splits = split(file_name, '.');
    if splits(2) == "JPG"
        result = true;
    else
        result = false;
    end
end

