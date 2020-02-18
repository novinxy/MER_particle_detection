classdef Path
   
    methods(Static)
       
        % Combines two paths into one
        function combinedPath = Combine(pathPart1, pathPart2)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            combinedPath = [char(pathPart1) filesep char(pathPart2)];
        end
        
        function fileName = GetFileName(path)
            [~, fileName, ~] = fileparts(char(path));
        end
        
        function extension = GetExtension(path)
            [~, ~, extension] = fileparts(path);
        end
        
        function directory = GetDirectory(path)
            [directory, ~, ~] = fileparts(char(path));
        end

        function directoryName = GetDirectoryName(path)
            splitted = strsplit(Path.GetDirectory(path), filesep);
            directoryName = splitted(length(splitted));
        end
        
        function result = IsJpgFile(fileName)
            extension = Path.GetExtension(char(fileName));
            if extension == ".JPG" || extension == ".jpg"
                result = true;
            else
                result = false;
            end
        end

    end
end

