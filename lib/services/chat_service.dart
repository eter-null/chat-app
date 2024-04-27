import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message_model.dart';

class ChatService{

  final auth = FirebaseAuth.instance;
  final firebase = FirebaseFirestore.instance;

  Future<void> sendChatMessage({required String message}) async {
    var currentUser = auth.currentUser;

    if (currentUser != null) {
      // Get user document from Firestore
      var userDoc = await firebase.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists) {
        var userName = userDoc.get('name');

        var messageModel = MessageModel(
          name: auth.currentUser!.email.toString(),
          message: message,
          uuid: currentUser.uid,
          time: Timestamp.now(),
          profileAvatar: userName,
        );

        // Add message to the "chat" collection
        await firebase.collection('chat').add(messageModel.toMap());
      }
    }
  }

}
