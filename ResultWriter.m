classdef ResultWriter
    properties
        ImagePath
        SegmentationMethod
        SaveStepImages
    end
    
    methods      
        function obj = ResultWriter(imagePath, segmentationMethod, saveStepImages)
            obj.ImagePath = imagePath;
            obj.SegmentationMethod = segmentationMethod;
            obj.SaveStepImages = saveStepImages;
        end

        function SaveImage(obj, image, fileName)
            resultDirectory = obj.GetResultDirectory();
            filePath = Path.Combine(resultDirectory, fileName);
            
            requiredDirectory = Path.GetDirectory(filePath);
            Directory.Create(requiredDirectory);

            imwrite(image, filePath);
        end

        function SaveStepImage(obj, image, fileName)
            if obj.SaveStepImages
                fileWithSubDirectory = Path.Combine('Steps', fileName);

                obj.SaveImage(image, fileWithSubDirectory);
            end
        end

        function resultDirectory = GetResultDirectory(obj)
            fileName = strrep(obj.ImagePath, 'Images', 'Results');
            
            splits = split(fileName, '.');
            resultDirectory = Path.Combine(splits{1}, obj.SegmentationMethod);
        end
    end
end

