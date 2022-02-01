import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';

enum CallSituations {
  Dialing,
  InCall,
  Done,
}

class CallPage extends StatefulWidget {
  static const ROUTE_NAME = '/callScreen';
  String? name;
  String? callType;
  String? contactId;
  String? roomId;
  bool? isOffering;

  CallPage(
      {this.name, this.callType, this.contactId, this.isOffering, this.roomId});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late CallSituations _callSituations = CallSituations.Dialing;

  late String docID;

  bool isFirst = true;
  RTCVideoRenderer _localVideoRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteVideoRenderer = RTCVideoRenderer();

  RTCPeerConnection? peerConnection;

  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final _roomRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('Room')
      .doc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(
        'THIS IS SEROIS  isOffering : ${widget.isOffering} and contactID : ${widget.contactId} and RoomID : ${widget.roomId}');
    docID = widget.roomId ?? '';
    _localVideoRenderer.initialize();
    _remoteVideoRenderer.initialize();
    initLocalCamera();
    if (widget.isOffering!) {
      print('this is inside of if');
      createOffer();
      print('this is contactId : ${widget.contactId}');
    }
    // navigator.getUserMedia(mediaConstraints) old way
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: RTCVideoView(_remoteVideoRenderer),
          ),
          Expanded(
            child: RTCVideoView(
              _localVideoRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    createAnswer(widget.roomId!);
                  },
                  icon: Icon(Icons.check),
                  label: Text('answer')),
              ElevatedButton.icon(
                  onPressed: () {
                    hangUp(docID);
                  },
                  icon: Icon(Icons.cancel),
                  label: Text('cancel')),
              ElevatedButton.icon(
                  onPressed: () {
                    setState(() {});
                  },
                  icon: Icon(Icons.restart_alt),
                  label: Text('state')),
            ],
          )
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Container(
  //       padding: EdgeInsets.fromLTRB(10, 50, 10, 50),
  //       width: double.infinity,
  //       height: double.infinity,
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: [
  //             Colors.deepOrange,
  //             Colors.orange,
  //             Colors.cyan,
  //             Colors.deepPurple
  //           ],
  //           begin: Alignment.topRight,
  //           end: Alignment.bottomLeft,
  //         ),
  //       ),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.max,
  //         children: [
  //           Text(widget.name!),
  //           SizedBox(
  //             height: 20,
  //           ),
  //           Text(
  //               'Dialling'), // TODO:'00:00' after Dialing must be replaced by CallTimer()
  //           Expanded(
  //             child: FittedBox(
  //               fit: BoxFit.contain,
  //               clipBehavior: Clip.hardEdge,
  //               child: CircleAvatar(
  //                 radius: 500,
  //                 // foregroundImage: AssetImage('assets/images/groom.png'),
  //                 child: RTCVideoView(
  //                   _localVideoRenderer,
  //                   mirror: true,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisSize: MainAxisSize.max,
  //             children: [
  //               ClipOval(
  //                 child: IconButton(
  //                     onPressed: () {}, icon: Icon(Icons.video_camera_front)),
  //               ),
  //               ClipOval(
  //                 child:
  //                     IconButton(onPressed: () {}, icon: Icon(Icons.mic_off)),
  //               ),
  //               ClipOval(
  //                   child: IconButton(
  //                 onPressed: () {},
  //                 icon: Icon(Icons.cancel_outlined),
  //               )),
  //             ],
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  initLocalCamera() async {
    _localStream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': true});
    _localVideoRenderer.srcObject = _localStream;
    // _localVideoRenderer.srcObject = await navigator.mediaDevices
    //     .getUserMedia({'video': true, 'audio': true});
    print('this source Object');
    print('this suarce  ${_localVideoRenderer.srcObject != null}');
    setState(() {});
  }

  void createOffer() async {
    print('this is creating offer');
    var roomId = _roomRef.id;
    docID = roomId;
    final _contactRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.contactId)
        .collection('Room')
        .doc(roomId);
    Map<String, dynamic> configuration = {
      'iceServers': [
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302'
          ]
        }
      ]
    };
    Map<String, dynamic> offerSdpConstraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': []
    };
    peerConnection =
        await createPeerConnection(configuration,offerSdpConstraints);

    peerConnection!.addStream(_localStream!);

    // _localStream!.getTracks().forEach((track) => peerConnection!.addTrack(track,_localStream!));

    print(
        'this is offer local streams lenght : ${peerConnection!.getLocalStreams().length}');

    // registerPeerConnectionListeners();
    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('this offer Connection state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      print("this offer Add remote stream");
      // onAddRemoteStream?.call(stream);
      _remoteStream = stream;
      _remoteVideoRenderer.srcObject = _remoteStream;
      print(
          'this is offer remote  streams on addStream lenght : ${peerConnection!.getRemoteStreams().length}');
      setState(() {});
    };

    peerConnection!.onIceCandidate = (RTCIceCandidate candidate) async {
      if (candidate.candidate != null) {
        /// PROBABLY SHOULD UPLOAD THIS TO FIREBASE
        final ref = await _roomRef
            .collection('callerCandidates')
            .add(candidate.toMap());
        // _contactRef.collection('callerCandidates').add(candidate.toMap());
        await _contactRef
            .collection('callerCandidates')
            .doc(ref.id)
            .set(candidate.toMap());
        // showing it locally
        print(
          'this is offer candidate' +
              json.encode({
                'candidate': candidate.candidate,
                'sdpMid': candidate.sdpMid,
                'sdpMlineIndex': candidate.sdpMlineIndex
              }),
        );
      }
    };

    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    print('this Create Offer $offer');
    await _roomRef.set({'offer': offer.toMap()});
    await _contactRef.set({'offer': offer.toMap()});
    await _roomRef
        .update({'offerFrom': FirebaseAuth.instance.currentUser!.uid});
    await _contactRef
        .update({'offerFrom': FirebaseAuth.instance.currentUser!.uid});
    await _roomRef.update({'roomId': _roomRef.id});
    await _contactRef.update({'roomId': _roomRef.id});

    print("this NEW ROOM CREATED WITH SDP OFFER ROOMID : $roomId");

    /// Tracks
    peerConnection!.onTrack = (RTCTrackEvent event) {
      print('this offer Got remote track : ${event.streams[0]}');

      event.streams[0].getTracks().forEach((element) {
        print('this add a track to the remoteStream $element');
        _remoteStream!.addTrack(element);
      });
    };

    /// setting up  a listener for remote sdp
    /// i really dont lnow if we should do the below for contacts also
    _roomRef.snapshots().listen((snapShot) async {
      print('this offer  Got updated room: ${snapShot.data()}');
      Map<String, dynamic> data = snapShot.data() as Map<String, dynamic>;
      if (data['answer'] != null) {
        var answer = RTCSessionDescription(
            data['answer']['sdp'], data['answer']['type']);
        print('this offer someone tried to connect');

        await peerConnection!.setRemoteDescription(answer);
      }
    });

    /// listening on remote ICE candidates
    _roomRef.collection('calleeCandidates').snapshots().listen((snapShot) {
      snapShot.docs.forEach((element) {
        Map<String, dynamic> data = element.data() as Map<String, dynamic>;
        print('this offer Got New Remote Ice Candidate ${jsonEncode(data)}');
        var remoteCandidate = RTCIceCandidate(
            data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
        peerConnection!.addCandidate(remoteCandidate);
      });
      // snapShot.docChanges.forEach((element) {
      //   if (element.type == DocumentChangeType.added) {
      //     Map<String, dynamic> data =
      //         element.doc.data() as Map<String, dynamic>;
      //     print('Got New Remote Ice Candidate ${jsonEncode(data)}');
      //     var remoteCandidate = RTCIceCandidate(
      //         data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
      //     peerConnection!.addCandidate(remoteCandidate);
      //   }
      // });
    });
  }

  void createAnswer(String docId) async {
    print('this is creating answer');
    final _myRoomRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Room')
        .doc(docId);
    final _contactsRoomRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.contactId)
        .collection('Room')
        .doc(docId);
    Map<String, dynamic> configuration = {
      'iceServers': [
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302'
          ]
        }
      ]
    };
    Map<String, dynamic> offerSdpConstraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': []
    };
    var roomSnapshot = await _myRoomRef.get();
    // var roomSnapshot2 = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('Room').get();
    // var roomSnapshot = roomSnapshot2.docs[0];
    print('this answer Got room ${roomSnapshot.exists}');
    if (roomSnapshot.exists) {
      print(
          'this answer Create PeerConnection with configuration: $configuration');
      peerConnection = await createPeerConnection(configuration,offerSdpConstraints);
      // _localStream = await initLocalCamera();
      peerConnection!.addStream(_localStream!);

      ///tracks

      // _localStream!.getTracks().forEach((track) {
      //   peerConnection!.addTrack(track,_localStream!);
      // });

      peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
        print('this answer Connection state change: $state');
      };

      peerConnection?.onAddStream = (MediaStream stream) {
        print("this answer Add remote stream");
        // onAddRemoteStream?.call(stream);
        _remoteStream = stream;
        _remoteVideoRenderer.srcObject = _remoteStream;
        setState(() {});
      };
      // registerPeerConnectionListeners();

      // _localStream?.getTracks().forEach((track) {
      //   peerConnection?.addTrack(track, _localStream!);
      // });

      // Code for collecting ICE candidates below
      var calleeCandidatesCollection =
          _myRoomRef.collection('calleeCandidates');
      var contactCalleeCandidateCollection =
          _contactsRoomRef.collection('calleeCandidates');

      peerConnection!.onIceCandidate = (RTCIceCandidate candidate) async {
        if (candidate == null) {
          print('this onIceCandidate: complete!');
          return;
        }
        print('this onIceCandidate: ${candidate.toMap()}');
        calleeCandidatesCollection.add(candidate.toMap()).then((value) =>
            contactCalleeCandidateCollection
                .doc(value.id)
                .set(candidate.toMap()));
        // contactCalleeCandidateCollection.doc(ref.id).set(candidate.toMap());
      };
      // Code for collecting ICE candidate above

      ///TRACKS THING
      peerConnection!.onTrack = (RTCTrackEvent event) {
        print('this answer Got Remote track : ${event.streams[0]}');
        event.streams[0].getTracks().forEach((track) {
          print('this answer Add a track to the remoteStreame : $track');
          _remoteStream!.addTrack(track);
        });
      };
      // peerConnection?.onTrack = (RTCTrackEvent event) {
      //   print('Got remote track: ${event.streams[0]}');
      //   event.streams[0].getTracks().forEach((track) {
      //     print('Add a track to the remoteStream: $track');
      //     _remoteStream?.addTrack(track);
      //   });
      // };

      // Code for creating SDP answer below
      var data = roomSnapshot.data() as Map<String, dynamic>;
      print('this Got offer $data');
      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      var answer = await peerConnection!.createAnswer();
      print('Created Answer $answer');

      await peerConnection!.setLocalDescription(answer);

      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };

      await _myRoomRef.update(roomWithAnswer);
      await _contactsRoomRef.update(roomWithAnswer);

      // Finished creating SDP answer

      // Listening for remote ICE candidates below
      _myRoomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        snapshot.docs.forEach((element) {
          var data = element.data() as Map<String, dynamic>;
          print(data);
          print('Got new remote ICE candidate: $data');
          final candidate = RTCIceCandidate(
              data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
          peerConnection!.addCandidate(candidate);
        });
        // snapshot.docChanges.forEach((document) {
        //   var data = document.doc.data() as Map<String, dynamic>;
        //   print(data);
        //   print('Got new remote ICE candidate: $data');
        //   final candidate = RTCIceCandidate(
        //       data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
        //   peerConnection!.addCandidate(candidate);
        // });
      });
    }
  }

  @override
  void dispose() {

    super.dispose();
    hangUp(docID);
    _localVideoRenderer.dispose();
    _remoteVideoRenderer.dispose();
  }
  
  void hangUp(String docId)async{
    _localStream!.getTracks().forEach((element) {
      element.stop();
    });
    if(_remoteStream !=null){
      _remoteStream!.getTracks().forEach((element) {
        element.stop();
      });
    }

    if(peerConnection != null){
      peerConnection!.close();
    }
    _localStream!.dispose();
    _remoteStream!.dispose();
    _localVideoRenderer.dispose();
    _remoteVideoRenderer.dispose();
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('Room').doc(docId).delete();
    await FirebaseFirestore.instance.collection('users').doc(widget.contactId).collection('Room').doc(docId).delete();
    Navigator.of(context).pop();
    }
  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE connection state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      print("Add remote stream");
      // onAddRemoteStream?.call(stream);
      setState(() {});
      _remoteStream = stream;
      _remoteVideoRenderer.srcObject = _remoteStream;
    };
  }
}

class CallTimer extends StatefulWidget {
  @override
  _CallTimerState createState() => _CallTimerState();
}

class _CallTimerState extends State<CallTimer> {
  late Timer _timer;
  int _timeExpandedBySeconds = 0;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeExpandedBySeconds += 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text('$_timeExpandedBySeconds');
  }
}
