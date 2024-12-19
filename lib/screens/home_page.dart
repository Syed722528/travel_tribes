import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_learn/screens/admin_page.dart';
import 'package:firebase_learn/screens/faqs_page.dart';
import 'package:firebase_learn/screens/friend_page.dart';
import 'package:firebase_learn/screens/notification_page.dart';
import 'package:firebase_learn/screens/places_page.dart';
import 'package:firebase_learn/screens/profile_page.dart';
import 'package:firebase_learn/services/auth/auth_gate.dart';
import 'package:firebase_learn/widgets/custom_drawer_list_tile.dart';
import 'package:firebase_learn/components/top_place_tile.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  Stream<int> getPendingRequestsCount() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friendRequests')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(auth),
      body:

          //-----------------------------------Home Tile of homePage----------------------------//

          selectedIndex == 0
              ? SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Top places',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 300,
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('top_places')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (snapshot.hasError) {
                                  return const Center(
                                      child: Text('Error loading places'));
                                }

                                // Parse Firestore data
                                final topPlacesDocs = snapshot.data?.docs ?? [];

                                if (topPlacesDocs.isEmpty) {
                                  return const Center(
                                      child: Text('No places available.'));
                                }

                                return SizedBox(
                                  height: 300,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: topPlacesDocs.length,
                                    itemBuilder: (context, index) {
                                      final place = topPlacesDocs[index];
                                      final title =
                                          place['title'] ?? 'No title';
                                      final imageUrl = place['image'] ?? '';

                                      return TopPlacesTile(
                                        imagePath: imageUrl,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PlacesPage()));
                                        },
                                        title: title,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              :

              //--------------------------------------Friends tab of HomePage ------------------------------//

              selectedIndex == 1
                  ? FriendPage()
                  : Container(
                      color: Colors.yellow,
                    ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.purple))),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_alt_outlined), label: 'Add Friends'),
            BottomNavigationBarItem(
                icon: Icon(Icons.location_on_outlined),
                label: 'Location Services'),
          ],
          currentIndex: selectedIndex,
          onTap: onItemTapped,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.merge_outlined),
      ),
    );
  }

  // Reusable AppBar Widget
  AppBar _buildAppBar() {
    return AppBar(
      title: GestureDetector(
          onLongPress: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AdminPage()));
          },
          child: const Text('Home Page')),
      actions: [
        StreamBuilder<int>(
          stream: getPendingRequestsCount(),
          builder: (context, snapshot) {
            final int requestCount = snapshot.data ?? 0;

            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationPage(),
                      ),
                    );
                  },
                ),
                if (requestCount > 0) // Only show badge if there are requests
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        requestCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.message),
          onPressed: () {},
        ),
      ],
    );
  }

  // Reusable Drawer Widget
  Drawer _buildDrawer(FirebaseAuth auth) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            child: Icon(
              Icons.filter_list,
              size: 50,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                CustomDrawerListTile(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                  title: 'Profile',
                  icon: const Icon(Icons.person),
                ),
                CustomDrawerListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FaqsPage()));
                  },
                  title: 'FAQs',
                  icon: const Icon(Icons.question_mark_rounded),
                ),
                CustomDrawerListTile(
                  onTap: () {},
                  title: 'Live Support',
                  icon: const Icon(Icons.support_agent_sharp),
                ),
              ],
            ),
          ),
          CustomDrawerListTile(
            onTap: () async {
              await auth.signOut();
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AuthGate()));
            },
            title: 'Log out',
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
    );
  }

  // Data for Top Places

  // Generate Top Places Tiles Dynamically
}