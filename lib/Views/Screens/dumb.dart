import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class DumbPage extends StatefulWidget {
  const DumbPage({ Key? key }) : super(key: key);

  @override
  _DumbPageState createState() => _DumbPageState();
}

class _DumbPageState extends State<DumbPage> {

  RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  bool showRTC = false;

  @override
  initState(){
    super.initState();
    _localRenderer.initialize();
    initCamera();
  }


  



  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            ElevatedButton(onPressed: (){
              initCamera();
            }, child: Text('be dumb')),
            if(showRTC)
            Expanded(child: CircleAvatar(child: RTCVideoView(_localRenderer,mirror: true,),radius: 50,)),
            if(showRTC)
            Text('RTC is shown')
          ],
        ),
      ),
    );
  }

  void initCamera() async {
    _localRenderer.srcObject = await navigator.mediaDevices.getUserMedia({
      'video' : true,
      'audio' : true
    });
    
    showRTC = true;
    setState(() {
      
    });
  }
}