function [result_file_name] = Create_file_name(file_name, suffix, subdir)

    splits2 = split(file_name, '/');
    
    if length(splits2) == 1
        splits2 = split(file_name, '\')';
    end
    
    name = splits2(1);
    
    for i = 2 : length(splits2)
        if splits2(i) == "Images"
            name = name + "\" + 'Results';    
        else
            name = name + "\" + splits2(i);
        end
    end
    
    splits = split(name, '.');
    
    if nargin < 3
        result_file_name = splits(1) + "\" + suffix + ".png";
    else
        result_file_name = splits(1) + "\" + subdir + "\" + suffix + ".png";
    end

    CreateDictionary(result_file_name);
end

