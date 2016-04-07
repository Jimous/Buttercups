/*  
 *  Sends readings through serial port so it may be added to CSV file  
 *  By Jimmy Andrés Vargas Delgado, April 4th, 2016
*/
//  libraries
//  pin constants
const int sensorPin0 = 0;// contact temperature 1
const int sensorPin1 = 1;// contact temperature 2
const int sensorPin2 = 2;// illuminance
//  variables
int index = 0;
float sensorValue[3] = {0,0,0};// ct1, ct2, lux
String dataString = "";
String serialInput = "";
//  
void setup()
{
pinMode(sensorPin0, INPUT);
pinMode(sensorPin1, INPUT);
pinMode(sensorPin2, INPUT);
Serial.begin(9600);
}
//  main loop
void loop()
{
 if (Serial.available()>0)
 { 
   serialInput=Serial.readStringUntil(';');
   index = serialInput.toInt();
    switch(index) 
    { 
      case 1:// read sensors and send to serial port
      {
        sensorValue[0] = analogRead(sensorPin0);
        sensorValue[1] = analogRead(sensorPin1);
        sensorValue[2] = analogRead(sensorPin2);
        dataString = String(sensorValue[0]) + ";" + String(sensorValue[1]) + ";" + String(sensorValue[2]);
        Serial.println(dataString);
        break;
      }
    }
 }
}
//  functions
