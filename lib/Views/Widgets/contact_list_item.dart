import 'package:chat_app/Views/Screens/call_screen.dart';
import 'package:chat_app/Views/Screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContactListItem extends StatefulWidget {
  final String chatDisplayName;
  final String chatId;
  final String chatProfilePic;
  final String contactPhoneNumber;
  String? docId;
  Function addToGp;

  ContactListItem(
      {required this.chatDisplayName,
      required this.chatId,
      required this.chatProfilePic,
      this.contactPhoneNumber = '',
      this.docId,
      required this.addToGp});

  @override
  State<ContactListItem> createState() => _ContactListItemState();
}

class _ContactListItemState extends State<ContactListItem> {
  bool isSelectedforGroup = false;

  void tap() {
    if (isSelectedforGroup) {
      setState(() {
        isSelectedforGroup = false;
      });
    } else {
      Navigator.of(context).pushNamed(ChatScreen.ROUTE_NAME, arguments: {
        'docId': widget.docId,
        'contactUid': widget.chatId,
        'displayName': widget.chatDisplayName,
        'contactProfile': widget.chatProfilePic
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: tap,
      onLongPress: longTap,
      leading: contactProfilePic(),
      title: Text(widget.chatDisplayName),
      subtitle: Text(widget.contactPhoneNumber),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: () {
                // Navigator.of(context).pushNamed(CallPage.ROUTE_NAME, arguments:  {
                //   'name' : widget.chatDisplayName,
                //   'callType' : 'Video',
                //   'contactId' : widget.chatId
                // });
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => CallPage(
                      callType: 'Video',
                      contactId: widget.chatId,
                      name: widget.chatDisplayName,
                      isOffering: true,
                      roomId: null,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.video_call_rounded)),
          IconButton(
            onPressed: () {
              // Navigator.of(context).pushNamed(CallPage.ROUTE_NAME, arguments:  {
              //   'name' : widget.chatDisplayName,
              //   'callType' : 'Audio',
              //   'contactId' : widget.chatId
              // });
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => CallPage(
                    callType: 'Audio',
                    contactId: widget.chatId,
                    name: widget.chatDisplayName,
                    isOffering: true,
                    roomId: null,
                  ),
                ),
              );
            },
            icon: Icon(Icons.call),
          )
        ],
      ),
    );
  }

  void longTap() {
    if (!isSelectedforGroup) {
      widget.addToGp(widget.chatId);
      setState(() {
        isSelectedforGroup = true;
      });
    }
  }

  void showContactDialog(
      BuildContext context, String contactProfiePic, String tag) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => Center(
        child: Hero(
          tag: tag,
          child: Container(
            padding: EdgeInsets.all(15),
            child: Image.network(
              contactProfiePic,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget contactProfilePic() {
    return Stack(children: [
      InkWell(
        onTap: () =>
            showContactDialog(context, widget.chatProfilePic, widget.chatId),
        child: Hero(
          tag: widget.chatId,
          child: CircleAvatar(
            backgroundImage: Image.network(widget.chatProfilePic).image,
            radius: 25,
          ),
        ),
      ),
      if (isSelectedforGroup)
        Positioned(
          bottom: 1,
          right: 1,
          child: Container(child: Icon(Icons.check, color: Colors.green)),
        )
    ]);
  }
}
