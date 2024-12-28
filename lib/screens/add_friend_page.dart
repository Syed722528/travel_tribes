import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_learn/components/friend_list_tile.dart';
import 'package:flutter/material.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  late String currentUserId;
  Set<String> friendRequests = <String>{}; // Track sent requests
bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    _fetchSentRequestsAndFriends();
  }

  
  // Fetch the list of sent requests from Firestore to persist the state
  Future<void> _fetchSentRequestsAndFriends() async {
  if (currentUserId.isEmpty) return;
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    Set<String> excludedUsers = {}; // Track users to exclude

    for (var doc in querySnapshot.docs) {
      // Check friendRequests subcollection for pending requests
      final friendRequestsRef = doc.reference.collection('friendRequests');
      final requestSnapshot =
          await friendRequestsRef.doc(currentUserId).get();
      if (requestSnapshot.exists) {
        excludedUsers.add(doc.id); // Add to excluded if request sent
      }

      // Check friends subcollection for already friends
      final friendsRef = doc.reference.collection('friends');
      final friendsSnapshot =
          await friendsRef.doc(currentUserId).get();
      if (friendsSnapshot.exists) {
        excludedUsers.add(doc.id); // Add to excluded if already friends
      }
    }

    setState(() {
      friendRequests = excludedUsers; // Combine sent requests and friends
      isLoading = false;
    });
  } catch (e) {
    print('Error fetching sent requests and friends: $e');
    setState(() {
      isLoading = false;
    });
  }
}


  //-------------------------Send Friend Request--------------------------//

  Future<void> sendFriendRequest(String recipientId, String recipientName) async {
    if (currentUserId.isEmpty) return;
    try{

      
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();

      final currentUserName = userDoc['username'];
    
    final friendRequestsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(recipientId)
        .collection('friendRequests');

    await friendRequestsRef.doc(currentUserId).set({
      'fromUserId': currentUserId,
      'name':currentUserName ?? 'Unknown User',
      'status': 'pending',
      'timestamp': Timestamp.now(),
    }
    );
  // After sending the request, update the state
      setState(() {
        friendRequests.add(recipientId);
      });
  
    }catch(e){
      print('Error sending friend request $e');
    }
  }

  //-------------------------Fetch Users-----------------------------//

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: currentUserId)
        .snapshots();
  }

  //-------------------------Accept Friend Request on Notification Page-----------------------------//



  //-------------------------UI-----------------------------//

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: isLoading?const Center(child: CircularProgressIndicator(),)
       :Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: fetchUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching users.'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No users to display.'));
            }

            final users = snapshot.data!.docs.where((doc) {
              // Exclude users who already sent a friend request
              return !friendRequests.contains(doc.id);
            }).toList();

          if (users.isEmpty) {
            return const Center(child: Text('No new users found'),);
          }
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index].data();
                final userId = users[index].id;
                final userName = user['username'] ?? 'Unknown User';

                return FriendListTile(
                  source: user['profilepic'] ?? 'images/profile.jpg',
                  bio: user['bio'] ?? 'No bio',
                  name: userName,
                  onPressed: () async {
                    await sendFriendRequest(userId, userName);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Friend request sent to $userName')),
                    );
                  },
                  
                );
              },
            );
          },
        ),
      ),
    );
  }
}
