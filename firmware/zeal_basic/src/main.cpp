/*
 * Example device for Zeal IoT
 * This firmware sent sensor data to firestore as a zeal documents, the device as 3 params :
 * c1 : control param
 * temp : temperature value
 * humid : humidity value
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

// include Firebase client
#include <Firebase_ESP_Client.h> //ttps://github.com/mobizt/Firebase-ESP-Client

// include sensor library eg: DHTxx
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>
#define DHTPIN D2     // Digital pin connected to the DHT sensor 
// Feather HUZZAH ESP8266 note: use pins 3, 4, 5, 12, 13 or 14 --
// Pin 15 can work but DHT must be disconnected during program upload.

// Uncomment the type of sensor in use:
#define DHTTYPE    DHT11     // DHT 11
//#define DHTTYPE    DHT22     // DHT 22 (AM2302)
//#define DHTTYPE    DHT21     // DHT 21 (AM2301)

DHT_Unified dht(DHTPIN, DHTTYPE);

float temp;
float humid;
uint32_t delayMS;

// Control PIN (c1)
#define C1PIN D3

/* 1. Define the WiFi credentials */
#define WIFI_SSID ""
#define WIFI_PASSWORD ""

/* 2. Define the Firebase project host name and API Key */
#define FIREBASE_HOST "FIREBASE_PROJECT_ID.firebaseio.com"
#define API_KEY ""

/* 3. Define the project ID */
#define FIREBASE_PROJECT_ID ""

/* 4. Define the user Email and password that alreadey registerd or added in your project */
#define USER_EMAIL ""
#define USER_PASSWORD ""

/* 5. Define the user access key and device id */
#define DEVICE_ID ""
#define ACCESS_KEY ""

// define NTP Client
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP);

//Define Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

unsigned long dataMillis = 0;
unsigned long controlMillis = 0;

void setup()
{
  Serial.begin(115200);

  // set pin mode
  pinMode(C1PIN, OUTPUT);

  // Initialize DHTxx device.
  dht.begin();
  Serial.println(F("DHTxx Unified Sensor"));
  // Print temperature sensor details.
  sensor_t sensor;
  dht.temperature().getSensor(&sensor);
  dht.humidity().getSensor(&sensor);

 

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
  //timeClient.setTimeOffset(25200);

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
  //Set the size of WiFi rx/tx buffers in the case where we want to work with large data.
  fbdo.setBSSLBufferSize(1024, 1024);
#endif

  // Set delay between sensor readings based on sensor details.
  delayMS = sensor.min_delay / 1000;
}




void loop()
{
  Serial.println("------------------------------------");
  Serial.println("Get Temperature...");
  Serial.println("------------------------------------");
  // Delay between measurements.
  delay(delayMS);
  // Get temperature event and print its value.
  sensors_event_t event;
  dht.temperature().getEvent(&event);
  if (isnan(event.temperature)) {
    Serial.println(F("Error reading temperature!"));
  }
  else {
    Serial.print(F("Temperature: "));
    Serial.print(event.temperature);
    temp = event.temperature;
    Serial.println(F("°C"));
  }
  // Get humidity event and print its value.
  dht.humidity().getEvent(&event);
  if (isnan(event.relative_humidity)) {
    Serial.println(F("Error reading humidity!"));
  }
  else {
    Serial.print(F("Humidity: "));
    Serial.print(event.relative_humidity);
    humid = event.relative_humidity;
    Serial.println(F("%"));
  }
  Serial.println("------------------------------------");
  Serial.println();

  // read data from firestore every 5 secound
  if (millis() - controlMillis > 3000 || controlMillis == 0)
  {
    controlMillis = millis();

    String documentPath = "messages/"+ String(ACCESS_KEY) + "_" + String(DEVICE_ID);
    String mask = "c1";

    Serial.println("------------------------------------");
    Serial.println("Get a document...");

    if (Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str(), mask.c_str()))
    {
      Serial.println("PASSED");
      Serial.println("------------------------------------");
      Serial.println(fbdo.payload());
      Serial.println("------------------------------------");
      Serial.println();

      // parse value
      FirebaseJson json;
      FirebaseJsonData jsonObj;
      String jsonStr;
      json.setJsonData(fbdo.payload());
      json.get(jsonObj, "fields/c1/booleanValue");
      Serial.print("c1 = ");
      Serial.println(jsonObj.boolValue);      
      Serial.println("------------------------------------");
      // action
      if (jsonObj.boolValue) {
        Serial.println("ON");
        digitalWrite(C1PIN, HIGH);
      } else {;
        Serial.println("OFF");
        digitalWrite(C1PIN, LOW);
      }
    }
    else
    {
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo.errorReason());
      Serial.println("------------------------------------");
      Serial.println();
    }
  }


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
    String documentLogPath = "messages/" + String(ACCESS_KEY) + "_" + String(DEVICE_ID) + "/log/" + String(timestamp) ;

    js.set("fields/temp/doubleValue", String(temp).c_str());
    js.set("fields/humid/doubleValue", String(humid).c_str());
    js.set("fields/timestamp/doubleValue", String(timestamp).c_str());
    js.toString(content);

    // create message document
    Serial.println("------------------------------------");
    Serial.println("Create a document...");

    if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "" /* databaseId can be (default) or empty */, documentPath.c_str(), content.c_str(), "temp,humid,timestamp" ))
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
    if (Firebase.Firestore.createDocument(&fbdo, FIREBASE_PROJECT_ID, "" /* databaseId can be (default) or empty */, documentLogPath.c_str(), content.c_str() ))
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
}
