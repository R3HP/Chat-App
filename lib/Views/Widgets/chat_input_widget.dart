import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatInputWidget extends StatelessWidget {
  Function createChatDoc;
  ChatInputWidget(this.createChatDoc);
  String? mediaMessage;

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 7,
      child: Row(
        children: [
          Icon(Icons.emoji_emotions),
          Expanded(
            child: TextField(
              controller: _controller,
            ),
          ),
          IconButton(
              onPressed: () => showMyBottomSheet(context),
              icon: Icon(Icons.control_point)),
          IconButton(
            onPressed: () {
              createChatDoc(
                _controller.text.trim(),
                ''
              );
              _controller.clear();
            },
            icon: Icon(Icons.send),
            color: Colors.amber,
          )
        ],
      ),
    );
  }

  showMyBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                createBottunCard('Use Camera', Icons.camera),
                createBottunCard('Use Gallery', Icons.storage_rounded),
                createBottunCard('Send File', Icons.document_scanner_rounded),
                createBottunCard('Send Location', Icons.location_on_rounded),
              ],
            ),
          );
        });
  }

  Card createBottunCard(String label, IconData icondata) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => handleBottomButtuns(label),
        child: Column(
          children: [
            Icon(icondata),
            SizedBox(
              height: 10,
            ),
            Text(label)
          ],
        ),
      ),
    );
  }

  handleBottomButtuns(String label) {
    switch (label) {
      case 'Use Camera':
        handleUseCamera(ImageSource.camera);
        break;
      case 'Use Gallery':
        handleUseCamera(ImageSource.gallery);
        break;
      case 'Send File':
        handleFile();
        break;
    }
  }

  void handleUseCamera(ImageSource source) async {
    var imagePicker = ImagePicker();
    try {
      var xfile = await imagePicker.pickImage(source: source, imageQuality: 50);
      // var file = await File(xfile!.path.substring(xfile.path.lastIndexOf('/')+1)).create();
      // print('file path ${file.path}');
      var uploadTask = await FirebaseStorage.instance
          .ref()
          .child('chats')
          .child('images')
          .child(xfile!.path.substring(xfile.path.lastIndexOf('/') + 1))
          .putData(await xfile.readAsBytes());

      mediaMessage = await uploadTask.ref.getDownloadURL();
      createChatDoc('', mediaMessage);
    } catch (err) {
      throw err;
    }
    // print('download${await uploadTask.ref.getDownloadURL()}');
  }

  void handleFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      //  List<File> files = result.paths.map((path) => File(path!)).toList();
      Uint8List fileBytes = result.files.first.bytes!;
      String fileName = result.files.first.name;
      var uploadTask = await FirebaseStorage.instance
          .ref()
          .child('chats')
          .child('files')
          .child(fileName)
          .putData(fileBytes);
      mediaMessage = await uploadTask.ref.getDownloadURL();
      createChatDoc('', mediaMessage);
    } else {
      // User canceled the picker
    }
  }
}
