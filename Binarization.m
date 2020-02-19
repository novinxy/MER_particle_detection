function [resultImage, thresholdLevel] = Binarization(resultWriter, sourceImage, thresholdLevel)

    % binarization OTSU threshold
    if nargin < 4
        thresholdLevel = graythresh(sourceImage);
    end

    binaryImage = imbinarize(sourceImage, thresholdLevel);

    % filling holes
    binaryImage = Converter.BinaryToUint8(binaryImage);
    filledImage = imfill(binaryImage);

    % deleting border objects
    resultImage = imclearborder(filledImage);

    % log step
    resultWriter.SaveStepImage(resultImage, "bin.png");
end
