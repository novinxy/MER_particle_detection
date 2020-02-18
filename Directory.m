classdef Directory
    
    methods(Static)
       
        function result = Exist(path)
            result = exist(path, 'dir');
        end
        
        function Create(path)
            if ~Directory.Exist(path)
               mkdir(path);
            end
        end

        function files = GetFiles(path)
            entries = dir(path);  %get list of files and folders in any subfolder
            fileStructs = entries(~[entries.isdir]);  %remove folders from list
            
           for ind=1:length(fileStructs)
                files{ind} = Path.Combine(fileStructs(ind).folder, fileStructs(ind).name);
            end
        end
        
        function directories = GetDirectories(path)
            entries = dir(path);  %get list of files and folders in any subfolder
            directoryStructs = entries([entries.isdir]);  %remove folders from list
            
           for ind=1:length(directoryStructs)
                directories{ind} = char(directoryStructs(ind).folder);
            end
        end
    end
end

