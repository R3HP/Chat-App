import 'package:chat_app/Models/user.dart';
import 'package:chat_app/Views/Screens/account_settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyDrawer extends Drawer {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Colors.white,
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<dynamic> asyncSnapshot) {

            if (asyncSnapshot.connectionState == ConnectionState.waiting)
              return Center(
                child: CircularProgressIndicator(),
              );
            print(asyncSnapshot.data);
            return Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(asyncSnapshot.data.data()['displayName'] ?? ''),
                  accountEmail: Text(asyncSnapshot.data.data()['phoneNumber'] ?? ''),
                  currentAccountPicture: CircleAvatar(
                    foregroundImage:
                        NetworkImage(asyncSnapshot.data.data()['profilePic'] ?? ''),
                    backgroundColor: Theme.of(context).accentColor,
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('Account Settings'),
                  onTap: () => Navigator.of(context).pushNamed(
                      AccountSettingPage.ROUTE_NAME,
                      arguments: MyUser(
                          phoneNumber: asyncSnapshot.data['phoneNumber'],
                          userId: FirebaseAuth.instance.currentUser!.uid,
                          profilepic: asyncSnapshot.data['profilePic'],
                          displayName: asyncSnapshot.data['displayName'])),
                )
              ],
            );
          }),
    )
        // )
        ;
  }
}
