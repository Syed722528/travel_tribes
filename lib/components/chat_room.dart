import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatRoomPage extends StatefulWidget {
  final String chatRoomId;
  final String friendName;
  final String friendId;

  const ChatRoomPage({
    super.key,
    required this.chatRoomId,
    required this.friendName,
    required this.friendId,
  });

  @override
  ChatRoomPageState createState() => ChatRoomPageState();
}

class ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController messageController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool isUserFriend = true;
  Set<String> friendRequests = <String>{};
  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    markMessagesAsRead();
    _checkFriendship();
    _getUserPhoneNumber();
  }
  Future<void> _getUserPhoneNumber() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.friendId)
            .get();

        if (userDoc.exists) {
          setState(() {
            phoneNumber = userDoc.data()?['phone'] as String?;
          });
        }
      }
    } catch (e) {
      print('Error fetching phone number: $e');
      setState(() {
        phoneNumber = 'Error fetching phone number';
      });
    }
  }

  Future<void> _checkFriendship() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .doc(widget.friendId)
          .get();

      setState(() {
        isUserFriend = doc.exists;
      });
    } catch (e) {
      print('Error checking friendship: $e');
      setState(() {
        isUserFriend = false;
      });
    }
  }

  Future<void> markMessagesAsRead() async {
    final unreadMessages = await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(widget.chatRoomId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unreadMessages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Future<void> sendMessage() async {
    final message = messageController.text.trim();
    if (message.isEmpty) return;

    final timestamp = Timestamp.now();

    await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(widget.chatRoomId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'message': message,
      'timestamp': timestamp,
      'isRead': false,
    });

    messageController.clear();
  }

  //-------------------------Send Friend Request--------------------------//

  Future<void> sendFriendRequest(
      String recipientId, String recipientName) async {
    if (currentUserId.isEmpty) return;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      final currentUserName = userDoc['username'];

      final friendRequestsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(recipientId)
          .collection('friendRequests');

      await friendRequestsRef.doc(currentUserId).set({
        'fromUserId': currentUserId,
        'name': currentUserName ?? 'Unknown User',
        'status': 'pending',
        'timestamp': Timestamp.now(),
      });
      // After sending the request, update the state
      setState(() {
        friendRequests.add(recipientId);
      });
    } catch (e) {
      print('Error sending friend request $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName),
        actions: [
          !isUserFriend
              ? IconButton(onPressed: ()async{  await sendFriendRequest(widget.friendId, widget.friendName);
                    setState(() {
                      isUserFriend = ! isUserFriend;
                    });}, icon: Icon(Icons.person_add))
              :CallButton(context)
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('chatRooms')
                  .doc(widget.chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('Error loading messages.'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data();
                    final isCurrentUser = message['senderId'] == currentUserId;

                    return buildMessageBubble(message, isCurrentUser);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessageBubble(Map<String, dynamic> message, bool isCurrentUser) {
    final timestamp = message['timestamp'] as Timestamp;
    final time = timestamp.toDate().toLocal();
    final formattedTime =
        "${time.hour}:${time.minute.toString().padLeft(2, '0')}";

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isCurrentUser ? const Radius.circular(12) : Radius.zero,
            bottomRight:
                isCurrentUser ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['message'],
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 10,
                    color: isCurrentUser ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (!isCurrentUser && message['isRead'] == true)
                  const Text(
                    '  Read',
                    style: TextStyle(fontSize: 10, color: Colors.green),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget CallButton (BuildContext context) {
    return IconButton(
      icon: Icon(Icons.phone, color: Colors.green),
      onPressed: () async {
        if (phoneNumber != null && phoneNumber!.isNotEmpty) { 
          final phoneUri = Uri(scheme: 'tel', path: phoneNumber);
          if (await canLaunchUrl(phoneUri)) {
            await launchUrl(phoneUri);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Could not launch dialer")),
            );
          }
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Phone Number Not Found'),
                content: Text("User hasn't added any phone number yet"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }
}



