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

% Last Modified by GUIDE v2.5 24-Jun-2019 22:46:04

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
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bin_ui (see VARARGIN)
function bin_ui_OpeningFcn(hObject, eventdata, handles, varargin)
    handles = guidata(hObject);
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

    % UIWAIT makes main wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
function varargout = bin_ui_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


% hObject    handle to radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of radius as text
%        str2double(get(hObject,'String')) returns contents of radius as a double
function radius_Callback(hObject, eventdata, handles)
    set(handles.radius, 'String', str2double(get(handles.radius,'String')));


% --- Executes during object creation, after setting all properties.
% hObject    handle to radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
function radius_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in otsuThreshold.
% hObject    handle to otsuThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of otsuThreshold
function otsuThreshold_Callback(hObject, eventdata, handles)
    flag = get(hObject, 'Value');
    if flag == true
        set(handles.binThreshold, 'enable', 'off')
    else
        set(handles.binThreshold, 'enable', 'on')
    end


% --- Executes on button press in refresh_btn.
function refresh_btn_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);

    radius_Callback(@radius_Callback, eventdata, handles);

    fullPath = GetFullPath(handles.selectedImage, handles.imageStructs);
    
    radius = Get(handles.radius);
    
    if handles.binarizationFlag.Value
        BnarizationCallback(handles, fullPath, radius);

    elseif handles.cannyFlag.Value
        CannyCallback(handles, fullPath, radius);

    elseif handles.waterFlag.Value
        WatershedCallback(handles, fullPath, radius);
    end


% --- Executes on button press in binarizationFlag.
% hObject    handle to binarizationFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of binarizationFlag
function binarizationFlag_Callback(hObject, eventdata, handles)
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
% hObject    handle to cannyFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of cannyFlag    flag_value = get(hObject, 'Value');
function cannyFlag_Callback(hObject, eventdata, handles)
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
% hObject    handle to waterFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of waterFlag
function waterFlag_Callback(hObject, eventdata, handles)
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


% hObject    handle to lowThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of lowThresh as text
%        str2double(get(hObject,'String')) returns contents of lowThresh as a double
function lowThresh_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
% hObject    handle to lowThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
function lowThresh_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% hObject    handle to highThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of highThresh as text
%        str2double(get(hObject,'String')) returns contents of highThresh as a double
function highThresh_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
% hObject    handle to highThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
function highThresh_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in imagesPopupmenu.
% hObject    handle to imagesPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h         short for handles - structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns imagesPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imagesPopupmenu
function imagesPopupmenu_Callback(hObject, eventdata, h)
    h = guidata(hObject);
    contents = cellstr(get(h.imagesPopupmenu,'String'));
    h.selectedImage = contents{get(h.imagesPopupmenu, 'Value')};

    fullPath = GetFullPath(h.selectedImage, h.imageStructs);
    myImage = imread(fullPath);
    myImage = histeq(myImage);
    DisplayImage(myImage, h);
    guidata(hObject, h);


% --- Executes during object creation, after setting all properties.
% hObject    handle to imagesPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
function imagesPopupmenu_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on slider movement.
% hObject    handle to binThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
function binThreshold_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    sliderValue = get(handles.binThreshold,'Value');
    set(handles.binThreshValueText,'String', num2str(sliderValue));

    
% --- Executes during object creation, after setting all properties.
% hObject    handle to binThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
function binThreshold_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', [.9 .9 .9]);
    end


% hObject    handle to sigmaValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of sigmaValue as text
%        str2double(get(hObject,'String')) returns contents of sigmaValue as a double
function sigmaValue_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
% hObject    handle to sigmaValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
function sigmaValue_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% hObject    handle to waterSigmaValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of waterSigmaValue as text
%        str2double(get(hObject,'String')) returns contents of waterSigmaValue as a double
function waterSigmaValue_Callback(hObject, eventdata, handles)

    
% --- Executes during object creation, after setting all properties.
% hObject    handle to waterSigmaValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
function waterSigmaValue_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% hObject    handle to gradientThreshValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of gradientThreshValue as text
%        str2double(get(hObject,'String')) returns contents of gradientThreshValue as a double
function gradientThreshValue_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
% hObject    handle to gradientThreshValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
function gradientThreshValue_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% hObject    handle to gaussSigmaValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of gaussSigmaValue as text
%        str2double(get(hObject,'String')) returns contents of gaussSigmaValue as a double
function gaussSigmaValue_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
% hObject    handle to gaussSigmaValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
function gaussSigmaValue_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% hObject    handle to filterValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of filterValue as text
%        str2double(get(hObject,'String')) returns contents of filterValue as a double
function filterValue_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
% hObject    handle to filterValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
function filterValue_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% hObject    handle to waterLowThreshValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of waterLowThreshValue as text
%        str2double(get(hObject,'String')) returns contents of waterLowThreshValue as a double
function waterLowThreshValue_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
% hObject    handle to waterLowThreshValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
function waterLowThreshValue_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% hObject    handle to waterHighThreshValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of waterHighThreshValue as text
%        str2double(get(hObject,'String')) returns contents of waterHighThreshValue as a double
function waterHighThreshValue_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
% hObject    handle to waterHighThreshValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
function waterHighThreshValue_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% hObject    handle to sharpRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of sharpRadius as text
%        str2double(get(hObject,'String')) returns contents of sharpRadius as a double
function sharpRadius_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
% hObject    handle to sharpRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
function sharpRadius_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end





% --- CUSTOM FUNCTIONS ---

% --- returns full path for file struct
function path = GetFullPath(fileID, imageStructs)
    parts = strsplit(fileID, ' ');
    fileName = parts(length(parts));

    for ind=1:length(imageStructs)
        if char(fileName) == imageStructs(ind).name
            path = strcat(imageStructs(ind).folder, '\', imageStructs(ind).name);
            break;
        end
    end


% --- Disaplays image in axes.
function DisplayImage(myImage, h)
    set(h.display ,'Units','pixels');
    resizePos = get(h.display ,'Position');
    myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(h.display);
    imshow(myImage);
    set(h.display ,'Units','normalized');


% --- Calls Binarization with correct args
function BnarizationCallback(h, path, radius)
    if h.otsuThreshold.Value == false
        [resultImg, otsu] = Binarization(path, radius, h.binThreshold.Value);
    else
        [resultImg, otsu] = Binarization(path, radius);
    end    

    set(h.binThreshValueText, 'String', num2str(otsu));
    set(h.binThreshold, 'Value', otsu);
    DisplayImage(resultImg, h);


% --- Calls Canny with correct args
function CannyCallback(h, path, radius)
    [s1, low]   = TryGet(h.lowThresh,  @(low) 0 < low && low < 1, "Incorrect low value, should be: 0 < low < high < 1");
    [s2, high]  = TryGet(h.highThresh, @(high) 0 < high && low < high && high < 1, "Incorrect high value, should be: 0 < low < high < 1");
    [s3, sigma] = TryGet(h.sigmaValue, @(sigma) sigma > 0, "Sigma should be bigger than zero: sigma > 0");

    if s1 && s1 && s3
        resultImg = Canny(path, radius, [low, high], sigma);
    else
        return;
    end
    DisplayImage(resultImg, h);


% --- Calls Watershed with correct args
function WatershedCallback(h, path, radius)
    [s1, sharp_radius]    = TryGet(h.sharpRadius,          @(radius) radius > 0, "Sharpen Radius should be bigger than zero: radius > 0");
    [s2, low]             = TryGet(h.waterLowThreshValue,  @(low) 0 < low && low < 1, "Incorrect low value, should be: 0 < low < high < 1");
    [s3, high]            = TryGet(h.waterHighThreshValue, @(high) 0 < high && low < high && high < 1, "Incorrect high value, should be: 0 < low < high < 1");
    [s4, sigma]           = TryGet(h.waterSigmaValue,      @(sigma) sigma > 0, "Sigma should be bigger than zero: sigma > 0");
    [s5, gradient_thresh] = TryGet(h.gradientThreshValue,  @(gThresh) gThresh > 0, "Gradient threshold should be bigger than zero: radius > 0");
    [s6, gauss_sigma]     = TryGet(h.gaussSigmaValue,      @(gSigma) gSigma > 0, "Gaussian sigma should be bigger than zero: gSigma > 0");
    [s7, gauss_filter]    = TryGet(h.filterValue,          @(gFilter) mod(gFilter, 2) == 1, "Gaussian filter should be odd value");

    if s1 && s2 && s3 && s4 && s5 && s6 && s7
        resultImg = Watershed(path, radius, sharp_radius, [low, high], sigma, gradient_thresh, gauss_sigma, gauss_filter);
    else
        return;
    end
    DisplayImage(resultImg, h);


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
