% Begin initialization code - DO NOT EDIT
function varargout = bin_ui(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                    'gui_Singleton',  gui_Singleton, ...
                    'gui_OpeningFcn', @bin_ui_OpeningFcn, ...
                    'gui_OutputFcn',  @bin_ui_OutputFcn, ...
                    'gui_LayoutFcn',  [] , ...
                    'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT

% --- Executes just before bin_ui is made visible.
function bin_ui_OpeningFcn(hObject, ~, h, varargin)
    set(h.pixelsPanel,  'Visible', 'off');
    set(h.grainsPanel,  'Visible', 'off');
    set(h.metricsPanel, 'Visible', 'on');
    set(h.statsPanel,   'Visible', 'on');

    set(h.binarizationFlag, 'Value', true);
    BinarizationFlag_Callback(h);


    % -- distribution
    x = {'<0.5', '>0.5', '>0.7', '>1.0', '>1.4', '>2.0', '>2.8', '4.0'};
    axes(h.granulometric);
    y = [0 0 0 0 0 0 0 0];
    bar(y);
    set(gca,'YLim',[0 100]);
    set(gca,'xticklabel',x)

    rootDirectory = 'Images';
    searchPath = Path.Combine(rootDirectory, "**\*.*");
    fileList = Directory.GetFiles(searchPath);
    
    h.imageInfoContainer = ImageInfoContainer(fileList);

    set(h.otsuFlag,             'value', true);
    set(h.otsuWaterFlag,        'value', true);
    set(h.sharpenRadiusFlag,    'value', true);
    set(h.sharpRadiusVal,       'enable', 'on');
    set(h.binThVal,             'enable', 'off');
    set(h.binWaterThVal,        'enable', 'off');
    set(h.imagesList,           'string', h.imageInfoContainer.GetAllImageIdentifiers());

    h.SelectedGrain = [];
    h.GrainsDeletedManualy = 0;
    h.WellDetectedGrains = [];

    h.displayContours = true;

    imageInfo = h.imageInfoContainer.GetSelectedImageInfo();
    
    DisplayImage(imageInfo.GetImage(), h);

    set(gcf,'WindowButtonDownFcn',@display_ButtonDownFcn)

    h.ResultWriter = ResultWriter(imageInfo.Path, "Binarization", 0);


    % Choose default command line output for main
    h.output = hObject;
    
    % Update handles structure
    guidata(hObject, h);

    
% --- Outputs from this function are returned to the command line.
function varargout = bin_ui_OutputFcn(~, ~, h) 
    varargout{1} = h.output;
    

% --- Executes on button press in otsuFlag.
function OtsuFlag_Callback(hObject, ~, h)
    flag = get(hObject, 'Value');

    if flag == true
        set(h.binThVal, 'enable', 'off')
    else
        set(h.binThVal, 'enable', 'on')
    end


% --- Executes on button press in refreshBtn.
function RefreshBtn_Callback(hObject, ~)
    h = guidata(hObject);

    set(h.refreshBtn, 'BackgroundColor', [0.940000000000000	0.940000000000000	0.940000000000000]);

    cla;
    h.SelectedGrain = [];
    h.WellDetectedGrains = [];
    h.GrainsDeletedManualy = 0;
    

    guidata(hObject, h);
    
    fullPath = h.imageInfoContainer.GetSelectedImageInfo().Path;
    
    radius = GetValue(h.radiusVal);
    
    if h.binarizationFlag.Value
        h.method = "Binarization";
        h.ResultWriter = ResultWriter(fullPath, h.method, h.saveStepsFlag.Value);
        resultImage = Binarization_Callback(h, fullPath, radius);

    elseif h.cannyFlag.Value
        h.method = "Canny";
        h.ResultWriter = ResultWriter(fullPath, h.method, h.saveStepsFlag.Value);
        resultImage = Canny_Callback(h, fullPath, radius);

    elseif h.waterFlag.Value
        h.method = "Watershed";
        h.ResultWriter = ResultWriter(fullPath, h.method, h.saveStepsFlag.Value);
        resultImage = Watershed_Callback(h, fullPath, radius);
    end


    guidata(hObject, h);

    resultImage = DeleteObjectsBydiameter(resultImage, GetValue(h.minDiameterVal), GetValue(h.maxDiameterVal));
    resultImage = DeleteObjectsByCircularity(resultImage, GetValue(h.circularityVal));
    
    
    if h.showOriginFlag.Value == false
        DisplayImage(resultImage, h);
    else
        myImage = imread(fullPath);
        DisplayImage(myImage, h);
    end
    
    DisplayContours(resultImage, h);
    
    CalculateParams(resultImage, hObject);
    h = guidata(hObject);
    set(h.detectedCountVal, 'string', h.Params.Number);
    DisplayData(hObject);
    set(h.refreshBtn, 'BackgroundColor', [0.301960784313725	0.745098039215686	0.933333333333333]);


% --- Executes on button press in binarizationFlag.
function BinarizationFlag_Callback(h)
    if h.binarizationFlag.Value == true
        set(h.binPanel,         'Visible', 'on');
        set(h.cannyPanel,       'Visible', 'off');
        set(h.waterPanel,       'Visible', 'off');
        set(h.cannyFlag,        'Value', false);
        set(h.waterFlag,        'Value', false);
    end


% --- Executes on button press in cannyFlag.
function CannyFlag_Callback(h)
    if h.cannyFlag.Value == true
        set(h.cannyPanel,       'Visible', 'on');
        set(h.binPanel,         'Visible', 'off');
        set(h.waterPanel,       'Visible', 'off');
        set(h.binarizationFlag, 'Value', false);
        set(h.waterFlag,        'Value', false);
    end


% --- Executes on button press in waterFlag.
function WaterFlag_Callback(h)
    if h.waterFlag.Value == true
        set(h.waterPanel,       'Visible', 'on');
        set(h.binPanel,         'Visible', 'off');
        set(h.cannyPanel,       'Visible', 'off');
        set(h.cannyFlag,        'Value', false);
        set(h.binarizationFlag, 'Value', false);
        set(h.cannyFlag,        'Value', false);
    end


% --- Executes on selection change in imagesList.
function ImagesList_Callback(hObject, ~)
    h = guidata(hObject);
    contents = cellstr(get(h.imagesList,'String'));
    h.imageInfoContainer.SetSelectedImage(contents{get(h.imagesList, 'Value')});
    
    cla;
    
    myImage = h.imageInfoContainer.GetSelectedImage();
    DisplayImage(myImage, h);
    guidata(hObject, h);



% --- CUSTOM FUNCTIONS ---

% --- Fits image to GUI axes
function resultImage = FitToAxes(image, h)
    set(h.display ,'Units','pixels');
    resizePos = get(h.display ,'Position');
    resultImage = imresize(image, [resizePos(3) resizePos(3)]);


% --- Disaplays image in axes.
function DisplayImage(myImage, h)
    myImage = FitToAxes(myImage, h);
    axes(h.display);
    imshow(myImage);
    set(h.display ,'Units','normalized');


% --- Calls Binarization with correct args
function resultImage = Binarization_Callback(h, path, radius)
    if h.otsuFlag.Value == false
        [success, binThresh] = TryGet(h.binThVal, @(binTh) 0 < binTh && binTh < 1, "Binarization threshold should be between 0 and 1: 0 < binThresh < 1");
        
        if success == false
            return;        
        end

        image = imread(path);

        opening_img = Opening(h.ResultWriter, image, radius);
        [resultImage, otsu] = Binarization(h.ResultWriter, opening_img, path, radius, binThresh);
    else

        image = imread(path);

        opening_img = Opening(h.ResultWriter, image, radius);
        [resultImage, otsu] = Binarization(h.ResultWriter, opening_img, path);
    end    

    set(h.binThVal, 'String', num2str(otsu));


% --- Calls Canny with correct args
function resultImage = Canny_Callback(h, path, radius)
    [success1, low]   = TryGet(h.lowThVal,  @(low) 0 < low && low < 1, "Incorrect low value, should be: 0 < low < high < 1");
    [success2, high]  = TryGet(h.highThVal, @(high) 0 < high && low < high && high < 1, "Incorrect high value, should be: 0 < low < high < 1");
    [success3, sigma] = TryGet(h.sigmaVal, @(sigma) sigma > 0, "Sigma should be bigger than zero: sigma > 0");

    if success1 && success2 && success3

        image = imread(path);
        % open operation
        opening_img = Opening(h.ResultWriter, image, radius);
        resultImage = Canny(h.ResultWriter, opening_img, path, [low, high], sigma);
    else
        return;
    end


% --- Calls Watershed with correct args
function resultImage = Watershed_Callback(h, path, radius)
    [success1, sharpRadius]     = TryGet(h.sharpRadiusVal,     @(radius) radius >= 0, "Sharpen Radius should be bigger or equal to zero: radius >= 0");
    [success2, low]             = TryGet(h.waterLowThVal,      @(low) 0 < low && low < 1, "Incorrect low value, should be: 0 < low < high < 1");
    [success3, high]            = TryGet(h.waterHighThVal,     @(high) 0 < high && low < high && high < 1, "Incorrect high value, should be: 0 < low < high < 1");
    [success4, sigma]           = TryGet(h.waterSigmaVal,      @(sigma) sigma > 0, "Sigma should be bigger than zero: sigma > 0");
    [success5, gaussSigma]      = TryGet(h.gaussSigmaVal,      @(gSigma) gSigma > 0, "Gaussian sigma should be bigger than zero: gSigma > 0");
    [success6, gaussFilter]     = TryGet(h.filterVal,          @(gFilter) mod(gFilter, 2) == 1, "Gaussian filter should be odd value");
    
    if h.sharpenRadiusFlag.Value == false
        sharpRadius = 0;
    end
    
    if (success1 && success2 && success3 && success4 && success5 && success6) == false
        return;
    end
    
    if h.otsuWaterFlag.Value == false
        [success7, binThresh] = TryGet(h.binWaterThVal, @(binTh) 0 < binTh && binTh < 1, "Binarization threshold should be between 0 and 1: 0 < binThresh < 1");
        if success7 == false
            return;
        end

        image = imread(path);

        opening_img = Opening(h.ResultWriter, image, radius);
        [resultImage, otsu] = Watershed(h.ResultWriter, opening_img, path, sharpRadius, [low, high], sigma, gaussSigma, gaussFilter, binThresh);
    else

        image = imread(path);

        opening_img = Opening(h.ResultWriter, image, radius);
        [resultImage, otsu] = Watershed(h.ResultWriter, opening_img, path, sharpRadius, [low, high], sigma, gaussSigma, gaussFilter);
    end

    set(h.binWaterThVal, 'String', num2str(otsu));

% --- Returns double value from handle
function value = GetValue(handle)
    value = str2double(handle.String);


% --- Returns value with validation
function [success, value] = TryGet(handle, predicate, errMsg)
    value = GetValue(handle);
    set(handle, 'Backgroundcolor', 'w');

    if predicate(value)
        success = true;
    else
        success = false;
        set(handle, 'Backgroundcolor', 'r');
        uiwait(msgbox(errMsg));
    end


% --- Displays contours on scaled image
function DisplayContours(image, h)
    hold on;

    if h.displayContours == true
        [B, ~] = bwboundaries(image, 'noholes');
        
        set(h.display, 'Units', 'pixels');
        resizePos = get(h.display ,'Position');
        scale = resizePos(3) / 1024;

        for k = 1:length(B)
            boundary = B{k}.*scale;
            plot(h.display, boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
        end

        for i = h.WellDetectedGrains
            boundary = B{i}.*scale;
            plot(h.display, boundary(:,2), boundary(:,1),'g', 'LineWidth', 2)
        end

        for j = h.SelectedGrain
            boundary = B{j}.*scale;
            plot(h.display, boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2)
        end
    end


% --- calculates contours/grains parameters from image
function CalculateParams(img,  hObject)
    h = guidata(hObject);
    [B, L] = bwboundaries(img,'noholes');
    stats = regionprops(L,'Area','Centroid', 'MinorAxisLength', 'MajorAxisLength', 'EquivDiameter', 'Perimeter', 'Circularity');
    h.resultImage = img;

    % diameters
    diameters = [stats.EquivDiameter];
    diametersTable = [median(diameters) ...
                      mean(diameters) ...
                      std(diameters)];
    
    % short axis
    shortAxisTable = [median([stats.MinorAxisLength]) ...
                      mean([stats.MinorAxisLength]) ...
                      std([stats.MinorAxisLength])];
    
    % long axis
    longAxisTable = [median([stats.MajorAxisLength]) ...
                     mean([stats.MajorAxisLength]) ...
                     std([stats.MajorAxisLength])];
    
    % Circularity   
    circularityTable = [median([stats.Circularity]) ...
                        mean([stats.Circularity]) ...
                        std([stats.Circularity])];
    
    % aspect ratio
    ratios = [stats.MinorAxisLength]./[stats.MajorAxisLength];
    ratioTable = [median(ratios) ...
                  mean(ratios) ...
                  std(ratios)];
    
    h.Params.DiametersList = diameters;
    h.Params.Perimeters = [stats.Perimeter];
    h.Params.Area = [stats.Area];
    h.Params.ShortAxisList = [stats.MinorAxisLength];
    h.Params.LongAxisList = [stats.MajorAxisLength];
    h.Params.CircularityList = [stats.Circularity];
    h.Params.RatioList = ratios;
    h.Params.Number = size(stats, 1);
    h.Params.Diameter = diametersTable;
    h.Params.ShortAxis = shortAxisTable;
    h.Params.LongAxis = longAxisTable;
    h.Params.Circularity = circularityTable;
    h.Params.Ratio = ratioTable;

    % -- distribution
    x = {'<0.5', '>0.5', '>0.71', '>1.0', '>1.4', '>2.0', '>2.8', '4.0'};

    y = CreateBarsValues(Converter.PixelsToMilimeters(diameters));
    h.Params.Granulometry = [];
    h.Params.Granulometry = y;
    cla(h.granulometric);
    axes(h.granulometric);
    bar(y);
    set(gca,'xticklabel', x)

    guidata(hObject, h);


% --- Creates
function values = CreateBarsValues(diameters)
    values = zeros(1, 8);
    for i = 1 : length(diameters)
        if diameters(i) < 0.5
            values(1) = values(1) + 1;
            continue;
        end
        if diameters(i) >= 0.5 && diameters(i) < 0.71 
            values(2) = values(2) + 1;
            continue;
        end
        if diameters(i) >= 0.71 && diameters(i) < 1.0 
            values(3) = values(3) + 1;
            continue;
        end
        if diameters(i) >= 1.0 && diameters(i) < 1.4 
            values(4) = values(4) + 1;
            continue;
        end
        if diameters(i) >= 1.4 && diameters(i) < 2.0 
            values(5) = values(5) + 1;
            continue;
        end
        if diameters(i) >= 2.0 && diameters(i) < 2.8 
            values(6) = values(6) + 1;
            continue;
        end
        if diameters(i) >= 2.8 && diameters(i) < 4.0 
            values(7) = values(7) + 1;
            continue;
        end
        if diameters(i) >= 4.0 
            values(8) = values(8) + 1;
            continue;
        end
    end



% --- displays data about detected grains
function DisplayData(hObject)
    h = guidata(hObject);
    set(h.grainsNumVal, 'String', h.Params.Number);

    infoPixels = [h.Params.Diameter; 
                  h.Params.ShortAxis; 
                  h.Params.LongAxis; 
                  h.Params.Circularity; 
                  h.Params.Ratio];

    set(h.tablePixels, 'Data',  infoPixels);

    infoMetric = [Converter.PixelsToMilimeters(h.Params.Diameter); 
                  Converter.PixelsToMilimeters(h.Params.ShortAxis); 
                  Converter.PixelsToMilimeters(h.Params.LongAxis); 
                  h.Params.Circularity; h.Params.Ratio];

    set(h.tableMetrics, 'Data',  infoMetric);


% --- writes grains data to file
function WriteDataToFile(hObject, dataTypes)
    h = guidata(hObject);

    resultDirectory = h.ResultWriter.GetResultDirectory();
    fileName = Path.Combine(resultDirectory, 'log.txt');
    file = fopen(fileName, 'wt');

    splited = split(h.ImageInfoContainer.SelectedImage, ' ');
    imageName = splited(length(splited));

    fprintf(file, 'Image ID: %s\n', string(imageName)); 

    fprintf(file, 'Method: ');
    if h.binarizationFlag.Value
        fprintf(file, 'Binarization\n\n');
        fprintf(file, '----------------\n');
        fprintf(file, 'Method parameters:\n');
        fprintf(file, 'Opening radius: %g\n', GetValue(h.radiusVal));
        fprintf(file, 'Binarization threshold: %g\n', GetValue(h.binThVal));
                        
    elseif h.cannyFlag.Value
        fprintf(file, 'Canny edge detection\n');
        fprintf(file, '----------------\n');
        fprintf(file, 'Method parameters:\n');
        fprintf(file, 'Opening radius: %g\n', GetValue(h.radiusVal));
        fprintf(file, 'Low threshold: %g\n', GetValue(h.lowThVal));
        fprintf(file, 'High threshold: %g\n', GetValue(h.highThVal));
        fprintf(file, 'Sigma: %g\n', GetValue(h.sigmaVal));

    else h.waterFlag.Value
        fprintf(file, 'Watershed\n');
        fprintf(file, '----------------\n');
        fprintf(file, 'Method parameters:\n');
        fprintf(file, 'Opening radius: %g\n', GetValue(h.radiusVal));
        sharpRadius = GetValue(h.sharpRadiusVal);
        
        if h.sharpenRadiusFlag.Value == false
            sharpRadius = 0;
        end

        fprintf(file, 'Sharpening radius: %g\n', sharpRadius);
        fprintf(file, 'Low threshold: %g\n', GetValue(h.waterLowThVal));
        fprintf(file, 'High threshold: %g\n', GetValue(h.waterHighThVal));
        fprintf(file, 'Sigma: %g\n', GetValue(h.waterSigmaVal));
        fprintf(file, 'Gaussian filtering sigma: %g\n', GetValue(h.gaussSigmaVal));
        fprintf(file, 'Gaussian filtering size: %g\n', GetValue(h.filterVal));
        fprintf(file, 'Binarization threshold: %g\n', GetValue(h.binWaterThVal));
        
    end

    fprintf(file, '\n----------------\n');

    
    fprintf(file, 'Filtering:\n');
    fprintf(file, 'Min diameter: %g\n', GetValue(h.minDiameterVal));
    fprintf(file, 'Max diameter: %g\n', GetValue(h.maxDiameterVal));
    fprintf(file, 'Min circularity: %g\n\n', GetValue(h.circularityVal));
    
    fprintf(file, '\n----------------\n');
    fprintf(file, 'Num of manualy deleted grains: %g\n\n', h.GrainsDeletedManualy);

    fprintf(file, '\n----------------\n');
    fprintf(file, 'Number of detected grains: %g\n', GetValue(h.detectedCountVal));
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


% --- writes grains data to file
function WriteGrainsToFile(hObject)
    h = guidata(hObject);

    resultDirectory = h.ResultWriter.GetResultDirectory();
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


% --- Executes on button press in metric2PixelToggle.
function ToMetrics_Callback(hObject)
    h = guidata(hObject);
    set(h.pixelsPanel, 'Visible', 'off');
    set(h.metricsPanel, 'Visible', 'on');
    set(h.toMetricsButton, 'BackgroundColor', [0.301960784313725	0.745098039215686	0.933333333333333]);
    set(h.toPixelsButton, 'BackgroundColor', [0.940000000000000	0.940000000000000	0.940000000000000]);

    guidata(hObject, h);

function ToPixels_Callback(hObject)
    h = guidata(hObject);
    set(h.pixelsPanel, 'Visible', 'on');
    set(h.metricsPanel, 'Visible', 'off');
    set(h.toPixelsButton, 'BackgroundColor', [0.301960784313725	0.745098039215686	0.933333333333333]);
    set(h.toMetricsButton, 'BackgroundColor', [0.940000000000000	0.940000000000000	0.940000000000000]);

    guidata(hObject, h);


function resultImage = DeleteObjectsBydiameter(image, minDiameter, maxDiameter)
    resultImage = bwpropfilt(imbinarize(image), 'EquivDiameter', [Converter.MilimetersToPixels(minDiameter) Converter.MilimetersToPixels(maxDiameter)]);


function resultImage = DeleteObjectsByCircularity(image, minCircularity)
    [~, L] = bwboundaries(image,'noholes');
    stats = regionprops(L,'Circularity');

    circularity = [stats.Circularity];
    for i = length(circularity):-1:1
        if circularity(i) < minCircularity
            L(L==i) = 0;
        end
    end

    resultImage = L;


function resultImage = DeleteObjectByIndex(image, indexes)
    [~, L] = bwboundaries(image, 'noholes');

    for i = indexes
        L(L==i) = 0;
    end

    resultImage = L;


% --- Executes on button press in sharpenRadiusFlag.
function SharpenRadiusFlag_Callback(hObject)
    h = guidata(hObject);

    if h.sharpenRadiusFlag.Value == false
        set(h.sharpenRadiusFlag, 'value', false);
        set(h.sharpRadiusVal, 'enable', 'off');
    else
        set(h.sharpenRadiusFlag, 'value', true);
        set(h.sharpRadiusVal, 'enable', 'on');
    end

    guidata(hObject, h);


% --- Executes on button press in otsuFlag.
function OtsuWaterFlag_Callback(hObject, ~, h)
    flag = get(hObject, 'Value');
    if flag == true
        set(h.binWaterThVal, 'enable', 'off')
    else
        set(h.binWaterThVal, 'enable', 'on')
    end


% --- Executes on button press in statsButton.
function statsButton_Callback(~, ~, handles)
    set(handles.statsPanel, 'Visible', 'on');
    set(handles.grainsPanel, 'Visible', 'off');
    set(handles.statsButton, 'BackgroundColor', [0.301960784313725	0.745098039215686	0.933333333333333]);
    set(handles.grainsButton, 'BackgroundColor', [0.940000000000000	0.940000000000000	0.940000000000000]);



% --- Executes on button press in grainsButton.
function grainsButton_Callback(~, ~, handles)
    set(handles.statsPanel, 'Visible', 'off');
    set(handles.grainsPanel, 'Visible', 'on');
    set(handles.grainsButton, 'BackgroundColor', [0.301960784313725	0.745098039215686	0.933333333333333]);
    set(handles.statsButton, 'BackgroundColor', [0.940000000000000	0.940000000000000	0.940000000000000]);
   

% --- Executes during object creation, after setting all properties.
function grainDataTable_CreateFcn(hObject, eventdata, handles)
set(hObject, 'Data', cell(1));


% --- Executes on button press in deleteGrain.
function deleteGrain_Callback(hObject, ~, ~)
    h = guidata(hObject);
    
    h.WellDetectedGrains = [];
    
    myImage = h.imageInfoContainer.GetSelectedImage();
    DisplayImage(myImage, h);
    
    h.resultImage = DeleteObjectByIndex(h.resultImage, h.SelectedGrain);

    h.GrainsDeletedManualy = h.GrainsDeletedManualy + length(h.SelectedGrain);
    h.SelectedGrain = [];
    DisplayContours(h.resultImage, h);

    guidata(hObject, h);

    CalculateParams(h.resultImage, hObject);
    h = guidata(hObject);

    DisplayData(hObject);

    guidata(hObject, h);


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, h)
    h.ResultWriter.SaveImage(h.resultImage, "grains.png");
    
    F = getframe(h.display);
    Image = frame2im(F);
    
    h.ResultWriter.SaveImage(Image, "result_display.png");

    newfig1 = figure('Visible','off'); 
    copyobj(h.granulometric, newfig1);

    resultDirectory = h.ResultWriter.GetResultDirectory();
    saveas(newfig1, Path.Combine(resultDirectory, 'granulometry.png'),'png');

    WriteDataToFile(hObject, ["Diameter", "Short axis", "Long axis", "Circularity", "Aspect ratio"]);
    WriteGrainsToFile(hObject);


function ShowOrigin_Callback(hObject, eventdata, h)

    resultImageExist = isfield(h, 'resultImage') && length(ishandle(h.resultImage)) > 0;

    if h.showOriginFlag.Value == false && resultImageExist
        DisplayImage(h.resultImage, h);
    else
        myImage = h.imageInfoContainer.GetSelectedImage();
        DisplayImage(myImage, h);
    end

    if resultImageExist
        DisplayContours(h.resultImage, h);
    end


% --- Executes on mouse press over axes background.
function display_ButtonDownFcn(hObject, eventdata)
    h = guidata(hObject);

    set(h.display ,'Units','pixels');
    resizePos = get(h.display ,'Position');
    scale = 1024 / resizePos(3);

    Mouse = get(h.display, 'currentpoint');
    Mouse = Mouse.*scale;

    
    resultImageExist = isfield(h, 'resultImage') && ~isempty(ishandle(h.resultImage));

    if resultImageExist
        [B, ~] = bwboundaries(h.resultImage, 'noholes');

        for i = 1 : length(B)
            boundary = B{i};

            if inpolygon(Mouse(1, 1), Mouse(1, 2), boundary(:,2), boundary(:,1))
                if any(h.SelectedGrain(:) == i)

                    scale2 = resizePos(3) / 1024;
                    boundary = boundary.*scale2;

                    plot(h.display, boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
                    h.SelectedGrain(h.SelectedGrain == i) = [];
                    break;
                end
                
                hold on;

                scale2 = resizePos(3) / 1024;
                boundary = boundary.*scale2;

                h.SelectedGrain(length(h.SelectedGrain) + 1) = i;
                plot(h.display, boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2)
            
                diameter = Converter.PixelsToMilimeters(h.Params.DiametersList(i));
                shortAxis = Converter.PixelsToMilimeters(h.Params.ShortAxisList(i));
                longAxis = Converter.PixelsToMilimeters(h.Params.LongAxisList(i));
                circularity = h.Params.CircularityList(i);
                ratio = h.Params.RatioList(i);
                data = [diameter, shortAxis, longAxis, circularity, ratio];
                set(h.grainDataTable, 'Data',  data);
                break;
            end
        end
        
    end

    guidata(hObject, h);


% --- Executes on button press in wellDetectedButton.
function wellDetectedButton_Callback(hObject)
    h = guidata(hObject);
    
    h.WellDetectedGrains = cat(2, h.WellDetectedGrains, h.SelectedGrain);
    h.SelectedGrain = [];
    
    [B, ~] = bwboundaries(h.resultImage, 'noholes');
      
    set(h.display ,'Units','pixels');
    resizePos = get(h.display ,'Position');
    scale = resizePos(3) / 1024;

    for i = h.WellDetectedGrains
        boundary = B{i}.*scale;
        plot(h.display, boundary(:,2),boundary(:,1),'g','LineWidth',2)
    end
    

    set(h.deValue, 'string', length(h.WellDetectedGrains));

    guidata(hObject, h);

    CalculateParams(h.resultImage, hObject);
    h = guidata(hObject);

    DisplayData(hObject);

    guidata(hObject, h);


% --- Executes on button press in displayContoursCheckbox.
function displayContoursCheckbox_Callback(hObject, eventdata, h)
    toggleContours = get(hObject, 'Value');

    if toggleContours == 0
        cla(h.display);
        myImage = h.imageInfoContainer.GetSelectedImage();
        DisplayImage(myImage, h);
        h.displayContours = false;
    else
        h.displayContours = true;
        guidata(hObject, h);
        DisplayContours(h.resultImage, h);
    end

    guidata(hObject, h);
