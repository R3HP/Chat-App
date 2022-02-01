import 'package:chat_app/Models/user.dart';
import 'package:chat_app/Views/Widgets/contact_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatItem extends StatelessWidget {
  final Key key;
  final Map<String, dynamic> chatInfo;

  ChatItem(this.key, this.chatInfo);

  @override
  Widget build(BuildContext context) {
    if (chatInfo['type'] == 'Private') {
      return FutureBuilder(
        future: Provider.of<UserManager>(context, listen: false).setContacts(),
        builder: (context, futureSnapshot) =>
            futureSnapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(chatInfo['users'].firstWhere((userId) =>
                            userId != FirebaseAuth.instance.currentUser!.uid))
                        .snapshots(),
                    builder: (context, AsyncSnapshot<dynamic> asyncSnapshot) {
                      if (asyncSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }
                      var data = asyncSnapshot.data.data();
                      print(asyncSnapshot.data.data());
                      print(data['displayName'].runtimeType);
                      // check if chat contact is a phone contact if it was we should change the displayName to contact Name
                      String? displayName =
                          Provider.of<UserManager>(context, listen: false)
                              .getDisplayNameForPhone(data['phoneNumber']);
                      print(displayName);
                      if (displayName == '') {
                        return ContactListItem(
                            docId: chatInfo['id'],
                            chatDisplayName: data['displayName'] ?? '',
                            chatId: asyncSnapshot.data.id,
                            chatProfilePic: data['profilePic'] ?? '',
                            contactPhoneNumber: data['phoneNumber'] ?? '',
                            addToGp: () {});
                      } else {
                        return ContactListItem(
                          docId: chatInfo['id'],
                          chatDisplayName: displayName ?? '',
                          chatId: asyncSnapshot.data.id,
                          chatProfilePic: data['profilePic'] ?? '',
                          contactPhoneNumber: data['phoneNumber'] ?? '',
                          addToGp: () {},
                        );
                      }
                    },
                  ),
      );
    } else {
      //its a group or channel
      return ContactListItem(
          docId: chatInfo['id'],
          chatDisplayName: chatInfo['displayName'],
          chatId: chatInfo['id'],
          chatProfilePic: chatInfo['chatPic'],
          addToGp: () {});
    }
  }
}
