How to deploy Zeal IoT
===

Zeal IoT developed with Dart, Flutter and working with Firebase, a cloud service from Google. To deploy Zeal IoT. You must build code from git repository and deploy to Firebase hosting.

1. You must have

    * [Git client](https://git-scm.com/)
    * [Flutter SDK](https://flutter.dev/) 
    * [Firebase account](https://firebase.google.com/)

2. Clone the project from [GitHub](https://github.com/anoochit/zeal_iot). The project consist of 

    * ``doc`` - Document 
    * ``firmware`` - An example firmware
    * ``zweb`` - Zeal IoT

3. Create new project at Firebase

4. Enable these services

    * Enable Firebase Authentication service with Email/Password signin method.
    * Enable Cloud Firestore.
    * Config Cloud Firestore rule, public can read and authentication user only can write data to Cloud Firestore.

5. You might upgrade Firebase plan to Blaze to extend you project to another services in Google Cloud.

6. Edit `lib/config.dart` with you Firebase web key, see your web key at project setting page.

7. Build Zeal IoT with Flutter ``flutter build web``.

8. Deploy Zeal IoT to Firebase Hosting ``firebase deploy --only hosting``.

9. Now, you can register a new account, add device and push data. 


Develop your firmware
===

You can develop firmware from an example firmware in ``firmware`` directory. ```zeal_basic``` is an example firmware which read temperature and humidity data from DHTx sensor. you can start to learn from this file.

The basic firmware send 2 data fields (temp, humid) and 1 control field (c1). You must add device with these fields.

 Edit ```zeal_basic``` , update your own data

  * WIFI_SSID
  * WIFI_PASSWORD
  * FIREBASE_PROJECT_ID
  * FIREBASE_HOST
  * API_KEY
  * USER_EMAIL
  * USER_PASSWORD
  * DEVICE_ID
  * ACCESS_KEY

Upload and see message log at serial monitor.


Send data to Zeal IoT
===

You can send the data to Zeal IoT by using script on any services. But you must authentication with username, password to push your data to Zeal IoT aka Cloud Firestore. You can push data to  ``messages`` collectoin directly with your device data strucure.

Example when you create a device with control fields and data fields for temperature sensor. You will get  data and control fields in your ``devices`` collection.

Then you can push data into 2 parts; current data and log data. The structure is look like this.

Send current sensor data to this path

/messages/``USERID_DEVICEID``/

And send your log data to this path

/messages/``USERID_DEVICEID``/log/``UNIXTIMESTAMP``/
