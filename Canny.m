function resultImage = Canny(resultWriter, sourceImage, fileName, threshold, sigma)
    % change to grayscale for JPG
    if Path.IsJpgFile(fileName)
        sourceImage = rgb2gray(sourceImage);
    end
        
    % canny detection
    contoursImage = edge(sourceImage,'canny', threshold, sigma);
    
    % thinning edges
    contoursImage = bwmorph(contoursImage,'thin',Inf);

    resultWriter.SaveStepImage(contoursImage, "edge.png");
    
    % filling image
    contoursImage = Converter.BinaryToUint8(contoursImage);
    filledContoursImage = imfill(contoursImage);
    
    % open operation
    squareShapeKernel = strel('square', 2);
    resultImage = imopen(filledContoursImage, squareShapeKernel);

    resultWriter.SaveStepImage(resultImage, "result.png");
end