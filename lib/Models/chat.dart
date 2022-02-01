
import 'dart:convert';

class Chat {
  final String chatName;
  final String? chatPhoneNumber;

  Chat(this.chatName,[this.chatPhoneNumber]);


  String toJson(){
    return jsonEncode({
      'chatName' : this.chatName,
      'chatPhoneNumber' : this.chatPhoneNumber ?? ''
    });
  }
  
}