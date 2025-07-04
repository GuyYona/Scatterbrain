function varargout = ScatterBrain(varargin)
% SCATTERBRAIN MATLAB code for ScatterBrain.fig


% Last Modified by GUIDE v2.5 04-Jul-2025 11:38:57

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ScatterBrain_OpeningFcn, ...
                   'gui_OutputFcn',  @ScatterBrain_OutputFcn, ...
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


% --- Executes just before ScatterBrain is made visible.
function ScatterBrain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user run (see GUIDATA)
% varargin   command line arguments to ScatterBrain (see VARARGIN)


% Choose default command line output for ScatterBrain
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ScatterBrain wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ScatterBrain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user run (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user run (see GUIDATA)

aperture_radius = 0;
cla;

fib_radius = getappdata (handles.radius, 'radius');
if isempty(fib_radius)
    fib_radius = 100;
    set(handles.radius,'string',num2str(fib_radius));
end

NA = getappdata (handles.NA, 'NA');
if isempty(NA)
    NA = 0.37;
    set(handles.NA,'string',num2str(NA));
end

g = getappdata (handles.anisotropy, 'anisotropy');
if isempty(g)
    g = 0.86;
    set(handles.anisotropy,'string',num2str(g));
end

b = getappdata (handles.scatter, 'scatter');
if isempty(b)
    b = 211;
    set(handles.scatter,'string',num2str(b));
end

a = getappdata (handles.absorb, 'absorb');
if isempty(a)
    a = 0;
    set(handles.absorb,'string',num2str(a));
end

n = getappdata (handles.refract, 'refract');
if isempty(n)
    n = 1.36;
    set(handles.refract,'string',num2str(n));
end

x_c = getappdata(handles.xc, 'x');
y_c = getappdata(handles.yc, 'y');
z_c = getappdata(handles.zc, 'z');

%updating max_z
if exist('max_z')
    max_z = evalin('base', 'max_z');
else
    max_z = 700; % um
end

%output is light intensity in the tissue sample at [x,y,z]
%coordinates should be translated to correct axis and quantized to light
%sampleing in dx,dy,dz.


if abs(x_c) > 500 
    errordlg ('x should be an integer between -500 to 500');
    waitfor (handles.xc);
end
if isempty(x_c)
    errordlg ('please insert x coordinate');
    waitfor (handles.xc);
end


if abs(y_c) > 500
    errordlg ('y should be an integer between -500 to 500');
    waitfor (handles.yc);
end
if isempty(y_c)
    errordlg('please insert y coordinate');
    waitfor (handles.xc);
end

if abs(z_c) > max_z
    errordlg ('z should be smaller then max z');
    waitfor (handles.zc);
end
if isempty(z_c)
    errordlg('please insert z coordinate');
    waitfor (handles.xc);
end

%running BSF


[out_z, out] = Calc_BSF_GUI(a/10000,b/10000,g,n,NA,fib_radius,aperture_radius,max_z);
out = out/max(max(max(out)));     % normalization


dx = evalin('base', 'dx');
dz = evalin('base', 'dz');
tis_x = evalin('base', 'tis_x');
tis_y = evalin('base', 'tis_y');
tis_z = evalin('base', 'tis_z');

assignin ('base', 'out_z', out_z);
assignin ('base', 'out', out);

% quantization: x=x_c/dx
% axis change x=x+tis_x/2
x = ceil((x_c/dx)+tis_x/2); 
y = ceil((y_c/dx)+tis_y/2);
z = ceil(z_c/dz);

if z_c<dz
    z_c=dz;
end

LightI = out(x,y,z);
set(handles.intensityresult,'string',num2str(LightI));

%plotting Intensity figure

if exist ('cross_section')
    cross_section = evalin('base', 'cross_section');
else
    cross_section=1;
end

axes(handles.axes1);
if cross_section
    imagesc((-tis_x*dx/2:dx:tis_x*dx/2),(0:dz:tis_z*dz),...
        log10(squeeze(out(:,y,:))'/max(max(max(out)))),[-9,0]);
    title(['Light intensity map (cross section at y=',num2str(y_c),' \mum)'],'FontSize',12);
    hold on
    scatter(x_c, z_c,'wd');
    hold off
else
    imagesc((-tis_y*dx/2:dx:tis_y*dx/2),(0:dz:tis_z*dz),...
        log10(squeeze(out(x,:,:))'/max(max(max(out)))),[-9,0]);
    title(['Light intensity map (cross section at x=',num2str(y_c),' \mum)'],'FontSize',12);

    hold on
    scatter(y_c, z_c,'wd');
    hold off
end

xlabel('Tissue width [\mum]','FontSize',11); ylabel('Tissue depth [ \mum]','FontSize',11);
xlim([-300 300]); 
ylim([0 500]); 

save('out.mat','out');
save('out_z.mat','out_z');
   
function radius_Callback(hObject, eventdata, handles)
% hObject    handle to radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user run (see GUIDATA)

% Hints: get(hObject,'String') returns contents of radius as text
%        str2double(get(hObject,'String')) returns contents of radius as a double

radius =  str2double(get(handles.radius, 'string'));

if isnan(radius)
    radius=100; %um
end

setappdata (handles.radius, 'radius', radius);

guidata(hObject, handles);

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



function NA_Callback(hObject, eventdata, handles)
% hObject    handle to NA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user run (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NA as text
%        str2double(get(hObject,'String')) returns contents of NA as a double


NA = str2double(get(handles.NA, 'string'));
if isnan(NA)
    NA=0.37;
end

setappdata (handles.NA, 'NA', NA);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function NA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function xc_Callback(hObject, eventdata, handles)
% hObject    handle to xc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user run (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xc as text
%        str2double(get(hObject,'String')) returns contents of xc as a double


x = str2double(get(handles.xc, 'string'));
setappdata (handles.xc, 'x', x);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function xc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yc_Callback(hObject, eventdata, handles)
% hObject    handle to yc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user run (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yc as text
%        str2double(get(hObject,'String')) returns contents of yc as a double

y =  str2double(get(handles.yc, 'string'));
setappdata (handles.yc, 'y', y);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function yc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zc_Callback(hObject, eventdata, handles)
% hObject    handle to zc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user run (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zc as text
%        str2double(get(hObject,'String')) returns contents of zc as a double

z = str2double(get(handles.zc, 'string'));
setappdata (handles.zc, 'z', z);

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function zc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function absorb_Callback(hObject, eventdata, handles)
% hObject    handle to absorb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of absorb as text
%        str2double(get(hObject,'String')) returns contents of absorb as a double


absorb =  str2double(get(handles.absorb, 'string'));
if isnan(absorb)
    absorb=0;
end

setappdata (handles.absorb, 'absorb', absorb);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function absorb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to absorb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function anisotropy_Callback(hObject, eventdata, handles)
% hObject    handle to anisotropy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of anisotropy as text
%        str2double(get(hObject,'String')) returns contents of anisotropy as a double


anisotropy =  str2double(get(handles.anisotropy, 'string'));
if isnan(anisotropy)
    anisotropy=0.86;
end

setappdata (handles.anisotropy, 'anisotropy', anisotropy);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function anisotropy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to anisotropy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function scatter_Callback(hObject, eventdata, handles)
% hObject    handle to scatter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scatter as text
%        str2double(get(hObject,'String')) returns contents of scatter as a double

scatter =  str2double(get(handles.scatter, 'string'));
if isnan(scatter)
    scatter=0.0210;
end

setappdata (handles.scatter, 'scatter', scatter);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function scatter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scatter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function refract_Callback(hObject, eventdata, handles)
% hObject    handle to refract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of refract as text
%        str2double(get(hObject,'String')) returns contents of refract as a double


refract = str2double(get(handles.refract, 'string'));
if isnan(refract)
    refract=1.36;
end

setappdata (handles.refract, 'refract', refract);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function refract_CreateFcn(hObject, eventdata, handles)
% hObject    handle to refract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function intensityresult_Callback(hObject, eventdata, handles)
% hObject    handle to intensityresult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intensityresult as text
%        str2double(get(hObject,'String')) returns contents of intensityresult as a double


% --- Executes during object creation, after setting all properties.
function intensityresult_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intensityresult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MoreOptions.
function MoreOptions_Callback(hObject, eventdata, handles)
% hObject    handle to MoreOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Get the current position of the GUI from the handles structure
% to pass to the MoreOptions.
pos_size = get(handles.figure1,'Position');

% Call modaldlg with the argument 'Position'.
user_response = Options('Title','More Options');


% --- Executes on button press in pushbutton_about.
function pushbutton_about_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
about;


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over radius.
function radius_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'enable','on');
set(hObject,'string','');


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over NA.
function NA_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to NA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'enable','on');
set(hObject,'string','');


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over xc.
function xc_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to xc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'enable','on');
set(hObject,'string','');


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over yc.
function yc_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to yc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'enable','on');
set(hObject,'string','');


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over zc.
function zc_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to zc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'enable','on');
set(hObject,'string','');


% --- Executes on button press in tgcolorbar.
function tgcolorbar_Callback(hObject, eventdata, handles)
% hObject    handle to tgcolorbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cb_exist = get(handles.axes1,'UserData');
if isempty(cb_exist)||cb_exist==0
    cb = colorbar;
    set(get(cb,'title'),'String','log_1_0(intensity)','FontSize',10);
    prop=get(handles.axes1,'position');
    prop(3) = 82;
    set(handles.axes1,'position',prop)
    set(handles.axes1,'UserData',1);
else
    colorbar('off');
    prop=get(handles.axes1,'position');
    prop(3) = 90.2;
    set(handles.axes1,'position',prop);
    set(handles.axes1,'UserData',0);
end
