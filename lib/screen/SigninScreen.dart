import 'dart:ui';

import 'package:calendar_event_app/helper/LocalStorageService.dart';
import 'package:calendar_event_app/helper/utils.dart';
import 'package:calendar_event_app/provider/CalenderEventProvider.dart';
import 'package:calendar_event_app/screen/CalendarEventsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as googleAPI;
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '555835726206-oenipjfm79m7cfe1h4pqn4u1fds0fqg4.apps.googleusercontent.com',
    scopes: <String>[
      'email',
      googleAPI.CalendarApi.CalendarEventsScope,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Event Calendar App",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: 200,
                    height: 200,
                    child: const Icon(Icons.date_range_rounded, size: 200),
                  ),
                  SizedBox(
                    height: 80,
                  ),
                  Container(
                    child: InkWell(
                      onTap: () {
                        _signInWithGoogle();
                      },
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width - 150,
                        color: CustomColor.dark_cyan,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 3),
                              height: 35,
                              width: 35,
                              decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          "https://cdn-icons-png.flaticon.com/512/2991/2991148.png"))),
                            ),
                            const Text("SignIn With Google",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ))
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            showLoader == true
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  bool showLoader = false;
  void _signInWithGoogle() async {
    print("google sign is called...");
    setState(() {
      showLoader = true;
    });
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      setState(() {
        showLoader = false;
      });
      return;
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final User user = (await _auth.signInWithCredential(credential)).user;
    print(user);
    assert(user.email != "");
    assert(user.displayName != "");
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != "");

    final User currentUser = await _auth.currentUser;
    assert(user.uid == currentUser.uid);
    if (user != null) {
      googleUser.authHeaders.then((value) {
        LocalStorageService.setToken(value["Authorization"].toString());
        print("auuth" + value["Authorization"].toString());
        LocalStorageService.setXGoodAuthUser(
            value["X-Goog-AuthUser"].toString());
        print("X-Goog-AuthUser" + value["X-Goog-AuthUser"].toString());
        Provider.of<CalenderEventProvider>(context, listen: false)
            .getGoogleEventsDataList();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => CalendarEvents()));
      });
    } else {
      setState(() {
        showLoader = false;
      });
    }
  }
}
