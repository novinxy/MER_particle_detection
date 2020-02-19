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

        % --- writes grains data to file
        function WriteDataToFile(obj, hObject)
            h = guidata(hObject);

            resultDirectory = obj.GetResultDirectory();
            fileName = Path.Combine(resultDirectory, 'log.txt');
            file = fopen(fileName, 'wt');

            splited = split(h.imageInfoContainer.SelectedImage, ' ');
            imageName = splited(length(splited));

            fprintf(file, 'Image ID: %s\n', string(imageName)); 

            fprintf(file, 'Method: ');
            if h.binarizationFlag.Value
                fprintf(file, 'Binarization\n\n');
                fprintf(file, '----------------\n');
                fprintf(file, 'Method parameters:\n');
                fprintf(file, 'Opening radius: %g\n', Utils.GetValue(h.radiusVal));
                fprintf(file, 'Binarization threshold: %g\n', Utils.GetValue(h.binThVal));
                                
            elseif h.cannyFlag.Value
                fprintf(file, 'Canny edge detection\n');
                fprintf(file, '----------------\n');
                fprintf(file, 'Method parameters:\n');
                fprintf(file, 'Opening radius: %g\n', Utils.GetValue(h.radiusVal));
                fprintf(file, 'Low threshold: %g\n', Utils.GetValue(h.lowThVal));
                fprintf(file, 'High threshold: %g\n', Utils.GetValue(h.highThVal));
                fprintf(file, 'Sigma: %g\n', Utils.GetValue(h.sigmaVal));

            else h.waterFlag.Value
                fprintf(file, 'Watershed\n');
                fprintf(file, '----------------\n');
                fprintf(file, 'Method parameters:\n');
                fprintf(file, 'Opening radius: %g\n', Utils.GetValue(h.radiusVal));
                sharpRadius = Utils.GetValue(h.sharpRadiusVal);
                
                if h.sharpenRadiusFlag.Value == false
                    sharpRadius = 0;
                end

                fprintf(file, 'Sharpening radius: %g\n', sharpRadius);
                fprintf(file, 'Low threshold: %g\n', Utils.GetValue(h.waterLowThVal));
                fprintf(file, 'High threshold: %g\n', Utils.GetValue(h.waterHighThVal));
                fprintf(file, 'Sigma: %g\n', Utils.GetValue(h.waterSigmaVal));
                fprintf(file, 'Gaussian filtering sigma: %g\n', Utils.GetValue(h.gaussSigmaVal));
                fprintf(file, 'Gaussian filtering size: %g\n', Utils.GetValue(h.filterVal));
                fprintf(file, 'Binarization threshold: %g\n', Utils.GetValue(h.binWaterThVal));
                
            end

            fprintf(file, '\n----------------\n');

            
            fprintf(file, 'Filtering:\n');
            fprintf(file, 'Min diameter: %g\n', Utils.GetValue(h.minDiameterVal));
            fprintf(file, 'Max diameter: %g\n', Utils.GetValue(h.maxDiameterVal));
            fprintf(file, 'Min circularity: %g\n\n', Utils.GetValue(h.circularityVal));
            
            fprintf(file, '\n----------------\n');
            fprintf(file, 'Num of manualy deleted grains: %g\n\n', h.GrainsDeletedManualy);

            fprintf(file, '\n----------------\n');
            fprintf(file, 'Number of detected grains: %g\n', Utils.GetValue(h.detectedCountVal));
            fprintf(file, 'Number of grains after filtering: %g\n', h.Params.Number);
            fprintf(file, 'Number of well detected grains: %g\n', length(h.WellDetectedGrains));

            fprintf(file, '\n----------------\n');
            fprintf(file, 'In pixels:\n');
            fprintf(file, 'Median\nMean\nStandard devation\n\n');
            dataMatrix = [h.Params.Diameter; 
                        h.Params.ShortAxis; 
                        h.Params.LongAxis; 
                        h.Params.Circularity; 
                        h.Params.Ratio];

            dataTypes = ["Diameter", "Short axis", "Long axis", "Circularity", "Aspect ratio"];

            for i = 1 : size(dataMatrix, 1)
                data = dataMatrix(i,:);
                fprintf(file, '%s:\n', dataTypes(i));
                fprintf(file, '%g\n', data(1));
                fprintf(file, '%g\n', data(2));
                fprintf(file, '%g\n', data(3));     
                fprintf(file, '\n');
            end

            fprintf(file, '----------------\n');
            fprintf(file, 'In MMs:\n');
            fprintf(file, 'Median\nMean\nStandard devation\n\n');
            dataMatrix = [Converter.PixelsToMilimeters(h.Params.Diameter); 
                        Converter.PixelsToMilimeters(h.Params.ShortAxis); 
                        Converter.PixelsToMilimeters(h.Params.LongAxis); 
                        h.Params.Circularity; h.Params.Ratio];

            for i = 1 : size(dataMatrix, 1)
                data = dataMatrix(i,:);
                fprintf(file, '%s:\n', dataTypes(i));
                fprintf(file, '%g\n', data(1));
                fprintf(file, '%g\n', data(2));
                fprintf(file, '%g\n', data(3));     
                fprintf(file, '\n');
            end


            fprintf(file, '\n-----------------------------------------\n');
            fprintf(file, 'Granulometry data:\n');
            fprintf(file, '\n');
            fprintf(file, '< 0.5\t:\t%g\n', h.Params.Granulometry(1));
            fprintf(file, '0.5 >=\t:\t%g\n', h.Params.Granulometry(2));
            fprintf(file, '0.71 >=\t:\t%g\n', h.Params.Granulometry(3));
            fprintf(file, '1.0 >=\t:\t%g\n', h.Params.Granulometry(4));
            fprintf(file, '1.4 >=\t:\t%g\n', h.Params.Granulometry(5));
            fprintf(file, '2.0 >=\t:\t%g\n', h.Params.Granulometry(6));
            fprintf(file, '2.8 >=\t:\t%g\n', h.Params.Granulometry(7));
            fprintf(file, '4.0 >=\t:\t%g\n', h.Params.Granulometry(8));

            fclose(file);
        end

        % --- writes grains data to file
        function WriteGrainsToFile(obj, hObject)
            h = guidata(hObject);

            resultDirectory = obj.GetResultDirectory();
            fileName = Path.Combine(resultDirectory, 'data.xls');
            
            if isfile(fileName) 
                delete(fileName);
            end

            Index = [1:1:h.Params.Number].';
            EquivDiameter = h.Params.DiametersList.';
            Perimeter = h.Params.Perimeters.';
            Area = h.Params.Area.';
            MinorAxis = h.Params.ShortAxisList.';
            MajorAxis = h.Params.LongAxisList.';
            Circularity = h.Params.CircularityList.';
            T = table(Index, EquivDiameter, Perimeter, Area, MinorAxis, MajorAxis, Circularity);
            writetable(T, fileName);
        end
    end
end

