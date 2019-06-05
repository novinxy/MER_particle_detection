function [result_file_name] = Create_file_name(file_name, suffix)
    splits = split(file_name, '.');
    result_file_name = splits(1) + "_" + suffix + ".png";
end

