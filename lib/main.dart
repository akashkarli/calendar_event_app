import 'package:calendar_event_app/provider/CalenderEventProvider.dart';
import 'package:calendar_event_app/screen/CalendarEventsScreen.dart';
import 'package:calendar_event_app/screen/SigninScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart' as firebaseclass;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CalenderEventProvider>(
      create: (_) => CalenderEventProvider(),
      child: MaterialApp(
        title: 'Calendar Event',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: user != null ? CalendarEvents() : SignInScreen(),
      ),
    );
  }
}
