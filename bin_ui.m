function varargout = bin_ui(varargin)
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

    % Last Modified by GUIDE v2.5 22-Jun-2019 19:11:40

    % Begin initialization code - DO NOT EDIT
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
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to bin_ui (see VARARGIN)

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
    fileName = get_full_path(char(contents(1)), handles);
    
    myImage = imread(fileName);
    myImage = histeq(myImage);

    display_image(myImage, handles);

    % Choose default command line output for bin_ui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes bin_ui wait for user response (see UIRESUME)
    % uiwait(handles.figure1);

function fullPath = get_full_path(fileID, handles)
    parts = strsplit(fileID, ' ');
    fileName = parts(length(parts));

    imageStructs = handles.imageStructs;
    for ind=1:length(imageStructs)
        if char(fileName) == imageStructs(ind).name
            fullPath = strcat(imageStructs(ind).folder, '\', imageStructs(ind).name);
            break;
        end
    end


% --- Outputs from this function are returned to the command line.
function varargout = bin_ui_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;



function radius_Callback(hObject, eventdata, handles)
    % hObject    handle to radius (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of radius as text
    %        str2double(get(hObject,'String')) returns contents of radius as a double
    set(handles.radius, 'String', str2double(get(handles.radius,'String')));

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



% function threshold_Callback(hObject, eventdata, handles)
%     % hObject    handle to threshold (see GCBO)
%     % eventdata  reserved - to be defined in a future version of MATLAB
%     % handles    structure with handles and user data (see GUIDATA)

%     % Hints: get(hObject,'String') returns contents of threshold as text
%     %        str2double(get(hObject,'String')) returns contents of threshold as a double
%     % set(handles.threshold, 'String', str2double(get(handles.threshold,'String')));


% % --- Executes during object creation, after setting all properties.
% function threshold_CreateFcn(hObject, eventdata, handles)
%     % hObject    handle to threshold (see GCBO)
%     % eventdata  reserved - to be defined in a future version of MATLAB
%     % handles    empty - handles not created until after all CreateFcns called

%     % Hint: edit controls usually have a white background on Windows.
%     %       See ISPC and COMPUTER.
%     if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%         set(hObject,'BackgroundColor','white');
%     end

% --- disaplays image in axes.
function display_image(myImage, handles)
    set(handles.display ,'Units','pixels');
    resizePos = get(handles.display ,'Position');
    myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.display);
    imshow(myImage);
    set(handles.display ,'Units','normalized');


% --- Executes on button press in refresh_btn.
function refresh_btn_Callback(hObject, eventdata, handles)
    % hObject    handle to refresh_btn (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    handles = guidata(hObject);

    radius_Callback(@radius_Callback, eventdata, handles);

    fullPath = get_full_path(handles.selectedImage, handles);
    
    radius = str2double(handles.radius.String);
    
    if handles.binarizationFlag.Value == true
        if handles.otsuThreshold.Value == false
            [myImage, otsu] = Binarization(fullPath, radius, handles.binThreshold.Value);
        else
            [myImage, otsu] = Binarization(fullPath, radius);
        end    
    
        sliderValue = get(handles.binThreshold,'Value');
        set(handles.binThreshValueText,'String',num2str(otsu));
        set(handles.binThreshold,'Value',otsu);
        display_image(myImage, handles);
    elseif handles.cannyFlag.Value == true
        low = str2double(handles.lowThresh.String);
        high = str2double(handles.highThresh.String);
        sigma = str2double(handles.sigmaValue.String);
        [myImage] = Canny(fullPath, radius, [low, high], sigma);
    
        display_image(myImage, handles);
    end
    


% --- Executes on button press in otsuThreshold.
function otsuThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to otsuThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of otsuThreshold
    flag = get(hObject, 'Value');
    if flag == true
        % set(handles.binThreshold, 'Value', "");
        set(handles.binThreshold, 'enable', 'off')
    else
        set(handles.binThreshold, 'enable', 'on')
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



function lowThresh_Callback(hObject, eventdata, handles)
% hObject    handle to lowThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lowThresh as text
%        str2double(get(hObject,'String')) returns contents of lowThresh as a double


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



function highThresh_Callback(hObject, eventdata, handles)
% hObject    handle to highThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of highThresh as text
%        str2double(get(hObject,'String')) returns contents of highThresh as a double


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

    fullPath = get_full_path(handles.selectedImage, handles);
    myImage = imread(fullPath);
    myImage = histeq(myImage);
    display_image(myImage, handles);
    guidata(hObject, handles);


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


% --- Executes during object creation, after setting all properties.
function binThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function sigmaValue_Callback(hObject, eventdata, handles)
% hObject    handle to sigmaValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigmaValue as text
%        str2double(get(hObject,'String')) returns contents of sigmaValue as a double


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



function waterSigmaValue_Callback(hObject, eventdata, handles)
% hObject    handle to waterSigmaValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of waterSigmaValue as text
%        str2double(get(hObject,'String')) returns contents of waterSigmaValue as a double


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



function gradientThreshValue_Callback(hObject, eventdata, handles)
% hObject    handle to gradientThreshValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gradientThreshValue as text
%        str2double(get(hObject,'String')) returns contents of gradientThreshValue as a double


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



function gaussianSigmaValue_Callback(hObject, eventdata, handles)
% hObject    handle to gaussianSigmaValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gaussianSigmaValue as text
%        str2double(get(hObject,'String')) returns contents of gaussianSigmaValue as a double


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



function filterValue_Callback(hObject, eventdata, handles)
% hObject    handle to filterValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filterValue as text
%        str2double(get(hObject,'String')) returns contents of filterValue as a double


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



function waterLowThreshValue_Callback(hObject, eventdata, handles)
% hObject    handle to waterLowThreshValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of waterLowThreshValue as text
%        str2double(get(hObject,'String')) returns contents of waterLowThreshValue as a double


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



function waterHighThreshValue_Callback(hObject, eventdata, handles)
% hObject    handle to waterHighThreshValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of waterHighThreshValue as text
%        str2double(get(hObject,'String')) returns contents of waterHighThreshValue as a double


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



function sharpenRadius_Callback(hObject, eventdata, handles)
% hObject    handle to sharpenRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sharpenRadius as text
%        str2double(get(hObject,'String')) returns contents of sharpenRadius as a double


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
