//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoochat_web/Configs/Dbkeys.dart';
import 'package:hoochat_web/Configs/Dbpaths.dart';
import 'package:hoochat_web/Configs/app_constants.dart';
import 'package:hoochat_web/Services/localization/language_constants.dart';
import 'package:hoochat_web/Screens/calling_screen/pickup_layout.dart';
import 'package:hoochat_web/Utils/determine_screen.dart';
import 'package:hoochat_web/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditGroupDetails extends StatefulWidget {
  final String? groupName;
  final String? groupDesc;
  final String? groupType;
  final String? groupID;
  final String currentUserNo;
  final bool isadmin;
  final SharedPreferences prefs;
  EditGroupDetails(
      {this.groupName,
      this.groupDesc,
      required this.isadmin,
      required this.prefs,
      this.groupID,
      this.groupType,
      required this.currentUserNo});
  @override
  State createState() => new EditGroupDetailsState();
}

class EditGroupDetailsState extends State<EditGroupDetails> {
  TextEditingController? controllerName = new TextEditingController();
  TextEditingController? controllerDesc = new TextEditingController();

  bool isLoading = false;

  final FocusNode focusNodeName = new FocusNode();
  final FocusNode focusNodeDesc = new FocusNode();

  String? groupTitle;
  String? groupDesc;
  String? groupType;

  @override
  void initState() {
    super.initState();
    Fiberchat.internetLookUp();
    groupDesc = widget.groupDesc;
    groupTitle = widget.groupName;
    groupType = widget.groupType;
    controllerName!.text = groupTitle!;
    controllerDesc!.text = groupDesc!;
  }

  void handleUpdateData() {
    focusNodeName.unfocus();
    focusNodeDesc.unfocus();

    setState(() {
      isLoading = true;
    });
    groupTitle =
        controllerName!.text.isEmpty ? groupTitle : controllerName!.text;
    groupDesc = controllerDesc!.text.isEmpty ? groupDesc : controllerDesc!.text;
    setState(() {});
    FirebaseFirestore.instance
        .collection(DbPaths.collectiongroups)
        .doc(widget.groupID)
        .set({
      Dbkeys.groupNAME: groupTitle,
      Dbkeys.groupDESCRIPTION: groupDesc,
      Dbkeys.groupTYPE: groupType,
    }, SetOptions(merge: true)).then((value) async {
      DateTime time = DateTime.now();
      await FirebaseFirestore.instance
          .collection(DbPaths.collectiongroups)
          .doc(widget.groupID)
          .collection(DbPaths.collectiongroupChats)
          .doc(time.millisecondsSinceEpoch.toString() +
              '--' +
              widget.currentUserNo)
          .set({
        Dbkeys.groupmsgCONTENT: widget.isadmin
            ? getTranslated(context, 'grpdetailsupdatebyadmin')
            : '${widget.currentUserNo} ${getTranslated(context, 'hasupdatedgrpdetails')}',
        Dbkeys.groupmsgLISToptional: [],
        Dbkeys.groupmsgTIME: time.millisecondsSinceEpoch,
        Dbkeys.groupmsgSENDBY: widget.currentUserNo,
        Dbkeys.groupmsgISDELETED: false,
        Dbkeys.groupmsgTYPE: Dbkeys.groupmsgTYPEnotificationUpdatedGroupDetails,
      });
      Navigator.of(context).pop();
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fiberchat.toast(err.toString());
    });
  }

  void _handleTypeChange(String value) {
    setState(() {
      groupType = value;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Fiberchat.getNTPWrappedWidget(Scaffold(
            backgroundColor: fiberchatScaffold,
            appBar: new AppBar(
              centerTitle: true,
              elevation: 0.4,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: fiberchatBlack,
                ),
              ),
              titleSpacing: 0,
              backgroundColor: fiberchatWhite,
              title: new Text(
                getTranslated(this.context, 'editgroup'),
                style: TextStyle(
                  fontSize: 20.0,
                  color: fiberchatBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: handleUpdateData,
                  child: Text(
                    getTranslated(this.context, 'save'),
                    style: TextStyle(
                      fontSize: 16,
                      color: fiberchatPRIMARYcolor,
                    ),
                  ),
                )
              ],
            ),
            body: Center(
              child: Container(
                margin: EdgeInsets.only(top: 20, bottom: 20),
                color: Colors.white,
                alignment: Alignment.center,
                width: getContentScreenWidth(MediaQuery.of(context).size.width),
                child: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 25,
                          ),
                          ListTile(
                              title: TextFormField(
                            autovalidateMode: AutovalidateMode.always,
                            controller: controllerName,
                            validator: (v) {
                              return v!.isEmpty
                                  ? getTranslated(this.context, 'validdetails')
                                  : null;
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(6),
                              labelStyle: TextStyle(height: 0.8),
                              labelText:
                                  getTranslated(this.context, 'groupname'),
                            ),
                          )),
                          SizedBox(
                            height: 30,
                          ),
                          ListTile(
                              title: TextFormField(
                            minLines: 1,
                            maxLines: 10,
                            controller: controllerDesc,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(6),
                              labelStyle: TextStyle(height: 0.8),
                              labelText:
                                  getTranslated(this.context, 'groupdesc'),
                            ),
                          )),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(5, 20, 12, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 20, 12, 10),
                                    child: Text(
                                      getTranslated(this.context, 'grouptype'),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value:
                                            'Both User & Admin Messages Allowed',
                                        groupValue: groupType,
                                        onChanged: (v) {
                                          _handleTypeChange(v!);
                                        },
                                      ),
                                      Container(
                                        width: getContentScreenWidth(
                                                MediaQuery.of(context)
                                                    .size
                                                    .width) /
                                            1.5,
                                        child: Text(
                                          getTranslated(
                                              this.context, 'bothuseradmin'),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Only Admin Messages Allowed',
                                        groupValue: groupType,
                                        onChanged: (v) {
                                          _handleTypeChange(v!);
                                        },
                                      ),
                                      Container(
                                        width: getContentScreenWidth(
                                                MediaQuery.of(context)
                                                    .size
                                                    .width) /
                                            1.5,
                                        child: Text(
                                          getTranslated(
                                              this.context, 'onlyadmin'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                        ],
                      ),
                      padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    ),
                    // Loading
                    Positioned(
                      child: isLoading
                          ? Container(
                              child: Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        fiberchatSECONDARYolor)),
                              ),
                              color: fiberchatWhite.withOpacity(0.8))
                          : Container(),
                    ),
                  ],
                ),
              ),
            ))));
  }
}
