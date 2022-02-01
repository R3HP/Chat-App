import 'package:chat_app/Views/Widgets/chat_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatList extends StatelessWidget {
  final String? filter;

  var stream = FirebaseFirestore.instance
      .collection('chats')
      .where('users', arrayContains: FirebaseAuth.instance.currentUser!.uid);
  late Query<Map<String, dynamic>> finalStream;
  ChatList({this.filter});

  @override
  Widget build(BuildContext context) {
    switch (filter) {
      case null:
        finalStream = stream;
        break;
      case 'Private':
        finalStream = stream;
        finalStream = finalStream.where('type', isEqualTo: 'Private');
        break;
      case 'Group':
        finalStream = stream;
        finalStream = finalStream.where('type', isEqualTo: 'Group');
        break;
      case 'Channel':
        finalStream = stream;
        finalStream = finalStream.where('type', isEqualTo: 'Channel');
        break;
    }
    print(finalStream.parameters);
    return StreamBuilder(
        stream: finalStream.snapshots(),
        builder: (context, AsyncSnapshot<dynamic> asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          var docs = asyncSnapshot.data.docs;
          
          var list = docs
              .map((doc) => <String, dynamic>{
                    'id': doc.id,
                    'type': doc.data()['type'],
                    'chatPic': doc.data()['chatPic'],
                    'users': doc.data()['users'],
                    'displayName': doc.data()['displayName'] ?? ''
                  })
              .toList();

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) =>
                ChatItem(ValueKey(list[index]['id']), list[index]),
          );
        });
  }
}
