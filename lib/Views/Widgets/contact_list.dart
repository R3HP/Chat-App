import 'package:chat_app/Models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'contact_list_item.dart';

class ContactsList extends StatelessWidget {
  const ContactsList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userManager = Provider.of<UserManager>(context,listen: false);
    return FutureBuilder(
        future: Provider.of<UserManager>(context, listen: false)
            .getUserContacts(),
        builder: (ctx, AsyncSnapshot<List<MyUser>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator.adaptive(),
            );
          // print('this is snapshot ${snapshot.data!.length}');
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('chats')
                    .where('users', whereIn: [
                  [
                    FirebaseAuth.instance.currentUser!.uid,
                    snapshot.data![index].userId
                  ],
                  [
                    snapshot.data![index].userId,
                    FirebaseAuth.instance.currentUser!.uid,
                  ]
                ]).get(),
                builder: (context, AsyncSnapshot<dynamic> asyncSnapshot) =>
                    asyncSnapshot.connectionState == ConnectionState.waiting
                        ? Container(
                          height: double.infinity,
                          child: Center(
                              child: CircularProgressIndicator(),
                            ),
                        )
                        : ContactListItem(
                          
                            contactPhoneNumber:
                                snapshot.data![index].phoneNumber,
                            chatDisplayName:
                                snapshot.data![index].displayName!,
                            chatProfilePic: snapshot.data![index].profilepic,
                            chatId: snapshot.data![index].userId,
                            docId: asyncSnapshot.data.docs.isNotEmpty ? asyncSnapshot.data.docs[0].id : null,
                            addToGp : userManager.addtogroupdUserIds
                          ),
              ),
            );
          
        });
  }
}
