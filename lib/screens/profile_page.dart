import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_learn/services/auth/auth_gate.dart';
import 'package:firebase_learn/widgets/custom_elevated_button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    
    if (uid == null) return;

    try {
      final file = File(pickedFile.path);
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_picture/$uid.jpg');

      await storageRef.putFile(file);

      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'profilepic': imageUrl});

      await getUserData();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile Pic updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {

    if (uid != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists) {
        setState(() {
          userData = snapshot.data();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateUserData(
      String field, String value) async {
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({field: value});
      await getUserData();
    }
    return null;
  }

  void showEditDialog(BuildContext context, String field, String initialValue) {
    final TextEditingController controller =
        TextEditingController(text: initialValue);

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit $field'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter new $field',
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () async {
                    if (controller.text.isNotEmpty) {
                      await updateUserData(field, controller.text);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Save'))
            ],
          );
        });
  }

void showGenderSelectionDialog(BuildContext context, String currentGender) {
  String selectedGender = currentGender.isNotEmpty ? currentGender : 'Prefer not to say';

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Select Gender'),
        content: DropdownButtonFormField<String>(
          value: selectedGender,
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
            DropdownMenuItem(value: 'Prefer not to say', child: Text('Prefer not to say')),
          ],
          onChanged: (value) {
            selectedGender = value!;
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
        
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await updateUserData('gender', selectedGender);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : userData == null
                ? const Center(
                    child: Text('Failed to load user data'),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 40, bottom: 15),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                ClipOval(
                                  child: userData?['profilepic'] != null
                                      ? Image.network(
                                          userData!['profilepic'],
                                          fit: BoxFit.cover,
                                          height: 100,
                                          width: 100,
                                        )
                                      : const Image(
                                          fit: BoxFit.cover,
                                          height: 100,
                                          width: 100,
                                          image:
                                              AssetImage('images/profile.jpg'),
                                        ),
                                ),
                                Positioned(
                                  right: -12,
                                  bottom: 0,
                                  child: IconButton(
                                    icon: Icon(Icons.photo_camera,color: Colors.purple,size: 30,),
                                    onPressed: uploadImage,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              userData?['username'] ?? 'No username',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          infoLabel(label: 'Bio'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              info(info: userData?['bio'] ?? 'Add bio'),
                              IconButton(
                                onPressed: () {
                                  showEditDialog(
                                      context, 'bio', userData?['bio'] ?? '');
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ],
                          ),
                          Divider(),
                          infoLabel(label: 'Gender'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              info(info: userData?['gender'] ?? 'Add Gender'),
                              IconButton(
                                onPressed: () {
                                  showGenderSelectionDialog(context, userData?['gender'] ?? '');
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ],
                          ),
                          Divider(),
                          infoLabel(label: 'Email'),
                          info(info: userData?['email']),
                          Divider(),
                          infoLabel(label: 'Username'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              info(info: userData?['username']),
                              IconButton(
                                onPressed: () {
                                  showEditDialog(context, 'username',
                                      userData?['username'] ?? '');
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ],
                          ),
                          Divider(),
                          infoLabel(label: 'Phone Number'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              info(
                                  info:
                                      userData?['phone'] ?? 'Add phone number'),
                              IconButton(
                                onPressed: () {
                                  showEditDialog(context, 'phone',
                                      userData?['phone'] ?? '');
                                },
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                          Divider(),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 30),
                        alignment: Alignment.center,
                        child: CustomElevatedButton(
                          label: const Text('Log out'),
                          buttonIcon: const Icon(Icons.logout),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthGate(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    ));
  }

  Widget info({required String info}) => Container(
        margin: const EdgeInsets.all(15),
        child: Text(
          info,
          style: const TextStyle(fontSize: 20),
        ),
      );

  Widget infoLabel({required String label}) => Container(
        margin: const EdgeInsets.all(18),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}
