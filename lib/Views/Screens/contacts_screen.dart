import 'package:chat_app/Views/Widgets/contact_list.dart';
import 'package:flutter/material.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({Key? key}) : super(key: key);
  static const ROUTE_NAME = '/contacts';

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body:ContactsList(),
        
      
    );
  }
}
