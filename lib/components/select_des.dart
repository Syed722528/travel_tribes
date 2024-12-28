import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_learn/components/chat_room.dart';
import 'package:firebase_learn/screens/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DestinationFormPage extends StatefulWidget {
  const DestinationFormPage({super.key});

  @override
  DestinationFormPageState createState() => DestinationFormPageState();
}

class DestinationFormPageState extends State<DestinationFormPage> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final _formKey = GlobalKey<FormState>();
  String? _selectedFrom;
  final List<String?> _selectedDestinations = [null];
  DateTime? _selectedDate;
  final Map<String, List<Map<String, String>>> _placesMap = {};
  final TextEditingController _messageController = TextEditingController();
  Stream<List<Map<String, dynamic>>>? _matchingUsersStream;

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String getChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '${user1}_$user2'
        : '${user2}_$user1';
  }

  Future<void> _fetchPlaces() async {
    final Map<String, List<Map<String, String>>> tempPlacesMap = {};
    final querySnapshot =
        await FirebaseFirestore.instance.collection('places').get();

    for (var doc in querySnapshot.docs) {
      final region = doc.id;
      final famousPlacesSnapshot = await FirebaseFirestore.instance
          .collection('places')
          .doc(region)
          .collection('famousPlaces')
          .get();

      final places = famousPlacesSnapshot.docs.map((placeDoc) {
        return {
          'id': placeDoc.id,
          'title': placeDoc['title'] ?? placeDoc.id,
        };
      }).toList();

      tempPlacesMap[region] = places.map((place) {
        return place.map((key, value) => MapEntry(key, value.toString()));
      }).toList();
    }

    setState(() {
      _placesMap.clear();
      _placesMap.addAll(tempPlacesMap);
    });
  }

  void _addDestinationField() {
    if (_selectedDestinations.length < 3) {
      setState(() {
        _selectedDestinations.add(null);
      });
    }
  }

  void _removeDestinationField() {
    if (_selectedDestinations.length > 1) {
      setState(() {
        _selectedDestinations.removeLast();
      });
    }
  }

  //----------------- Fetch Username of the Current User ----------------------------//

  Future<String?> fetchUsername() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          return userDoc.data()?['username'] as String?;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching username: $e');
      }
    }
    return null;
  }
  //------------------ Saving Users' Choice of Place to Document --------------------//

  Future<void> _createSearch({
    required String from,
    required String to,
    String? message,
    required String date,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userName = await fetchUsername();

    // Save current user's search data
    await FirebaseFirestore.instance
        .collection('searchBuddy')
        .doc(currentUser!.uid)
        .set({
      'from': from.toLowerCase(),
      'to': to.toLowerCase(),
      'message': message,
      'date': date,
      'username': userName,
      'uid': currentUser.uid,
    });

    setState(() {
      _matchingUsersStream = _getMatchingUsersStream(from, to);
    });
  }

  //------------------ Stream to get matching users ------------------//

  Stream<List<Map<String, dynamic>>> _getMatchingUsersStream(
      String from, String to) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('searchBuddy')
        .where('from', isEqualTo: from.toLowerCase())
        .where('to', isEqualTo: to.toLowerCase())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) => doc.id != currentUser!.uid)
            .map((doc) => doc.data())
            .toList());
  }

  void _cancelStream()async {
    _matchingUsersStream?.listen(null).cancel();
    _matchingUsersStream = null;
    await FirebaseFirestore.instance.collection('searchBuddy').doc(FirebaseAuth.instance.currentUser!.uid).delete();
  }

  //------------------ Displaying Matching Users in a Dialog -------------------//

  Future _showMatchingUsersDialog(
      BuildContext context, List<Map<String, dynamic>> matchingUsers) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Matching Travel buddies'),
          content: SingleChildScrollView(
            child: SizedBox(
              height: 300,
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: matchingUsers.length,
                itemBuilder: (context, index) {
                  final user = matchingUsers[index];
                  return ListTile(
                    title: Text('Name: ${user['username']}'),
                    subtitle: Text('${user['message']}\nDate: ${user['date']}'),
                    trailing: IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatRoomPage(
                                        chatRoomId: getChatRoomId(
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                            user['uid']),
                                        friendId: user['uid'],
                                        friendName: user['username'],
                                      )));
                        },
                        icon: Icon(Icons.chat)),
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Continue Searching'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelStream();
              },
              child: const Text('Cancel Searching'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Travel Planner'), 
         leading:  IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            icon: const Icon(Icons.arrow_back),
          )
      ),
        body: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.screen_search_desktop_sharp, size: 100),
                    const SizedBox(height: 20),
                    _buildDropdown(
                      label: 'From',
                      value: _selectedFrom,
                      onChanged: (value) =>
                          setState(() => _selectedFrom = value),
                    ),
                    const SizedBox(height: 20),
                    ..._selectedDestinations.asMap().entries.map((entry) {
                      final index = entry.key;
                      final selectedDestination = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: _buildDropdown(
                          label: 'Destination ${index + 1}',
                          value: selectedDestination,
                          onChanged: (value) => setState(
                              () => _selectedDestinations[index] = value),
                        ),
                      );
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _addDestinationField,
                          icon: const Icon(Icons.add_circle),
                        ),
                        IconButton(
                          onPressed: _removeDestinationField,
                          icon: const Icon(Icons.remove_circle),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: _selectedDate == null
                            ? 'Select a date'
                            : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                        border: const OutlineInputBorder(),
                      ),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() => _selectedDate = pickedDate);
                        }
                      },
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Add a message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _createSearch(
                            from: _selectedFrom!,
                            to: _selectedDestinations.toString(),
                            date: _selectedDate!
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                          );
                        }
                      },
                      child: const Text('Find Travel Buddy'),
                    ),
                    const SizedBox(height: 20),
                    _matchingUsersStream != null
                        ? StreamBuilder<List<Map<String, dynamic>>>(
                            stream: _matchingUsersStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _showMatchingUsersDialog(
                                      context, snapshot.data!);
                                });
                                return Container(); // Return an empty container to avoid UI issues
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else {
                                return const Text(
                                    'Nothing found yet, Just hold for a few moments');
                              }
                            },
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: _placesMap.entries.expand((entry) {
        final region = entry.key;
        final places = entry.value;
        return [
          DropdownMenuItem(
            value: '',
            enabled: false,
            child: Text(region,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...places.map((place) {
            return DropdownMenuItem(
              value: place['title']!,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(place['title']!),
              ),
            );
          }),
        ];
      }).toList(),
      onChanged: onChanged,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please select a location' : null,
    );
  }
}
