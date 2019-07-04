% BIN_UI MATLAB code for bin_ui.fig
%      BIN_UI, by itself, creates a new BIN_UI or raises the existing
%      singleton*.
%
%      H = BIN_UI returns the handle to a new BIN_UI or the handle to
%      the existing singleton*.
%
%      BIN_UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BIN_UI.M with the given input arguments.
%
%      BIN_UI('Property','Value',...) creates a new BIN_UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bin_ui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bin_ui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bin_ui

% Last Modified by GUIDE v2.5 01-Jul-2019 22:29:01

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
function bin_ui_OpeningFcn(hObject, eventdata, handles, varargin)
    h = handles;

    set(h.binarizationFlag, 'Value', true);
    binarizationFlag_Callback(@binarizationFlag_Callback, eventdata, h);

    rootdir = 'Images';
    filelist = dir(fullfile(rootdir, '**\*.*'));  %get list of files and folders in any subfolder
    filelist = filelist(~[filelist.isdir]);  %remove folders from list

    h.imageStructs = filelist;

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

    % set(handles.imageList,'string', fileNames); 
    set(h.otsuThreshold, 'value', true);
    set(h.binThreshold, 'enable', 'off')
    set(h.imagesPopupmenu, 'string', fileNames);

    contents = cellstr(get(h.imagesPopupmenu,'String'));
    h.selectedImage = contents{get(h.imagesPopupmenu,'Value')};

    contents = cellstr(h.imagesPopupmenu.String);
    fileName = GetFullPath(char(contents(1)), h.imageStructs);
    
    myImage = imread(fileName);
    myImage = histeq(myImage);

    DisplayImage(myImage, h);

    % Choose default command line output for main
    h.output = hObject;

    % Update handles structure
    guidata(hObject, h);



% --- Outputs from this function are returned to the command line.
function varargout = bin_ui_OutputFcn(~, ~, handles) 
    varargout{1} = handles.output;


    % --- Executes during object creation, after setting all properties.
function imagesPopupmenu_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes during object creation, after setting all properties.
function gaussSigmaValue_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes during object creation, after setting all properties.
function filterValue_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function waterLowThreshValue_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes during object creation, after setting all properties.
function waterHighThreshValue_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes during object creation, after setting all properties.
function sharpRadius_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes during object creation, after setting all properties.
function binThreshold_CreateFcn(hObject, ~, ~)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', [.9 .9 .9]);
    end


% --- Executes during object creation, after setting all properties.
function sigmaValue_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    
% --- Executes during object creation, after setting all properties.
function waterSigmaValue_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes during object creation, after setting all properties.
function gradientThreshValue_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes during object creation, after setting all properties.
function radius_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes during object creation, after setting all properties.
function lowThresh_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes during object creation, after setting all properties.
function highThresh_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function radius_Callback(hObject, eventdata, handles)		
    set(handles.radius, 'String', str2double(get(handles.radius,'String')));

% --- Executes on button press in otsuThreshold.
function otsuThreshold_Callback(hObject, ~, handles)
    flag = get(hObject, 'Value');
    if flag == true
        set(handles.binThreshold, 'enable', 'off')
    else
        set(handles.binThreshold, 'enable', 'on')
    end

function lowThresh_Callback(hObject, eventdata, handles)		
function highThresh_Callback(hObject, eventdata, handles)		
function sigmaValue_Callback(hObject, eventdata, handles)		
function waterSigmaValue_Callback(hObject, eventdata, handles)
function gradientThreshValue_Callback(hObject, eventdata, handles)		
function gaussSigmaValue_Callback(hObject, eventdata, handles)		
function filterValue_Callback(hObject, eventdata, handles)		
function waterLowThreshValue_Callback(hObject, eventdata, handles)		
function sharpRadius_Callback(hObject, eventdata, handles)		
function saveStepsIMGs_Callback(hObject, eventdata, handles)		
function showOriginal_Callback(hObject, eventdata, handles)
function waterHighThreshValue_Callback(hObject, eventdata, handles)		






% --- Executes on button press in refresh_btn.
function refresh_btn_Callback(~, eventdata, h)

    radius_Callback(@radius_Callback, eventdata, h);

    fullPath = GetFullPath(h.selectedImage, h.imageStructs);
    
    radius = Get(h.radius);
    
    if h.binarizationFlag.Value
        result_image = BnarizationCallback(h, fullPath, radius);

    elseif h.cannyFlag.Value
        result_image = CannyCallback(h, fullPath, radius);

    elseif h.waterFlag.Value
        result_image = WatershedCallback(h, fullPath, radius);
    end
    
    if h.showOriginal.Value == false
        DisplayImage(result_image, h);
    else
        myImage = imread(fullPath);
        myImage = histeq(myImage);
        DisplayImage(myImage, h);
    end

    result_image = bwareaopen(result_image, 200);

    DisplayContours(result_image, h);
    CalculateParams(result_image, h);

    F = getframe(h.display);
    Image = frame2im(F);
    CreateDictionary(fullPath);
    imwrite(Image, Create_file_name(fullPath, "display"));
    

% --- Executes on button press in binarizationFlag.
function binarizationFlag_Callback(~, ~, handles)
    flag_value = handles.binarizationFlag.Value;
    if flag_value == true
        set(handles.lowThresh, 'enable', 'off');
        set(handles.highThresh, 'enable', 'off');
        set(handles.sigmaValue, 'enable', 'off');
        set(handles.otsuThreshold, 'enable', 'on');
        set(handles.binThreshold, 'enable', 'on');
        set(handles.binPanel, 'Visible', 'on');
        set(handles.cannyPanel, 'Visible', 'off');
        set(handles.waterPanel, 'Visible', 'off');
        set(handles.cannyFlag, 'Value', false);
        set(handles.waterFlag, 'Value', false);
    end


% --- Executes on button press in cannyFlag.
function cannyFlag_Callback(~, ~, handles)
    flag_value = handles.cannyFlag.Value;
    if flag_value == true
        set(handles.lowThresh, 'enable', 'on');
        set(handles.highThresh, 'enable', 'on');
        set(handles.sigmaValue, 'enable', 'on');
        set(handles.otsuThreshold, 'enable', 'off');
        set(handles.binThreshold, 'enable', 'off');
        set(handles.binPanel, 'Visible', 'off');
        set(handles.cannyPanel, 'Visible', 'on');
        set(handles.waterPanel, 'Visible', 'off');
        set(handles.binarizationFlag, 'Value', false);
        set(handles.waterFlag, 'Value', false);
    end


% --- Executes on button press in waterFlag.
function waterFlag_Callback(~, ~, handles)
    flag_value = handles.waterFlag.Value;
    if flag_value == true
        set(handles.lowThresh, 'enable', 'off');
        set(handles.highThresh, 'enable', 'off');
        set(handles.sigmaValue, 'enable', 'off');
        set(handles.otsuThreshold, 'enable', 'off');
        set(handles.binThreshold, 'enable', 'off');
        set(handles.binPanel, 'Visible', 'off');
        set(handles.cannyPanel, 'Visible', 'off');
        set(handles.waterPanel, 'Visible', 'on');
        set(handles.cannyFlag, 'Value', false);
        set(handles.binarizationFlag, 'Value', false);
        set(handles.cannyFlag, 'Value', false);
    end


% --- Executes on selection change in imagesPopupmenu.
function imagesPopupmenu_Callback(hObject, ~, ~)
    h = guidata(hObject);
    contents = cellstr(get(h.imagesPopupmenu,'String'));
    h.selectedImage = contents{get(h.imagesPopupmenu, 'Value')};

    fullPath = GetFullPath(h.selectedImage, h.imageStructs);
    myImage = imread(fullPath);
    myImage = histeq(myImage);
    DisplayImage(myImage, h);
    guidata(hObject, h);


% --- Executes on slider movement.
function binThreshold_Callback(hObject, ~, ~)
    handles = guidata(hObject);
    sliderValue = get(handles.binThreshold,'Value');
    set(handles.binThreshValueText,'String', num2str(sliderValue));


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
function result_image = FitToAxes(image, h)
    set(h.display ,'Units','pixels');
    resizePos = get(h.display ,'Position');
    result_image = imresize(image, [resizePos(3) resizePos(3)]);


% --- Disaplays image in axes.
function DisplayImage(myImage, h)
    myImage = FitToAxes(myImage, h);
    axes(h.display);
    imshow(myImage);
    set(h.display ,'Units','normalized');


% --- Calls Binarization with correct args
function resultImg = BnarizationCallback(h, path, radius)
    saveImgsflag = h.saveStepsIMGs.Value;

    if h.otsuThreshold.Value == false
        [resultImg, otsu] = Binarization(path, saveImgsflag, radius, h.binThreshold.Value);
    else
        [resultImg, otsu] = Binarization(path, saveImgsflag, radius);
    end    

    set(h.binThreshValueText, 'String', num2str(otsu));
    set(h.binThreshold, 'Value', otsu);


% --- Calls Canny with correct args
function resultImg = CannyCallback(h, path, radius)
    saveImgsflag = h.saveStepsIMGs.Value;

    [s1, low]   = TryGet(h.lowThresh,  @(low) 0 < low && low < 1, "Incorrect low value, should be: 0 < low < high < 1");
    [s2, high]  = TryGet(h.highThresh, @(high) 0 < high && low < high && high < 1, "Incorrect high value, should be: 0 < low < high < 1");
    [s3, sigma] = TryGet(h.sigmaValue, @(sigma) sigma > 0, "Sigma should be bigger than zero: sigma > 0");

    if s1 && s2 && s3
        resultImg = Canny(path, saveImgsflag, radius, [low, high], sigma);
    else
        return;
    end


% --- Calls Watershed with correct args
function resultImg = WatershedCallback(h, path, radius)
    saveImgsflag = h.saveStepsIMGs.Value;

    [s1, sharp_radius]    = TryGet(h.sharpRadius,          @(radius) radius > 0, "Sharpen Radius should be bigger than zero: radius > 0");
    [s2, low]             = TryGet(h.waterLowThreshValue,  @(low) 0 < low && low < 1, "Incorrect low value, should be: 0 < low < high < 1");
    [s3, high]            = TryGet(h.waterHighThreshValue, @(high) 0 < high && low < high && high < 1, "Incorrect high value, should be: 0 < low < high < 1");
    [s4, sigma]           = TryGet(h.waterSigmaValue,      @(sigma) sigma > 0, "Sigma should be bigger than zero: sigma > 0");
    [s5, gradient_thresh] = TryGet(h.gradientThreshValue,  @(gThresh) gThresh > 0, "Gradient threshold should be bigger than zero: radius > 0");
    [s6, gauss_sigma]     = TryGet(h.gaussSigmaValue,      @(gSigma) gSigma > 0, "Gaussian sigma should be bigger than zero: gSigma > 0");
    [s7, gauss_filter]    = TryGet(h.filterValue,          @(gFilter) mod(gFilter, 2) == 1, "Gaussian filter should be odd value");

    if s1 && s2 && s3 && s4 && s5 && s6 && s7
        resultImg = Watershed(path, saveImgsflag, radius, sharp_radius, [low, high], sigma, gradient_thresh, gauss_sigma, gauss_filter);
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
    

% --- calculates contours parameters from image
function CalculateParams(image, handles)
    [B, L] = bwboundaries(image,'noholes');
    stats = regionprops(L,'Area','Centroid', 'MinorAxisLength', 'MajorAxisLength');

    set(handles.grainsNumberValue, 'String', size(stats, 1));

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

    info = [diametersTable; shortAxisTable; longAxisTable; circularityTable; ratioTable];
    set(handles.tablePixels, 'Data',  info);
