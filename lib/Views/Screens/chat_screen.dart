import 'package:chat_app/Views/Widgets/chat_bubble.dart';
import 'package:chat_app/Views/Widgets/chat_input_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  static const ROUTE_NAME = '/chats';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? docID;
  bool isFirst = true;
  late final String? contactUid;
  late final String contactProfile;
  late final String displayName;
  var state = false;

  bool hasChatBeenCreated =false;

  void createChatDoc(String textMessage, String mediaMessage) async {
    try {
      await createChatDocument();
      await createMessageDocument(textMessage, mediaMessage);
      await updateCurrentUserChatProperty();
      await updateContactChatProperty();
      updateState();
    } catch (error) {
      handleCreateChatDocError(error);
    }
  }

  void handleCreateChatDocError(Object error) {
    print('siiiiiiiiix');
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error.toString())));
    print('ERORR = $error');
    throw error;
  }

  void updateState() {
    if(hasChatBeenCreated){
    print('five');
    if (state) {
      setState(() => null);
      state = false;
    }
    }
  }

  Future<void> updateContactChatProperty() async {
    if(hasChatBeenCreated){
    if(contactUid !=null){
    print('four');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(contactUid)
        .update({
      'chats': [docID]
    });
    }
    }
  }

  Future<void> updateCurrentUserChatProperty() async {
    if(hasChatBeenCreated){
    if(contactUid != null){
    print('three');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'chats': [docID]
    });
    }
    }
  }

  Future<void> createMessageDocument(
      String textMessage, String mediaMessage) async {
    final userRes = await FirebaseFirestore.instance
        .collection('chats')
        .doc(docID)
        .collection('messages')
        .add({
      'senderId': FirebaseAuth.instance.currentUser!.uid,
      'createdAt': Timestamp.now(),
      'textMessage': textMessage,
      'mediaMessage': mediaMessage
    });
  }

  Future<void> createChatDocument() async {
    if (docID == null) {
      hasChatBeenCreated = true;
      final res = await FirebaseFirestore.instance.collection('chats').add({
        'users': [FirebaseAuth.instance.currentUser!.uid, contactUid],
        'type': 'Private'
      });
      if (docID == null) {
        state = true;
        docID = res.id;
      }
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (isFirst) {
      var args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      docID = args['docId'];
      contactUid = args['contactUid'] ?? '';
      contactProfile = args['contactProfile']!;
      displayName = args['displayName']!;
      isFirst = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundImage: Image.network(contactProfile).image,
              maxRadius: 15,
            ),
            Text(displayName)
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: docID == null
                ? Center(
                    child: Text('Nothing Yet'),
                  )
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('chats/$docID/messages')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (ctx, AsyncSnapshot<dynamic> streamSnapShot) {
                      // print('snapshot'streamSnapShot.data.docs!.length);
                      if (streamSnapShot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      } else if (streamSnapShot.hasError) {
                        print(streamSnapShot.error);
                        return Center(
                          child: Text('Something went wrong'),
                        );
                      } else {
                        print(streamSnapShot.data);
                        return ListView.builder(
                          reverse: true,
                          itemCount: streamSnapShot.data!.docs.length,
                          itemBuilder: (ctx, index) => 
                          // streamSnapShot
                          //         .data!.docs[index]['textMessage'].isEmpty
                          //     ? Image.network(streamSnapShot.data!.docs[index]
                          //             ['mediaMessage'])
                          //     : 
                              ChatBubble(
                                  streamSnapShot.data!.docs[index]
                                      ['textMessage'],
                                  streamSnapShot.data!.docs[index]
                                          ['senderId'] ==
                                      FirebaseAuth.instance.currentUser!.uid,
                                  ValueKey(streamSnapShot.data!.docs[index].id),
                                  streamSnapShot.data!.docs[index]
                                      ['mediaMessage']),
                        );
                      }
                    },
                  ),
          ),
          ChatInputWidget(createChatDoc),
        ],
      ),
    );
  }
}
