import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meetups/http/web.dart';
import 'package:meetups/models/device.dart';
import 'package:meetups/screens/events_screen.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  String? token = await messaging.getToken();
  print('TOKEN: $token');

  setPushToken(token);

  runApp(App());
}

void setPushToken(String? token) async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? brand;
  String? model;

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('Rodando no ${androidInfo.model}');
    brand = androidInfo.brand;
    model = androidInfo.model;
  } else {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    print('Rodando no ${iosInfo.utsname.machine}');
    model = iosInfo.utsname.machine;
    brand = 'Apple';
  }

  Device device = Device(brand: brand, model: model, token: token);
  sendDevice(device);
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dev meetups',
      home: EventsScreen(),
    );
  }
}
