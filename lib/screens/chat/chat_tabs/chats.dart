import 'dart:typed_data';

import 'package:chat_application_iub_cse464/const_config/text_config.dart';
import 'package:chat_application_iub_cse464/widgets/custom_buttons/Rouded_Action_Button.dart';
import 'package:chat_application_iub_cse464/widgets/input_widgets/simple_input_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_avatar/random_avatar.dart'; // Import the random_avatar package

import '../../../const_config/color_config.dart';
import '../../../services/chat_service.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final firebase = FirebaseFirestore.instance;
  final messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.scaffoldColor,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: firebase.collection('chat').orderBy('time').snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData && snapshot.connectionState == ConnectionState.active) {
                  var data = snapshot.data.docs;
                  return data.length != 0
                      ? ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      Timestamp timestamp = snapshot.data.docs[index]['time'];
                      DateTime dateTime = timestamp.toDate();
                      String formattedTime = DateFormat.jm().format(dateTime);
                      String formattedDate = DateFormat.yMMMMd().format(dateTime);

                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(snapshot.data.docs[index]['profileAvatar'],
                            style: TextDesign().bodyTextSmall,),
                            Row(
                              children: [
                                CircleAvatar(
                                  child: RandomAvatar(
                                    snapshot.data.docs[index]['profileAvatar'],
                                    trBackground: false,
                                    height: 100,
                                    width: 100,
                                  ),
                                ),
                                Card(
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(snapshot.data.docs[index]['message']),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 56.0, top: 4.0),
                              child: Text(
                                '$formattedTime, $formattedDate',
                                style: TextDesign().bodyTextExtraSmall,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )

                      : const Center(child: Text("No Chats to show"));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          SimpleInputField(
            controller: messageController,
            hintText: "Aa..",
            needValidation: true,
            errorMessage: "Message box can't be empty",
            fieldTitle: "",
            needTitle: false,
          ),
          const SizedBox(
            height: 10,
          ),
          RoundedActionButton(
            onClick: () {
              ChatService().sendChatMessage(message: messageController.text);
            },
            label: "Send Message",
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
