import 'package:chat_app/Models/user.dart';
import 'package:chat_app/Views/Screens/contacts_screen.dart';
import 'package:chat_app/Views/Screens/create_group.dart';
import 'package:chat_app/Views/Widgets/chats_list_widget.dart';
import 'package:chat_app/Views/Widgets/my_drawer_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          actions: [PopupMenuButton<String>(
              onSelected: (val) => handlePopUpMenu(val,context),
              itemBuilder: (context) => ['New Group' , 'New Channel' , 'LogOut'].map((e) => 
              PopupMenuItem<String>(
                value: e,
                child: Text(e))
              ).toList(),
            )],
          toolbarHeight: 50,
          title: const Text('Chat'),
          centerTitle: true,
          primary: true,
          
          bottom: TabBar(tabs: [
            Text('All'),
            Text('PV'),
            Text('Groups'),
            Text('Channels')
          ]),
          
        ),
        drawer: MyDrawer(),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.create),
          onPressed: (){
          // Provider.of<UserManager>(context,listen: false).setContacts();
          Navigator.of(context).pushNamed(ContactsPage.ROUTE_NAME);
        }),
        body: TabBarView(children: [
          ChatList(),
          ChatList(filter: 'Private',),
          ChatList(filter: 'Group',),
          ChatList(filter: 'Channel',)
        ]),
      ),
    );
  }

  void handlePopUpMenu(String value,BuildContext context) {
    switch(value){
      case 'New Group':
      //CREATE A NEW GROUP
      Navigator.of(context).pushNamed(CreateGroupPage.ROUTE_NAME);
      break;
      case 'New Channel':
      //CREATE A NEW CHANNEL
      break;
      case 'LogOut':
      FirebaseAuth.instance.signOut();
      break;
    }
  }
}
