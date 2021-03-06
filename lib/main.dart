import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:meetups/http/web.dart';
import 'package:meetups/models/device.dart';
import 'package:meetups/screens/events_screen.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Replace with actual values
    options: FirebaseOptions(
      apiKey: "AIzaSyDqh_P0XISW7QJ1a0di4NTgT0icmy1EQeA",
      authDomain: "dev-meetups-78c19.firebaseapp.com",
      projectId: "dev-meetups-78c19",
      storageBucket: "dev-meetups-78c19.appspot.com",
      messagingSenderId: "818484536144",
      appId: "1:818484536144:web:43887e986bbfcabea28255",
      measurementId: "G-7HM6N6FXBB",
    ),
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('Permissão concedida pelo usuário: ${settings.authorizationStatus}');
    _startPushNotificationsHandler(messaging);
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print(
        'Permissão concedida provisionamento pelo usuário: ${settings.authorizationStatus}');
    _startPushNotificationsHandler(messaging);
  } else {
    print('Permissão negada pelo usuário');
  }

  runApp(App());
}

void _startPushNotificationsHandler(FirebaseMessaging messaging) async {
  String? token = await messaging.getToken();
  print('TOKEN: $token');
  _setPushToken(token);

  // Foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Recebi mensagem enquanto estava com o App aberto');
    print('Dados da mensagem: ${message.data}');

    if (message.notification != null) {
      print(
          'A mensagem também continha uma notificação: ${message.notification!.title}, ${message.notification!.body}');
    }
  });

  // Background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Terminated
  var notification = await FirebaseMessaging.instance.getInitialMessage();
  if (notification != null &&
      notification.data['message'] != null &&
      notification.data['message'].length > 0) {
    showMyDialog(notification.data['message']);
  }
}

void _setPushToken(String? token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? prefsToken = prefs.getString('pushToken');
  bool? prefSent = prefs.getBool('tokenSent');
  print('Prefs token: $prefsToken');

  if (prefsToken != token || (prefsToken == token && prefSent == false)) {
    print('Enviando token para o servidor...');

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? brand;
    String? model;
    if (kIsWeb) {
      WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
      brand = webInfo.vendor;
      model = webInfo.userAgent;
      print('Rodando no ${webInfo.userAgent}');
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Rodando no ${androidInfo.model}');
      brand = androidInfo.brand;
      model = androidInfo.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Rodando no ${iosInfo.utsname.machine}');
      model = iosInfo.utsname.machine;
      brand = 'Apple';
    }

    Device device = Device(brand: brand, model: model, token: token);
    sendDevice(device);
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dev meetups',
      home: EventsScreen(),
      navigatorKey: navigatorKey,
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Mensagem recebida em background: ${message.notification}');
}

// Criar tela de mensagem
void showMyDialog(String message) {
  Widget okButton = OutlinedButton(
    onPressed: () => Navigator.pop(navigatorKey.currentContext!),
    child: Text('Ok!'),
  );

  AlertDialog alerta = AlertDialog(
    title: Text('Promoção imperdível'),
    content: Text(message),
    actions: [okButton],
  );

  showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext contextDialog) {
        return alerta;
      });
}
