import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();

    // Listen for incoming messages while app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${message.notification?.title}: ${message.notification?.body}')),
      );
    });
  }

  // Accept Friend Request
  Future<void> acceptFriendRequest(String senderId) async {
    if (currentUserId.isEmpty) return;

    try {
      // Fetch current user details
      final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
      final currentUserName = currentUserDoc['username'];

      // Fetch sender details dynamically to ensure updated data
      final senderDoc = await FirebaseFirestore.instance.collection('users').doc(senderId).get();
      final senderName = senderDoc['username'];

      // Update friends collection for both users
      final currentUserFriendsRef = FirebaseFirestore.instance.collection('users').doc(currentUserId).collection('friends');
      final senderFriendsRef = FirebaseFirestore.instance.collection('users').doc(senderId).collection('friends');

      await currentUserFriendsRef.doc(senderId).set({
        'friendId': senderId,
        'addedAt': Timestamp.now(),
      });

      await senderFriendsRef.doc(currentUserId).set({
        'friendId': currentUserId,
        'addedAt': Timestamp.now(),
      });

      // Remove the friend request
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('friendRequests')
          .doc(senderId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$senderName is now your friend!')),
      );
    } catch (e) {
      print('Error accepting friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to accept friend request.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('friendRequests')
            .snapshots(),
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
                  onPressed: () => acceptFriendRequest(senderId),
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
