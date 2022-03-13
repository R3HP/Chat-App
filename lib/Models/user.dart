import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class MyUser {
  String phoneNumber;
  String? displayName;
  String userId;
  String profilepic = '';
  MyUser(
      {required this.phoneNumber,
      this.displayName = '',
      required this.userId,
      required this.profilepic});
}

class UserManager with ChangeNotifier {
  late MyUser _currentUser;
  List<MyUser> _currentUserContacts = [];
  List<Contact> _phoneContacts = [];

  List<String> _groupUserIds = [];

  void addtogroupdUserIds(String userId){
    _groupUserIds.add(userId);
    notifyListeners();
  }

  List<String> get groupUserIds{
    _groupUserIds.add(FirebaseAuth.instance.currentUser!.uid);
    return List.from(_groupUserIds);
  }

  Future<List<MyUser>> getUserContacts() async {
    _currentUserContacts.clear();
    await setContacts();
    return List.from(_currentUserContacts);
  }

  void createUser(String phoneNumber, String userId, String? displayName,
      String profilePic) async {
    _currentUser = MyUser(
        phoneNumber: phoneNumber,
        userId: userId,
        displayName: displayName,
        profilepic: profilePic);
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'chats': [],
      'channels': []
    });
  }

  MyUser get currentUser {
    return _currentUser;
  }

  Future<void> setContacts() async {
    await setUpContacts();
    var firestore = FirebaseFirestore.instance.collection('users');
    print('2');
    for (final contact in _phoneContacts) {
      print('3');
      for (final phone in contact.phones) {
        print('4');
        final res = await firestore
            .where('phoneNumber', isEqualTo: phone.normalizedNumber)
            .get();
        print('5');
        res.docs.forEach((querySnapShot) {
          print('6');
          _currentUserContacts.add(MyUser(
              phoneNumber: querySnapShot.data()['phoneNumber'],
              userId: querySnapShot.id,
              profilepic: querySnapShot.data()['profilePic'] ?? '',
              displayName: contact.displayName));
        });
      }
    }
  }

  Future<void> setUpContacts() async {
    print('setUpContacts');
    if (await FlutterContacts.requestPermission()) {
      _phoneContacts = await FlutterContacts.getContacts(withProperties: true);
    }
    print(_phoneContacts);
  }

  void createCurrentUserContact(
      Map<String, dynamic> data, String userId, String displayName) {
    _currentUserContacts.add(MyUser(
        phoneNumber: data['phoneNumber'],
        profilepic: data['profilePic'],
        userId: userId,
        displayName: displayName));
    notifyListeners();
  }

  String? getDisplayNameForPhone(String phoneNumber) {
    print(phoneNumber);
    print(_currentUserContacts);
    MyUser user = _currentUserContacts.firstWhere(
        (element) => element.phoneNumber == phoneNumber,
        orElse: () => MyUser(
            phoneNumber: phoneNumber,
            userId: '',
            profilepic: '',
            displayName: ''));
    print(user);
    return user.displayName;
  }
}
