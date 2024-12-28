import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_learn/components/chat_room.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

   ChatPage({super.key});

  Stream<List<Map<String, dynamic>>> fetchFriends() async* {
    final friendsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .snapshots();

    await for (final snapshot in friendsStream) {
      final friendsData = await Future.wait(snapshot.docs.map((doc) async {
        final friendId = doc.id;
        final friendSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(friendId).get();

        return {
          'uid': friendId,
          'name': friendSnapshot.data()?['username'] ?? 'Unknown User',
          'profilepic': friendSnapshot.data()?['profilepic'] ?? 'images/profile.jpg',
        };
      }).toList());

      yield friendsData;
    }
  }

  String getChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '${user1}_$user2' : '${user2}_$user1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fetchFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No friends available.'));
          }

          final friends = snapshot.data!;

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              final friendId = friend['uid'];
              final friendName = friend['name'];
              final profilePic = friend['profilepic'];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(profilePic),
                  child: profilePic == 'images/profile.jpg'
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(friendName),
                onTap: () {
                  final chatRoomId = getChatRoomId(currentUserId, friendId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoomPage(
                        chatRoomId: chatRoomId,
                        friendName: friendName,
                        friendId: friendId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
