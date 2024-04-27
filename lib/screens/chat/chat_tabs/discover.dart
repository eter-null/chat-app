import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:intl/intl.dart'; // Import DateFormat to format timestamp

import '../../../const_config/text_config.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Discover',
          style: TextDesign().headerText,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userName = userData['name'];
              final lastActive = userData['last_active'] as Timestamp;

              // time difference from last active time to now
              final lastActiveTime = lastActive.toDate();
              final now = DateTime.now();
              final difference = now.difference(lastActiveTime);

              // if user is currently active
              final bool isActive = difference.inMinutes < 4;

              return ListTile(
                leading: CircleAvatar(
                  child: RandomAvatar(
                    userName,
                    trBackground: false,
                    height: 100,
                    width: 100,
                  ),
                ),
                title: Row(
                  children: [
                    Text(userName),
                    SizedBox(width: 10),
                    if (isActive)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                subtitle: Text(_formatLastActive(lastActiveTime)),
                onTap: () {

                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatLastActive(DateTime lastActiveTime) {
    final now = DateTime.now();
    final difference = now.difference(lastActiveTime);

    if (difference.inMinutes < 4) {
      return 'Active now';
    } else if (difference.inHours < 1) {
      return 'Active ${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return 'Active ${difference.inHours} hours ago';
    } else {
      return 'Active on ${DateFormat('dd MMM yyyy').format(lastActiveTime)}';
    }
  }
}
