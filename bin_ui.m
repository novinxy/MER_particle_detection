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
    h.metricFlag.Value = false;
    set(h.pixelsPanel, 'Visible', 'on');
    set(h.metricsPanel, 'Visible', 'off');

    set(h.binarizationFlag, 'Value', true);
    BinarizationFlag_Callback(h);

    axes(h.granulometric);
    set(h.granulometric.XLabel, 'String', 'Diameter [mm]');
    set(h.granulometric.YLabel, 'String', 'Cumulative [%]');
    set(gca,'XLim',[0 2],'YLim',[0 100]);

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
    set(h.binThVal, 'enable', 'off')
    set(h.imagesList, 'string', fileNames);

    contents = cellstr(get(h.imagesList,'String'));
    h.selectedImage = contents{get(h.imagesList,'Value')};

    contents = cellstr(h.imagesList.String);
    fileName = GetFullPath(char(contents(1)), h.imageStructs);
    
    myImage = imread(fileName);
    myImage = histeq(myImage);

    DisplayImage(myImage, h);

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
function RefreshBtn_Callback(hObject, h)
    h = guidata(hObject);
    fullPath = GetFullPath(h.selectedImage, h.imageStructs);
    
    radius = Get(h.radiusVal);
    
    CreateDictionary(fullPath);

    if h.binarizationFlag.Value
        resultImg = Binarization_Callback(h, fullPath, radius);

    elseif h.cannyFlag.Value
        resultImg = Canny_Callback(h, fullPath, radius);

    elseif h.waterFlag.Value
        resultImg = Watershed_Callback(h, fullPath, radius);
    end
    
    if h.showOriginFlag.Value == false
        DisplayImage(resultImg, h);
    else
        myImage = imread(fullPath);
        myImage = histeq(myImage);
        DisplayImage(myImage, h);
    end

    resultImg = bwareaopen(resultImg, 200);

    DisplayContours(resultImg, h);

    CalculateParams(resultImg, hObject);
    DisplayData(hObject);


    F = getframe(h.display);
    Image = frame2im(F);
    CreateDictionary(fullPath);
    imwrite(Image, Create_file_name(fullPath, "display"));

    WriteDataToFile(hObject, ["Diameter", "Short axis", "Long axis", "Circularity", "Aspect ratio"]);
%     guidata(hObject, h);


% --- Executes on button press in binarizationFlag.
function BinarizationFlag_Callback(h)
    flag_value = h.binarizationFlag.Value;
    if flag_value == true
        set(h.lowThVal, 'enable', 'off');
        set(h.highThVal, 'enable', 'off');
        set(h.sigmaVal, 'enable', 'off');
        set(h.otsuFlag, 'enable', 'on');
        set(h.binThVal, 'enable', 'on');
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
        set(h.lowThVal, 'enable', 'on');
        set(h.highThVal, 'enable', 'on');
        set(h.sigmaVal, 'enable', 'on');
        set(h.otsuFlag, 'enable', 'off');
        set(h.binThVal, 'enable', 'off');
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
        set(h.lowThVal, 'enable', 'off');
        set(h.highThVal, 'enable', 'off');
        set(h.sigmaVal, 'enable', 'off');
        set(h.otsuFlag, 'enable', 'off');
        set(h.binThVal, 'enable', 'off');
        set(h.binPanel, 'Visible', 'off');
        set(h.cannyPanel, 'Visible', 'off');
        set(h.waterPanel, 'Visible', 'on');
        set(h.cannyFlag, 'Value', false);
        set(h.binarizationFlag, 'Value', false);
        set(h.cannyFlag, 'Value', false);
    end


% --- Executes on selection change in imagesList.
function ImagesList_Callback(hObject, h)
    h = guidata(hObject);
    contents = cellstr(get(h.imagesList,'String'));
    h.selectedImage = contents{get(h.imagesList, 'Value')};
    
    fullPath = GetFullPath(h.selectedImage, h.imageStructs);
    myImage = imread(fullPath);
    myImage = histeq(myImage);
    DisplayImage(myImage, h);
    guidata(hObject, h);


% --- Executes on slider movement.
function BinThreshold_Callback(h)
    sliderValue = get(h.binThVal,'Value');
    set(h.binThValLbl,'String', num2str(sliderValue));


% --- CUSTOM FUNCTIONS ---

% --- returns full path for file struct
function path = GetFullPath(fileID, imageStructs)
    parts = strsplit(fileID, ' ');
    fileName = char(parts(length(parts)));

    for ind=1:length(imageStructs)
        if strcmp(fileName,imageStructs(ind).name)
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
        [resultImg, otsu] = Binarization(path, h.saveStepsFlag.Value, radius, h.binThVal.Value);
    else
        [resultImg, otsu] = Binarization(path, h.saveStepsFlag.Value, radius);
    end    

    set(h.binThValLbl, 'String', num2str(otsu));
    set(h.binThVal, 'Value', otsu);


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
    [s1, sharpRadius]    = TryGet(h.sharpRadiusVal,          @(radius) radius > 0, "Sharpen Radius should be bigger than zero: radius > 0");
    [s2, low]             = TryGet(h.waterLowThVal,  @(low) 0 < low && low < 1, "Incorrect low value, should be: 0 < low < high < 1");
    [s3, high]            = TryGet(h.waterHighThVal, @(high) 0 < high && low < high && high < 1, "Incorrect high value, should be: 0 < low < high < 1");
    [s4, sigma]           = TryGet(h.waterSigmaVal,      @(sigma) sigma > 0, "Sigma should be bigger than zero: sigma > 0");
    [s5, gradientThresh] = TryGet(h.gradientThVal,  @(gThresh) gThresh > 0, "Gradient threshold should be bigger than zero: radius > 0");
    [s6, gaussSigma]     = TryGet(h.gaussSigmaVal,      @(gSigma) gSigma > 0, "Gaussian sigma should be bigger than zero: gSigma > 0");
    [s7, gaussFilter]    = TryGet(h.filterVal,          @(gFilter) mod(gFilter, 2) == 1, "Gaussian filter should be odd value");

    if s1 && s2 && s3 && s4 && s5 && s6 && s7
        resultImg = Watershed(path, h.saveStepsFlag.Value, radius, sharpRadius, [low, high], sigma, gradientThresh, gaussSigma, gaussFilter);
    else
        return;
    end


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
    dispalyImage = FitToAxes(image, h);
    [B, ~] = bwboundaries(dispalyImage,'noholes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2),boundary(:,1),'r','LineWidth',2)
    end
    

% --- calculates contours/grains parameters from image
function CalculateParams(img,  hObject)
    h = guidata(hObject);
    [B, L] = bwboundaries(img,'noholes');
    stats = regionprops(L,'Area','Centroid', 'MinorAxisLength', 'MajorAxisLength');

    % diameters
    diameters = mean(transpose([stats.MajorAxisLength ;stats.MinorAxisLength]),2);
    diametersTable = [median(diameters) mean(diameters) std(diameters)];
    
    % short axis
    shortAxisTable = [median([stats.MinorAxisLength]) mean([stats.MinorAxisLength]) std([stats.MinorAxisLength])];
    
    % long axis
    longAxisTable = [median([stats.MajorAxisLength]) mean([stats.MajorAxisLength]) std([stats.MajorAxisLength])];
    
    % Circularity   
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
    
    circularityTable = [median(circularity) mean(circularity) std(circularity)];
    
    % aspect ratio
    ratios = [stats.MinorAxisLength]./[stats.MajorAxisLength];
    ratioTable = [median(ratios) mean(ratios) std(ratios)];
    
    h.Params.Number = size(stats, 1);
    h.Params.Diameter = diametersTable;
    h.Params.ShortAxis = shortAxisTable;
    h.Params.LongAxis = longAxisTable;
    h.Params.Circularity = circularityTable;
    h.Params.Ratio = ratioTable;



    % -- distribution
    pd = makedist('Normal');
    values = sort(Pixels2MM(diameters));
    y = cdf(pd, sort(Pixels2MM(diameters)));

    axes(h.granulometric);
    
    plot(values, y.*100);

    set(h.granulometric.XLabel, 'String', 'Diameter [mm]');
    set(h.granulometric.YLabel, 'String', 'Cumulative [%]');
    % set(gca,'XLim',[0 2],'YLim',[0 100]);
    set(gca,'XLim',[0 2]);


    fullPath = GetFullPath(h.selectedImage, h.imageStructs);
    F = getframe(h.granulometric);
    Image = frame2im(F);
    CreateDictionary(fullPath);
    imwrite(Image, Create_file_name(fullPath, "distribution"));

    % f = figure('visible','off');
    % copyobj(h.granulometric, f);
    % hgsave(f, 'myFigure.fig');

    % savefig([h.granulometric], Create_file_name(fullPath, "figure"));
    % saveas(h.granulometric, "myFigure.fig");


    guidata(hObject, h);


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
    scale = 0.034;
    convertedVaue = value.* scale;


% --- writes grains data to file
function WriteDataToFile(hObject, dataTypes)
    h = guidata(hObject);

    fullPath = GetFullPath(h.selectedImage, h.imageStructs);
    splited = split(Create_file_name(fullPath, "data"), '.');
    fileName = splited(1) + ".txt";
    file = fopen(fileName, 'wt');

    fprintf(file, 'Number of grains: %g\n', h.Params.Number);
    fprintf(file, '\nIn pixels:\n');
    dataMatrix = [h.Params.Diameter; h.Params.ShortAxis; h.Params.LongAxis; h.Params.Circularity; h.Params.Ratio];
    for i = 1 : size(dataMatrix, 1)
        data = dataMatrix(i,:);
        fprintf(file, '%s:\n', dataTypes(i));
        fprintf(file, '\tMedian: %g\n', data(1));
        fprintf(file, '\tMean: %g\n', data(2));
        fprintf(file, '\tStandard devation: %g\n', data(3));     
        fprintf(file, '\n');
    end

    fprintf(file, '\nIn MMs:\n');
    dataMatrix = [Pixels2MM(h.Params.Diameter); Pixels2MM(h.Params.ShortAxis); Pixels2MM(h.Params.LongAxis); h.Params.Circularity; h.Params.Ratio];
    for i = 1 : size(dataMatrix, 1)
        data = dataMatrix(i,:);
        fprintf(file, '%s:\n', dataTypes(i));
        fprintf(file, '\tMedian: %g\n', data(1));
        fprintf(file, '\tMean: %g\n', data(2));
        fprintf(file, '\tStandard devation: %g\n', data(3));     
        fprintf(file, '\n');
    end

    fclose(file);


% --- Executes on button press in metric2PixelToggle.
function Metric2PixelToggle_Callback(hObject, eventdata, handles)
    h = guidata(hObject);
    metric_value = h.metricFlag.Value;
    if metric_value == true
        h.metricFlag.Value = false;
        set(h.pixelsPanel, 'Visible', 'on');
        set(h.metricsPanel, 'Visible', 'off');
        set(h.metric2PixelToggle, 'String', 'Metrics');
    else
        h.metricFlag.Value = true;
        set(h.pixelsPanel, 'Visible', 'off');
        set(h.metricsPanel, 'Visible', 'on');
        set(h.metric2PixelToggle, 'String', 'Pixels');
    end

    guidata(hObject, h);
