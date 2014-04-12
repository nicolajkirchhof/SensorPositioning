function varargout = SystemCalibrationGui(varargin)
% SYSTEMCALIBRATIONGUI MATLAB code for SystemCalibrationGui.fig
%      SYSTEMCALIBRATIONGUI, by itself, creates a new SYSTEMCALIBRATIONGUI or raises the existing
%      singleton*.
%
%      H = SYSTEMCALIBRATIONGUI returns the handle to a new SYSTEMCALIBRATIONGUI or the handle to
%      the existing singleton*.
%
%      SYSTEMCALIBRATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SYSTEMCALIBRATIONGUI.M with the given input arguments.
%
%      SYSTEMCALIBRATIONGUI('Property','Value',...) creates a new SYSTEMCALIBRATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SystemCalibrationGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SystemCalibrationGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SystemCalibrationGui

% Last Modified by GUIDE v2.5 18-Jul-2011 17:22:08
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SystemCalibrationGui_OpeningFcn, ...
                   'gui_OutputFcn',  @SystemCalibrationGui_OutputFcn, ...
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


% --- Executes just before SystemCalibrationGui is made visible.
function SystemCalibrationGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SystemCalibrationGui (see VARARGIN)
% Choose default command line output for SystemCalibrationGui
handles.output = hObject;
%%
dir = mfilename('fullpath');
p = fileparts(dir);
paramDir = [p, '/Parameters/'];

% sceneFile  = [paramDir ,'P1-01-R106.scene.yml'];
% configFile = [paramDir ,'ThILo.config.yml'];
sceneFile  = [paramDir ,'config.yml'];
configFile = [paramDir ,'SqrtOpt.yml'];

config = Tools.Parser.parseYaml( {sceneFile, configFile} );
sensors = config.Configuration.thilo.sensorModel;
%%
    handles.connections = { ...
        'tcp://localhost:40009' ...
        'tcp://localhost:40008' ...
        'tcp://localhost:40005' ...
        'tcp://localhost:40006' ...
        'tcp://localhost:40004' ...
        'tcp://localhost:40007' ... %% seems to be defekt
        'tcp://localhost:40011' ...
        'tcp://localhost:40010' ...
        };

handles.livedatacollection = LiveTest.LSCollection();

dataIds = handles.livedatacollection.Name; % get names

mapping = [];
for i=1:numel(sensors)
    sensId = sensors{i}.Id;
    j = find( strcmp(dataIds,sensId) );
    if isempty(j)
        continue;
        Warning('Sensor not found');
    end
    mapping(i) = j;
end

handles.livedatacollection.series_ = handles.livedatacollection.series_(mapping);

numConnections = numel(handles.connections);
for i=1:numConnections
    handles.livedatacollection.addLS( handles.connections{i} );
end
handles.pixel_values = cell(8, 1);
handles.raw_data = {};
handles.noOfPoints = 0;
handles.init_data = {};
handles.config = config;
handles.result = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SystemCalibrationGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SystemCalibrationGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of togglebutton1
state = get(hObject,'Value');
if state == 0
    handles.state = 0;
    set(hObject, 'String', 'Begin');
   set(handles.txt_ptsCounter, 'String', {'No. Pts:', '0'});
    handles.noOfPoints = 0;
    handles.pixel_values = cell(8, 1);
    handles.raw_data = {};
    handles.noOfPoints = 0;
    handles.init_data = {};
else
    handles.state = 4;
    set(hObject, 'String', 'End');
end
pushbutton3_Callback(handles.pushbutton3, eventdata, handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stop_string = {'Stop!', '- hold your position -'};
init_string = {'Init!', '- move fast in quad -'};
move_string = {'GO!', '- find new position -'};
ctr_string = {'No. Pts:', '0'};
state = handles.state;
switch state
    case 0      
        set(hObject, 'Enable', 'off');
    case 1
        set(handles.txt_calibInfo, 'String', stop_string);
        drawnow;
        handles = gatherCalibrationData(handles);
        set(handles.txt_calibInfo, 'String', move_string);
        handles.noOfPoints = handles.noOfPoints + 1;
        ctr_string{2} = num2str(handles.noOfPoints);
        set(handles.txt_ptsCounter, 'String', ctr_string);
    case 2
        set(hObject, 'String', 'Position Found');
        set(handles.txt_calibInfo, 'String', move_string);
        set(handles.txt_ptsCounter, 'String', ctr_string);
        handles.state = 1;
        set(handles.pushbutton3, 'Enable', 'on');
    case 4
        handles.init = 1;
        handles.state = 3;
        set(handles.txt_calibInfo, 'String', init_string);
        drawnow;
        guidata(hObject, handles);
        handles = gatherInitData(handles);
        return;
end

if handles.noOfPoints > 20
    set(handles.pushbutton4, 'Enable', 'on');
end
guidata(hObject, handles);

function handles = gatherInitData(handles)
start_time = rem(now,1)*1e5;
end_time = start_time+60;
cnt = 1; 
data = {};
while rem(now,1)*1e5 < end_time
    data{cnt,1} = handles.livedatacollection.Data();
    set(handles.txt_calibInfo, 'String', num2str(end_time - (rem(now,1)*1e5)));
    drawnow;
    cnt = cnt+1;
end
handles.init_data = data;
handles.state = 2;
guidata(handles.pushbutton3, handles);
pushbutton3_Callback(handles.pushbutton3, [], handles);


function handles = gatherCalibrationData(handles)
data = cell(8,1);
for i = 1:100;
    new_data = handles.livedatacollection.Data();
    for idx_sensor = 1:8
        data{idx_sensor} = [data{idx_sensor}, new_data{idx_sensor}];
    end
end

for idx_sensor = 1:8
    handles.pixel_values{idx_sensor}(:,end+1) = mean(data{idx_sensor},2);
    handles.raw_data{end+1} = data;
end



% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[pixel_values_normalized, aoas] = Experimental.extractNpvAoaAndPvFromPixelValues(handles.init_data, handles.pixel_values, handles.config);
%%
% [pixel_values_normalized, aoas] = Experimental.extractNpvAoaAndPvFromPixelValues(init_data, pixel_values, config);
%%
syscal_config = handles.config.Configuration.optimization.syscal_config;
syscal_config.pixval_normalized = pixel_values_normalized;
syscal_config.aoas = aoas;
filter = config.Configuration.optimization.filter;
handles.result = filter.filter(syscal_config);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 keydate = datestr(now,30);
 filename = ['systemCalibrationData_' keydate];
 save(filename, '-struct', 'handles', 'pixel_values', 'raw_data', 'init_data', 'config');
 