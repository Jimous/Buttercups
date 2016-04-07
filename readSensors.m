function [ sensorValue ] = readSensors( serial )
% 'readSensors' saves a sensor reading into array as float values.
% By Jimmy Andres Vargas Delgado - April 7, 2016.
fprintf(serial,'%s',sprintf('1;'));
inputString = fscanf(serial,'%s');%example: inputString = '0.3234;890.2344;373.3412';
inputString = strsplit(inputString,';');
sensorValue = str2double(inputString);
end
