import 'package:chat_app/Models/user.dart';
import 'package:chat_app/Views/Widgets/contact_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'chat_screen.dart';

class CreateGroupPage extends StatelessWidget {
  static const ROUTE_NAME = '/create_group';

  final _controller = TextEditingController();

  XFile? xFile;


  void changeUserProfile(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Row(
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: ElevatedButton.icon(
                      onPressed: () => pickImage(ImageSource.camera, context),
                      icon: Icon(Icons.camera),
                      label: Text('Pick Camera')),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: ElevatedButton.icon(
                      onPressed: () => pickImage(ImageSource.gallery, context),
                      icon: Icon(Icons.storage_rounded),
                      label: Text('Use Storage')),
                ),
              ],
            ));
  }

  pickImage(ImageSource imageSource, BuildContext context) async {
    var imagePicker = ImagePicker();
    try {
      xFile = await imagePicker.pickImage(source: imageSource);
    } catch (err) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err.toString())));
      throw err;
    }
  }

  @override
  Widget build(BuildContext context) {
    // var isUsedForNonPV = ModalRoute.of(context)!.settings.arguments;
    final userManager = Provider.of<UserManager>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: (){}),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.create_rounded),
          onPressed: () async {
            ///CREATE A GROUP IN DATABASE
            final gpUsers = userManager.groupUserIds;
            if (_controller.text.isEmpty ||
                gpUsers[0] == FirebaseAuth.instance.currentUser!.uid) {
              return;
            }
            final uploadTask = await FirebaseStorage.instance.ref().child('users').child(_controller.text.trim()).child('profile_pictures')
        .child(xFile!.path.substring(xFile!.path.lastIndexOf('/') + 1))
        .putData(await xFile!.readAsBytes());

            final docRef =
                await FirebaseFirestore.instance.collection('chats').add({
              'displayName': _controller.text.trim(),
              'users': gpUsers,
              'type': 'Group',
              'chatPic': await uploadTask.ref.getDownloadURL(),
            });
            for (final gpuser in gpUsers) {
              final user = await FirebaseFirestore.instance.collection('users').doc(gpuser).get();
              final userChats = user.data()!['chats'];
              userChats.add(docRef.id);
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(gpuser)
                  .update({
                'chats': userChats
              });
            }
            Navigator.of(context).pushReplacementNamed(ChatScreen.ROUTE_NAME, arguments: {
            'docId': docRef.id,
            'contactUid': null,
            'displayName': _controller.text.trim(),
            'contactProfile': (await docRef.get()).data()!['chatPic']
          });
          }),
      body: Column(
        children: [
          Row(
            children: [
              ClipOval(
                child: IconButton(onPressed: () => changeUserProfile(context), icon: Icon(Icons.add_a_photo_outlined)),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(labelText: 'Declare a Name'),
                  maxLines: 1,
                  maxLength: 35,
                ),
              ),
            ],
          ),
          Expanded(child: ContactsList()),
        ],
      ),
    );
  }
}
