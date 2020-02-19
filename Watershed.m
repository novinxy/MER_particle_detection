function [resultImage, otsuThreshold] = Watershed(resultWriter, sourceImage, sharpenRadius, thresh, sigma, gaussianSigma, guassianFilter, otsuThreshold)
    
    % sharpening image
    if sharpenRadius ~= 0
        sharpenedImage = imsharpen(sourceImage, "Radius", sharpenRadius);
    else
        sharpenedImage = sourceImage;
    end

    % FIRST PARALLEL 
    % START

        % canny detection
        contoursImage = edge(sharpenedImage,'canny', thresh, sigma);
        contoursImage = Converter.BinaryToValues(contoursImage, sourceImage);

        resultWriter.SaveStepImage(contoursImage, "edge.png");

        % add edge to sharpened img
        addedContoursImage = sharpenedImage + contoursImage;

        resultWriter.SaveStepImage(addedContoursImage, "add.png");

        % gradient filtering
        [gradientImage, ~] = imgradient(addedContoursImage);
        gradientImage = rescale(gradientImage);
        resultWriter.SaveStepImage(gradientImage, "gradient.png");

    % FIRST PARALLEL 
    % END

    % SECOND PARALLEL 
    % START

        % binarization OTSU threshold
        if nargin < 9
            otsuThreshold = graythresh(sharpenedImage);
        end
        binaryImage = imbinarize(sharpenedImage, otsuThreshold);
        resultWriter.SaveStepImage(binaryImage, "bin.png");

        % filling holes
        binaryImage = Converter.BinaryToValues(binaryImage, sourceImage);
        filledHolesImage = imfill(binaryImage);
        resultWriter.SaveStepImage(filledHolesImage, "fill.png");

        % distance transform
        distanceTransformImage = rescale(bwdist(~filledHolesImage));

        % gaussian filtering
        gaussianFilteringImage = imgaussfilt(distanceTransformImage, gaussianSigma, 'FilterSize', guassianFilter);
        resultWriter.SaveStepImage(gaussianFilteringImage, "gaussian.png");

        % Finding markers(MS)/ extended maxima detection
        extendedMaximaImage = imextendedmax(gaussianFilteringImage, 0.001);
        resultWriter.SaveStepImage(extendedMaximaImage, "MAX.png");

    % SECOND PARALLEL 
    % END

    % adding two together
    combinedImage = imimposemin(gradientImage, extendedMaximaImage);
    resultWriter.SaveStepImage(combinedImage, "combined.png");
    
    % watershed
    watershedImage = watershed(combinedImage);
    watershedImage = Converter.BinaryToValues(watershedImage, sourceImage);

    % binarization OTSU threshold
    otsuThreshold = graythresh(watershedImage);
    binaryImage = imbinarize(watershedImage, otsuThreshold);

    % deleting border objects
    resultImage = imclearborder(binaryImage);
    resultImage = Converter.BinaryToValues(resultImage, sourceImage);

    resultImage = imfill(resultImage);
    resultWriter.SaveStepImage(resultImage, "result.png");
end
