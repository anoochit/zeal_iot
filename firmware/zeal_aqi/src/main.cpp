/*
 * Example device for Zeal IoT
 * This firmware sent sensor data to firestore as a zeal documents, the device as 4 params :
 * c1 : control param
 * pm1 : PM 1.0 (ug/m3)
 * pm25 : PM 2.5 (ug/m3)
 * pm10 : PM 10.0 (ug/m3)
 *
 */
#include <Arduino.h>

#if defined(ESP32)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#endif

// include NTP Client
#include <NTPClient.h>
#include <WiFiUdp.h>

// include PMS7003
#include "PMS.h"
#include <SPI.h>
HardwareSerial SerialPMS(1);
PMS pms(SerialPMS);
PMS::DATA data;
#define RXD2 26
#define TXD2 25

// include Firebase client
#include <Firebase_ESP_Client.h>

// Control PIN (c1)
#define C1PIN 4

/* 1. Define the WiFi credentials */
#define WIFI_SSID " "
#define WIFI_PASSWORD " "

/* 2. Define the Firebase project host name and API Key */
#define FIREBASE_HOST " "
#define API_KEY " "

/* 3. Define the project ID */
#define FIREBASE_PROJECT_ID " "

/* 4. Define the user Email and password that alreadey registerd or added in your project */
#define USER_EMAIL " "
#define USER_PASSWORD " "

/* 5. Define the user access key and device id */
#define DEVICE_ID " "
#define ACCESS_KEY " "

// define NTP Client
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP);

// Define Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

unsigned long dataMillis = 0;
unsigned long controlMillis = 0;

void setup()
{
  Serial.begin(9600);

  // set pin mode
  pinMode(C1PIN, OUTPUT);

  // Initialize PMS device.
  SerialPMS.begin(9600, SERIAL_8N1, RXD2, TXD2);
  pms.passiveMode();

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  // Set offset time in seconds to adjust for your timezone, for example:
  // GMT +1 = 3600
  // GMT +8 = 28800
  // GMT -1 = -3600
  // GMT 0 = 0
  timeClient.begin();
  // timeClient.setTimeOffset(25200);

  // force update time
  timeClient.update();

  /* Assign the project host and api key (required) */
  config.host = FIREBASE_HOST;
  config.api_key = API_KEY;

  /* Assign the user sign in credentials */
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

#if defined(ESP8266)
  // Set the size of WiFi rx/tx buffers in the case where we want to work with large data.
  fbdo.setBSSLBufferSize(1024, 1024);
#endif
}

uint16_t pm1;
uint16_t pm25;
uint16_t pm10;

void loop()
{

  Serial.println("------------------------------------");
  Serial.println("Get AQI...");
  Serial.println("------------------------------------");
  // Delay between measurements, get AQI print its value.
  pms.wakeUp();
  delay(30000);
  Serial.println("Send read request...");
  pms.requestRead();

  if (pms.readUntil(data))
  {
    Serial.print("PM 1.0 (ug/m3): ");
    Serial.println(data.PM_AE_UG_1_0);
    pm1 = data.PM_AE_UG_1_0;

    Serial.print("PM 2.5 (ug/m3): ");
    Serial.println(data.PM_AE_UG_2_5);
    pm25 = data.PM_AE_UG_2_5;

    Serial.print("PM 10.0 (ug/m3): ");
    Serial.println(data.PM_AE_UG_10_0);
    pm10 = data.PM_AE_UG_10_0;
  }
  else
  {
    Serial.println("No data.");
  }

  // // read data from firestore every 5 secound
  // if (millis() - controlMillis > 3000 || controlMillis == 0)
  // {
  //   controlMillis = millis();

  //   String documentPath = "messages/"+ String(ACCESS_KEY) + "_" + String(DEVICE_ID);
  //   String mask = "c1";

  //   Serial.println("------------------------------------");
  //   Serial.println("Get a document...");

  //   if (Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str(), mask.c_str()))
  //   {
  //     Serial.println("PASSED");
  //     Serial.println("------------------------------------");
  //     Serial.println(fbdo.payload());
  //     Serial.println("------------------------------------");
  //     Serial.println();

  //     // parse value
  //     FirebaseJson json;
  //     FirebaseJsonData jsonObj;
  //     String jsonStr;
  //     json.setJsonData(fbdo.payload());
  //     json.get(jsonObj, "fields/c1/booleanValue");
  //     Serial.print("c1 = ");
  //     Serial.println(jsonObj.boolValue);
  //     Serial.println("------------------------------------");
  //     // action
  //     if (jsonObj.boolValue) {
  //       Serial.println("ON");
  //       digitalWrite(C1PIN, HIGH);
  //     } else {;
  //       Serial.println("OFF");
  //       digitalWrite(C1PIN, LOW);
  //     }
  //   }
  //   else
  //   {
  //     Serial.println("FAILED");
  //     Serial.println("REASON: " + fbdo.errorReason());
  //     Serial.println("------------------------------------");
  //     Serial.println();
  //   }
  // }

  // update data to firestore every 60 secound
  if (millis() - dataMillis > 60000 || dataMillis == 0)
  {
    dataMillis = millis();

    // show epoch time
    double timestamp = timeClient.getEpochTime();

    String content;
    FirebaseJson js;

    // Document path is "messages/ACCESS_KEY_DEVICE_ID"
    // following with your device default fields and timestamp eg: temp, humid, timestamp
    String documentPath = "messages/" + String(ACCESS_KEY) + "_" + String(DEVICE_ID);
    String documentLogPath = "messages/" + String(ACCESS_KEY) + "_" + String(DEVICE_ID) + "/log/" + String(timestamp);

    js.set("fields/pm1/integerValue", String(pm1).c_str());
    js.set("fields/pm25/integerValue", String(pm25).c_str());
    js.set("fields/pm10/integerValue", String(pm10).c_str());
    js.set("fields/timestamp/doubleValue", String(timestamp).c_str());
    js.toString(content);

    // create message document
    Serial.println("------------------------------------");
    Serial.println("Create a document...");

    if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "" /* databaseId can be (default) or empty */, documentPath.c_str(), content.c_str(), "pm1,pm25,pm10,timestamp"))
    {
      Serial.println("PASSED");
      Serial.println("------------------------------------");
      Serial.println(fbdo.payload());
      Serial.println("------------------------------------");
      Serial.println();
    }
    else
    {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
      Serial.println("------------------------------------");
      Serial.println();
    }

    // create message log doucment
    if (Firebase.Firestore.createDocument(&fbdo, FIREBASE_PROJECT_ID, "" /* databaseId can be (default) or empty */, documentLogPath.c_str(), content.c_str()))
    {
      Serial.println("PASSED");
      Serial.println("------------------------------------");
      Serial.println(fbdo.payload());
      Serial.println("------------------------------------");
      Serial.println();
    }
    else
    {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
      Serial.println("------------------------------------");
      Serial.println();
    }
  }

  Serial.println("PMS going to sleep");
  pms.sleep();
  delay(60000);
}
