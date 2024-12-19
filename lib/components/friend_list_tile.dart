import 'package:flutter/material.dart';

class FriendListTile extends StatelessWidget {
  const FriendListTile({
    required this.source,
    required this.bio,
    required this.name,
    required this.onPressed,
    super.key,
  });

  final String source;
  final String bio;
  final String name;

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        tileColor: Colors.blueGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.black),
        ),
        leading: ClipOval(
          child: Image.asset(
            source,
            height: 60,
            width: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          bio,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: ElevatedButton.icon(
          onPressed: onPressed,
          label: Text('Send Request'),
          icon: const Icon(Icons.add),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
