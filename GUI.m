function varargout = GUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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

function GUI_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
refresh(handles,0);
set(handles.figure1, 'UserData',[]);
userData.stop = false;
set(handles.figure1, 'UserData',userData);
serialPorts = instrhwinfo('serial');
set(handles.portList, 'String',[{'Select a port'} ; serialPorts.SerialPorts ]);
set(handles.portList, 'Value', 2);
handles.output = hObject;
guidata(hObject, handles);

function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function portList_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>

function portList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function BaudRate_Callback(hObject, eventdata, handles)

function BaudRate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function connectButton_Callback(hObject, eventdata, handles)
if strcmp(get(hObject,'String'),'Connect') % currently disconnected
    serPortn = get(handles.portList, 'Value');
    if serPortn == 1
        errordlg('Select valid serial port');
    else
        serList = get(handles.portList,'String');
        serPort = serList{serPortn};
        serConn = serial(serPort,'TimeOut',1,'BaudRate', str2double(get(handles.BaudRate, 'String')));
        try
            fopen(serConn);
            handles.serConn = serConn;            
            set(hObject, 'String','Disconnect')
        catch e
            errordlg(e.message);
        end    
    end
else    
    set(hObject, 'String','Connect')
    fclose(handles.serConn);
end
guidata(hObject, handles);

function SampleRate_Callback(hObject, eventdata, handles)

function SampleRate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SampleDuration_Callback(hObject, eventdata, handles)

function SampleDuration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function filename_Callback(hObject, eventdata, handles)

function filename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function startButton_Callback(hObject, eventdata, handles)
SR = str2double(get(handles.SampleRate,'String'));
SD = str2double(get(handles.SampleDuration,'string'));
Times = round(SD/SR);
moreWork = true;
while moreWork
    for i=1:Times
        write(handles);
        refresh(handles,SR);
        userData = get(handles.figure1, 'UserData');
        if i == Times
            userData.stop = false; %reset for next time
            set(handles.figure1,'UserData',userData);
            moreWork = false; %to stop the loop
        end
    end
end

function write(handles)
filename = get(handles.filename,'String');
writeLine(handles.serConn,filename);
%writeLine(1,filename);% for debugglng without Arduino

function writeLine(serial,filename)
numarray = readInputs(serial);
%numarray = rand(1,3)*10000;% for debugglng without Arduino
dateVector = clock;
for j=1:6
    numarray(end+1) = dateVector(j); %#ok<AGROW>
end
file = fopen(filename,'a');
for k=1:8
    fprintf(file, num2str(numarray(k)));
    fprintf(file,';');
end
    fprintf(file, num2str(numarray(9)));
    fprintf(file,'\n');
    fclose(file);
    
function [sensorValue] = readInputs(serial)
fprintf(serial,'%s',sprintf('1;'));
inputString = fscanf(serial,'%s');
inputString = strsplit(inputString,';');
sensorValue = str2double(inputString); 
%sensorValue = sensorValue*0.0078125; %mode 16x gain ADC
sensorValue = sensorValue*0.0625; %mode 2x gain ADC

%Rinicial = 5000;
%Rfinal   = 32500;
%Vinicial = 662.2;
%Vfinal   = 2048;

%m = (Rfinal - Rinicial)/(Vfinal-Vinicial);
m = 0.0315;
Rinicial = 64.512;
sensorValue(:,1) = -m*sensorValue(:,1)+Rinicial
sensorValue(:,2) = -m*sensorValue(:,2)+Rinicial; %Resistance
sensorValue(:,2) = sensorValue(:,2)-0.2;
sensorValue(:,3) = sensorValue(:,3)*64.500;

%  a = 3.3540154e-03;
%  b = 2.5627725e-04;
%  c = 2.0829210e-06;
%  d = 7.3003206e-08;
%  R = 10000;%ohms
%  
%  %CompensationCh1 = 6.2130;
%  %CompensationCh2 = 6.1015;
%  
%  for i=1:size(sensorValue,1)
%     sensorValue(i,1) = 1/(a+b*log(sensorValue(i,1)/R)+c*log(sensorValue(i,1)/R)^2+d*log(sensorValue(i,1)/R)^3)-273.15;
%     sensorValue(i,2) = 1/(a+b*log(sensorValue(i,2)/R)+c*log(sensorValue(i,2)/R)^2+d*log(sensorValue(i,2)/R)^3)-273.15;
%  end

function refresh(handles,delay)
[temp1,temp2,ill,year,month,day,hour,minute,second] = CSVData(handles); %#ok<ASGLU>
axes(handles.axes1);
plottemp(temp1,temp2);
axes(handles.axes2);
plotillum(ill);
pause(delay);

function plottemp(ch1,ch2)
cla; hold on; grid on;
plot(ch1,'r-');
plot(ch2,'b-');
%xlabel('Samples','FontSize',12,'FontWeight','bold','Color','blue');
%ylabel('Temperature Input','FontSize',12,'FontWeight','bold','Color','blue');
%set(gca, 'XTick', []); %turn X axis off
legend('Inner Temperature','Outer Temperature','Location','northwest');

function plotillum(ch3)
cla; hold on; grid on;
semilogy(ch3,'g-');
xlabel('Samples','FontSize',12,'FontWeight','bold','Color','blue');
%ylabel('Illuminance Input','FontSize',12,'FontWeight','bold','Color','blue');
legend('Illuminance','Location','northwest');

function [temp1,temp2,ill,year,month,day,hour,minute,second] = CSVData(handles)
file = fopen(get(handles.filename,'String'));
data    = textscan(file,'%f %f %f %f %f %f %f %f %f %f','headerLines',1,'Delimiter',';');
fclose(file);
temp1   = data{1,1}(:,1);
temp2   = data{1,2}(:,1);
ill     = data{1,3}(:,1);
year    = data{1,4}(:,1);
month   = data{1,5}(:,1);
day     = data{1,6}(:,1);
hour    = data{1,7}(:,1);
minute  = data{1,8}(:,1);
second  = data{1,9}(:,1);

function snap()
DSLR_Namespace = NET.addAssembly([pwd '\CameraControl.Devices.dll']); %#ok<NASGU>
DeviceManager = CameraControl.Devices.CameraDeviceManager; 
DeviceManager.ConnectToCamera();
myCamera = DeviceManager.ConnectedDevices.Item(0);
myPhotoSession = PhotoSession(myCamera); %#ok<NASGU>
myCamera.CapturePhoto();

function captureCycle(CR,CD,handles)
Times = round(CD/CR);
moreWork = true;
while moreWork
    for i=1:Times
        snap();
        pause(CR);
        userData = get(handles.figure1, 'UserData');
        if i == Times
            userData.stop = false; %reset for next time
            set(handles.figure1,'UserData',userData);
            moreWork = false; %to stop the loop
        end
    end
end

function clearButton_Callback(hObject, eventdata, handles)
file = fopen(get(handles.filename,'String'), 'wt');
fprintf(file, '');
fclose(file);
refresh(handles,0);

function captureButton_Callback(hObject, eventdata, handles)
CR = str2double(get(handles.captureRate,'String'));
CD = str2double(get(handles.captureDuration,'string'));
captureCycle(CR,CD,handles);

function captureRate_Callback(hObject, eventdata, handles)

function captureRate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function captureDuration_Callback(hObject, eventdata, handles)

function captureDuration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
