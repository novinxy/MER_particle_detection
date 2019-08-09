function CreateDictionary(file_name)

    splits2 = split(file_name, '/');
    
    if length(splits2) == 1
        splits2 = split(file_name, '\')';
    end
    
    name = splits2(1);
    len = length(splits2);
    for i = 2 : len - 1
        if splits2(i) == "Images"
            name = name + "\" + 'Results';    
        else
            name = name + "\" + splits2(i);
        end
    end

    if ~exist(name, 'dir')
       mkdir(name);
    end
end
