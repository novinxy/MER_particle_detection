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
    set(h.pixelsPanel, 'Visible', 'off');
    set(h.metricsPanel, 'Visible', 'on');
    set(h.statsPanel, 'Visible', 'on');
    set(h.grainsPanel, 'Visible', 'off');

    set(h.binarizationFlag, 'Value', true);
    BinarizationFlag_Callback(h);


    % -- distribution
    pd = makedist('Normal');
    x = {'<0.5', '>0.5', '>0.7', '>1.0', '>1.4', '>2.0', '>2.8', '4.0'};
    axes(h.granulometric);
    y = [0 0 0 0 0 0 0 0];
    bar(y);
    set(gca,'YLim',[0 100]);
    set(gca,'xticklabel',x)

    rootdir = 'Images';
    filelist = dir(fullfile(rootdir, '**\*.*'));  %get list of files and folders in any subfolder
    filelist = filelist(~[filelist.isdir]);  %remove folders from list
    
    for ind=1:length(filelist)
        splitted = strsplit(filelist(ind).folder, '\');
        solFolder = splitted(length(splitted));
        if contains(solFolder, 'sol')
            fileName = strcat(solFolder, "    ", filelist(ind).name);
        else
            fileName = filelist(ind).name;
        end
        fileNames{ind} = fileName; %compile cell array of names.
    end
    
    h.imageStructs = filelist;
    set(h.otsuFlag, 'value', true);
    set(h.otsuWaterFlag, 'value', true);
    set(h.sharpenRadiusFlag, 'value', true);
    set(h.sharpRadiusVal, 'enable', 'on');
    set(h.binThVal, 'enable', 'off');
    set(h.binWaterThVal, 'enable', 'off');
    set(h.imagesList, 'string', fileNames);

    contents = cellstr(get(h.imagesList,'String'));
    h.selectedImage = contents{get(h.imagesList,'Value')};
    h.SelectedGrain = [];
    h.GrainsDeletedManualy = 0;
    h.WellDetectedGrains = [];

    contents = cellstr(h.imagesList.String);
    fileName = GetFullPath(char(contents(1)), h.imageStructs);
    
    myImage = imread(fileName);
    myImage = histeq(myImage);

    DisplayImage(myImage, h);

    set(gcf,'WindowButtonDownFcn',@display_ButtonDownFcn)
    
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

    h.SelectedGrain = [];
    h.WellDetectedGrains = [];
    guidata(hObject, h);
    fullPath = GetFullPath(h.selectedImage, h.imageStructs);
    
    radius = Get(h.radiusVal);
    
    if h.saveStepsFlag.Value
        CreateDictionary(fullPath);
    end

    if h.binarizationFlag.Value
        resultImg = Binarization_Callback(h, fullPath, radius);
        h.method = "Binarization";

    elseif h.cannyFlag.Value
        resultImg = Canny_Callback(h, fullPath, radius);
        h.method = "Canny";

    elseif h.waterFlag.Value
        resultImg = Watershed_Callback(h, fullPath, radius);
        h.method = "Watershed";
    end
    guidata(hObject, h);

    resultImg = DeleteObjectsBydiameter(resultImg, Get(h.minDiameterVal), Get(h.maxDiameterVal));
    resultImg = DeleteObjectsByCircularity(resultImg, Get(h.circularityVal));
    
    
    if h.showOriginFlag.Value == false
        DisplayImage(resultImg, h);
    else
        myImage = imread(fullPath);
        myImage = histeq(myImage);
        DisplayImage(myImage, h);
    end
    
    DisplayContours(resultImg, h);
    
    CalculateParams(resultImg, hObject);
    h = guidata(hObject);
    set(h.detectedCountVal, 'string', h.Params.Number);
    DisplayData(hObject);

%     guidata(hObject, h);


% --- Executes on button press in binarizationFlag.
function BinarizationFlag_Callback(h)
    flag_value = h.binarizationFlag.Value;
    if flag_value == true
        set(h.binPanel, 'Visible', 'on');
        set(h.cannyPanel, 'Visible', 'off');
        set(h.waterPanel, 'Visible', 'off');
        set(h.cannyFlag, 'Value', false);
        set(h.waterFlag, 'Value', false);
    end


% --- Executes on button press in cannyFlag.
function CannyFlag_Callback(h)
    flag_value = h.cannyFlag.Value;
    if flag_value == true
        set(h.binPanel, 'Visible', 'off');
        set(h.cannyPanel, 'Visible', 'on');
        set(h.waterPanel, 'Visible', 'off');
        set(h.binarizationFlag, 'Value', false);
        set(h.waterFlag, 'Value', false);
    end


% --- Executes on button press in waterFlag.
function WaterFlag_Callback(h)
    flag_value = h.waterFlag.Value;
    if flag_value == true
        set(h.binPanel, 'Visible', 'off');
        set(h.cannyPanel, 'Visible', 'off');
        set(h.waterPanel, 'Visible', 'on');
        set(h.cannyFlag, 'Value', false);
        set(h.binarizationFlag, 'Value', false);
        set(h.cannyFlag, 'Value', false);
    end


% --- Executes on selection change in imagesList.
function ImagesList_Callback(hObject, ~)
    h = guidata(hObject);
    contents = cellstr(get(h.imagesList,'String'));
    h.selectedImage = contents{get(h.imagesList, 'Value')};
    
    fullPath = GetFullPath(h.selectedImage, h.imageStructs);
    myImage = imread(fullPath);
    myImage = histeq(myImage);
    DisplayImage(myImage, h);
    guidata(hObject, h);



% --- CUSTOM FUNCTIONS ---

% --- returns full path for file struct
function path = GetFullPath(fileID, imageStructs)
    parts = strsplit(fileID, ' ');
    fileName = char(parts(length(parts)));

    for ind=1:length(imageStructs)
        if strcmp(fileName, imageStructs(ind).name)
            path = strcat(imageStructs(ind).folder, '\', imageStructs(ind).name);
            break;
        end
    end


% --- Fits image to GUI axes
function resultImg = FitToAxes(image, h)
    set(h.display ,'Units','pixels');
    resizePos = get(h.display ,'Position');
    resultImg = imresize(image, [resizePos(3) resizePos(3)]);


% --- Disaplays image in axes.
function DisplayImage(myImage, h)
    myImage = FitToAxes(myImage, h);
    axes(h.display);
    imshow(myImage);
    set(h.display ,'Units','normalized');


% --- Calls Binarization with correct args
function resultImg = Binarization_Callback(h, path, radius)
    if h.otsuFlag.Value == false
        [s, binThresh] = TryGet(h.binThVal,  @(binTh) 0 < binTh && binTh < 1, "Binarization threshold should be between 0 and 1: 0 < binThresh < 1");
        if s == false
            return;        
        end
        [resultImg, otsu] = Binarization(path, h.saveStepsFlag.Value, radius, binThresh);
    else
        [resultImg, otsu] = Binarization(path, h.saveStepsFlag.Value, radius);
    end    

    set(h.binThVal, 'String', num2str(otsu));


% --- Calls Canny with correct args
function resultImg = Canny_Callback(h, path, radius)
    [s1, low]   = TryGet(h.lowThVal,  @(low) 0 < low && low < 1, "Incorrect low value, should be: 0 < low < high < 1");
    [s2, high]  = TryGet(h.highThVal, @(high) 0 < high && low < high && high < 1, "Incorrect high value, should be: 0 < low < high < 1");
    [s3, sigma] = TryGet(h.sigmaVal, @(sigma) sigma > 0, "Sigma should be bigger than zero: sigma > 0");

    if s1 && s2 && s3
        resultImg = Canny(path, h.saveStepsFlag.Value, radius, [low, high], sigma);
    else
        return;
    end


% --- Calls Watershed with correct args
function resultImg = Watershed_Callback(h, path, radius)
    [s1, sharpRadius]     = TryGet(h.sharpRadiusVal,     @(radius) radius >= 0, "Sharpen Radius should be bigger or equal to zero: radius >= 0");
    [s2, low]             = TryGet(h.waterLowThVal,      @(low) 0 < low && low < 1, "Incorrect low value, should be: 0 < low < high < 1");
    [s3, high]            = TryGet(h.waterHighThVal,     @(high) 0 < high && low < high && high < 1, "Incorrect high value, should be: 0 < low < high < 1");
    [s4, sigma]           = TryGet(h.waterSigmaVal,      @(sigma) sigma > 0, "Sigma should be bigger than zero: sigma > 0");
    [s5, gaussSigma]      = TryGet(h.gaussSigmaVal,      @(gSigma) gSigma > 0, "Gaussian sigma should be bigger than zero: gSigma > 0");
    [s6, gaussFilter]     = TryGet(h.filterVal,          @(gFilter) mod(gFilter, 2) == 1, "Gaussian filter should be odd value");
    
    if h.sharpenRadiusFlag.Value == false
        sharpRadius = 0;
    end
    
    if (s1 && s2 && s3 && s4 && s5 && s6) == false
        return;
    end
    
    if h.otsuWaterFlag.Value == false
        [s7, binThresh] = TryGet(h.binWaterThVal, @(binTh) 0 < binTh && binTh < 1, "Binarization threshold should be between 0 and 1: 0 < binThresh < 1");
        if s7 == false
            return;
        end
        [resultImg, otsu] = Watershed(path, h.saveStepsFlag.Value, radius, sharpRadius, [low, high], sigma, gaussSigma, gaussFilter, binThresh);
    else
        [resultImg, otsu] = Watershed(path, h.saveStepsFlag.Value, radius, sharpRadius, [low, high], sigma, gaussSigma, gaussFilter);
    end

    set(h.binWaterThVal, 'String', num2str(otsu));

% --- Returns double value from handle
function value = Get(handle)
    value = str2double(handle.String);


% --- Returns value with validation
function [success, value] = TryGet(handle, predicate, errMsg)
    value = Get(handle);
    set(handle,'Backgroundcolor','w');
    if predicate(value)
        success = true;
    else
        success = false;
        set(handle,'Backgroundcolor','r');
        uiwait(msgbox(errMsg));
    end


% --- Displays contours on scaled image
function DisplayContours(image, h)
    hold on;
    % displayImage = FitToAxes(image, h);
    displayImage = image;
    [B, ~] = bwboundaries(displayImage,'noholes');
    
    
    set(h.display ,'Units','pixels');
    resizePos = get(h.display ,'Position');
    scale = resizePos(3) / 1024;

    for k = 1:length(B)
        boundary = B{k}.*scale;
        plot(boundary(:,2),boundary(:,1),'r','LineWidth',2)
    end

    for i = 1:length(h.SelectedGrain)
        boundary = B{h.SelectedGrain(i)}.*scale;
        plot(boundary(:,2),boundary(:,1),'b','LineWidth',2)
    end

    for i = 1:length(h.WellDetectedGrains)
        boundary = B{h.WellDetectedGrains(i)}.*scale;
        plot(boundary(:,2),boundary(:,1),'g','LineWidth',2)
    end



% --- calculates contours/grains parameters from image
function CalculateParams(img,  hObject)
    h = guidata(hObject);
    [B, L] = bwboundaries(img,'noholes');
    stats = regionprops(L,'Area','Centroid', 'MinorAxisLength', 'MajorAxisLength', 'EquivDiameter', 'Perimeter', 'Circularity');
    h.resultImage = img;

    % diameters
    diameters = [stats.EquivDiameter];
    diametersTable = [median(diameters) mean(diameters) std(diameters)];
    
    % short axis
    shortAxisTable = [median([stats.MinorAxisLength]) mean([stats.MinorAxisLength]) std([stats.MinorAxisLength])];
    
    % long axis
    longAxisTable = [median([stats.MajorAxisLength]) mean([stats.MajorAxisLength]) std([stats.MajorAxisLength])];
    
    % Circularity   
    circularityTable = [median([stats.Circularity]) mean([stats.Circularity]) std([stats.Circularity])];
    
    % aspect ratio
    ratios = [stats.MinorAxisLength]./[stats.MajorAxisLength];
    ratioTable = [median(ratios) mean(ratios) std(ratios)];
    
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
    pd = makedist('Normal');
    x = {'<0.5', '>0.5', '>0.71', '>1.0', '>1.4', '>2.0', '>2.8', '4.0'};

    y = CreateBarsValues(Pixels2MM(diameters));
    h.Params.Granulometry = y;
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

    infoPixels = [h.Params.Diameter; h.Params.ShortAxis; h.Params.LongAxis; h.Params.Circularity; h.Params.Ratio];
    set(h.tablePixels, 'Data',  infoPixels);

    infoMetric = [Pixels2MM(h.Params.Diameter); Pixels2MM(h.Params.ShortAxis); Pixels2MM(h.Params.LongAxis); h.Params.Circularity; h.Params.Ratio];
    set(h.tableMetrics, 'Data',  infoMetric);


% --- converts Pixels to MMs, value can be scalar or matrix
function convertedVaue = Pixels2MM(value)
    scale = 0.031;
    convertedVaue = value.* scale;


% --- converts MMs to Pixels, value can be scalar or matrix
function convertedVaue = MMs2Pixels(value)
    scale = 0.031;
    convertedVaue = value./ scale;


% --- writes grains data to file
function WriteDataToFile(hObject, dataTypes)
    h = guidata(hObject);

    fullPath = GetFullPath(h.selectedImage, h.imageStructs);
    splited = split(Create_file_name(fullPath, "log", h.method), '.');
    fileName = splited(1) + ".txt";
    file = fopen(fileName, 'wt');


    splited = split(h.selectedImage, ' ');
    imageName = splited(length(splited));
    fprintf(file, 'Image ID: %s\n', string(imageName)); 

    fprintf(file, 'Method: ');
    if h.binarizationFlag.Value
        fprintf(file, 'Binarization\n\n');
        fprintf(file, '----------------\n');
        fprintf(file, 'Method parameters:\n');
        fprintf(file, 'Opening radius: %g\n', Get(h.radiusVal));
        fprintf(file, 'Binarization threshold: %g\n', Get(h.binThVal));
                        
    elseif h.cannyFlag.Value
        fprintf(file, 'Canny edge detection\n');
        fprintf(file, '----------------\n');
        fprintf(file, 'Method parameters:\n');
        fprintf(file, 'Opening radius: %g\n', Get(h.radiusVal));
        fprintf(file, 'Low threshold: %g\n', Get(h.lowThVal));
        fprintf(file, 'High threshold: %g\n', Get(h.highThVal));
        fprintf(file, 'Sigma: %g\n', Get(h.sigmaVal));

    else h.waterFlag.Value
        fprintf(file, 'Watershed\n');
        fprintf(file, '----------------\n');
        fprintf(file, 'Method parameters:\n');
        fprintf(file, 'Opening radius: %g\n', Get(h.radiusVal));
        sharpRadius = Get(h.sharpRadiusVal);
        if h.sharpenRadiusFlag.Value == false
            sharpRadius = 0;
        end

        fprintf(file, 'Sharpening radius: %g\n', sharpRadius);
        fprintf(file, 'Low threshold: %g\n', Get(h.waterLowThVal));
        fprintf(file, 'High threshold: %g\n', Get(h.waterHighThVal));
        fprintf(file, 'Sigma: %g\n', Get(h.waterSigmaVal));
        fprintf(file, 'Gaussian filtering sigma: %g\n', Get(h.gaussSigmaVal));
        fprintf(file, 'Gaussian filtering size: %g\n', Get(h.filterVal));
        fprintf(file, 'Binarization threshold: %g\n', Get(h.binWaterThVal));
        
    end

    fprintf(file, '\n----------------\n');

    
    fprintf(file, 'Filtering:\n');
    fprintf(file, 'Min diameter: %g\n', Get(h.minDiameterVal));
    fprintf(file, 'Max diameter: %g\n', Get(h.maxDiameterVal));
    fprintf(file, 'Min circularity: %g\n\n', Get(h.circularityVal));
    
    fprintf(file, '\n----------------\n');
    fprintf(file, 'Num of manualy deleted grains: %g\n\n', h.GrainsDeletedManualy);

    fprintf(file, '\n----------------\n');
    fprintf(file, 'Number of detected grains: %g\n', Get(h.detectedCountVal));
    fprintf(file, 'Number of grains after filtering: %g\n', h.Params.Number);
    fprintf(file, 'Number of well detected grains: %g\n', length(h.WellDetectedGrains));

    fprintf(file, '\n----------------\n');
    fprintf(file, 'In pixels:\n');
    fprintf(file, 'Median\nMean\nStandard devation\n\n');
    dataMatrix = [h.Params.Diameter; h.Params.ShortAxis; h.Params.LongAxis; h.Params.Circularity; h.Params.Ratio];
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
    dataMatrix = [Pixels2MM(h.Params.Diameter); Pixels2MM(h.Params.ShortAxis); Pixels2MM(h.Params.LongAxis); h.Params.Circularity; h.Params.Ratio];
    for i = 1 : size(dataMatrix, 1)
        data = dataMatrix(i,:);
        fprintf(file, '%s:\n', dataTypes(i));
        fprintf(file, '%g\n', data(1));
        fprintf(file, '%g\n', data(2));
        fprintf(file, '%g\n', data(3));     
        fprintf(file, '\n');
    end

    x = {'<0.5', '>0.5', '>0.71', '>1.0', '>1.4', '>2.0', '>2.8', '4.0'};

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

    fullPath = GetFullPath(h.selectedImage, h.imageStructs);
    splited = split(Create_file_name(fullPath, "data", h.method), '.');
    fileName = splited(1) + ".xls";
    
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


function resultImg = DeleteObjectsBydiameter(image, minDiameter, maxDiameter)
    resultImg = bwpropfilt(imbinarize(image), 'EquivDiameter', [MMs2Pixels(minDiameter) MMs2Pixels(maxDiameter)]);


function resultImg = DeleteObjectsByCircularity(image, minCircularity)
    [B, L] = bwboundaries(image,'noholes');
    stats = regionprops(L,'Area');

    circularity = zeros(1, length(B));
    for k = 1:length(B)
        
        % obtain (X,Y) boundary coordinates corresponding to label 'k'
        boundary = B{k};
        
        % compute a simple estimate of the object's perimeter
        delta_sq = diff(boundary).^2;    
        perimeter = sum(sqrt(sum(delta_sq,2)));
        
        % obtain the area calculation corresponding to label 'k'
        area = stats(k).Area;
        
        % compute the roundness metric
        circularity(k) = 4*pi*area/perimeter^2;
    end

    for i = length(circularity):-1:1
        if circularity(i) < minCircularity
            B(i) = [];
            for x = 1:length(L)
                for y = 1:length(L)
                    if L(x ,y) == i
                        L(x,y) = 0;
                    end
                end
            end
        end
    end

    resultImg = L;


function resultImg = DeleteObjectByIndex(image, indexes)
    [~, L] = bwboundaries(image,'noholes');
    for x = 1:length(L)
        for y = 1:length(L)
            for i = 1:length(indexes)
                if L(x ,y) == indexes(i)
                    L(x,y) = 0;
                end
            end
        end
    end

    resultImg = L;


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
    
    fullPath = GetFullPath(h.selectedImage, h.imageStructs);
    h.WellDetectedGrains = [];
    
    myImage = imread(fullPath);
    myImage = histeq(myImage);
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
    fullPath = GetFullPath(h.selectedImage, h.imageStructs);
    CreateDictionary(fullPath);

    imwrite(h.resultImage, Create_file_name(fullPath, "grains", h.method));
    
    F = getframe(h.display);
    Image = frame2im(F);
    imwrite(Image, Create_file_name(fullPath, "result_display", h.method));

    newfig1 = figure('Visible','off'); 
    copyobj(h.granulometric, newfig1);
    saveas(newfig1, Create_file_name(fullPath, "granulometry", h.method),'jpg');

    WriteDataToFile(hObject, ["Diameter", "Short axis", "Long axis", "Circularity", "Aspect ratio"]);
    WriteGrainsToFile(hObject);


function ShowOrigin_Callback(hObject, eventdata, h)
    resultImageExist = isfield(h, 'resultImage') && length(ishandle(h.resultImage)) > 0;
    if h.showOriginFlag.Value == false && resultImageExist
        DisplayImage(h.resultImage, h);
    else
        fullPath = GetFullPath(h.selectedImage, h.imageStructs);
        myImage = imread(fullPath);
        myImage = histeq(myImage);
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

    p = get(h.display, 'currentpoint');
    p = p.*scale;

    resultImageExist = isfield(h, 'resultImage') && length(ishandle(h.resultImage)) > 0;
    if resultImageExist
        [B, ~] = bwboundaries(h.resultImage,'noholes');
        for i = 1 : length(B)
            if inpolygon(p(1, 1), p(1, 2), B{i}(:,2), B{i}(:,1))
                exist = false;
                for j = 1 : length(h.SelectedGrain)
                    if h.SelectedGrain(j) == i
                        h.SelectedGrain(j) = [];
                        exist = true;
                        break;
                    end
                end
                
                if ~exist
                    h.SelectedGrain(length(h.SelectedGrain) + 1) = i;
                end

                DisplayContours(h.resultImage, h);
            
                diameter = Pixels2MM(h.Params.DiametersList(i));
                shortAxis = Pixels2MM(h.Params.ShortAxisList(i));
                longAxis = Pixels2MM(h.Params.LongAxisList(i));
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
function wellDetectedButton_Callback(hObject, eventdata, handles)
    h = guidata(hObject);
    
    fullPath = GetFullPath(h.selectedImage, h.imageStructs);
    
    myImage = imread(fullPath);
    myImage = histeq(myImage);
    DisplayImage(myImage, h);
    

    h.WellDetectedGrains = cat(2, h.WellDetectedGrains, h.SelectedGrain);

    h.SelectedGrain = [];
    DisplayContours(h.resultImage, h);

    set(h.deValue, 'string', length(h.WellDetectedGrains));

    guidata(hObject, h);

    CalculateParams(h.resultImage, hObject);
    h = guidata(hObject);

    DisplayData(hObject);

    guidata(hObject, h);