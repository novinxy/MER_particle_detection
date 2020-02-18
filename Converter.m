classdef Converter
    
    methods(Static)
        
        function image = BinaryToUint8(binaryImage)
            image = uint8(255 * binaryImage);
        end
        
        function image = BinaryToUint16(binaryImage)
            image = uint16(65535 * binaryImage);
        end
        
        function image = BinaryToValues(binaryImage, typeTemplateImage)
            if isa(typeTemplateImage, 'uint8')
                image = Converter.BinaryToUint8(binaryImage);
            else
                image = Converter.BinaryToUint16(binaryImage);
            end
        end

        function convertedVaue = PixelsToMilimeters(value)
            scale = 0.031;
            convertedVaue = value.* scale;
        end

        function convertedVaue = MilimetersToPixels(value)
            scale = 0.031;
            convertedVaue = value./ scale;
        end
    end
end

