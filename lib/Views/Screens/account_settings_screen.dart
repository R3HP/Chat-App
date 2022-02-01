import 'dart:io';
import 'dart:math';

import 'package:chat_app/Models/theme.dart';
import 'package:chat_app/Models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

enum TextSizes { Small, Medium, Large }

class AccountSettingPage extends StatelessWidget {
  static const ROUTE_NAME = '/account_settings';

  // File? selectedImageFile;

  late MyUser user;
  XFile? xFile;
  final _controller = TextEditingController();
  // GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // final userManager = Provider.of<UserManager>(context);
    // user = userManager.currentUser;
    final myTheme = Provider.of<MyTheme>(context, listen: false);
    user = ModalRoute.of(context)!.settings.arguments as MyUser;
    _controller.text = user.displayName!;
    return Scaffold(
      // key: scaffoldKey,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () => updateUser(context), icon: Icon(Icons.check))
        ],
        title: Text(
            user.displayName!.isEmpty ? user.phoneNumber : user.displayName!),
      ),
      body: SingleChildScrollView(
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 350,
              child: Stack(
                children: [
                  FadeInImage(
                    fit: BoxFit.cover,
                    placeholder: AssetImage(Random().nextInt(2) == 0
                        ? 'assets/images/groom.png'
                        : 'assets/images/bride.png'),
                    imageErrorBuilder: (context, _, a) => Image.asset(
                        Random().nextInt(2) == 0
                            ? 'assets/images/groom.png'
                            : 'assets/images/bride.png'),
                    image: NetworkImage(user.profilepic),
                  ),
                  Positioned(
                    bottom: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.white60]),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                Text('Change Your Profile Pic'),
                ClipOval(
                  child: IconButton(
                      onPressed: () => changeUserProfile(context),
                      icon: Icon(Icons.add_a_photo_rounded)),
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
              controller: _controller,
              decoration:
                  InputDecoration(labelText: 'Change Your Displayed Name'),
            ),
            SizedBox(
              height: 5,
            ),
            Divider(),
            SizedBox(
              height: 5,
            ),
            const Text('Choose Your Prefered Color'),
            SizedBox(
              height: 5,
            ),
            // TODO :Make the hieght OF LISTVIEW below dynamic
            SizedBox(
              height: 35,
              child: ListView.builder(
                itemCount: myTheme.appPreDefinedColors.length,
                itemBuilder: (ctx, index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  child: CircleAvatar(
                    child: IconButton(onPressed: () => myTheme.selectedMainColor(myTheme.appPreDefinedColors.keys.elementAt(index)), icon: Icon(Icons.check_circle_outline)),
                    backgroundColor:
                        myTheme.appPreDefinedColors.values.elementAt(index),
                  ),
                ),
                scrollDirection: Axis.horizontal,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Divider(),
            SizedBox(
              height: 5,
            ),
            const Text('Select Your Prefered Size'),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Chip(
                  
                  label: 
                  TextButton(
                    onPressed: () => myTheme.selectTextSize(ThemePreDifendTextSize.Small),
                    child: Text('Small'),
                  ),
                  side: BorderSide(
                      width: 3, color: Theme.of(context).colorScheme.secondary),
                ),
                Chip(
                  label:TextButton(
                    onPressed: () => myTheme.selectTextSize(ThemePreDifendTextSize.Medium),
                    child: Text('Medium'),
                  ),
                  side: BorderSide(
                      width: 3, color: Theme.of(context).colorScheme.secondary),
                ),
                Chip(
                  label: TextButton(
                    onPressed: () => myTheme.selectTextSize(ThemePreDifendTextSize.Large),
                    child: Text('Large'),
                  ),
                  side: BorderSide(
                      width: 3, color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

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

  void updateUser(BuildContext context) async {
    if (_controller.text.isEmpty || _controller == null) {
      return;
    }
    // await FirebaseStorage.instance.ref().child('users').child(user.userId).delete();
    var uploadTask = await FirebaseStorage.instance
        .ref()
        .child('users')
        .child(user.userId)
        .child('profile_pictures')
        .child(xFile!.path.substring(xFile!.path.lastIndexOf('/') + 1))
        .putData(await xFile!.readAsBytes());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.userId)
        .update({
      'displayName': _controller.text.trim(),
      'profilePic': await uploadTask.ref.getDownloadURL()
    });
    Navigator.of(context).pop();
  }
}
