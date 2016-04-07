% Temperature and Illuminance Sensing - Functions Brainstorming Script.
% By Jimmy Andres Vargas Delgado - April 5th, 2016
%% Connect Arduino
global Arduino
Arduino = serial('/dev/cu.usbmodem1421');% Dell: Arduino = serial('COM4');
set(Arduino,'DataBits',8);
set(Arduino,'StopBits',1);
set(Arduino,'BaudRate',9600);
set(Arduino,'Parity','none');
set(Arduino,'Timeout',40);
fopen(Arduino);
disp('Serial connection stablished.');
%% Disconnect Arduino
if exist('Arduino','var')
    fclose(Arduino);
    delete (Arduino);
    clear Arduino;
end
disp('Arduino global variable cleared.');
%% Read CSV Data
file    = fopen('data.csv');
header  = textscan(file,'%s %s %s %s %s %s %s %s %s %s',1,'headerLines',0,'Delimiter',';');
data    = textscan(file,'%f %f %f %d %d %d %d %d %d %d','headerLines',1,'Delimiter',';');
fclose(file);
temp1   = data{1,1}(:,1);
temp2   = data{1,2}(:,1);
lux     = data{1,3}(:,1);
year    = data{1,4}(:,1);
month   = data{1,5}(:,1);
day     = data{1,6}(:,1);
hour    = data{1,7}(:,1);
minute  = data{1,8}(:,1);
second  = data{1,9}(:,1);
%% Plot Data
f1 = figure(1);
cla; hold on; grid on;
plot(temp1,'r-');
plot(temp2,'k-');
plot(lux,'g-');
%% Read Sensors
fprintf(Arduino,'%s',sprintf('1;'));
inputString = fscanf(Arduino,'%s');%example: inputString = '0.3234;890.2344;373.3412';
inputString = strsplit(inputString,';');
sensorValue = str2double(inputString);
%% Get Date & Time
t = datetime;
dateVector = datevec(t);
%% Write New CSV Line
numarray = readSensors(Arduino);
t = datetime;
dateVector = datevec(t);
for i=1:6
    numarray(end+1) = dateVector(i); %#ok<SAGROW>
end
file = fopen('testfile.csv', 'a');
 
fprintf(file, '\n');
for i=1:8
    fprintf(file, num2str(numarray(i)));
    fprintf(file,';');
end
fprintf(file, num2str(numarray(9)));
fclose(file);