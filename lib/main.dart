import 'package:chat_app/Models/theme.dart';
import 'package:chat_app/Models/user.dart';
import 'package:chat_app/Views/Screens/account_settings_screen.dart';
import 'package:chat_app/Views/Screens/auth_screen.dart';
import 'package:chat_app/Views/Screens/call_screen.dart';
import 'package:chat_app/Views/Screens/chat_screen.dart';
import 'package:chat_app/Views/Screens/contacts_screen.dart';
import 'package:chat_app/Views/Screens/create_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart' as sysPath;
import 'package:hive_flutter/hive_flutter.dart';

import 'Views/Screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDir = await sysPath.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDir.path);
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserManager()),
        ChangeNotifierProvider(create: (context) => MyTheme())
      ],
      child: Builder(builder: (context) {
        return FutureBuilder(
          future: Provider.of<MyTheme>(context, listen: false).setTheme(),
          builder: (context, asanshot) => asanshot.connectionState ==
                  ConnectionState.waiting
              ? Center()
              : Consumer<MyTheme>(
                  builder: (context, myTheme, child) => MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'Flutter Demo',
                    theme: myTheme.getTheme,
                    home: StreamBuilder(
                        stream: FirebaseAuth.instance.authStateChanges(),
                        builder: (context, userSnapsoht) {
                          if (userSnapsoht.hasData) {
                            print('this is snapshot ${userSnapsoht.data}');
                          }
                          return userSnapsoht.connectionState ==
                                  ConnectionState.waiting
                              ? Scaffold(
                                  body: Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  ),
                                )
                              : userSnapsoht.hasData
                                  ? StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .collection('Room')
                                          .where('offerFrom',
                                              isNotEqualTo: FirebaseAuth
                                                  .instance.currentUser!.uid)
                                          .snapshots(),
                                      builder: (context,
                                              AsyncSnapshot<dynamic>
                                                  snapshot) =>
                                          snapshot.connectionState ==
                                                  ConnectionState.waiting
                                              ? Scaffold(
                                                  body: Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                )
                                              : snapshot.data.docs.isEmpty
                                                  ? HomePage()
                                                  : CallPage(
                                                      name: 'mostafa',
                                                      callType: 'Video',
                                                      isOffering: false,
                                                      contactId: snapshot
                                                          .data.docs[0]
                                                          .data()['offerFrom'],
                                                      roomId: snapshot
                                                          .data.docs[0]
                                                          .data()['roomId'],
                                                    ),
                                    )
                                  : AuthPage();
                        }),
                    routes: {
                      ContactsPage.ROUTE_NAME: (context) => ContactsPage(),
                      ChatScreen.ROUTE_NAME: (context) => ChatScreen(),
                      AccountSettingPage.ROUTE_NAME: (context) =>
                          AccountSettingPage(),
                      CreateGroupPage.ROUTE_NAME: (context) =>
                          CreateGroupPage(),
                      CallPage.ROUTE_NAME: (context) => CallPage()
                    },
                  ),
                ),
        );
      }),
    );
  }
}
