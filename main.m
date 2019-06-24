function varargout = main(varargin)
    % MAIN MATLAB code for main.fig
    %      MAIN, by itself, creates a new MAIN or raises the existing
    %      singleton*.
    %
    %      H = MAIN returns the handle to a new MAIN or the handle to
    %      the existing singleton*.
    %
    %      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in MAIN.M with the given input arguments.
    %
    %      MAIN('Property','Value',...) creates a new MAIN or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before main_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to main_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help main

    % Last Modified by GUIDE v2.5 24-Jun-2019 19:27:58

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                    'gui_Singleton',  gui_Singleton, ...
                    'gui_OpeningFcn', @main_OpeningFcn, ...
                    'gui_OutputFcn',  @main_OutputFcn, ...
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
end

% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to main (see VARARGIN)

    handles = guidata(hObject);

    set(handles.binarizationFlag, 'Value', true);
    binarizationFlag_Callback(@binarizationFlag_Callback, eventdata, handles);

    rootdir = 'Images';
    filelist = dir(fullfile(rootdir, '**\*.*'));  %get list of files and folders in any subfolder
    filelist = filelist(~[filelist.isdir]);  %remove folders from list

    handles.imageStructs = filelist;

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
    set(handles.otsuThreshold, 'value', true);
    set(handles.binThreshold, 'enable', 'off')
    set(handles.imagesPopupmenu, 'string', fileNames);

    contents = cellstr(get(handles.imagesPopupmenu,'String'));
    handles.selectedImage = contents{get(handles.imagesPopupmenu,'Value')};

    contents = cellstr(handles.imagesPopupmenu.String);
    fileName = GetFullPath(char(contents(1)), handles.imageStructs);
    
    myImage = imread(fileName);
    myImage = histeq(myImage);

    DisplayImage(myImage, handles);

    % Choose default command line output for main
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes main wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

function radius_Callback(hObject, eventdata, handles)
    % hObject    handle to radius (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of radius as text
    %        str2double(get(hObject,'String')) returns contents of radius as a double
    set(handles.radius, 'String', Get(handles.radius));
end

% --- Executes during object creation, after setting all properties.
function radius_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to radius (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in refresh_btn.
function refresh_btn_Callback(hObject, eventdata, handles)
    % hObject    handle to refresh_btn (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    handles = guidata(hObject);

    radius_Callback(@radius_Callback, eventdata, handles);

    fullPath = GetFullPath(handles.selectedImage, handles.imageStructs);
    
    radius = Get(handles.radius);
    
    if handles.binarizationFlag.Value
        BnarizationCallback(handles, fullPath, radius);

    elseif handles.cannyFlag.Value
        CannyCallback(handles, fullPath, radius);

    elseif handles.watershedFlag.Value
        WatershedCallback(handles, fullPath, radius);
    end
end

% --- Executes on button press in otsuThreshold.
function otsuThreshold_Callback(hObject, eventdata, handles)
    % hObject    handle to otsuThreshold (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of otsuThreshold
    flag = get(hObject, 'Value');
    if flag == true
        set(handles.binThreshold, 'enable', 'off')
    else
        set(handles.binThreshold, 'enable', 'on')
    end
end

% --- Executes on button press in binarizationFlag.
function binarizationFlag_Callback(hObject, eventdata, handles)
    % hObject    handle to binarizationFlag (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of binarizationFlag
    flag_value = handles.binarizationFlag.Value;
    if flag_value == true
        set(handles.lowThresh, 'enable', 'off');
        set(handles.highThresh, 'enable', 'off');
        set(handles.sigmaValue, 'enable', 'off');
        set(handles.otsuThreshold, 'enable', 'on');
        set(handles.binThreshold, 'enable', 'on');
        set(handles.binPanel, 'Visible', 'on');
        set(handles.cannyPanel, 'Visible', 'off');
        set(handles.watershedPanel, 'Visible', 'off');
        set(handles.cannyFlag, 'Value', false);
        set(handles.watershedFlag, 'Value', false);
    end
end

% --- Executes on button press in cannyFlag.
function cannyFlag_Callback(hObject, eventdata, handles)
    % hObject    handle to cannyFlag (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of cannyFlag    flag_value = get(hObject, 'Value');
    flag_value = handles.cannyFlag.Value;
    if flag_value == true
        set(handles.lowThresh, 'enable', 'on');
        set(handles.highThresh, 'enable', 'on');
        set(handles.sigmaValue, 'enable', 'on');
        set(handles.otsuThreshold, 'enable', 'off');
        set(handles.binThreshold, 'enable', 'off');
        set(handles.binPanel, 'Visible', 'off');
        set(handles.cannyPanel, 'Visible', 'on');
        set(handles.watershedPanel, 'Visible', 'off');
        set(handles.binarizationFlag, 'Value', false);
        set(handles.watershedFlag, 'Value', false);
    end
end

function lowThresh_Callback(hObject, eventdata, handles)
    % hObject    handle to lowThresh (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of lowThresh as text
    %        str2double(get(hObject,'String')) returns contents of lowThresh as a double
end

% --- Executes during object creation, after setting all properties.
function lowThresh_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to lowThresh (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function highThresh_Callback(hObject, eventdata, handles)
    % hObject    handle to highThresh (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of highThresh as text
    %        str2double(get(hObject,'String')) returns contents of highThresh as a double
end

% --- Executes during object creation, after setting all properties.
function highThresh_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to highThresh (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on selection change in imagesPopupmenu.
function imagesPopupmenu_Callback(hObject, eventdata, handles)
    % hObject    handle to imagesPopupmenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns imagesPopupmenu contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from imagesPopupmenu

    handles = guidata(hObject);
    contents = cellstr(get(handles.imagesPopupmenu,'String'));
    handles.selectedImage = contents{get(handles.imagesPopupmenu,'Value')};

    fullPath = GetFullPath(handles.selectedImage, handles.imageStructs);
    myImage = imread(fullPath);
    myImage = histeq(myImage);
    DisplayImage(myImage, handles);
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function imagesPopupmenu_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to imagesPopupmenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on slider movement.
function binThreshold_Callback(hObject, eventdata, handles)
    % hObject    handle to binThreshold (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    handles = guidata(hObject);
    sliderValue = get(handles.binThreshold,'Value');
    set(handles.binThreshValueText,'String',num2str(sliderValue));
end

% --- Executes during object creation, after setting all properties.
function binThreshold_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to binThreshold (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

function sigmaValue_Callback(hObject, eventdata, handles)
    % hObject    handle to sigmaValue (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of sigmaValue as text
    %        str2double(get(hObject,'String')) returns contents of sigmaValue as a double
end

% --- Executes during object creation, after setting all properties.
function sigmaValue_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to sigmaValue (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in watershedFlag.
function watershedFlag_Callback(hObject, eventdata, handles)
    % hObject    handle to watershedFlag (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of watershedFlag
    flag_value = handles.watershedFlag.Value;
    if flag_value == true
        set(handles.lowThresh, 'enable', 'off');
        set(handles.highThresh, 'enable', 'off');
        set(handles.sigmaValue, 'enable', 'off');
        set(handles.otsuThreshold, 'enable', 'off');
        set(handles.binThreshold, 'enable', 'off');
        set(handles.binPanel, 'Visible', 'off');
        set(handles.cannyPanel, 'Visible', 'off');
        set(handles.watershedPanel, 'Visible', 'on');
        set(handles.cannyFlag, 'Value', false);
        set(handles.binarizationFlag, 'Value', false);
        set(handles.cannyFlag, 'Value', false);
    end
end

function waterSigmaValue_Callback(hObject, eventdata, handles)
    % hObject    handle to waterSigmaValue (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of waterSigmaValue as text
    %        str2double(get(hObject,'String')) returns contents of waterSigmaValue as a double
end

% --- Executes during object creation, after setting all properties.
function waterSigmaValue_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to waterSigmaValue (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function gradientThreshValue_Callback(hObject, eventdata, handles)
    % hObject    handle to gradientThreshValue (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of gradientThreshValue as text
    %        str2double(get(hObject,'String')) returns contents of gradientThreshValue as a double
end

% --- Executes during object creation, after setting all properties.
function gradientThreshValue_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to gradientThreshValue (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function gaussianSigmaValue_Callback(hObject, eventdata, handles)
    % hObject    handle to gaussianSigmaValue (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of gaussianSigmaValue as text
    %        str2double(get(hObject,'String')) returns contents of gaussianSigmaValue as a double
end

% --- Executes during object creation, after setting all properties.
function gaussianSigmaValue_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to gaussianSigmaValue (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function filterValue_Callback(hObject, eventdata, handles)
    % hObject    handle to filterValue (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of filterValue as text
    %        str2double(get(hObject,'String')) returns contents of filterValue as a double
end

% --- Executes during object creation, after setting all properties.
function filterValue_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to filterValue (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function waterLowThreshValue_Callback(hObject, eventdata, handles)
    % hObject    handle to waterLowThreshValue (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of waterLowThreshValue as text
    %        str2double(get(hObject,'String')) returns contents of waterLowThreshValue as a double
end

% --- Executes during object creation, after setting all properties.
function waterLowThreshValue_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to waterLowThreshValue (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function waterHighThreshValue_Callback(hObject, eventdata, handles)
    % hObject    handle to waterHighThreshValue (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of waterHighThreshValue as text
    %        str2double(get(hObject,'String')) returns contents of waterHighThreshValue as a double
end

% --- Executes during object creation, after setting all properties.
function waterHighThreshValue_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to waterHighThreshValue (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function sharpenRadius_Callback(hObject, eventdata, handles)
    % hObject    handle to sharpenRadius (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of sharpenRadius as text
    %        str2double(get(hObject,'String')) returns contents of sharpenRadius as a double
end

% --- Executes during object creation, after setting all properties.
function sharpenRadius_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to sharpenRadius (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
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
end

% --- Disaplays image in axes.
function DisplayImage(myImage, handles)
    set(handles.display ,'Units','pixels');
    resizePos = get(handles.display ,'Position');
    myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.display);
    imshow(myImage);
    set(handles.display ,'Units','normalized');
end

% --- Calls Binarization with correct args
function BnarizationCallback(handles, imagePath, radius)
    if handles.otsuThreshold.Value == false
        [resultImg, otsu] = Binarization(imagePath, radius, handles.binThreshold.Value);
    else
        [resultImg, otsu] = Binarization(imagePath, radius);
    end    

    set(handles.binThreshValueText, 'String', num2str(otsu));
    set(handles.binThreshold, 'Value', otsu);
    DisplayImage(resultImg, handles);
end

% --- Calls Canny with correct args
function CannyCallback(handles, imagePath, radius)
    low = Get(handles.lowThresh);
    high = Get(handles.highThresh);

    valid_thresholds = ValidateThresholds(handles.lowThresh, handles.highThresh);
    [success, sigma] = TryGet(handles.sigmaValue, @(x) x > 0);

    if valid_thresholds && success
        resultImg = Canny(imagePath, radius, [low, high], sigma);
    else
        return;
    end
    DisplayImage(resultImg, handles);
end

% --- Calls Watershed with correct args
function WatershedCallback(handles, imagePath, radius)
    low = Get(handles.waterLowThreshValue);
    high = Get(handles.waterHighThreshValue);
    sigma = Get(handles.waterSigmaValue);
    sharpen_radius = Get(handles.sharpenRadius);
    gradient_threshold = Get(handles.gradientThreshValue);
    gaussian_sigma = Get(handles.gaussianSigmaValue);
    guassian_filter = Get(handles.filterValue);

    valid_thresholds = ValidateThresholds(handles.waterLowThreshValue, handles.waterHighThreshValue);
    valid_sigma = LargerThanZero(handles.waterSigmaValue);
    valid_gaussian_sigma = LargerThanZero(handles.gaussianSigmaValue);
    valid_gaussian_filter = IsOddValue(handles.filterValue);
    

    if valid_thresholds && valid_sigma && valid_gaussian_sigma && valid_gaussian_filter
        resultImg = Watershed(imagePath, radius, sharpen_radius, [low, high], sigma, gradient_threshold, gaussian_sigma, guassian_filter);
    else
        return;
    end
    DisplayImage(resultImg, handles);
end

% --- Returns double value from handle
function value = Get(handle)
    value = str2double(handle.String);
end

function [success, value] = TryGet(handle, predicate)
    value = Get(handle);
    set(handle,'Backgroundcolor','w');
    if predicate(value)
        success = true;
    else
        success = false;
        set(handle,'Backgroundcolor','r');
        uiwait(msgbox(strcat(handle.Tag, ' must be odd value')));
    end
end

% --- Checks if value is odd number 
function result = IsOddValue(handle)
    value = Get(handle);
    set(handle,'Backgroundcolor','w');
    if mod(value, 2) == 1
        result = true;
    else
        result = false;
        set(handle,'Backgroundcolor','r');
        uiwait(msgbox(strcat(handle.TAG, ' must be odd value')));
    end
end

% --- Ensures that thresholds have correct values
function result = ValidateThresholds(lowThresh, highThresh)
    low = Get(lowThresh);
    high = Get(highThresh);

    set(lowThresh,'Backgroundcolor','w');
    set(highThresh,'Backgroundcolor','w');
    if 0 < low && low < high && high < 1
        result = true;
    else
        result = false;
        if low <= 0 || low >= high || low >= 1 || isnan(low)
            set(lowThresh,'Backgroundcolor','r');
        end
        if high <= 0 || high <= low || high >= 1 || isnan(high)
            set(highThresh,'Backgroundcolor','r');
        end
        uiwait(msgbox('Threshold must be [low high], where 0 < low < high < 1'));
    end
end

% --- Checks if value is bigger than 0
function result = LargerThanZero(value)
    set(value,'Backgroundcolor','w');
    if Get(value) > 0
        result = true;
    else
        result = false;
        set(value,'Backgroundcolor','r');
        uiwait(msgbox(strcat(value.Tag, ' must be positive')));
    end
end
