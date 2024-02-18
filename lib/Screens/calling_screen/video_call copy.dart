// // //*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************
// // androidIosBarrier
// import 'dart:async';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hoochat_web/Configs/Dbkeys.dart';
// import 'package:hoochat_web/Configs/Dbpaths.dart';
// import 'package:hoochat_web/Configs/app_constants.dart';
// import 'package:hoochat_web/Configs/optional_constants.dart';
// import 'package:hoochat_web/Screens/homepage/homepage.dart';
// import 'package:hoochat_web/Services/Providers/Observer.dart';
// import 'package:hoochat_web/Services/Providers/call_history_provider.dart';
// import 'package:hoochat_web/Services/localization/language_constants.dart';
// import 'package:hoochat_web/Models/call.dart';
// import 'package:hoochat_web/Utils/call_utilities.dart';
// import 'package:hoochat_web/Utils/determine_screen.dart';
// import 'package:hoochat_web/Utils/setStatusBarColor.dart';
// import 'package:flutter/material.dart';
// import 'package:pip_view/pip_view.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// class VideoCall extends StatefulWidget {
//   final String channelName;
//   final String currentuseruid;
//   final SharedPreferences prefs;
//   final Call call;
//   final ClientRoleType role;
//   const VideoCall(
//       {Key? key,
//       required this.call,
//       required this.prefs,
//       required this.currentuseruid,
//       required this.channelName,
//       required this.role})
//       : super(key: key);

//   @override
//   _VideoCallState createState() => _VideoCallState();
// }

// class _VideoCallState extends State<VideoCall> {
//   bool islandscapeMode = false;
//   final _users = <int>[];
//   final _infoStrings = <String>[];
//   bool muted = false;
//   late RtcEngine _engine;
//   bool isspeaker = true;
//   bool isalreadyendedcall = false;
//   @override
//   void dispose() {
//     // clear users
//     _users.clear();
//     // destroy sdk
//     _engine.leaveChannel();
//     _engine.stopPreview();
//     _engine.release();

//     super.dispose();
//   }

//   bool isPickedup = false;
//   double screenHeight = 0.0;
//   double screenWidth = 0.0;
//   Stream<DocumentSnapshot>? stream;
//   @override
//   void initState() {
//     super.initState();
//     initAgora();

//     stream = FirebaseFirestore.instance
//         .collection(DbPaths.collectionusers)
//         .doc(widget.currentuseruid == widget.call.callerId
//             ? widget.call.receiverId
//             : widget.call.callerId)
//         .collection(DbPaths.collectioncallhistory)
//         .doc(widget.call.timeepoch.toString())
//         .snapshots();

//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       final observer = Provider.of<Observer>(this.context, listen: false);
//       observer.setisOngoingCall(true);
//     });
//   }

//   String? mp3Uri;
//   bool _localUserJoined = false;
//   bool isfakeloader = false;
//   int? _remoteUid;
//   runFakeloader() {
//     Future.delayed(const Duration(milliseconds: 400), () {
//       setState(() {
//         isfakeloader = false;
//       });
//     });
//   }

//   Future<void> initAgora() async {
//     //create the engine
//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(const RtcEngineContext(
//       appId: Agora_APP_ID,
//       channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//     ));
//     VideoEncoderConfiguration configuration = VideoEncoderConfiguration(
//         dimensions: VideoDimensions(
//             height: AgoraVideoResultionHEIGHT,
//             width: AgoraVideoResultionWIDTH));

//     _engine.registerEventHandler(RtcEngineEventHandler(onError: (type, code) {
//       setState(() {
//         final info = 'onError: $code';
//         _infoStrings.add(info);
//       });
//     }, onJoinChannelSuccess: (conn, elapsed) {
//       if (widget.call.callerId == widget.currentuseruid) {
//         _localUserJoined = true;
//         setState(() {});
//         FirebaseFirestore.instance
//             .collection(DbPaths.collectionusers)
//             .doc(widget.call.callerId)
//             .collection(DbPaths.collectioncallhistory)
//             .doc(widget.call.timeepoch.toString())
//             .set({
//           'TYPE': 'OUTGOING',
//           'ISVIDEOCALL': widget.call.isvideocall,
//           'PEER': widget.call.receiverId,
//           'TIME': widget.call.timeepoch,
//           'DP': widget.call.receiverPic,
//           'ISMUTED': false,
//           'TARGET': widget.call.receiverId,
//           'ISJOINEDEVER': false,
//           'STATUS': 'calling',
//           'STARTED': null,
//           'ENDED': null,
//           'CALLERNAME': widget.call.callerName,
//           'CHANNEL': conn.channelId ?? "",
//           'UID': conn.localUid ?? 0,
//         }, SetOptions(merge: true));
//         FirebaseFirestore.instance
//             .collection(DbPaths.collectionusers)
//             .doc(widget.call.receiverId)
//             .collection(DbPaths.collectioncallhistory)
//             .doc(widget.call.timeepoch.toString())
//             .set({
//           'TYPE': 'INCOMING',
//           'ISVIDEOCALL': widget.call.isvideocall,
//           'PEER': widget.call.callerId,
//           'TIME': widget.call.timeepoch,
//           'DP': widget.call.callerPic,
//           'ISMUTED': false,
//           'TARGET': widget.call.receiverId,
//           'ISJOINEDEVER': true,
//           'STATUS': 'missedcall',
//           'STARTED': null,
//           'ENDED': null,
//           'CALLERNAME': widget.call.callerName,
//           'CHANNEL': conn.channelId ?? "",
//           'UID': conn.localUid ?? 0,
//         }, SetOptions(merge: true));
//       }
//       WakelockPlus.enable();
//     }, onLeaveChannel: (conn, stats) {
//       setState(() {
//         _infoStrings.add('onLeaveChannel');
//         _users.clear();
//       });
//       if (isalreadyendedcall == false) {
//         FirebaseFirestore.instance
//             .collection(DbPaths.collectionusers)
//             .doc(widget.call.callerId)
//             .collection(DbPaths.collectioncallhistory)
//             .doc(widget.call.timeepoch.toString())
//             .set({
//           'STATUS': 'ended',
//           'ENDED': DateTime.now(),
//         }, SetOptions(merge: true));
//         FirebaseFirestore.instance
//             .collection(DbPaths.collectionusers)
//             .doc(widget.call.receiverId)
//             .collection(DbPaths.collectioncallhistory)
//             .doc(widget.call.timeepoch.toString())
//             .set({
//           'STATUS': 'ended',
//           'ENDED': DateTime.now(),
//         }, SetOptions(merge: true));
//       }
//       WakelockPlus.disable();
//     }, onUserJoined: (conn, uid, elapsed) {
//       setState(() {
//         _users.add(conn.localUid ?? 0);
//       });

//       if (widget.currentuseruid == widget.call.callerId) {
//         FirebaseFirestore.instance
//             .collection(DbPaths.collectionusers)
//             .doc(widget.call.callerId)
//             .collection(DbPaths.collectioncallhistory)
//             .doc(widget.call.timeepoch.toString())
//             .set({
//           'STARTED': DateTime.now(),
//           'STATUS': 'pickedup',
//           'ISJOINEDEVER': true,
//         }, SetOptions(merge: true));
//         FirebaseFirestore.instance
//             .collection(DbPaths.collectionusers)
//             .doc(widget.call.receiverId)
//             .collection(DbPaths.collectioncallhistory)
//             .doc(widget.call.timeepoch.toString())
//             .set({
//           'STARTED': DateTime.now(),
//           'STATUS': 'pickedup',
//         }, SetOptions(merge: true));
//         FirebaseFirestore.instance
//             .collection(DbPaths.collectionusers)
//             .doc(widget.call.callerId)
//             .set({
//           Dbkeys.videoCallMade: FieldValue.increment(1),
//         }, SetOptions(merge: true));
//         FirebaseFirestore.instance
//             .collection(DbPaths.collectionusers)
//             .doc(widget.call.receiverId)
//             .set({
//           Dbkeys.videoCallRecieved: FieldValue.increment(1),
//         }, SetOptions(merge: true));
//         FirebaseFirestore.instance
//             .collection(DbPaths.collectiondashboard)
//             .doc(DbPaths.docchatdata)
//             .set({
//           Dbkeys.videocallsmade: FieldValue.increment(1),
//         }, SetOptions(merge: true));

//         setState(() {
//           isPickedup = true;
//           _remoteUid = conn.localUid;
//           isfakeloader = true;
//         });
//       }
//       WakelockPlus.enable();
//     }, onUserOffline: (conn, uid, elapsed) {
//       setState(() {
//         _users.remove(conn.localUid);
//       });

//       if (isalreadyendedcall == false) {
//         FirebaseFirestore.instance
//             .collection(DbPaths.collectionusers)
//             .doc(widget.call.callerId)
//             .collection(DbPaths.collectioncallhistory)
//             .doc(widget.call.timeepoch.toString())
//             .set({
//           'STATUS': 'ended',
//           'ENDED': DateTime.now(),
//         }, SetOptions(merge: true));
//         FirebaseFirestore.instance
//             .collection(DbPaths.collectionusers)
//             .doc(widget.call.receiverId)
//             .collection(DbPaths.collectioncallhistory)
//             .doc(widget.call.timeepoch.toString())
//             .set({
//           'STATUS': 'ended',
//           'ENDED': DateTime.now(),
//         }, SetOptions(merge: true));
//         //----------
//       }
//     }, onFirstRemoteVideoFrame: (conn, uid, width, height, elapsed) {
//       setState(() {
//         final info = 'firstRemoteVideo: $uid ${width}x $height';
//         _infoStrings.add(info);
//       });
//     }));

//     await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//     await _engine.enableVideo();
//     await _engine.startPreview();
//     await _engine.setVideoEncoderConfiguration(configuration);

//     await _engine.joinChannel(
//       token: widget.call.token ?? '',
//       channelId: widget.channelName,
//       uid: 0,
//       options: const ChannelMediaOptions(),
//     );
//   }

//   // List<Widget> _getRenderViews() {
//   //   final List<StatefulWidget> list = [];
//   //   if (widget.role == ClientRoleType.clientRoleBroadcaster) {
//   //     list.add(RtcLocalView.SurfaceView());
//   //   }
//   //   _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(
//   //         uid: uid,
//   //         channelId: widget.channelName,
//   //       )));
//   //   return list;
//   // }

//   void _onToggleSpeaker() {
//     setState(() {
//       isspeaker = !isspeaker;
//     });
//     _engine.setEnableSpeakerphone(isspeaker);
//   }

//   Widget _toolbar(
//     BuildContext context,
//     bool isshowspeaker,
//     String? status,
//   ) {
//     final observer = Provider.of<Observer>(this.context, listen: true);
//     if (widget.role == ClientRoleType.clientRoleAudience) return Container();

//     return Container(
//       alignment: Alignment.bottomCenter,
//       padding: const EdgeInsets.symmetric(vertical: 35),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           isshowspeaker == true
//               ? SizedBox(
//                   width: 65.67,
//                   child: RawMaterialButton(
//                     onPressed: _onToggleSpeaker,
//                     child: Icon(
//                       isspeaker
//                           ? Icons.volume_mute_rounded
//                           : Icons.volume_off_sharp,
//                       color: isspeaker ? Colors.white : colorCallbuttons,
//                       size: 22.0,
//                     ),
//                     shape: CircleBorder(),
//                     elevation: 2.0,
//                     fillColor: isspeaker ? colorCallbuttons : Colors.white,
//                     padding: const EdgeInsets.all(12.0),
//                   ))
//               : SizedBox(height: 0, width: 65.67),
//           status != 'ended' && status != 'rejected'
//               ? SizedBox(
//                   width: 65.67,
//                   child: RawMaterialButton(
//                     onPressed: _onToggleMute,
//                     child: Icon(
//                       muted ? Icons.mic_off : Icons.mic,
//                       color: muted ? Colors.white : colorCallbuttons,
//                       size: 22.0,
//                     ),
//                     shape: CircleBorder(),
//                     elevation: 2.0,
//                     fillColor: muted ? colorCallbuttons : Colors.white,
//                     padding: const EdgeInsets.all(12.0),
//                   ))
//               : SizedBox(height: 42, width: 65.67),
//           SizedBox(
//             width: 65.67,
//             child: RawMaterialButton(
//               onPressed: () async {
//                 setState(() {
//                   isalreadyendedcall =
//                       status == 'ended' || status == 'rejected' ? true : false;
//                 });

//                 _onCallEnd(context);
//               },
//               child: Icon(
//                 status == 'ended' || status == 'rejected'
//                     ? Icons.close
//                     : Icons.call,
//                 color: Colors.white,
//                 size: 35.0,
//               ),
//               shape: CircleBorder(),
//               elevation: 2.0,
//               fillColor: status == 'ended' || status == 'rejected'
//                   ? Colors.black
//                   : Colors.redAccent,
//               padding: const EdgeInsets.all(15.0),
//             ),
//           ),
//           isWideScreen(MediaQuery.of(context).size.width) == true
//               ? SizedBox()
//               : status == 'ended' || status == 'rejected'
//                   ? SizedBox(
//                       width: 65.67,
//                     )
//                   : SizedBox(
//                       width: 65.67,
//                       child: RawMaterialButton(
//                         onPressed: _onSwitchCamera,
//                         child: Icon(
//                           Icons.switch_camera,
//                           color: colorCallbuttons,
//                           size: 20.0,
//                         ),
//                         shape: CircleBorder(),
//                         elevation: 2.0,
//                         fillColor: Colors.white,
//                         padding: const EdgeInsets.all(12.0),
//                       ),
//                     ),
//           status == 'ended' || status == 'rejected'
//               ? SizedBox(
//                   width: 0,
//                 )
//               : SizedBox(
//                   width: 65.67,
//                   child: RawMaterialButton(
//                     onPressed: () {
//                       setState(() {
//                         islandscapeMode = !islandscapeMode;
//                       });
//                     },
//                     child: Icon(
//                       Icons.width_wide_outlined,
//                       color: islandscapeMode == true
//                           ? Colors.white
//                           : colorCallbuttons,
//                       size: 20.0,
//                     ),
//                     shape: CircleBorder(),
//                     elevation: 2.0,
//                     fillColor: islandscapeMode == true
//                         ? colorCallbuttons
//                         : Colors.white,
//                     padding: const EdgeInsets.all(12.0),
//                   ),
//                 ),
//           status == 'pickedup'
//               ? SizedBox(
//                   width: 65.67,
//                   child: RawMaterialButton(
//                     onPressed: () {
//                       PIPView.of(context)!.presentBelow(Homepage(
//                           doc: observer.userAppSettingsDoc!,
//                           isShowOnlyCircularSpin: true,
//                           currentUserNo: widget.currentuseruid,
//                           prefs: widget.prefs));
//                     },
//                     child: Icon(
//                       Icons.open_in_full_outlined,
//                       color: Colors.black87,
//                       size: 15.0,
//                     ),
//                     shape: CircleBorder(),
//                     elevation: 2.0,
//                     fillColor: Colors.white,
//                     padding: const EdgeInsets.all(12.0),
//                   ),
//                 )
//               : SizedBox(
//                   width: 65.67,
//                 ),
//         ],
//       ),
//     );
//   }

//   bool isuserenlarged = false;
//   // onetooneview(double h, double w, bool iscallended, bool userenlarged) {
//   //   final views = _getRenderViews();

//   //   if (iscallended == true) {
//   //     return Container(
//   //       color: Colors.black,
//   //       height: h,
//   //       width: w,
//   //       child: Center(
//   //           child: Icon(
//   //         Icons.videocam_off,
//   //         size: 120,
//   //         color: Colors.red,
//   //       )),
//   //     );
//   //   } else if (userenlarged == false) {
//   //     switch (views.length) {
//   //       case 1:
//   //         return Container(
//   //             child: Column(
//   //           children: <Widget>[_videoView(views[0])],
//   //         ));

//   //       case 2:
//   //         return Container(
//   //             child: Column(
//   //           children: <Widget>[_videoView(views[1])],
//   //         ));

//   //       default:
//   //         return Container(
//   //           child: Center(child: Text('Max 2. participants allowed')),
//   //         );
//   //     }
//   //   } else if (userenlarged == true) {
//   //     switch (views.length) {
//   //       case 1:
//   //         return Container(
//   //             child: Column(
//   //           children: <Widget>[_videoView(views[0])],
//   //         ));

//   //       case 2:
//   //         return Container(
//   //             child: Column(
//   //           children: <Widget>[_videoView(views[0])],
//   //         ));

//   //       default:
//   //         return Container(
//   //           child: Center(child: Text('Max 2. participants allowed')),
//   //         );
//   //     }
//   //   }
//   // }

//   Widget _panel(
//       {required BuildContext context, bool? ispeermuted, String? status}) {
//     if (status == 'rejected') {}
//     return Container(
//       // padding: const EdgeInsets.symmetric(vertical: 28),
//       alignment: Alignment.bottomCenter,
//       child: Container(
//         // height: 73,
//         margin: const EdgeInsets.symmetric(vertical: 138),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             status == 'pickedup' && ispeermuted == true
//                 ? Flexible(
//                     child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 7,
//                           horizontal: 15,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           getTranslated(context, 'muted'),
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 15,
//                               color: Colors.black87),
//                         )),
//                   )
//                 : SizedBox(
//                     height: 0,
//                     width: 0,
//                   ),
//             status == 'calling' || status == 'ringing' || status == 'missedcall'
//                 ? Flexible(
//                     child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 7,
//                           horizontal: 15,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           getTranslated(
//                               context,
//                               widget.call.receiverId == widget.currentuseruid
//                                   ? 'connecting'
//                                   : 'calling'),
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 15,
//                               color: Colors.black87),
//                         )),
//                   )
//                 : SizedBox(
//                     height: 0,
//                     width: 0,
//                   ),
//             status == 'nonetwork'
//                 ? Flexible(
//                     child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 7,
//                           horizontal: 15,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           getTranslated(context, 'connecting'),
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 13,
//                               color: Colors.black87),
//                         )),
//                   )
//                 : SizedBox(
//                     height: 0,
//                     width: 0,
//                   ),
//             status == 'ended'
//                 ? Flexible(
//                     child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 7,
//                           horizontal: 15,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.red,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           getTranslated(context, 'callended'),
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 13,
//                               color: fiberchatWhite),
//                         )),
//                   )
//                 : SizedBox(
//                     height: 0,
//                     width: 0,
//                   ),
//             status == 'rejected'
//                 ? Flexible(
//                     child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 7,
//                           horizontal: 15,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           getTranslated(context, 'callrejected'),
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 13,
//                               color: Colors.red[500]),
//                         )),
//                   )
//                 : SizedBox(
//                     height: 0,
//                     width: 0,
//                   ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _onCallEnd(BuildContext context) async {
//     final FirestoreDataProviderCALLHISTORY firestoreDataProviderCALLHISTORY =
//         Provider.of<FirestoreDataProviderCALLHISTORY>(context, listen: false);
//     final observer = Provider.of<Observer>(context, listen: false);

//     await CallUtils.callMethods.endCall(call: widget.call);
//     DateTime now = DateTime.now();
//     observer.setisOngoingCall(false);
//     if (isalreadyendedcall == false) {
//       await FirebaseFirestore.instance
//           .collection(DbPaths.collectionusers)
//           .doc(widget.call.callerId)
//           .collection(DbPaths.collectioncallhistory)
//           .doc(widget.call.timeepoch.toString())
//           .set({'STATUS': 'ended', 'ENDED': now}, SetOptions(merge: true));
//       await FirebaseFirestore.instance
//           .collection(DbPaths.collectionusers)
//           .doc(widget.call.receiverId)
//           .collection(DbPaths.collectioncallhistory)
//           .doc(widget.call.timeepoch.toString())
//           .set({'STATUS': 'ended', 'ENDED': now}, SetOptions(merge: true));
//       //----------
//       //----------
//       //----------

//       if (widget.currentuseruid == widget.call.callerId) {
//         try {
//           await FirebaseFirestore.instance
//               .collection(DbPaths.collectionusers)
//               .doc(widget.call.callerId)
//               .collection('recent')
//               .doc('callended')
//               .delete();
//           if (isPickedup == false) {
//             await FirebaseFirestore.instance
//                 .collection(DbPaths.collectionusers)
//                 .doc(widget.call.receiverId)
//                 .collection('recent')
//                 .doc('callended')
//                 .set({
//               'id': widget.call.receiverId,
//               'ENDED': DateTime.now().millisecondsSinceEpoch,
//               'CALLERNAME': widget.call.callerName,
//             }, SetOptions(merge: true));
//           }
//         } catch (e) {}
//       } else {
//         try {
//           await FirebaseFirestore.instance
//               .collection(DbPaths.collectionusers)
//               .doc(widget.call.receiverId)
//               .collection('recent')
//               .doc('callended')
//               .delete();
//           if (isPickedup == false) {
//             await FirebaseFirestore.instance
//                 .collection(DbPaths.collectionusers)
//                 .doc(widget.call.callerId)
//                 .collection('recent')
//                 .doc('callended')
//                 .delete();
//             Future.delayed(const Duration(milliseconds: 300), () async {
//               await FirebaseFirestore.instance
//                   .collection(DbPaths.collectionusers)
//                   .doc(widget.call.callerId)
//                   .collection('recent')
//                   .doc('callended')
//                   .set({
//                 'id': widget.call.callerId,
//                 'ENDED': DateTime.now().millisecondsSinceEpoch,
//                 'CALLERNAME': widget.call.callerName,
//               });
//             });
//           }
//         } catch (e) {}
//       }
//     }
//     WakelockPlus.disable();

//     firestoreDataProviderCALLHISTORY.fetchNextData(
//         'CALLHISTORY',
//         FirebaseFirestore.instance
//             .collection(DbPaths.collectionusers)
//             .doc(widget.currentuseruid)
//             .collection(DbPaths.collectioncallhistory)
//             .orderBy('TIME', descending: true)
//             .limit(14),
//         true);
//     Navigator.pop(context);
//     setStatusBarColor();
//   }

//   void _onToggleMute() {
//     setState(() {
//       muted = !muted;
//     });

//     _engine.muteLocalAudioStream(muted);
//     FirebaseFirestore.instance
//         .collection(DbPaths.collectionusers)
//         .doc(widget.currentuseruid)
//         .collection(DbPaths.collectioncallhistory)
//         .doc(widget.call.timeepoch.toString())
//         .set({'ISMUTED': muted}, SetOptions(merge: true));
//   }

//   void _onSwitchCamera() {
//     _engine.switchCamera();
//   }

//   Future<bool> onWillPopNEw() {
//     return Future.value(false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     var screenHeight = MediaQuery.of(context).size.height;
//     var screenWidth = MediaQuery.of(context).size.width;
//     setStatusBarColor();
//     return WillPopScope(
//         onWillPop: onWillPopNEw,
//         child: PIPView(builder: (context, isFloating) {
//           return Scaffold(
//               backgroundColor: Colors.black,
//               body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>?>?>(
//                 stream:
//                     stream as Stream<DocumentSnapshot<Map<String, dynamic>?>?>?,
//                 builder: (BuildContext context, snapshot) {
//                   if (_localUserJoined == false) {
//                     return Center(
//                       child: Stack(
//                         children: <Widget>[
//                           _remoteUid == null
//                               ? _localVideo()
//                               : isuserenlarged
//                                   ? _localVideo()
//                                   : _remoteVideo(),
//                           _toolbar(context, false, 'calling'),
//                           _panel(
//                               context: context,
//                               status: 'calling',
//                               ispeermuted: false),
//                         ],
//                       ),
//                     );
//                   } else if (snapshot.hasData && snapshot.data != null) {
//                     if (snapshot.data!.data() == null) {
//                       return Center(
//                         child: Stack(
//                           children: <Widget>[
//                             _remoteUid == null
//                                 ? _localVideo()
//                                 : isuserenlarged == true
//                                     ? _localVideo()
//                                     : _remoteVideo(),
//                             _toolbar(context, false, 'calling'),
//                             _panel(
//                                 status: 'calling',
//                                 ispeermuted: false,
//                                 context: context),
//                           ],
//                         ),
//                       );
//                     } else {
//                       return Center(
//                         child: Stack(
//                           children: <Widget>[
//                             isfakeloader
//                                 ? Container()
//                                 : _remoteUid == null
//                                     ? _localVideo()
//                                     : isuserenlarged
//                                         ? _localVideo()
//                                         : _remoteVideo(),
//                             _toolbar(
//                                 context,
//                                 snapshot.data!.data()!["STATUS"] == 'pickedup'
//                                     ? true
//                                     : false,
//                                 snapshot.data!.data()!["STATUS"]),
//                             snapshot.data!.data()!["STATUS"] == 'pickedup' &&
//                                     _remoteUid != null &&
//                                     _localUserJoined == true
//                                 ? Positioned(
//                                     bottom:
//                                         screenWidth > screenHeight ? 40 : 120,
//                                     right: screenWidth > screenHeight ? 20 : 10,
//                                     child: isfakeloader
//                                         ? Container()
//                                         : SizedBox(
//                                             height: screenWidth > screenHeight
//                                                 ? screenWidth / 4.7
//                                                 : screenHeight / 4.7,
//                                             width: screenWidth > screenHeight
//                                                 ? (screenWidth / 4.7) / 1.7
//                                                 : (screenHeight / 4.7) / 1.7,
//                                             child: Stack(
//                                               children: [
//                                                 Center(
//                                                   child: InkWell(
//                                                     onTap: () {
//                                                       setState(() {
//                                                         isuserenlarged =
//                                                             !isuserenlarged;
//                                                         isfakeloader = true;
//                                                       });

//                                                       runFakeloader();
//                                                     },
//                                                     child: isuserenlarged
//                                                         ? _remoteVideo()
//                                                         : _localVideo(),
//                                                   ),
//                                                 ),
//                                                 Positioned(
//                                                     top: 5,
//                                                     right: 5,
//                                                     child: Icon(
//                                                       Icons.sync,
//                                                       color: Colors.white70,
//                                                       size: 20,
//                                                     ))
//                                               ],
//                                             ),
//                                           ))
//                                 : SizedBox(),
//                             _panel(
//                                 context: context,
//                                 status: snapshot.data!.data()!["STATUS"],
//                                 ispeermuted: snapshot.data!.data()!["ISMUTED"]),
//                           ],
//                         ),
//                       );
//                     }
//                   }

//                   // if (snapshot.hasData) {
//                   //   if (snapshot.data == null) {
//                   //     return Center(
//                   //       child: Stack(
//                   //         children: <Widget>[
//                   //           onetooneview(screenHeight, screenWidth, false,
//                   //               isuserenlarged),
//                   //           _toolbar(context, false, 'calling'),
//                   //           _panel(
//                   //               status: 'calling',
//                   //               ispeermuted: false,
//                   //               context: context),
//                   //         ],
//                   //       ),
//                   //     );
//                   //   } else if (snapshot.data != null) {
//                   //     if (snapshot.data!.data() == null) {
//                   //       return Center(
//                   //         child: Stack(
//                   //           children: <Widget>[
//                   //             onetooneview(screenHeight, screenWidth, false,
//                   //                 isuserenlarged),
//                   //             _toolbar(context, false, 'calling'),
//                   //             _panel(
//                   //                 status: 'calling',
//                   //                 ispeermuted: false,
//                   //                 context: context),
//                   //           ],
//                   //         ),
//                   //       );
//                   //     } else {
//                   //       return Center(
//                   //         child: Stack(
//                   //           children: <Widget>[
//                   //             Center(
//                   //               child: Container(
//                   //                 width: islandscapeMode == true
//                   //                     ? MediaQuery.of(context).size.width
//                   //                     : isWideScreen(
//                   //                             MediaQuery.of(context).size.width)
//                   //                         ? getContentScreenWidth(
//                   //                                 MediaQuery.of(context)
//                   //                                     .size
//                   //                                     .width) /
//                   //                             1.4
//                   //                         : MediaQuery.of(context).size.width,
//                   //                 child: onetooneview(
//                   //                     screenHeight,
//                   //                     screenWidth,
//                   //                     snapshot.data!.data()!["STATUS"] ==
//                   //                             'ended'
//                   //                         ? true
//                   //                         : false,
//                   //                     isuserenlarged),
//                   //               ),
//                   //             ),
//                   //             _toolbar(
//                   //                 context,
//                   //                 snapshot.data!.data()!["STATUS"] == 'pickedup'
//                   //                     ? true
//                   //                     : false,
//                   //                 snapshot.data!.data()!["STATUS"]),
//                   //             snapshot.data!.data()!["STATUS"] == 'pickedup' &&
//                   //                     _getRenderViews().length > 1
//                   //                 ? Positioned(
//                   //                     bottom:
//                   //                         screenWidth > screenHeight ? 40 : 120,
//                   //                     right:
//                   //                         screenWidth > screenHeight ? 20 : 10,
//                   //                     child: InkWell(
//                   //                       onTap: () {
//                   //                         isuserenlarged = !isuserenlarged;
//                   //                         setState(() {});
//                   //                       },
//                   //                       child: Stack(
//                   //                         children: [
//                   //                           Container(
//                   //                             height: screenWidth > screenHeight
//                   //                                 ? screenWidth / 4.7
//                   //                                 : screenHeight / 4.7,
//                   //                             width: screenWidth > screenHeight
//                   //                                 ? (screenWidth / 4.7) / 1.7
//                   //                                 : (screenHeight / 4.7) / 1.7,
//                   //                             child: _getRenderViews()[
//                   //                                 isuserenlarged == true
//                   //                                     ? 1
//                   //                                     : 0],
//                   //                           ),
//                   //                           Positioned(
//                   //                               top: 7,
//                   //                               right: 7,
//                   //                               child: Icon(
//                   //                                 Icons.sync,
//                   //                                 color: Colors.white70,
//                   //                                 size: 20,
//                   //                               ))
//                   //                         ],
//                   //                       ),
//                   //                     ),
//                   //                   )
//                   //                 : SizedBox(),
//                   //             _panel(
//                   //                 context: context,
//                   //                 status: snapshot.data!.data()!["STATUS"],
//                   //                 ispeermuted:
//                   //                     snapshot.data!.data()!["ISMUTED"]),
//                   //           ],
//                   //         ),
//                   //       );
//                   //     }
//                   //   }
//                   // } else if (!snapshot.hasData) {
//                   //   return Center(
//                   //     child: Stack(
//                   //       children: <Widget>[
//                   //         onetooneview(
//                   //             screenHeight, screenWidth, false, isuserenlarged),
//                   //         _toolbar(context, false, 'nonetwork'),
//                   //         _panel(
//                   //             context: context,
//                   //             status: 'nonetwork',
//                   //             ispeermuted: false),
//                   //       ],
//                   //     ),
//                   //   );
//                   // }
//                   return Center(
//                     child: Stack(
//                       children: <Widget>[
//                         _remoteUid == null
//                             ? _localVideo()
//                             : isuserenlarged
//                                 ? _localVideo()
//                                 : _remoteVideo(),
//                         _toolbar(context, false, 'calling'),
//                         _panel(
//                             context: context,
//                             status: 'calling',
//                             ispeermuted: false),
//                       ],
//                     ),
//                   );
//                 },
//               ));
//         }));
//   }

//   // Display remote user's video
//   Widget _remoteVideo() {
//     if (_remoteUid != null) {
//       return AgoraVideoView(
//         controller: VideoViewController.remote(
//           rtcEngine: _engine,
//           canvas: VideoCanvas(uid: _remoteUid),
//           connection: RtcConnection(channelId: widget.channelName),
//         ),
//       );
//     } else {
//       return SizedBox();
//     }
//   }

//   // Display local user's video
//   Widget _localVideo() {
//     if (_localUserJoined == true) {
//       return AgoraVideoView(
//         controller: VideoViewController(
//           rtcEngine: _engine,
//           canvas: const VideoCanvas(uid: 0),
//         ),
//       );
//     } else {
//       return SizedBox();
//     }
//   }
// }

// class Bcg extends StatefulWidget {
//   const Bcg({Key? key}) : super(key: key);

//   @override
//   _BcgState createState() => _BcgState();
// }

// class _BcgState extends State<Bcg> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.brown,
//       body: Center(
//         child: Text(''),
//       ),
//     );
//   }
// }
