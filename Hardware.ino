/*  
 *  Sends readings through serial port so it may be added to CSV file  
 *  By Jimmy Andrés Vargas Delgado, April 26th, 2016
*/
//  libraries
#include <Wire.h>
#include <Adafruit_ADS1015.h>

Adafruit_ADS1115 ads;

//  variables
int index = 0;
String dataString = "";
String serialInput = "";


void setup()
{
Serial.begin(9600);


//ads.setGain(GAIN_SIXTEEN);    // 16x gain  +/- 0.256V  1 bit = 0.0078125mV
ads.setGain(GAIN_TWO);        // 2x gain   +/- 2.048V  1 bit = 0.0625mV
ads.begin();
}
//  main loop
void loop()
{
 int16_t adc0, adc1, adc2;
 if (Serial.available()>0)
 {
   serialInput=Serial.readStringUntil(';');
   index = serialInput.toInt();
    switch(index) 
    { 
      case 1:// read sensors and send to serial port
      {
        adc0 = ads.readADC_SingleEnded(0);
        adc1 = ads.readADC_SingleEnded(1);
        adc2 = ads.readADC_SingleEnded(2);
        dataString = String(adc1) + ";" + String(adc2) + ";" + String(adc0);
        Serial.println(dataString);
        break;
      }
    }
 }
}
