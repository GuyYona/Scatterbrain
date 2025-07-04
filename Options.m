function varargout = Options(varargin)
% OPTIONS MATLAB code for Options.fig
%      OPTIONS, by itself, creates a new OPTIONS or raises the existing
%      singleton*.
%
%      H = OPTIONS returns the handle to a new OPTIONS or the handle to
%      the existing singleton*.
%
%      OPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPTIONS.M with the given input arguments.
%
%      OPTIONS('Property','Value',...) creates a new OPTIONS or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Options_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Options_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Options

% Last Modified by GUIDE v2.5 04-Jul-2025 11:42:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Options_OpeningFcn, ...
                   'gui_OutputFcn',  @Options_OutputFcn, ...
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

% --- Executes just before Options is made visible.
function Options_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Options (see VARARGIN)

% Choose default command line output for Options
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes Options wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Options_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in SaveParams.
function SaveParams_Callback(hObject, eventdata, handles)
% hObject    handle to SaveParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


ANGLE_RES = getappdata (handles.angle_res, 'angel_res');
max_z = getappdata (handles.max_z, 'max_z');
tissue_x = getappdata (handles.tissue_x, 'tissue_x');
time_p = getappdata (handles.max_t, 'time_p');
dt = getappdata (handles.dt, 'dt');
cross_section = getappdata (handles.cross_y, 'cross_section');

setappdata(0,'angle_res',ANGLE_RES);
% %export params to workspace
% assignin ('base', 'ANGLE_RES', ANGLE_RES);
% assignin ('base', 'max_z', max_z);
% assignin ('base', 'tissue_x', tissue_x);
% assignin ('base', 'time_p', time_p);
% assignin ('base', 'dt', dt);
% assignin ('base', 'cross_section', cross_section);

save ('params.mat','ANGLE_RES', 'tissue_x', 'time_p', 'dt');

delete(handles.figure1)


% --- Executes on button press in DefaulParams.
function DefaulParams_Callback(hObject, eventdata, handles)
% hObject    handle to DefaulParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

initialize_gui(gcbf, handles, true);

% --- Executes when selected object changed in GraphControl.
function GraphControl_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in GraphControl 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (hObject == handles.cross_y)
    cross_section=1;
else
    cross_section=0;

end

setappdata (handles.cross_y, 'cross_section', cross_section);


% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)


%show default values
set(handles.angle_res, 'String', 32);
set(handles.max_z,  'String', 700);
set(handles.tissue_x, 'String', 1200);
set(handles.max_t, 'String', 5);
set(handles.dt, 'String', 5);

set(handles.GraphControl, 'SelectedObject', handles.cross_y);

%save default values
setappdata (handles.angle_res, 'angel_res', 32);
setappdata (handles.max_z, 'max_z', 700);
setappdata (handles.tissue_x, 'tissue_x', 1200);
setappdata (handles.max_t, 'time_p', 5);
setappdata (handles.dt, 'dt', 5);
setappdata (handles.cross_y, 'cross_section', 1);


% Update handles structure
guidata(handles.figure1, handles);



% --- Executes during object creation, after setting all properties.
function angle_res_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angle_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function angle_res_Callback(hObject, eventdata, handles)
% hObject    handle to angle_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of angle_res as text
%        str2double(get(hObject,'String')) returns contents of angle_res as a double

angel_res= str2double(get(hObject, 'String'));
if isnan(angel_res)
    angel_res= 32;
end


setappdata (handles.angle_res, 'angel_res', angel_res);
guidata(hObject, handles);



function max_z_Callback(hObject, eventdata, handles)
% hObject    handle to max_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_z as text
%        str2double(get(hObject,'String')) returns contents of max_z as a double

max_z =  str2double(get(handles.max_z, 'string'));
if isnan(max_z)
    set(hObject, 'String', 700);
end


setappdata (handles.max_z, 'max_z', max_z);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function max_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tissue_x_Callback(hObject, eventdata, handles)
% hObject    handle to tissue_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tissue_x as text
%        str2double(get(hObject,'String')) returns contents of tissue_x as a double

tissue_x =  str2double(get(handles.tissue_x, 'string'));
if isnan(tissue_x)
    set(hObject, 'String', 1200);
end

setappdata (handles.tissue_x, 'tissue_x', tissue_x);
guidata(hObject, handles);

function tissue_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tissue_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_t_Callback(hObject, eventdata, handles)
% hObject    handle to max_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_t as text
%        str2double(get(hObject,'String')) returns contents of max_t as a double

time_p =  str2double(get(handles.max_t, 'string'));
if isnan(time_p)
    set(hObject, 'String', 5);
end


setappdata (handles.max_t, 'time_p', time_p);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function max_t_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dt_Callback(hObject, eventdata, handles)
% hObject    handle to dt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dt as text
%        str2double(get(hObject,'String')) returns contents of dt as a double

dt =  str2double(get(handles.dt, 'string'));
if isnan(dt)
    set(hObject, 'String', 5);
end


setappdata (handles.dt, 'dt', dt);
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function dt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
