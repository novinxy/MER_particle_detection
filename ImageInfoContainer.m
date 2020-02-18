classdef ImageInfoContainer < handle
    properties
        ImageInfos = ImageInfo.empty;
        SelectedImage = "";
    end
    
    methods
        function obj = ImageInfoContainer(imageFileList)
            for ind=1:length(imageFileList)
                currentImageFile = imageFileList(ind);
                
                directory = Path.GetDirectoryName(currentImageFile);
                
                if contains(directory, 'sol')
                    category = directory;
                else
                    category = "";
                end
                obj.ImageInfos(ind) = ImageInfo(currentImageFile, category);
            end
            obj.SelectedImage = obj.ImageInfos(1).GetIndentifier();
        end
        
        function SetSelectedImage(obj, newSelectedImage)
            obj.SelectedImage = newSelectedImage;
        end

        function imageInfo = GetSelectedImageInfo(obj)
            imageInfo = obj.GetImageInfo(obj.SelectedImage);
        end

        function image = GetSelectedImage(obj)
            imageInfo = obj.GetSelectedImageInfo();
            image = imageInfo.GetImage();
        end

        function imageInfo = GetImageInfo(obj, identifier)
            for ind=1:length(obj.ImageInfos)
                currentImageInfo = obj.ImageInfos(ind);

                if strcmp(identifier, currentImageInfo.GetIndentifier())
                    imageInfo = currentImageInfo;
                    break;
                end
            end
        end

        function identifiers = GetAllImageIdentifiers(obj)
            for ind=1:length(obj.ImageInfos)
                currentImageInfo = obj.ImageInfos(ind);

                identifiers{ind} = currentImageInfo.GetIndentifier();
            end
        end
    end
end

