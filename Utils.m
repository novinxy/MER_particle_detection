classdef Utils
    
    methods(Static)
       
        % --- Returns double value from handle
        function value = GetValue(handle)
            value = str2double(handle.String);
        end
    end
end

