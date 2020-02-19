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
    
    DisplayImage(h, imageInfo.GetImage());

    set(gcf,'WindowButtonDownFcn', @display_ButtonDownFcn)

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
    
    selectedImageInfo = h.imageInfoContainer.GetSelectedImageInfo();
    selectedImage = selectedImageInfo.GetImageGray();

    if h.binarizationFlag.Value
        h.method = "Binarization";
        h.ResultWriter = ResultWriter(selectedImageInfo.Path, h.method, h.saveStepsFlag.Value);
        resultImage = Binarization_Callback(h, selectedImage);

    elseif h.cannyFlag.Value
        h.method = "Canny";
        h.ResultWriter = ResultWriter(selectedImageInfo.Path, h.method, h.saveStepsFlag.Value);
        resultImage = Canny_Callback(h, selectedImage);

    elseif h.waterFlag.Value
        h.method = "Watershed";
        h.ResultWriter = ResultWriter(selectedImageInfo.Path, h.method, h.saveStepsFlag.Value);
        resultImage = Watershed_Callback(h, selectedImage);
    end


    guidata(hObject, h);

    resultImage = DeleteObjectsByDiameter(resultImage, Utils.GetValue(h.minDiameterVal), Utils.GetValue(h.maxDiameterVal));
    resultImage = DeleteObjectsByCircularity(resultImage, Utils.GetValue(h.circularityVal));
    
    if h.showOriginFlag.Value == false
        DisplayImage(h, resultImage);
    else
        DisplayImage(h, selectedImageInfo.GetImage());
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
    
    selectedImage = h.imageInfoContainer.GetSelectedImage();
    DisplayImage(h, selectedImage);
    guidata(hObject, h);



% --- CUSTOM FUNCTIONS ---

% --- Fits image to GUI axes
function resultImage = FitToAxes(h, image)
    set(h.display ,'Units','pixels');
    resizePos = get(h.display ,'Position');
    resultImage = imresize(image, [resizePos(3) resizePos(3)]);


% --- Disaplays image in axes.
function DisplayImage(h, image)
    image = FitToAxes(h, image);
    axes(h.display);
    imshow(image);
    set(h.display ,'Units','normalized');


% --- Calls Binarization with correct args
function resultImage = Binarization_Callback(h, image)

    radius = Utils.GetValue(h.radiusVal);
    
    if h.otsuFlag.Value == false
        [success, binThresh] = TryGet(h.binThVal, @(binTh) 0 < binTh && binTh < 1, "Binarization threshold should be between 0 and 1: 0 < binThresh < 1");
        
        if success == false
            return;        
        end

        opening_img = Opening(h.ResultWriter, image, radius);
        [resultImage, otsu] = Binarization(h.ResultWriter, opening_img, radius, binThresh);
    else

        opening_img = Opening(h.ResultWriter, image, radius);
        [resultImage, otsu] = Binarization(h.ResultWriter, opening_img);
    end    

    set(h.binThVal, 'String', num2str(otsu));


% --- Calls Canny with correct args
function resultImage = Canny_Callback(h, image)

    radius = Utils.GetValue(h.radiusVal);

    [success1, low]   = TryGet(h.lowThVal,  @(low) 0 < low && low < 1, "Incorrect low value, should be: 0 < low < high < 1");
    [success2, high]  = TryGet(h.highThVal, @(high) 0 < high && low < high && high < 1, "Incorrect high value, should be: 0 < low < high < 1");
    [success3, sigma] = TryGet(h.sigmaVal, @(sigma) sigma > 0, "Sigma should be bigger than zero: sigma > 0");

    if success1 && success2 && success3

        % open operation
        opening_img = Opening(h.ResultWriter, image, radius);
        resultImage = Canny(h.ResultWriter, opening_img, [low, high], sigma);
    else
        return;
    end


% --- Calls Watershed with correct args
function resultImage = Watershed_Callback(h, image)

    radius = Utils.GetValue(h.radiusVal);

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

        opening_img = Opening(h.ResultWriter, image, radius);
        [resultImage, otsu] = Watershed(h.ResultWriter, opening_img, sharpRadius, [low, high], sigma, gaussSigma, gaussFilter, binThresh);
    else

        opening_img = Opening(h.ResultWriter, image, radius);
        [resultImage, otsu] = Watershed(h.ResultWriter, opening_img, sharpRadius, [low, high], sigma, gaussSigma, gaussFilter);
    end

    set(h.binWaterThVal, 'String', num2str(otsu));


% --- Returns value with validation
function [success, value] = TryGet(handle, predicate, errMsg)
    value = Utils.GetValue(handle);
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


function resultImage = DeleteObjectsByDiameter(image, minDiameter, maxDiameter)
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
    DisplayImage(h, myImage);
    
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

    h.ResultWriter.WriteDataToFile(hObject);
    h.ResultWriter.WriteGrainsToFile(hObject);


function ShowOrigin_Callback(hObject, eventdata, h)

    resultImageExist = isfield(h, 'resultImage') && length(ishandle(h.resultImage)) > 0;

    if h.showOriginFlag.Value == false && resultImageExist
        DisplayImage(h, h.resultImage);
    else
        myImage = h.imageInfoContainer.GetSelectedImage();
        DisplayImage(h, myImage);
    end

    if resultImageExist
        DisplayContours(h.resultImage, h);
    end


function result = IsInBoundary(boundary, Point)
    result = inpolygon(Point(1, 1), Point(1, 2), boundary(:,2), boundary(:,1));


function result = IsAlreadySelected(h, index)
    result = any(h.SelectedGrain(:) == index);


function handle = UnSelectGrain(h, boundary, index)
    plot(h.display, boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
    h.SelectedGrain(h.SelectedGrain == index) = [];
    handle = h;


function handle = SelectGrain(h, boundary, index)
    h.SelectedGrain(length(h.SelectedGrain) + 1) = index;
    plot(h.display, boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2)
    handle = h;


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

            if IsInBoundary(boundary, Mouse)
                if IsAlreadySelected(h, i)
                    scale2 = resizePos(3) / 1024;
                    boundary = boundary.*scale2;
                    h = UnSelectGrain(h, boundary, i);
                    break;
                end
                
                hold on;

                scale2 = resizePos(3) / 1024;
                boundary = boundary.*scale2;

                h = SelectGrain(h, boundary, i);
            
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
        DisplayImage(h, myImage);
        h.displayContours = false;
    else
        h.displayContours = true;
        guidata(hObject, h);
        DisplayContours(h.resultImage, h);
    end

    guidata(hObject, h);
