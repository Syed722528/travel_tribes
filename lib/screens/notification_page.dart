// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
// ------------------ Getting Notification count -------------------//
  Stream<int> getPendingRequestsCount() {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .collection('friendRequests')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}

  //-------------------------Fetch Friend Requests-----------------------------//
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchFriendRequests() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friendRequests')
        .snapshots();
  }

  //-------------------------Accept Friend Request-----------------------------//
  Future<void> acceptFriendRequest(String senderId, String senderName) async {
    if (currentUserId.isEmpty) return;
try{
  final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();

      final currentUserName = userDoc['username'];
    final currentUserFriendsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friends');

    final senderFriendsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .collection('friends');

    // Add each other to friends collection
    await currentUserFriendsRef.doc(senderId).set({
      'friendId': senderId,
      'name': senderName,
      'addedAt': Timestamp.now(),
    });

    await senderFriendsRef.doc(currentUserId).set({
      'friendId': currentUserId,
      'name': currentUserName ?? 'Unknown User',
      'addedAt': Timestamp.now(),
    });

    // Remove the friend request
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friendRequests')
        .doc(senderId)
        .delete();
  }catch(e){
    print('Error accepting friend request $e');
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: fetchFriendRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching requests.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No friend requests.'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index].data();
              final senderId = requests[index].id;
              final senderName = request['name'] ?? 'Unknown User';

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(senderName),
                subtitle: const Text('Sent you a friend request'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await acceptFriendRequest(senderId, senderName);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$senderName is now your friend!')),
                    );
                  },
                  child: const Text('Accept'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
