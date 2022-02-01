import 'dart:math';

import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String chatText;
  final String chatMedia;
  final bool isFromMe;
  final Key textKey;
  ChatBubble(this.chatText, this.isFromMe, this.textKey, this.chatMedia);
  @override
  Widget build(BuildContext context) {
    return Row(

        mainAxisAlignment:
            isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
          
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color:
                  isFromMe ? Theme.of(context).primaryColorDark : Theme.of(context).colorScheme.secondaryVariant,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft:
                      isFromMe ? Radius.circular(10) : Radius.circular(-5),
                  bottomRight:
                      isFromMe ? Radius.circular(-5) : Radius.circular(10)),
            ),
            width: chatText.isEmpty ? 300 : min(chatText.length * 15 + 20, 300),

            child: Column(
              children: [
                if (chatMedia.isNotEmpty && chatMedia.contains('.jpg?alt='))
                  Image.network(
                    chatMedia,
                    width: 300,
                    fit: BoxFit.cover,
                  ),
                if (chatMedia.isNotEmpty && !chatMedia.contains('.jpg?alt='))
                  Row(
                    children: [
                      CircularProgressIndicator.adaptive(),
                      Text(chatMedia)
                    ],
                  ),
                Text(
                  chatText,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      // TODO : implement settings based sizes like meduim , large , extra large
                      fontSize: 15),
                )
              ],
            ),
            // chatText.isEmpty
            //     ? chatMedia.contains('.jpg?alt=')
            //         ? Image.network(chatMedia,width: 300,fit: BoxFit.cover,)
            //         : Row(
            //             children: [
            //               CircularProgressIndicator.adaptive(),
            //               Text(chatMedia)
            //             ],
            //           )
            //     : Text(
            //         chatText,
            //         softWrap: true,
            //         overflow: TextOverflow.clip,
            //         style: TextStyle(
            //             color:
            //                 Theme.of(context).accentTextTheme.headline1!.color,
            //             // TODO : implement settings based sizes like meduim , large , extra large
            //             fontSize: 15),
            //       ),
          ),
        ]);
  }
}
